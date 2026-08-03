<?php

namespace App\Repositories;

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

    public function saveMySize(int $userId, int $dotationTypeId, ?int $dotationSizeId, ?string $observations): ?array
    {
        return $this->first('SP_BBF_DOTACION_MI_TALLA_GUARDAR', [
            $userId,
            $dotationTypeId,
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

    public function deliveryDetails(int $deliveryId): array
    {
        return $this->call('SP_BBF_DOTACION_ENTREGA_DETALLE_LISTAR', [$deliveryId]);
    }
}
