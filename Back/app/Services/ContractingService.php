<?php

namespace App\Services;

use App\Exceptions\ApiException;
use App\Repositories\ContractingRepository;

class ContractingService
{
    public function __construct(
        private readonly ContractingRepository $contracting,
        private readonly AuditService $audit,
    ) {}

    public function listEmployees(?string $search, ?int $areaId, ?int $positionId, ?string $status): array
    {
        return $this->contracting->listEmployees($this->blankToNull($search), $areaId, $positionId, $this->blankToNull($status));
    }

    public function getProfile(int $employeeId): ?array
    {
        return $this->contracting->getProfile($employeeId);
    }

    public function saveProfile(int $employeeId, int $userId, array $data, array $context): array
    {
        $payload = $this->normalizeData($data);
        $saved = $this->contracting->saveProfile($employeeId, $payload);

        if (! $saved) {
            throw new ApiException('No fue posible guardar la ficha de contratacion.', 422);
        }

        $this->audit->record($userId, 'CONTRATACION', 'CONTRATACION_FICHA_GUARDAR', 'CONTRATACION_FICHA', $employeeId, null, [
            'id_empleado' => $employeeId,
            'request' => $payload,
            'result' => $saved,
        ], $context);

        return $saved;
    }

    public function listContracts(int $employeeId): array
    {
        return $this->contracting->listContracts($employeeId);
    }

    public function createContract(int $employeeId, int $userId, array $data, array $context): array
    {
        $payload = $this->normalizeData($data);
        $created = $this->contracting->createContract($employeeId, $userId, $payload);

        if (! $created) {
            throw new ApiException('No fue posible crear el contrato del empleado.', 422);
        }

        $this->audit->record($userId, 'CONTRATACION', 'CONTRATACION_CONTRATO_CREAR', 'CONTRATO_EMPLEADO', $this->contractId($created), null, [
            'id_empleado' => $employeeId,
            'id_tipo_contrato' => $payload['id_tipo_contrato'] ?? null,
            'numero_contrato' => $payload['numero_contrato'] ?? null,
            'tipo_cargo_contrato' => $payload['tipo_cargo_contrato'] ?? null,
            'fecha_inicio' => $payload['fecha_inicio'] ?? null,
            'fecha_fin' => $payload['fecha_fin'] ?? null,
            'request' => $payload,
            'result' => $created,
        ], $context);

        return $created;
    }

    public function getSocialSecurity(int $employeeId): ?array
    {
        return $this->contracting->getSocialSecurity($employeeId);
    }

    public function saveSocialSecurity(int $employeeId, int $userId, array $data, array $context): array
    {
        $payload = $this->normalizeData($data);
        $saved = $this->contracting->saveSocialSecurity($employeeId, $payload);

        if (! $saved) {
            throw new ApiException('No fue posible guardar la seguridad social del empleado.', 422);
        }

        $this->audit->record($userId, 'CONTRATACION', 'CONTRATACION_SEGURIDAD_SOCIAL_GUARDAR', 'SEGURIDAD_SOCIAL_EMPLEADO', $employeeId, null, [
            'id_empleado' => $employeeId,
            'request' => $payload,
            'result' => $saved,
        ], $context);

        return $saved;
    }

    public function listMedicalExams(int $employeeId): array
    {
        return $this->contracting->listMedicalExams($employeeId);
    }

    public function createMedicalExam(int $employeeId, int $userId, array $data, array $context): array
    {
        $payload = $this->normalizeData($data);
        $created = $this->contracting->createMedicalExam($employeeId, $payload);

        if (! $created) {
            throw new ApiException('No fue posible registrar el examen medico.', 422);
        }

        $this->audit->record($userId, 'CONTRATACION', 'CONTRATACION_EXAMEN_CREAR', 'EXAMEN_MEDICO_EMPLEADO', $this->nullableInt($created, 'id_empleado_examen_medico'), null, [
            'id_empleado' => $employeeId,
            'request' => $payload,
            'result' => $created,
        ], $context);

        return $created;
    }

    public function listDocuments(int $employeeId): array
    {
        return $this->contracting->listDocuments($employeeId);
    }

    public function registerDocument(int $employeeId, int $userId, array $data, array $context): array
    {
        $payload = $this->normalizeData($data);
        $registered = $this->contracting->registerDocument($employeeId, $userId, $payload);

        if (! $registered) {
            throw new ApiException('No fue posible registrar el documento laboral.', 422);
        }

        $this->audit->record($userId, 'CONTRATACION', 'CONTRATACION_DOCUMENTO_REGISTRAR', 'DOCUMENTO_LABORAL_EMPLEADO', $this->nullableInt($registered, 'id_empleado_documento_laboral'), null, [
            'id_empleado' => $employeeId,
            'request' => $payload,
            'result' => $registered,
        ], $context);

        return $registered;
    }

    public function listAlerts(?int $days): array
    {
        return $this->contracting->listAlerts($days);
    }

    private function normalizeData(array $data): array
    {
        return array_map(function (mixed $value): mixed {
            if (is_array($value)) {
                return $this->normalizeData($value);
            }

            return is_string($value) ? $this->blankToNull($value) : $value;
        }, $data);
    }

    private function nullableInt(array $row, string $key): ?int
    {
        if (! array_key_exists($key, $row) || $row[$key] === null || $row[$key] === '') {
            return null;
        }

        return (int) $row[$key];
    }

    private function contractId(array $row): ?int
    {
        return $this->nullableInt($row, 'id_empleado_contrato')
            ?? $this->nullableInt($row, 'id_contrato_empleado');
    }

    private function blankToNull(?string $value): ?string
    {
        if ($value === null || trim($value) === '') {
            return null;
        }

        return $value;
    }
}
