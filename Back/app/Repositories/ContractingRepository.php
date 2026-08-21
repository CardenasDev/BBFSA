<?php

namespace App\Repositories;

use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\DB;

class ContractingRepository extends StoredProcedureRepository
{
    public function listEmployees(?string $search, ?int $areaId, ?int $positionId, ?string $status): array
    {
        return $this->call('SP_BBF_CONTRATACION_LISTAR_EMPLEADOS', [$search, $areaId, $positionId, $status]);
    }

    public function getProfile(int $employeeId): ?array
    {
        $profile = $this->first('SP_BBF_CONTRATACION_FICHA_OBTENER', [$employeeId]);
        if ($profile) {
            $location = $this->first('SP_BBF_CONTRATACION_LUGAR_EXPEDICION_OBTENER', [$employeeId]);
            $profile['lugar_expedicion_documento'] = $location['lugar_expedicion_documento'] ?? null;
        }
        return $profile;
    }

    public function saveProfile(int $employeeId, array $data): array
    {
        $contact = $data['contacto_emergencia'] ?? [];

        $result = $this->first('SP_BBF_CONTRATACION_FICHA_GUARDAR', [
            $employeeId,
            $data['numero_carpeta'] ?? null,
            $data['genero'] ?? null,
            $data['fecha_expedicion_documento'] ?? null,
            $data['id_departamento_nacimiento'] ?? null,
            $data['id_municipio_nacimiento'] ?? null,
            $data['id_departamento_residencia'] ?? null,
            $data['id_municipio_residencia'] ?? null,
            $data['direccion_residencia'] ?? null,
            $data['telefono_alterno'] ?? null,
            $data['correo_personal'] ?? null,
            $data['estado_civil'] ?? null,
            $data['nivel_educativo'] ?? null,
            $data['personas_a_cargo'] ?? null,
            $data['numero_hijos'] ?? null,
            $data['personas_vivienda'] ?? null,
            $this->booleanToDatabase($data['menores_estudian'] ?? null),
            $data['observaciones'] ?? null,
            $contact['nombre_completo'] ?? null,
            $contact['parentesco'] ?? null,
            $contact['telefono'] ?? null,
            $contact['telefono_alterno'] ?? null,
            $contact['direccion'] ?? null,
            $contact['observaciones'] ?? null,
        ]) ?? [];
        $this->first('SP_BBF_CONTRATACION_LUGAR_EXPEDICION_GUARDAR', [$employeeId, $data['lugar_expedicion_documento'] ?? null]);
        $result['lugar_expedicion_documento'] = $data['lugar_expedicion_documento'] ?? null;
        return $result;
    }

    public function listContractTemplates(array $filters): array
    {
        return array_map(fn (array $row): array => $this->normalizeTemplateJson($row), $this->call('SP_BBF_CONTRATO_PLANTILLAS_LISTAR', [
            $filters['id_tipo_contrato'] ?? null,
            $filters['tipo_cargo_contrato'] ?? null,
            $filters['solo_activas'] ?? 1,
        ]));
    }

    public function getContractTemplate(int $templateId): ?array
    {
        $row = $this->first('SP_BBF_CONTRATO_PLANTILLA_OBTENER', [$templateId]);

        return $row ? $this->normalizeTemplateJson($row) : null;
    }

    public function getContractTemplateByType(int $contractTypeId, ?string $positionType): ?array
    {
        $row = $this->first('SP_BBF_CONTRATO_PLANTILLA_POR_TIPO_OBTENER', [$contractTypeId, $positionType]);

        return $row ? $this->normalizeTemplateJson($row) : null;
    }

    public function getCurrentParameter(string $code, string $date): ?array
    {
        return $this->first('SP_BBF_PARAMETRO_VIGENTE_OBTENER', [$code, $date]);
    }

    public function listContracts(int $employeeId): array
    {
        return array_map(fn (array $row): array => $this->normalizeTemplateJson($row), $this->call('SP_BBF_CONTRATACION_CONTRATOS_LISTAR', [$employeeId]));
    }

    public function contractNumberExists(int $employeeId, string $contractNumber, ?int $excludeContractId = null): bool
    {
        return DB::table('bbf_empleado_contratos')
            ->where('ID_EMPLEADO', $employeeId)
            ->where('NUMERO_CONTRATO', trim($contractNumber))
            ->where('ELIMINADO', 0)
            ->when($excludeContractId, fn ($query) => $query->where('ID_EMPLEADO_CONTRATO', '<>', $excludeContractId))
            ->exists();
    }

    public function findContract(int $employeeId, int $employeeContractId): ?array
    {
        $row = DB::table('bbf_empleado_contratos')->where('ID_EMPLEADO', $employeeId)
            ->where('ID_EMPLEADO_CONTRATO', $employeeContractId)->where('ELIMINADO', 0)->first();

        return $row ? (array) $row : null;
    }

    public function updateContract(int $employeeId, int $employeeContractId, array $data): void
    {
        DB::table('bbf_empleado_contratos')->where('ID_EMPLEADO', $employeeId)
            ->where('ID_EMPLEADO_CONTRATO', $employeeContractId)->where('ELIMINADO', 0)->update([
                'ID_TIPO_CONTRATO' => $data['id_tipo_contrato'] ?? null, 'ID_PLANTILLA_CONTRATO' => $data['id_plantilla_contrato'] ?? null,
                'ID_AREA' => $data['id_area'] ?? null, 'ID_CARGO' => $data['id_cargo'] ?? null,
                'FECHA_INICIO' => $data['fecha_inicio'], 'FECHA_FIN' => $data['fecha_fin'] ?? null,
                'DURACION_MESES' => $data['duracion_meses'] ?? null, 'SALARIO_BASE' => $data['salario_base'] ?? null,
                'AUXILIO_TRANSPORTE' => $this->booleanToDatabase($data['auxilio_transporte'] ?? null),
                'PERIODO_PAGO' => $data['periodo_pago'] ?? null, 'LUGAR_LABORES' => $data['lugar_labores'] ?? null,
                'NUMERO_CONTRATO' => $data['numero_contrato'] ?? null, 'TIPO_CARGO_CONTRATO' => $data['tipo_cargo_contrato'] ?? null,
                'OBJETO_OBRA_LABOR' => $data['objeto_obra_labor'] ?? null, 'PRORROGA_DIAS' => $data['prorroga_dias'] ?? null,
                'CLAUSULA_FUNCIONES' => $data['clausula_funciones'] ?? null, 'JORNADA_LABORAL' => $data['jornada_laboral'] ?? null,
                'PERIODO_PRUEBA_DIAS' => $data['periodo_prueba_dias'] ?? null, 'ESTADO_CONTRATO' => $data['estado_contrato'] ?? 'ACTIVO',
                'ARCHIVO_CONTRATO_URL' => $data['archivo_contrato_url'] ?? null, 'OBSERVACIONES' => $data['observaciones'] ?? null,
                'UPDATED_AT' => now(),
            ]);
    }

    public function createContract(int $employeeId, int $userId, array $data): array
    {
        return $this->first('SP_BBF_CONTRATACION_CONTRATO_CREAR', [
            $employeeId,
            $data['id_tipo_contrato'] ?? null,
            $data['id_plantilla_contrato'] ?? null,
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

    public function signContract(int $employeeContractId, int $userId, array $data): array
    {
        return $this->first('SP_BBF_CONTRATACION_CONTRATO_FIRMADO_REGISTRAR', [
            $employeeContractId,
            $data['fecha_firma'],
            $data['nombre_archivo'],
            $data['nombre_original'] ?? null,
            $data['archivo_url'] ?? null,
            $data['archivo_ruta'] ?? null,
            $data['mime_type'] ?? null,
            $data['peso_bytes'] ?? null,
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

    public function getContractGenerationData(int $employeeContractId): ?array
    {
        $row = $this->first('SP_BBF_CONTRATACION_CONTRATO_DATOS_GENERAR', [$employeeContractId]);

        return $row ? $this->normalizeTemplateJson($row) : null;
    }

    private function normalizeTemplateJson(array $row): array
    {
        $row['config_campos'] = $this->decodeJsonField($row['config_campos_json'] ?? $row['config_campos'] ?? null, 'config_campos');
        $row['valores_default'] = $this->decodeJsonField($row['valores_default_json'] ?? $row['valores_default'] ?? null, 'valores_default');
        unset($row['config_campos_json'], $row['valores_default_json']);

        return $row;
    }

    private function decodeJsonField(mixed $value, string $field): mixed
    {
        if ($value === null || $value === '') {
            return null;
        }

        if (is_array($value) || is_object($value)) {
            return $value;
        }

        if (! is_string($value)) {
            return $value;
        }

        $decoded = json_decode($value, true);
        if (json_last_error() === JSON_ERROR_NONE) {
            return $decoded;
        }

        Log::warning('No fue posible decodificar JSON de plantilla de contrato.', [
            'field' => $field,
            'error' => json_last_error_msg(),
        ]);

        return $value;
    }
}
