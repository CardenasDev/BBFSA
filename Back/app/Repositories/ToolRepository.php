<?php

namespace App\Repositories;

class ToolRepository extends StoredProcedureRepository
{
    public function list(bool $onlyActive): array
    {
        return $this->call('SP_BBF_HERRAMIENTAS_LISTAR', [(int) $onlyActive]);
    }

    public function create(string $name, ?string $description): array
    {
        return $this->first('SP_BBF_HERRAMIENTAS_CREAR', [$name, $description]) ?? [];
    }

    public function update(int $toolId, string $name, ?string $description): array
    {
        return $this->first('SP_BBF_HERRAMIENTAS_ACTUALIZAR', [$toolId, $name, $description]) ?? [];
    }

    public function changeStatus(int $toolId, bool $active): array
    {
        return $this->first('SP_BBF_HERRAMIENTAS_CAMBIAR_ESTADO', [$toolId, (int) $active]) ?? [];
    }

    public function createDelivery(
        int $employeeId,
        string $deliveryDate,
        ?string $observations,
        string $details,
        string $evidence,
    ): int {
        $row = $this->first('SP_BBF_HERRAMIENTAS_ENTREGA_CREAR', [
            $employeeId,
            $deliveryDate,
            $observations,
            $details,
            $evidence,
        ]);

        return (int) ($row['id_entrega'] ?? 0);
    }

    public function deliveries(?int $employeeId, ?string $status): array
    {
        return $this->call('SP_BBF_HERRAMIENTAS_ENTREGAS_LISTAR', [$employeeId, $status]);
    }

    public function delivery(int $deliveryId): ?array
    {
        return $this->first('SP_BBF_HERRAMIENTAS_ENTREGA_OBTENER', [$deliveryId]);
    }

    public function deliveryDetails(int $deliveryId): array
    {
        return $this->call('SP_BBF_HERRAMIENTAS_ENTREGA_DETALLE_LISTAR', [$deliveryId]);
    }

    public function deliveryEvidence(int $deliveryId): array
    {
        return $this->call('SP_BBF_HERRAMIENTAS_ENTREGA_EVIDENCIAS_LISTAR', [$deliveryId]);
    }

    public function confirmDelivery(int $deliveryId): array
    {
        return $this->first('SP_BBF_HERRAMIENTAS_ENTREGA_CONFIRMAR', [$deliveryId]) ?? [];
    }

    public function deleteDelivery(int $deliveryId): array
    {
        return $this->first('SP_BBF_HERRAMIENTAS_ENTREGA_ELIMINAR', [$deliveryId]) ?? [];
    }

    public function employeeForUser(int $userId): ?int
    {
        $row = $this->first('SP_BBF_HERRAMIENTAS_EMPLEADO_USUARIO_OBTENER', [$userId]);
        $employeeId = (int) ($row['id_empleado'] ?? 0);

        return $employeeId > 0 ? $employeeId : null;
    }

    public function listMyDeliveries(int $employeeId): array
    {
        return $this->call('SP_BBF_HERRAMIENTAS_MIS_ENTREGAS_LISTAR', [$employeeId]);
    }

    public function getMyDelivery(int $deliveryId, int $employeeId): ?array
    {
        return $this->first('SP_BBF_HERRAMIENTAS_MI_ENTREGA_OBTENER', [$deliveryId, $employeeId]);
    }

    public function getMyDeliveryDetails(int $deliveryId, int $employeeId): array
    {
        return $this->call('SP_BBF_HERRAMIENTAS_MI_ENTREGA_DETALLE_LISTAR', [$deliveryId, $employeeId]);
    }

    public function confirmMyDelivery(int $deliveryId, int $employeeId, int $userId): array
    {
        return $this->first('SP_BBF_HERRAMIENTAS_MI_ENTREGA_CONFIRMAR', [$deliveryId, $employeeId, $userId]) ?? [];
    }
}
