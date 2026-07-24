<?php

namespace App\Repositories;

class ApplicantRepository extends StoredProcedureRepository
{
    public function listApplicants(?string $search, ?string $status, ?int $areaId, ?int $positionId): array
    {
        return $this->call('SP_BBF_ASPIRANTES_LISTAR', [$search, $status, $areaId, $positionId]);
    }

    public function getApplicant(int $applicantId): ?array
    {
        return $this->first('SP_BBF_ASPIRANTES_OBTENER', [$applicantId]);
    }

    public function createApplicant(array $data, int $userId): array
    {
        return $this->first('SP_BBF_ASPIRANTES_CREAR', [
            $data['id_tipo_documento'] ?? null,
            $data['numero_documento'],
            $data['nombres'],
            $data['apellidos'],
            $data['correo'] ?? null,
            $data['telefono'] ?? null,
            $data['direccion'] ?? null,
            $data['fecha_nacimiento'] ?? null,
            $data['id_departamento_nacimiento'] ?? null,
            $data['id_municipio_nacimiento'] ?? null,
            $data['nacionalidad'] ?? null,
            $data['id_departamento_residencia'] ?? null,
            $data['id_municipio_residencia'] ?? null,
            $data['estado_civil'] ?? null,
            $data['nivel_educativo'] ?? null,
            $data['personas_a_cargo'] ?? null,
            $data['numero_hijos'] ?? null,
            $data['id_area_aspira'] ?? null,
            $data['id_cargo_aspira'] ?? null,
            $data['observaciones'] ?? null,
            $userId,
        ]) ?? [];
    }

    public function updateApplicant(int $applicantId, array $data): array
    {
        return $this->first('SP_BBF_ASPIRANTES_ACTUALIZAR', [
            $applicantId,
            $data['id_tipo_documento'] ?? null,
            $data['numero_documento'],
            $data['nombres'],
            $data['apellidos'],
            $data['correo'] ?? null,
            $data['telefono'] ?? null,
            $data['direccion'] ?? null,
            $data['fecha_nacimiento'] ?? null,
            $data['id_departamento_nacimiento'] ?? null,
            $data['id_municipio_nacimiento'] ?? null,
            $data['nacionalidad'] ?? null,
            $data['id_departamento_residencia'] ?? null,
            $data['id_municipio_residencia'] ?? null,
            $data['estado_civil'] ?? null,
            $data['nivel_educativo'] ?? null,
            $data['personas_a_cargo'] ?? null,
            $data['numero_hijos'] ?? null,
            $data['id_area_aspira'] ?? null,
            $data['id_cargo_aspira'] ?? null,
            $data['observaciones'] ?? null,
        ]) ?? [];
    }

    public function changeStatus(int $applicantId, string $newStatus, ?string $observations, int $userId): array
    {
        return $this->first('SP_BBF_ASPIRANTES_CAMBIAR_ESTADO', [$applicantId, $newStatus, $observations, $userId]) ?? [];
    }

    public function listDocuments(int $applicantId): array
    {
        return $this->call('SP_BBF_ASPIRANTES_DOCUMENTOS_LISTAR', [$applicantId]);
    }

    public function registerDocument(int $applicantId, array $data, int $userId): array
    {
        return $this->first('SP_BBF_ASPIRANTES_DOCUMENTO_REGISTRAR', [
            $applicantId,
            $data['id_tipo_documento_laboral'],
            $data['nombre_archivo'],
            $data['nombre_original'] ?? null,
            $data['archivo_url'],
            $data['archivo_ruta'] ?? null,
            $data['mime_type'] ?? null,
            $data['peso_bytes'] ?? null,
            $data['estado_documento'] ?? null,
            $data['observaciones'] ?? null,
            $userId,
        ]) ?? [];
    }

    public function listStatusHistory(int $applicantId): array
    {
        return $this->call('SP_BBF_ASPIRANTES_HISTORIAL_ESTADOS', [$applicantId]);
    }

    public function convertToEmployee(int $applicantId, array $data, int $userId): array
    {
        return $this->first('SP_BBF_ASPIRANTES_CONVERTIR_EMPLEADO', [
            $applicantId,
            $data['id_tipo_contrato'] ?? null,
            $data['fecha_ingreso'] ?? null,
            $userId,
            $data['observaciones'] ?? null,
        ]) ?? [];
    }
}
