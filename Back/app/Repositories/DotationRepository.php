<?php

namespace App\Repositories;

use Illuminate\Support\Facades\DB;

class DotationRepository extends StoredProcedureRepository
{
    public function types(bool $onlyActive): array
    {
        return $this->call('SP_BBF_DOTACION_TIPOS_LISTAR', [(int) $onlyActive]);
    }

    public function sizes(?int $dotationTypeId, bool $onlyActive): array
    {
        return $this->call('SP_BBF_DOTACION_TALLAS_LISTAR', [$dotationTypeId, (int) $onlyActive]);
    }

    public function articles(?int $dotationTypeId, ?string $gender, bool $includeInactive): array
    {
        return $this->call('SP_BBF_DOTACION_ARTICULOS_LISTAR', [
            $dotationTypeId,
            $gender,
            (int) $includeInactive,
        ]);
    }

    public function combinations(): array
    {
        return $this->call('SP_BBF_DOTACION_COMBINACIONES_LISTAR');
    }

    public function combinationDetails(int $combinationId): array
    {
        return $this->call('SP_BBF_DOTACION_COMBINACION_DETALLE_LISTAR', [$combinationId]);
    }

    public function mySizes(int $userId): array
    {
        return $this->call('SP_BBF_DOTACION_MIS_TALLAS_LISTAR', [$userId]);
    }

    public function myDeliveries(int $userId): array
    {
        return $this->call('SP_BBF_DOTACION_MIS_ENTREGAS_LISTAR', [$userId]);
    }

    public function saveMySize(int $userId, int $articleId, int $dotationSizeId, ?string $observations): ?array
    {
        return $this->first('SP_BBF_DOTACION_MI_TALLA_ARTICULO_GUARDAR', [
            $userId,
            $articleId,
            $dotationSizeId,
            $observations,
        ]);
    }

    public function employees(?string $search, ?int $areaId, ?int $positionId): array
    {
        return $this->call('SP_BBF_DOTACION_EMPLEADOS_LISTAR', [$search, $areaId, $positionId]);
    }

    public function quotationReport(?int $areaId, ?int $positionId, ?int $employeeId): array
    {
        return $this->call('SP_BBF_DOTACION_COTIZACION_LISTAR', [$areaId, $positionId, $employeeId]);
    }

    public function purchaseQuotationReport(?int $areaId, ?int $positionId, ?int $employeeId): array
    {
        return $this->call('SP_BBF_DOTACION_COTIZACION_POR_COMPRAR_LISTAR', [$areaId, $positionId, $employeeId]);
    }

    public function employeeSizes(int $employeeId): array
    {
        return $this->call('SP_BBF_DOTACION_TALLAS_EMPLEADO_LISTAR', [$employeeId]);
    }

    public function employeeArticleSizes(int $employeeId): array
    {
        return DB::table('bbf_dotacion_articulos as a')
            ->join('bbf_tipos_dotacion as t', 't.ID_TIPO_DOTACION', '=', 'a.ID_TIPO_DOTACION')
            ->join('bbf_empleados as e', function ($join) use ($employeeId): void {
                $join->where('e.ID_EMPLEADO', '=', $employeeId)
                    ->where('e.ELIMINADO', '=', 0);
            })
            ->leftJoin('bbf_empleado_dotacion_articulo_tallas as et', function ($join): void {
                $join->on('et.ID_DOTACION_ARTICULO', '=', 'a.ID_DOTACION_ARTICULO')
                    ->on('et.ID_EMPLEADO', '=', 'e.ID_EMPLEADO');
            })
            ->leftJoin('bbf_tallas_dotacion as s', 's.ID_TALLA_DOTACION', '=', 'et.ID_TALLA_DOTACION')
            ->where('a.ACTIVO', 1)->where('a.ES_LEGACY', 0)->where('t.ACTIVO', 1)
            ->orderBy('t.NOMBRE')->orderBy('a.NOMBRE')
            ->get([
                'e.ID_EMPLEADO as id_empleado', 'e.NUMERO_DOCUMENTO as numero_documento',
                DB::raw("CONCAT_WS(' ', e.NOMBRES, e.APELLIDOS) as nombre_completo"),
                'a.ID_DOTACION_ARTICULO as id_dotacion_articulo', 'a.CODIGO as codigo_articulo',
                'a.NOMBRE as articulo', 'a.GENERO as genero', 'a.UNIDAD_MEDIDA as unidad_medida',
                't.ID_TIPO_DOTACION as id_tipo_dotacion', 't.NOMBRE as tipo_dotacion',
                't.REQUIERE_TALLA as requiere_talla',
                'et.ID_EMPLEADO_DOTACION_ARTICULO_TALLA as id_empleado_dotacion_articulo_talla',
                'et.ID_TALLA_DOTACION as id_talla_dotacion', 's.TALLA as talla',
                'et.OBSERVACIONES as observaciones', 'et.CREATED_AT as created_at', 'et.UPDATED_AT as updated_at',
            ])->map(fn ($row) => (array) $row)->all();
    }

    public function saveEmployeeArticleSize(int $employeeId, int $articleId, int $sizeId, ?string $observations, int $actorId): void
    {
        $this->call('SP_BBF_DOTACION_ARTICULO_TALLA_GUARDAR', [
            $employeeId, $articleId, $sizeId, $observations, $actorId ?: null,
        ]);
    }

    public function employeeHistory(int $employeeId): array
    {
        return $this->call('SP_BBF_DOTACION_HISTORIAL_EMPLEADO', [$employeeId]);
    }

    public function createDelivery(
        int $employeeId,
        string $deliveryDate,
        string $deliveryType,
        ?int $combinationId,
        int $registeredBy,
        ?string $observations,
        string $initialStatus,
        ?string $evidenceFilename,
        ?string $evidenceOriginalName,
        ?string $evidenceUrl,
        ?string $evidencePath,
        ?string $evidenceMimeType,
        ?int $evidenceSizeBytes,
    ): int {
        $row = $this->first('SP_BBF_DOTACION_ENTREGA_CREAR_V2', [
            $employeeId,
            $deliveryDate,
            $deliveryType,
            $combinationId,
            $registeredBy,
            $observations,
            $initialStatus,
            $evidenceFilename,
            $evidenceOriginalName,
            $evidenceUrl,
            $evidencePath,
            $evidenceMimeType,
            $evidenceSizeBytes,
        ]);

        return (int) ($row['id_dotacion_entrega'] ?? 0);
    }

    public function prepareDelivery(
        int $deliveryId,
        string $deliveryDate,
        int $userId,
        ?string $evidenceFilename,
        ?string $evidenceOriginalName,
        ?string $evidenceUrl,
        ?string $evidencePath,
        ?string $evidenceMimeType,
        ?int $evidenceSizeBytes,
    ): ?array {
        return $this->first('SP_BBF_DOTACION_POR_COMPRAR_PREPARAR_ENTREGA', [
            $deliveryId, $deliveryDate, $userId, $evidenceFilename, $evidenceOriginalName,
            $evidenceUrl, $evidencePath, $evidenceMimeType, $evidenceSizeBytes,
        ]);
    }

    public function addDeliveryDetail(
        int $deliveryId,
        int $dotationArticleId,
        int $dotationTypeId,
        ?int $dotationSizeId,
        int $quantity,
        ?string $observations,
    ): void {
        $this->call('SP_BBF_DOTACION_ENTREGA_DETALLE_AGREGAR_V2', [
            $deliveryId,
            $dotationArticleId,
            $dotationTypeId,
            $dotationSizeId,
            $quantity,
            $observations,
        ]);
    }

    public function deliveries(?int $employeeId, ?string $startDate, ?string $endDate): array
    {
        return $this->call('SP_BBF_DOTACION_ENTREGAS_LISTAR', [$employeeId, $startDate, $endDate]);
    }

    public function deleteDelivery(int $deliveryId, int $userId, ?string $deletionReason): array
    {
        return $this->first('SP_BBF_DOTACION_ENTREGA_ELIMINAR_LOGICO', [
            $deliveryId,
            $userId,
            $deletionReason,
        ]) ?? [];
    }

    public function confirmDeliveryReceived(
        int $userId,
        int $deliveryId,
        ?string $confirmationObservation,
        ?string $signatureUrl,
    ): ?array {
        return $this->first('SP_BBF_DOTACION_ENTREGA_CONFIRMAR_RECIBIDO', [
            $userId,
            $deliveryId,
            $confirmationObservation,
            $signatureUrl,
        ]);
    }

    public function confirmDeliveryByHr(
        int $userId,
        int $deliveryId,
        ?string $confirmationObservation,
    ): ?array {
        return $this->first('SP_BBF_DOTACION_ENTREGA_CONFIRMAR_POR_RRHH', [
            $userId,
            $deliveryId,
            $confirmationObservation,
        ]);
    }

    public function deliveryDetails(int $deliveryId): array
    {
        return $this->call('SP_BBF_DOTACION_ENTREGA_DETALLE_LISTAR', [$deliveryId]);
    }
}
