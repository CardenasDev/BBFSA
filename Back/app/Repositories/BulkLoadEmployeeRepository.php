<?php

namespace App\Repositories;

use Illuminate\Support\Facades\DB;

class BulkLoadEmployeeRepository extends StoredProcedureRepository
{
    public function catalogs(): array
    {
        return [
            'document_types' => $this->active('bbf_tipos_documento', 'ID_TIPO_DOCUMENTO', 'NOMBRE'),
            'areas' => $this->active('bbf_areas', 'ID_AREA', 'NOMBRE'),
            'positions' => $this->active('bbf_cargos', 'ID_CARGO', 'NOMBRE'),
            'contract_types' => $this->active('bbf_tipos_contrato', 'ID_TIPO_CONTRATO', 'NOMBRE'),
            'social_security' => DB::table('bbf_entidades_seguridad_social')
                ->where('ACTIVO', 1)->orderBy('TIPO_ENTIDAD')->orderBy('NOMBRE')
                ->get(['ID_ENTIDAD_SEGURIDAD_SOCIAL as id', 'NOMBRE as name', 'TIPO_ENTIDAD as type'])
                ->map(fn ($row) => (array) $row)->all(),
            'dotation_sizes' => DB::table('bbf_tallas_dotacion as s')
                ->join('bbf_tipos_dotacion as t', 't.ID_TIPO_DOTACION', '=', 's.ID_TIPO_DOTACION')
                ->where('s.ACTIVO', 1)->where('t.ACTIVO', 1)
                ->whereIn('t.NOMBRE', ['Camisa', 'Pantalón', 'Calzado', 'Overol'])
                ->orderBy('t.NOMBRE')->orderBy('s.ORDEN')
                ->get(['s.ID_TALLA_DOTACION as id', 's.ID_TIPO_DOTACION as type_id', 't.NOMBRE as type', 's.TALLA as name'])
                ->map(fn ($row) => (array) $row)->all(),
        ];
    }

    public function existingDocuments(array $documents): array
    {
        if ($documents === []) {
            return [];
        }

        return DB::table('bbf_empleados')
            ->whereIn('NUMERO_DOCUMENTO', $documents)
            ->pluck('NUMERO_DOCUMENTO')->map(fn ($value) => (string) $value)->all();
    }

    public function createEmployee(array $data): int
    {
        $row = $this->first('SP_BBF_EMPLEADOS_CREAR', [
            $data['id_tipo_documento'], $data['numero_documento'], $data['nombres'], $data['apellidos'],
            $data['correo'], $data['telefono'], null, $data['id_area'], $data['id_cargo'],
            $data['id_tipo_contrato'], $data['fecha_ingreso'], null,
            $data['estado_empleado'] ?? 'ACTIVO', $data['observaciones_empleado'],
        ]);

        return (int) ($row['id_empleado'] ?? 0);
    }

    public function saveProfile(int $employeeId, array $data): void
    {
        DB::table('bbf_empleado_ficha_ingreso')->insert([
            'ID_EMPLEADO' => $employeeId,
            'NUMERO_CARPETA' => $data['numero_carpeta'],
            'GENERO' => $data['genero'],
            'FECHA_EXPEDICION_DOCUMENTO' => $data['fecha_expedicion_documento'],
            'FECHA_NACIMIENTO' => $data['fecha_nacimiento'],
            'DIRECCION_RESIDENCIA' => $data['direccion_residencia'],
            'TELEFONO_ALTERNO' => null,
            'CORREO_PERSONAL' => null,
            'ESTADO_CIVIL' => null,
            'NIVEL_EDUCATIVO' => null,
            'PERSONAS_A_CARGO' => null,
            'NUMERO_HIJOS' => null,
            'PERSONAS_VIVIENDA' => $data['personas_vivienda'],
            'MENORES_ESTUDIAN' => $data['menores_estudian'],
            'ESTADO_FICHA' => 'INCOMPLETA',
            'OBSERVACIONES' => null,
        ]);
    }

    public function saveSocialSecurity(int $employeeId, array $data): void
    {
        DB::table('bbf_empleado_seguridad_social')->insert([
            'ID_EMPLEADO' => $employeeId,
            'ID_EPS' => $data['id_eps'], 'ID_ARL' => $data['id_arl'],
            'ID_FONDO_PENSION' => $data['id_pension'], 'ID_FONDO_CESANTIAS' => $data['id_cesantias'],
            'ID_CAJA_COMPENSACION' => $data['id_caja'],
            'FECHA_AFILIACION_EPS' => null,
            'FECHA_AFILIACION_ARL' => null,
            'FECHA_AFILIACION_PENSION' => null,
            'FECHA_AFILIACION_CESANTIAS' => null,
            'FECHA_AFILIACION_CAJA' => null,
            'OBSERVACIONES' => null,
        ]);
    }

    public function saveSize(int $employeeId, int $typeId, int $sizeId, int $actorId): void
    {
        DB::table('bbf_empleado_dotacion_tallas')->insert([
            'ID_EMPLEADO' => $employeeId, 'ID_TIPO_DOTACION' => $typeId,
            'ID_TALLA_DOTACION' => $sizeId, 'ACTUALIZADO_POR_USUARIO' => $actorId ?: null,
        ]);
    }

    private function active(string $table, string $id, string $name): array
    {
        return DB::table($table)->where('ACTIVO', 1)->orderBy($name)
            ->get(["{$id} as id", "{$name} as name"])->map(fn ($row) => (array) $row)->all();
    }
}
