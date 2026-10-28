<?php

namespace App\Repositories;

use Illuminate\Support\Facades\DB;
use PDO;

class EvaluationRepository extends StoredProcedureRepository
{
    public function labors(bool $includeInactive = false): array
    {
        return DB::table('bbf_evaluacion_labores')
            ->when(! $includeInactive, static fn ($query) => $query->where('ACTIVO', 1))
            ->orderBy('ORDEN')
            ->orderBy('NOMBRE')
            ->get()
            ->map(static fn ($row) => array_change_key_case((array) $row, CASE_LOWER))
            ->all();
    }

    public function evaluations(array $filters = []): array
    {
        $query = DB::table('bbf_evaluaciones')->where('ELIMINADO', 0);

        if (! empty($filters['anio'])) {
            $query->where('ANIO', (int) $filters['anio']);
        }
        if (! empty($filters['numero_semana'])) {
            $query->where('NUMERO_SEMANA', (int) $filters['numero_semana']);
        }
        if (! empty($filters['estado'])) {
            $query->where('ESTADO', strtoupper((string) $filters['estado']));
        }

        return $query
            ->orderByDesc('FECHA_INICIO')
            ->orderByDesc('ID_EVALUACION')
            ->get()
            ->map(static fn ($row) => array_change_key_case((array) $row, CASE_LOWER))
            ->all();
    }

    public function find(int $id): ?array
    {
        $row = DB::table('bbf_evaluaciones')
            ->where('ID_EVALUACION', $id)
            ->where('ELIMINADO', 0)
            ->first();

        return $row ? array_change_key_case((array) $row, CASE_LOWER) : null;
    }

    public function create(array $data, int $actorId): ?array
    {
        return $this->first('SP_BBF_EVALUACION_CREAR', [
            $data['numero_semana'] ?? null,
            $data['nombre_semana'] ?? null,
            $data['anio'] ?? null,
            $data['fecha_inicio'] ?? null,
            $data['fecha_fin'] ?? null,
            $data['observaciones'] ?? null,
            $actorId,
        ]);
    }

    public function ensureDefaultMetas(int $evaluationId, int $actorId, float $defaultMeta = 1168.0): void
    {
        DB::statement(
            'INSERT IGNORE INTO `bbf_evaluacion_metas_finca` (`ID_EVALUACION`, `ID_EVALUACION_LABOR`, `META_CAMAS`, `ID_REGISTRADO_POR`) SELECT ?, `ID_EVALUACION_LABOR`, ?, ? FROM `bbf_evaluacion_labores` WHERE `ACTIVO` = 1',
            [$evaluationId, $defaultMeta, $actorId]
        );
    }

    public function employees(int $evaluationId): array
    {
        $employees = DB::table('bbf_evaluacion_empleados as ee')
            ->join('bbf_empleados as e', 'e.ID_EMPLEADO', '=', 'ee.ID_EMPLEADO')
            ->where('ee.ID_EVALUACION', $evaluationId)
            ->select('ee.*', 'e.NUMERO_DOCUMENTO', 'e.NOMBRES', 'e.APELLIDOS', 'e.ESTADO_EMPLEADO')
            ->orderBy('e.NOMBRES')
            ->orderBy('e.APELLIDOS')
            ->get()
            ->map(static fn ($row) => array_change_key_case((array) $row, CASE_LOWER))
            ->all();

        $details = DB::table('bbf_evaluacion_detalles as d')
            ->join('bbf_evaluacion_empleados as ee', 'ee.ID_EVALUACION_EMPLEADO', '=', 'd.ID_EVALUACION_EMPLEADO')
            ->join('bbf_evaluacion_labores as l', 'l.ID_EVALUACION_LABOR', '=', 'd.ID_EVALUACION_LABOR')
            ->where('ee.ID_EVALUACION', $evaluationId)
            ->select('ee.ID_EMPLEADO', 'd.ID_EVALUACION_LABOR', 'd.VALOR_OBTENIDO', 'd.VALOR_MAXIMO', 'd.OBSERVACIONES', 'l.CODIGO', 'l.NOMBRE')
            ->get()
            ->map(static fn ($row) => array_change_key_case((array) $row, CASE_LOWER))
            ->all();

        $byEmployee = [];
        foreach ($details as $detail) {
            $byEmployee[$detail['id_empleado']][] = $detail;
        }

        foreach ($employees as &$employee) {
            $employeeDetails = $byEmployee[$employee['id_empleado']] ?? [];
            $employee['detalles'] = $employeeDetails;
            $employee['total_semana'] = array_sum(array_column($employeeDetails, 'valor_obtenido'));
        }
        unset($employee);

        return $employees;
    }

    public function addEmployee(int $evaluationId, int $employeeId, ?string $observations, int $actorId): ?array
    {
        return $this->first('SP_BBF_EVALUACION_EMPLEADO_AGREGAR', [
            $evaluationId,
            $employeeId,
            $observations,
            $actorId,
        ]);
    }

    public function addAllActiveEmployees(int $evaluationId, int $actorId): array
    {
        $rows = DB::select(
            'CALL SP_BBF_EVALUACION_AGREGAR_EMPLEADOS_TODOS(?, ?, @p_insertados, @p_omitidos_duplicados, @p_mensaje)',
            [$evaluationId, $actorId]
        );

        $outRows = DB::select('SELECT @p_insertados AS insertados, @p_omitidos_duplicados AS omitidos_duplicados, @p_mensaje AS mensaje');
        $out = (array) ($outRows[0] ?? (object) []);

        return [
            'insertados' => (int) ($out['insertados'] ?? 0),
            'omitidos_duplicados' => (int) ($out['omitidos_duplicados'] ?? 0),
            'mensaje' => (string) ($out['mensaje'] ?? ''),
            'empleados' => array_map(static fn ($row) => array_change_key_case((array) $row, CASE_LOWER), $rows),
        ];
    }

    public function removeEmployee(int $evaluationId, int $employeeId): int
    {
        return DB::table('bbf_evaluacion_empleados')
            ->where('ID_EVALUACION', $evaluationId)
            ->where('ID_EMPLEADO', $employeeId)
            ->delete();
    }

    public function saveScores(int $evaluationId, array $scores, int $actorId): array
    {
        $saved = [];

        foreach ($scores as $score) {
            $row = $this->first('SP_BBF_EVALUACION_REGISTRAR_CALIFICACIONES', [
                $evaluationId,
                $score['id_empleado'],
                $score['id_evaluacion_labor'],
                $score['valor_obtenido'],
                $score['valor_maximo'] ?? null,
                $score['observaciones'] ?? null,
                $actorId,
            ]);

            if ($row) {
                $saved[] = $row;
            }
        }

        return $saved;
    }

    public function managementPanel(int $evaluationId): array
    {
        $statement = DB::connection()->getPdo()->prepare('CALL SP_BBF_EVALUACION_PANEL_GERENCIAL_OBTENER(?)');
        $statement->execute([$evaluationId]);

        $sets = [];
        try {
            do {
                if ($statement->columnCount() > 0) {
                    $sets[] = array_map(
                        static fn (array $row) => array_change_key_case($row, CASE_LOWER),
                        $statement->fetchAll(PDO::FETCH_ASSOC)
                    );
                }
            } while ($statement->nextRowset());
        } finally {
            $statement->closeCursor();
        }

        $labores = array_map(static function (array $row): array {
            foreach (['camas_ejecutadas', 'meta_camas', 'porcentaje_avance', 'camas_pendientes', 'ponderacion_maxima'] as $key) {
                if (array_key_exists($key, $row) && $row[$key] !== null) {
                    $row[$key] = (float) $row[$key];
                }
            }

            return $row;
        }, $sets[0] ?? []);

        $resumen = $sets[1][0] ?? null;
        if (is_array($resumen)) {
            $resumen = array_change_key_case($resumen, CASE_LOWER);
            foreach (['total_camas_ejecutadas', 'total_meta_camas', 'porcentaje_cobertura_global'] as $key) {
                if (array_key_exists($key, $resumen) && $resumen[$key] !== null) {
                    $resumen[$key] = (float) $resumen[$key];
                }
            }
        }

        return [
            'labores' => $labores,
            'resumen' => $resumen,
        ];
    }
}
