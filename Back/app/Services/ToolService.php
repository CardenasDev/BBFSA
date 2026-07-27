<?php

namespace App\Services;

use App\Exceptions\ApiException;
use App\Repositories\ToolRepository;
use JsonException;

class ToolService
{
    public function __construct(
        private readonly ToolRepository $tools,
        private readonly AuditService $audit,
    ) {}

    public function tools(bool $onlyActive): array
    {
        return array_map(fn (array $row): array => $this->mapTool($row), $this->tools->list($onlyActive));
    }

    public function createTool(array $data): array
    {
        $row = $this->tools->create($data['nombre'], $data['descripcion'] ?? null);

        return $row === [] ? [
            'nombre' => $data['nombre'],
            'descripcion' => $data['descripcion'] ?? null,
            'activo' => true,
        ] : $this->mapTool($row);
    }

    public function updateTool(int $toolId, array $data): array
    {
        $row = $this->tools->update($toolId, $data['nombre'], $data['descripcion'] ?? null);

        return $row === [] ? [
            'id_herramienta' => $toolId,
            'nombre' => $data['nombre'],
            'descripcion' => $data['descripcion'] ?? null,
        ] : $this->mapTool($row);
    }

    public function changeToolStatus(int $toolId, bool $active): array
    {
        $row = $this->tools->changeStatus($toolId, $active);

        return $row === [] ? [
            'id_herramienta' => $toolId,
            'activo' => $active,
        ] : $this->mapTool($row);
    }

    public function createDelivery(array $data): array
    {
        try {
            $details = json_encode($data['herramientas'], JSON_THROW_ON_ERROR | JSON_UNESCAPED_UNICODE);
        } catch (JsonException) {
            throw new ApiException('El detalle de herramientas no tiene un formato válido.', 422);
        }

        $deliveryId = $this->tools->createDelivery(
            (int) $data['id_empleado'],
            $data['fecha_entrega'],
            $data['observaciones'] ?? null,
            $details,
        );
        if ($deliveryId < 1) {
            throw new ApiException('No fue posible registrar la entrega de herramientas.', 422);
        }

        return ['id_entrega' => $deliveryId, 'estado' => 'pendiente'];
    }

    public function deliveries(?int $employeeId, ?string $status): array
    {
        return array_map(fn (array $row): array => $this->mapDelivery($row), $this->tools->deliveries($employeeId, $status));
    }

    public function delivery(int $deliveryId): array
    {
        $delivery = $this->tools->delivery($deliveryId);
        if ($delivery === null) {
            throw new ApiException('La entrega de herramientas no existe.', 404);
        }

        return [
            ...$this->mapDelivery($delivery),
            'herramientas' => array_map(
                fn (array $row): array => $this->mapDeliveryDetail($row),
                $this->tools->deliveryDetails($deliveryId),
            ),
        ];
    }

    public function confirmDelivery(int $deliveryId): array
    {
        $row = $this->tools->confirmDelivery($deliveryId);

        return $row === [] ? ['id_entrega' => $deliveryId, 'estado' => 'confirmada'] : $this->mapDelivery($row);
    }

    public function deleteDelivery(int $deliveryId): array
    {
        $row = $this->tools->deleteDelivery($deliveryId);

        return $row === [] ? ['id_entrega' => $deliveryId] : $this->mapDelivery($row);
    }

    public function getMyDeliveries(int $userId): array
    {
        $employeeId = $this->employeeIdForUser($userId);

        return array_map(
            fn (array $row): array => $this->mapDelivery($row),
            $this->tools->listMyDeliveries($employeeId),
        );
    }

    public function getMyDelivery(int $userId, int $deliveryId): array
    {
        $employeeId = $this->employeeIdForUser($userId);
        $delivery = $this->tools->getMyDelivery($deliveryId, $employeeId);
        if ($delivery === null) {
            throw new ApiException('La entrega de herramientas no existe.', 404);
        }

        return [
            ...$this->mapDelivery($delivery),
            'herramientas' => array_map(
                fn (array $row): array => $this->mapDeliveryDetail($row),
                $this->tools->getMyDeliveryDetails($deliveryId, $employeeId),
            ),
        ];
    }

    public function confirmMyDelivery(int $userId, int $deliveryId, array $context = []): array
    {
        $employeeId = $this->employeeIdForUser($userId);
        $row = $this->tools->confirmMyDelivery($deliveryId, $employeeId, $userId);
        $result = $row === [] ? [
            'id_entrega' => $deliveryId,
            'estado' => 'confirmada',
        ] : $this->mapDelivery($row);

        $this->audit->record(
            $userId,
            'HERRAMIENTAS',
            'HERRAMIENTA_ENTREGA_CONFIRMAR_EMPLEADO',
            'HERRAMIENTA_ENTREGA',
            $deliveryId,
            null,
            ['id_entrega' => $deliveryId, 'id_empleado' => $employeeId, 'id_usuario' => $userId],
            $context,
        );

        return $result;
    }

    private function employeeIdForUser(int $userId): int
    {
        $employeeId = $this->tools->employeeForUser($userId);
        if ($employeeId === null) {
            throw new ApiException('No se encontró un empleado asociado al usuario autenticado.', 422);
        }

        return $employeeId;
    }

    private function mapTool(array $row): array
    {
        return array_filter([
            'id_herramienta' => isset($row['id_herramienta']) ? (int) $row['id_herramienta'] : null,
            'nombre' => $row['nombre'] ?? null,
            'descripcion' => $row['descripcion'] ?? null,
            'activo' => isset($row['activo']) ? (bool) $row['activo'] : null,
            'created_at' => $row['created_at'] ?? null,
            'updated_at' => $row['updated_at'] ?? null,
        ], static fn (mixed $value): bool => $value !== null);
    }

    private function mapDelivery(array $row): array
    {
        $mapped = $row;
        foreach (['id_entrega', 'id_empleado'] as $key) {
            if (isset($mapped[$key])) {
                $mapped[$key] = (int) $mapped[$key];
            }
        }
        if (! isset($mapped['empleado']) && (isset($mapped['nombres']) || isset($mapped['apellidos']))) {
            $mapped['empleado'] = trim(($mapped['nombres'] ?? '').' '.($mapped['apellidos'] ?? ''));
        }

        return $mapped;
    }

    private function mapDeliveryDetail(array $row): array
    {
        foreach (['id_detalle', 'id_herramienta', 'cantidad'] as $key) {
            if (isset($row[$key])) {
                $row[$key] = (int) $row[$key];
            }
        }

        return $row;
    }
}
