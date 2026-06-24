<?php

namespace App\Repositories;

class ContractingRepository extends StoredProcedureRepository
{
    public function listEmployees(?string $search, ?int $areaId, ?int $positionId, ?string $status): array
    {
        return $this->call('SP_BBF_CONTRATACION_LISTAR_EMPLEADOS', [$search, $areaId, $positionId, $status]);
    }

    public function getProfile(int $employeeId): ?array
    {
        return $this->first('SP_BBF_CONTRATACION_FICHA_OBTENER', [$employeeId]);
    }

    public function saveProfile(int $employeeId, array $data): array
    {
        $contact = $data['contacto_emergencia'] ?? [];

        return $this->first('SP_BBF_CONTRATACION_FICHA_GUARDAR', [
            $employeeId,
            $data['lugar_nacimiento'] ?? null,
            $data['departamento_nacimiento'] ?? null,
            $data['ciudad_residencia'] ?? null,
            $data['departamento_residencia'] ?? null,
            $data['direccion_residencia'] ?? null,
            $data['telefono_alterno'] ?? null,
            $data['correo_personal'] ?? null,
            $data['estado_civil'] ?? null,
            $data['nivel_educativo'] ?? null,
            $data['personas_a_cargo'] ?? null,
            $data['numero_hijos'] ?? null,
            $data['observaciones'] ?? null,
            $contact['nombre_completo'] ?? null,
            $contact['parentesco'] ?? null,
            $contact['telefono'] ?? null,
            $contact['telefono_alterno'] ?? null,
            $contact['direccion'] ?? null,
            $contact['observaciones'] ?? null,
        ]) ?? [];
    }

    public function listContracts(int $employeeId): array
    {
        return $this->call('SP_BBF_CONTRATACION_CONTRATOS_LISTAR', [$employeeId]);
    }

    public function createContract(int $employeeId, int $userId, array $data): array
    {
        return $this->first('SP_BBF_CONTRATACION_CONTRATO_CREAR', [
            $employeeId,
            $data['id_tipo_contrato'] ?? null,
            $data['id_area'] ?? null,
            $data['id_cargo'] ?? null,
            $data['fecha_inicio'],
            $data['fecha_fin'] ?? null,
            $data['duracion_meses'] ?? null,
            $data['salario_base'] ?? null,
            $this->booleanToDatabase($data['auxilio_transporte'] ?? null),
            $data['periodo_pago'] ?? null,
            $data['lugar_labores'] ?? null,
            $data['numero_contrato'] ?? null,
            $data['tipo_cargo_contrato'] ?? null,
            $data['objeto_obra_labor'] ?? null,
            $data['prorroga_dias'] ?? null,
            $data['clausula_funciones'] ?? null,
            $data['jornada_laboral'] ?? null,
            $data['periodo_prueba_dias'] ?? null,
            $data['estado_contrato'] ?? null,
            $data['archivo_contrato_url'] ?? null,
            $data['observaciones'] ?? null,
            $userId,
        ]) ?? [];
    }

    private function booleanToDatabase(mixed $value): ?int
    {
        if ($value === null || $value === '') {
            return null;
        }

        return filter_var($value, FILTER_VALIDATE_BOOLEAN) ? 1 : 0;
    }

    public function getSocialSecurity(int $employeeId): ?array
    {
        return $this->first('SP_BBF_CONTRATACION_SEGURIDAD_SOCIAL_OBTENER', [$employeeId]);
    }

    public function saveSocialSecurity(int $employeeId, array $data): array
    {
        return $this->first('SP_BBF_CONTRATACION_SEGURIDAD_SOCIAL_GUARDAR', [
            $employeeId,
            $data['id_eps'] ?? null,
            $data['id_arl'] ?? null,
            $data['id_fondo_pension'] ?? null,
            $data['id_fondo_cesantias'] ?? null,
            $data['id_caja_compensacion'] ?? null,
            $data['fecha_afiliacion_eps'] ?? null,
            $data['fecha_afiliacion_arl'] ?? null,
            $data['fecha_afiliacion_pension'] ?? null,
            $data['fecha_afiliacion_cesantias'] ?? null,
            $data['fecha_afiliacion_caja'] ?? null,
            $data['observaciones'] ?? null,
        ]) ?? [];
    }

    public function listMedicalExams(int $employeeId): array
    {
        return $this->call('SP_BBF_CONTRATACION_EXAMENES_LISTAR', [$employeeId]);
    }

    public function createMedicalExam(int $employeeId, array $data): array
    {
        return $this->first('SP_BBF_CONTRATACION_EXAMEN_CREAR', [
            $employeeId,
            $data['id_tipo_examen_medico'],
            $data['fecha_examen'],
            $data['entidad_realiza'] ?? null,
            $data['resultado_general'] ?? null,
            $data['fecha_vencimiento'] ?? null,
            $data['archivo_url'] ?? null,
            $data['observaciones'] ?? null,
        ]) ?? [];
    }

    public function listDocuments(int $employeeId): array
    {
        return $this->call('SP_BBF_CONTRATACION_DOCUMENTOS_LISTAR', [$employeeId]);
    }

    public function registerDocument(int $employeeId, int $userId, array $data): array
    {
        return $this->first('SP_BBF_CONTRATACION_DOCUMENTO_REGISTRAR', [
            $employeeId,
            $data['id_tipo_documento_laboral'],
            $data['nombre_archivo'],
            $data['archivo_url'],
            $data['mime_type'] ?? null,
            $data['peso_bytes'] ?? null,
            $data['fecha_vencimiento'] ?? null,
            $data['estado_documento'] ?? null,
            $data['observaciones'] ?? null,
            $userId,
        ]) ?? [];
    }

    public function listAlerts(?int $days): array
    {
        return $this->call('SP_BBF_CONTRATACION_ALERTAS_LISTAR', [$days]);
    }
}
