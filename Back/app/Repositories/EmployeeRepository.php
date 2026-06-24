<?php

namespace App\Repositories;

class EmployeeRepository extends StoredProcedureRepository
{
    public function list(?string $status, ?int $areaId, ?int $positionId, ?string $search): array
    {
        return $this->call('SP_BBF_EMPLEADOS_LISTAR', [$status, $areaId, $positionId, $search]);
    }

    public function find(int $employeeId): ?array
    {
        return $this->first('SP_BBF_EMPLEADOS_OBTENER_POR_ID', [$employeeId]);
    }

    public function findByDocument(string $document): ?array
    {
        return $this->first('SP_BBF_EMPLEADOS_OBTENER_POR_DOCUMENTO', [$document]);
    }

    public function create(array $data): int
    {
        $row = $this->first('SP_BBF_EMPLEADOS_CREAR', $this->payload($data));

        return (int) ($row['id_empleado'] ?? 0);
    }

    public function update(int $employeeId, array $data): int
    {
        $row = $this->first('SP_BBF_EMPLEADOS_ACTUALIZAR', array_merge([$employeeId], $this->payload($data)));

        return (int) ($row['filas_afectadas'] ?? 0);
    }

    public function updatePhotoUrl(int $employeeId, string $photoUrl, array $employee): int
    {
        $employee['foto_url'] = $photoUrl;

        return $this->update($employeeId, $employee);
    }

    public function changeStatus(int $employeeId, string $status, ?string $retirementDate): int
    {
        $row = $this->first('SP_BBF_EMPLEADOS_CAMBIAR_ESTADO', [$employeeId, $status, $retirementDate]);

        return (int) ($row['filas_afectadas'] ?? 0);
    }

    public function deleteLogical(int $employeeId): int
    {
        $row = $this->first('SP_BBF_EMPLEADOS_ELIMINAR', [$employeeId]);

        return (int) ($row['filas_afectadas'] ?? 0);
    }

    private function payload(array $data): array
    {
        return [
            $data['id_tipo_documento'] ?? null,
            $data['numero_documento'],
            $data['nombres'],
            $data['apellidos'],
            $data['correo'] ?? null,
            $data['telefono'] ?? null,
            $data['foto_url'] ?? null,
            $data['id_area'] ?? null,
            $data['id_cargo'] ?? null,
            $data['id_tipo_contrato'] ?? null,
            $data['fecha_ingreso'] ?? null,
            $data['fecha_retiro'] ?? null,
            $data['estado_empleado'] ?? 'ACTIVO',
            $data['observaciones'] ?? null,
        ];
    }
}
