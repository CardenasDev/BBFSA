<?php

namespace App\Services;

use App\Exceptions\ApiException;
use App\Repositories\DotationRepository;
use Illuminate\Support\Facades\DB;

class DotationService
{
    public function __construct(
        private readonly DotationRepository $dotations,
        private readonly AuditService $audit,
    ) {}

    public function types(bool $onlyActive = true): array
    {
        return array_map(fn (array $row): array => $this->mapType($row), $this->dotations->types($onlyActive));
    }

    public function sizes(?int $dotationTypeId, bool $onlyActive = true): array
    {
        return array_map(fn (array $row): array => $this->mapSize($row), $this->dotations->sizes($dotationTypeId, $onlyActive));
    }

    public function combinations(): array
    {
        return array_map(fn (array $row): array => $this->mapCombination($row), $this->dotations->combinations());
    }

    public function combinationDetails(int $combinationId): array
    {
        return array_map(
            fn (array $row): array => $this->mapCombinationDetail($row),
            $this->dotations->combinationDetails($combinationId),
        );
    }

    public function mySizes(int $userId): array
    {
        return array_map(fn (array $row): array => $this->mapMySize($row), $this->dotations->mySizes($userId));
    }

    public function myDeliveries(int $userId): array
    {
        return array_map(fn (array $row): array => $this->mapDelivery($row), $this->dotations->myDeliveries($userId));
    }

    public function saveMySize(int $userId, array $data, array $context): array
    {
        $saved = $this->dotations->saveMySize(
            $userId,
            (int) $data['id_tipo_dotacion'],
            $this->nullableInt($data, 'id_talla_dotacion'),
            $data['observaciones'] ?? null,
        );

        if (! $saved) {
            throw new ApiException('No fue posible guardar la talla de dotación.', 422);
        }

        $mapped = $this->mapSavedMySize($saved);
        $this->audit->record($userId, 'DOTACIONES', 'DOTACIONES_MI_TALLA_GUARDAR', 'DOTACION_TALLA', $mapped['id_empleado_dotacion_talla'], null, $mapped, $context);

        return $mapped;
    }

    public function employees(?string $search, ?int $areaId, ?int $positionId): array
    {
        return array_map(
            fn (array $row): array => $this->mapEmployeeSummary($row),
            $this->dotations->employees($this->blankToNull($search), $areaId, $positionId),
        );
    }

    public function employeeSizes(int $employeeId): array
    {
        return array_map(fn (array $row): array => $this->mapEmployeeSize($row), $this->dotations->employeeSizes($employeeId));
    }

    public function employeeHistory(int $employeeId): array
    {
        return array_map(fn (array $row): array => $this->mapEmployeeHistory($row), $this->dotations->employeeHistory($employeeId));
    }

    public function createDelivery(array $data, int $registeredBy, array $context): array
    {
        $deliveryType = strtoupper(trim((string) $data['tipo_entrega']));
        $combinationId = $this->nullableInt($data, 'id_dotacion_combinacion');
        $details = $this->validateDelivery(
            (int) $data['id_empleado'],
            $deliveryType,
            $combinationId,
            $data['detalles'],
        );

        $deliveryId = DB::transaction(function () use ($data, $registeredBy, $deliveryType, $combinationId, $details): int {
            $deliveryId = $this->dotations->createDelivery(
                (int) $data['id_empleado'],
                (string) $data['fecha_entrega'],
                $deliveryType,
                $combinationId,
                $registeredBy,
                $data['observaciones'] ?? null,
            );

            if ($deliveryId < 1) {
                throw new ApiException('No fue posible registrar la entrega de dotación.', 500);
            }

            foreach ($details as $detail) {
                $this->dotations->addDeliveryDetail(
                    $deliveryId,
                    (int) $detail['id_tipo_dotacion'],
                    $this->nullableInt($detail, 'id_talla_dotacion'),
                    (int) $detail['cantidad'],
                    $detail['observaciones'] ?? null,
                );
            }

            return $deliveryId;
        });

        $result = ['id_dotacion_entrega' => $deliveryId];
        $this->audit->record($registeredBy, 'DOTACIONES', 'DOTACIONES_ENTREGA_CREAR', 'DOTACION_ENTREGA', $deliveryId, null, ['request' => $data, 'result' => $result], $context);

        return $result;
    }

    private function validateDelivery(int $employeeId, string $deliveryType, ?int $combinationId, array $details): array
    {
        if (! in_array($deliveryType, ['ORDINARIA', 'EXTRAORDINARIA'], true)) {
            throw new ApiException('El tipo de entrega no es válido.', 422);
        }

        if ($deliveryType === 'ORDINARIA' && $combinationId === null) {
            throw new ApiException('La entrega ordinaria requiere una combinación.', 422);
        }

        if ($deliveryType === 'EXTRAORDINARIA' && $combinationId !== null) {
            throw new ApiException('La entrega extraordinaria no debe tener una combinación asociada.', 422);
        }

        $employeeSizes = $this->dotations->employeeSizes($employeeId);
        if ($employeeSizes === []) {
            throw new ApiException('El empleado no existe o no se encuentra activo.', 422);
        }

        $detailsByType = [];
        foreach ($details as $detail) {
            $dotationTypeId = (int) $detail['id_tipo_dotacion'];
            if (isset($detailsByType[$dotationTypeId])) {
                throw new ApiException('No se puede duplicar un tipo de dotación dentro de la misma entrega.', 422);
            }
            if ((int) $detail['cantidad'] < 1) {
                throw new ApiException('La cantidad de cada prenda debe ser mayor a cero.', 422);
            }
            $detailsByType[$dotationTypeId] = $detail;
        }

        $activeTypes = [];
        foreach ($this->dotations->types(true) as $type) {
            $activeTypes[(int) $type['id_tipo_dotacion']] = $type;
        }

        $activeSizes = [];
        foreach ($this->dotations->sizes(null, true) as $size) {
            $activeSizes[(int) $size['id_talla_dotacion']] = $size;
        }

        $employeeSizesByType = [];
        foreach ($employeeSizes as $employeeSize) {
            $employeeSizesByType[(int) $employeeSize['id_tipo_dotacion']] = $employeeSize;
        }

        if ($deliveryType === 'ORDINARIA') {
            $combination = $this->dotations->combinationDetails((int) $combinationId);
            if ($combination === []) {
                throw new ApiException('La combinación no existe, no está activa o no contiene prendas activas.', 422);
            }

            $combinationByType = [];
            foreach ($combination as $item) {
                $combinationByType[(int) $item['id_tipo_dotacion']] = $item;
            }

            $missing = array_diff_key($combinationByType, $detailsByType);
            $additional = array_diff_key($detailsByType, $combinationByType);
            if ($missing !== [] || $additional !== []) {
                throw new ApiException('Las prendas enviadas no corresponden a la combinación seleccionada.', 422);
            }

            foreach ($combinationByType as $dotationTypeId => $item) {
                if ((int) $detailsByType[$dotationTypeId]['cantidad'] !== (int) $item['cantidad']) {
                    throw new ApiException("La cantidad de {$item['tipo_dotacion']} no corresponde a la combinación seleccionada.", 422);
                }
            }
        }

        foreach ($detailsByType as $dotationTypeId => $detail) {
            $type = $activeTypes[$dotationTypeId] ?? null;
            if ($type === null) {
                throw new ApiException('Uno de los tipos de dotación no existe o no está activo.', 422);
            }

            $typeName = (string) ($type['nombre'] ?? 'la prenda');
            $sentSizeId = $this->nullableInt($detail, 'id_talla_dotacion');
            $requiresSize = (bool) ($type['requiere_talla'] ?? false);

            if ($requiresSize) {
                $registeredSizeId = $this->nullableInt($employeeSizesByType[$dotationTypeId] ?? [], 'id_talla_dotacion');
                if ($registeredSizeId === null) {
                    throw new ApiException("El empleado no tiene registrada talla para {$typeName}.", 422);
                }
                if ($sentSizeId === null || $sentSizeId !== $registeredSizeId) {
                    throw new ApiException("El empleado no tiene registrada la talla indicada para {$typeName}.", 422);
                }
            }

            if ($sentSizeId !== null) {
                $size = $activeSizes[$sentSizeId] ?? null;
                if ($size === null || (int) $size['id_tipo_dotacion'] !== $dotationTypeId) {
                    throw new ApiException("La talla indicada no es válida para {$typeName}.", 422);
                }
            }
        }

        return array_values($detailsByType);
    }

    public function deliveries(?int $employeeId, ?string $startDate, ?string $endDate): array
    {
        return array_map(
            fn (array $row): array => $this->mapDelivery($row),
            $this->dotations->deliveries($employeeId, $this->blankToNull($startDate), $this->blankToNull($endDate)),
        );
    }

    public function deliveryDetails(int $deliveryId): array
    {
        return array_map(fn (array $row): array => $this->mapDeliveryDetail($row), $this->dotations->deliveryDetails($deliveryId));
    }

    public function deleteDelivery(int $deliveryId, int $userId, ?string $deletionReason): array
    {
        $deleted = $this->dotations->deleteDelivery($deliveryId, $userId, $this->blankToNull($deletionReason));

        if (! $deleted) {
            throw new ApiException('No fue posible eliminar la entrega de dotacion.', 422);
        }

        $mapped = $this->mapDeletedDelivery($deleted);
        $this->audit->record($userId, 'DOTACIONES', 'DOTACIONES_ENTREGA_ELIMINAR', 'DOTACION_ENTREGA', $deliveryId, null, [
            'id_usuario' => $userId,
            'id_dotacion_entrega' => $deliveryId,
            'motivo_eliminacion' => $deletionReason,
        ]);

        return $mapped;
    }

    public function confirmDeliveryReceived(int $userId, int $deliveryId, array $data, array $context): array
    {
        $confirmed = $this->dotations->confirmDeliveryReceived(
            $userId,
            $deliveryId,
            $data['observacion_confirmacion'] ?? null,
            $data['firma_url'] ?? null,
        );

        if (! $confirmed) {
            throw new ApiException('No fue posible confirmar la entrega de dotacion.', 422);
        }

        $mapped = $this->mapConfirmedDelivery($confirmed);
        $this->audit->record($userId, 'DOTACIONES', 'DOTACIONES_ENTREGA_CONFIRMAR_RECIBIDO', 'DOTACION_ENTREGA', $deliveryId, null, [
            'id_usuario' => $userId,
            'id_dotacion_entrega' => $deliveryId,
            'observacion_confirmacion' => $data['observacion_confirmacion'] ?? null,
            'firma_url' => $data['firma_url'] ?? null,
        ], $context);

        return $mapped;
    }

    private function mapType(array $row): array
    {
        return [
            'id_tipo_dotacion' => (int) ($row['id_tipo_dotacion'] ?? 0),
            'nombre' => (string) ($row['nombre'] ?? ''),
            'descripcion' => $row['descripcion'] ?? null,
            'requiere_talla' => (bool) ($row['requiere_talla'] ?? false),
            'activo' => (bool) ($row['activo'] ?? false),
        ];
    }

    private function mapSize(array $row): array
    {
        return [
            'id_talla_dotacion' => (int) ($row['id_talla_dotacion'] ?? 0),
            'id_tipo_dotacion' => (int) ($row['id_tipo_dotacion'] ?? 0),
            'talla' => (string) ($row['talla'] ?? ''),
            'descripcion' => $row['descripcion'] ?? null,
            'orden' => $this->nullableInt($row, 'orden'),
            'activo' => (bool) ($row['activo'] ?? false),
        ];
    }

    private function mapCombination(array $row): array
    {
        return [
            'id_dotacion_combinacion' => (int) ($row['id_dotacion_combinacion'] ?? 0),
            'codigo' => (string) ($row['codigo'] ?? ''),
            'nombre' => (string) ($row['nombre'] ?? ''),
            'descripcion' => $row['descripcion'] ?? null,
            'activo' => (bool) ($row['activo'] ?? false),
        ];
    }

    private function mapCombinationDetail(array $row): array
    {
        return [
            'id_dotacion_combinacion_detalle' => (int) ($row['id_dotacion_combinacion_detalle'] ?? 0),
            'id_dotacion_combinacion' => (int) ($row['id_dotacion_combinacion'] ?? 0),
            'codigo_combinacion' => (string) ($row['codigo_combinacion'] ?? ''),
            'combinacion' => (string) ($row['combinacion'] ?? ''),
            'id_tipo_dotacion' => (int) ($row['id_tipo_dotacion'] ?? 0),
            'tipo_dotacion' => (string) ($row['tipo_dotacion'] ?? ''),
            'requiere_talla' => (bool) ($row['requiere_talla'] ?? false),
            'cantidad' => (int) ($row['cantidad'] ?? 0),
            'orden' => (int) ($row['orden'] ?? 0),
            'activo' => (bool) ($row['activo'] ?? false),
        ];
    }

    private function mapMySize(array $row): array
    {
        return [
            'id_tipo_dotacion' => (int) ($row['id_tipo_dotacion'] ?? 0),
            'tipo_dotacion' => (string) ($row['tipo_dotacion'] ?? ''),
            'tipo_dotacion_descripcion' => $row['tipo_dotacion_descripcion'] ?? null,
            'requiere_talla' => (bool) ($row['requiere_talla'] ?? false),
            'id_empleado_dotacion_talla' => $this->nullableInt($row, 'id_empleado_dotacion_talla'),
            'id_empleado' => $this->nullableInt($row, 'id_empleado'),
            'id_talla_dotacion' => $this->nullableInt($row, 'id_talla_dotacion'),
            'talla' => $row['talla'] ?? null,
            'talla_descripcion' => $row['talla_descripcion'] ?? null,
            'observaciones' => $row['observaciones'] ?? null,
            'created_at' => $row['created_at'] ?? null,
            'updated_at' => $row['updated_at'] ?? null,
        ];
    }

    private function mapSavedMySize(array $row): array
    {
        return [
            'id_empleado_dotacion_talla' => $this->nullableInt($row, 'id_empleado_dotacion_talla'),
            'id_empleado' => $this->nullableInt($row, 'id_empleado'),
            'id_tipo_dotacion' => (int) ($row['id_tipo_dotacion'] ?? 0),
            'tipo_dotacion' => (string) ($row['tipo_dotacion'] ?? ''),
            'id_talla_dotacion' => $this->nullableInt($row, 'id_talla_dotacion'),
            'talla' => $row['talla'] ?? null,
            'observaciones' => $row['observaciones'] ?? null,
        ];
    }

    private function mapEmployeeSummary(array $row): array
    {
        return [
            'id_empleado' => (int) ($row['id_empleado'] ?? 0),
            'numero_documento' => (string) ($row['numero_documento'] ?? ''),
            'nombre_completo' => (string) ($row['nombre_completo'] ?? ''),
            'correo' => $row['correo'] ?? null,
            'telefono' => $row['telefono'] ?? null,
            'id_area' => $this->nullableInt($row, 'id_area'),
            'area' => $row['area'] ?? null,
            'id_cargo' => $this->nullableInt($row, 'id_cargo'),
            'cargo' => $row['cargo'] ?? null,
            'estado_empleado' => (string) ($row['estado_empleado'] ?? ''),
            'resumen_tallas' => $row['resumen_tallas'] ?? null,
            'total_entregas' => $this->nullableInt($row, 'total_entregas'),
            'entregas_pendientes_confirmacion' => $this->nullableInt($row, 'entregas_pendientes_confirmacion'),
            'ultima_fecha_entrega' => $row['ultima_fecha_entrega'] ?? null,
        ];
    }

    private function mapEmployeeSize(array $row): array
    {
        return [
            'id_empleado' => (int) ($row['id_empleado'] ?? 0),
            'numero_documento' => (string) ($row['numero_documento'] ?? ''),
            'nombre_completo' => (string) ($row['nombre_completo'] ?? ''),
            'id_tipo_dotacion' => (int) ($row['id_tipo_dotacion'] ?? 0),
            'tipo_dotacion' => (string) ($row['tipo_dotacion'] ?? ''),
            'id_empleado_dotacion_talla' => $this->nullableInt($row, 'id_empleado_dotacion_talla'),
            'id_talla_dotacion' => $this->nullableInt($row, 'id_talla_dotacion'),
            'talla' => $row['talla'] ?? null,
            'observaciones' => $row['observaciones'] ?? null,
            'created_at' => $row['created_at'] ?? null,
            'updated_at' => $row['updated_at'] ?? null,
        ];
    }

    private function mapEmployeeHistory(array $row): array
    {
        return [
            'id_dotacion_entrega' => (int) ($row['id_dotacion_entrega'] ?? 0),
            'id_empleado' => (int) ($row['id_empleado'] ?? 0),
            'numero_documento' => (string) ($row['numero_documento'] ?? ''),
            'nombre_completo' => (string) ($row['nombre_completo'] ?? ''),
            'area' => $row['area'] ?? null,
            'cargo' => $row['cargo'] ?? null,
            'fecha_entrega' => (string) ($row['fecha_entrega'] ?? ''),
            'tipo_entrega' => (string) ($row['tipo_entrega'] ?? 'ORDINARIA'),
            'id_dotacion_combinacion' => $this->nullableInt($row, 'id_dotacion_combinacion'),
            'codigo_combinacion' => $row['codigo_combinacion'] ?? null,
            'nombre_combinacion' => $row['nombre_combinacion'] ?? null,
            'fecha_confirmacion' => $row['fecha_confirmacion'] ?? null,
            'estado' => (string) ($row['estado'] ?? ''),
            'observaciones_entrega' => $row['observaciones_entrega'] ?? null,
            'observacion_confirmacion' => $row['observacion_confirmacion'] ?? null,
            'firma_url' => $row['firma_url'] ?? null,
            'id_registrado_por' => $this->nullableInt($row, 'id_registrado_por'),
            'registrado_por' => $row['registrado_por'] ?? null,
            'id_confirmado_por' => $this->nullableInt($row, 'id_confirmado_por'),
            'confirmado_por' => $row['confirmado_por'] ?? null,
            'id_dotacion_entrega_detalle' => (int) ($row['id_dotacion_entrega_detalle'] ?? 0),
            'id_tipo_dotacion' => (int) ($row['id_tipo_dotacion'] ?? 0),
            'tipo_dotacion' => (string) ($row['tipo_dotacion'] ?? ''),
            'id_talla_dotacion' => $this->nullableInt($row, 'id_talla_dotacion'),
            'talla' => $row['talla'] ?? null,
            'cantidad' => (int) ($row['cantidad'] ?? 0),
            'observaciones_detalle' => $row['observaciones_detalle'] ?? null,
            'created_at' => $row['created_at'] ?? null,
            'updated_at' => $row['updated_at'] ?? null,
        ];
    }

    private function mapDelivery(array $row): array
    {
        return [
            'id_dotacion_entrega' => (int) ($row['id_dotacion_entrega'] ?? 0),
            'id_empleado' => (int) ($row['id_empleado'] ?? 0),
            'numero_documento' => (string) ($row['numero_documento'] ?? ''),
            'nombre_completo' => (string) ($row['nombre_completo'] ?? ''),
            'fecha_entrega' => (string) ($row['fecha_entrega'] ?? ''),
            'tipo_entrega' => (string) ($row['tipo_entrega'] ?? 'ORDINARIA'),
            'id_dotacion_combinacion' => $this->nullableInt($row, 'id_dotacion_combinacion'),
            'codigo_combinacion' => $row['codigo_combinacion'] ?? null,
            'nombre_combinacion' => $row['nombre_combinacion'] ?? null,
            'fecha_confirmacion' => $row['fecha_confirmacion'] ?? null,
            'estado' => (string) ($row['estado'] ?? ''),
            'observaciones' => $row['observaciones'] ?? null,
            'observacion_confirmacion' => $row['observacion_confirmacion'] ?? null,
            'firma_url' => $row['firma_url'] ?? null,
            'id_registrado_por' => $this->nullableInt($row, 'id_registrado_por'),
            'registrado_por' => $row['registrado_por'] ?? null,
            'id_confirmado_por' => $this->nullableInt($row, 'id_confirmado_por'),
            'confirmado_por' => $row['confirmado_por'] ?? null,
            'created_at' => $row['created_at'] ?? null,
            'updated_at' => $row['updated_at'] ?? null,
        ];
    }

    private function mapConfirmedDelivery(array $row): array
    {
        return [
            'id_dotacion_entrega' => (int) ($row['id_dotacion_entrega'] ?? 0),
            'id_empleado' => (int) ($row['id_empleado'] ?? 0),
            'fecha_entrega' => (string) ($row['fecha_entrega'] ?? ''),
            'fecha_confirmacion' => $row['fecha_confirmacion'] ?? null,
            'estado' => (string) ($row['estado'] ?? ''),
            'observaciones' => $row['observaciones'] ?? null,
            'observacion_confirmacion' => $row['observacion_confirmacion'] ?? null,
            'firma_url' => $row['firma_url'] ?? null,
            'id_confirmado_por' => $this->nullableInt($row, 'id_confirmado_por'),
        ];
    }

    private function mapDeletedDelivery(array $row): array
    {
        return [
            'id_dotacion_entrega' => (int) ($row['id_dotacion_entrega'] ?? 0),
            'eliminado' => (bool) ($row['eliminado'] ?? false),
            'estado' => (string) ($row['estado'] ?? ''),
            'fecha_eliminacion' => $row['fecha_eliminacion'] ?? null,
        ];
    }

    private function mapDeliveryDetail(array $row): array
    {
        return [
            'id_dotacion_entrega_detalle' => (int) ($row['id_dotacion_entrega_detalle'] ?? 0),
            'id_dotacion_entrega' => (int) ($row['id_dotacion_entrega'] ?? 0),
            'id_empleado' => $this->nullableInt($row, 'id_empleado'),
            'fecha_entrega' => $row['fecha_entrega'] ?? null,
            'tipo_entrega' => (string) ($row['tipo_entrega'] ?? 'ORDINARIA'),
            'id_dotacion_combinacion' => $this->nullableInt($row, 'id_dotacion_combinacion'),
            'codigo_combinacion' => $row['codigo_combinacion'] ?? null,
            'nombre_combinacion' => $row['nombre_combinacion'] ?? null,
            'estado' => $row['estado'] ?? null,
            'observaciones_entrega' => $row['observaciones_entrega'] ?? null,
            'fecha_confirmacion' => $row['fecha_confirmacion'] ?? null,
            'id_tipo_dotacion' => (int) ($row['id_tipo_dotacion'] ?? 0),
            'tipo_dotacion' => (string) ($row['tipo_dotacion'] ?? ''),
            'requiere_talla' => (bool) ($row['requiere_talla'] ?? false),
            'id_talla_dotacion' => $this->nullableInt($row, 'id_talla_dotacion'),
            'talla' => $row['talla'] ?? null,
            'cantidad' => (int) ($row['cantidad'] ?? 0),
            'observaciones' => $row['observaciones'] ?? null,
            'created_at' => $row['created_at'] ?? null,
        ];
    }

    private function nullableInt(array $row, string $key): ?int
    {
        if (! array_key_exists($key, $row) || $row[$key] === null || $row[$key] === '') {
            return null;
        }

        return (int) $row[$key];
    }

    private function blankToNull(?string $value): ?string
    {
        if ($value === null || trim($value) === '') {
            return null;
        }

        return $value;
    }
}
