<?php

namespace App\Repositories;

use Illuminate\Support\Facades\DB;
use PDO;

class TrainingRepository extends StoredProcedureRepository
{
    public function tasks(bool $includeInactive): array
    {
        return $this->call('SP_BBF_CAPACITACION_LABORES_LISTAR', [$includeInactive ? 1 : 0]);
    }

    public function attachedTasks(int $trainingId, bool $includeInactive): array
    {
        return $this->call('SP_BBF_CAPACITACION_LABORES_ASOCIADAS_LISTAR', [$trainingId, $includeInactive ? 1 : 0]);
    }

    public function saveTask(array $data): ?array
    {
        return $this->first('SP_BBF_CAPACITACION_LABOR_GUARDAR', [$data['id_capacitacion_labor'] ?? null, $data['codigo'], $data['nombre'], $data['descripcion'] ?? null, $data['orden'] ?? 0, ($data['activo'] ?? true) ? 1 : 0]);
    }

    public function trainings(?string $type, bool $includeInactive): array
    {
        return $this->call('SP_BBF_CAPACITACIONES_LISTAR', [$type, $includeInactive ? 1 : 0]);
    }

    public function saveTraining(array $data, int $actorId): ?array
    {
        return $this->first('SP_BBF_CAPACITACION_GUARDAR', [$data['id_capacitacion'] ?? null, $data['codigo'], $data['nombre'], $data['descripcion'] ?? null, $data['tipo'], ($data['requiere_evaluacion'] ?? true) ? 1 : 0, ($data['requiere_confirmacion'] ?? true) ? 1 : 0, $data['puntaje_minimo'] ?? null, $data['puntaje_maximo'] ?? null, $data['regla_calculo'] ?? null, ($data['generar_compromiso_no_aprobado'] ?? false) ? 1 : 0, $data['dias_para_evaluar'] ?? null, ($data['activo'] ?? true) ? 1 : 0, $actorId]);
    }

    public function attachTask(array $data): ?array
    {
        return $this->first('SP_BBF_CAPACITACION_LABOR_ASOCIAR', [$data['id_capacitacion'], $data['id_capacitacion_labor'], $data['puntaje_minimo_labor'] ?? null, $data['puntaje_maximo_labor'] ?? null, $data['orden'] ?? 0]);
    }

    public function createSession(array $data, int $actorId): ?array
    {
        return $this->first('SP_BBF_CAPACITACION_SESION_CREAR', [$data['id_capacitacion'], $data['fecha_inicio'], $data['fecha_fin'], $data['id_instructor_usuario'] ?? null, $data['instructor_externo'] ?? null, $data['lugar'] ?? null, $data['observaciones'] ?? null, $actorId]);
    }

    public function sessions(array $filters): array
    {
        return $this->call('SP_BBF_CAPACITACION_SESIONES_LISTAR', [$filters['id_capacitacion'] ?? null, $filters['anio'] ?? null, $filters['semana'] ?? null, $filters['estado'] ?? null]);
    }

    public function changeSessionStatus(int $id, string $status, int $actorId): ?array
    {
        return $this->first('SP_BBF_CAPACITACION_SESION_CAMBIAR_ESTADO', [$id, $status, $actorId]);
    }

    public function sessionDetail(int $id): array
    {
        return $this->multi('SP_BBF_CAPACITACION_SESION_DETALLE', [$id]);
    }

    public function addParticipant(int $sessionId, int $employeeId, ?string $observations, int $actorId): ?array
    {
        return $this->first('SP_BBF_CAPACITACION_PARTICIPANTE_AGREGAR', [$sessionId, $employeeId, $observations, $actorId]);
    }

    public function attendance(int $participantId, string $status, ?string $observations): ?array
    {
        return $this->first('SP_BBF_CAPACITACION_ASISTENCIA_REGISTRAR', [$participantId, $status, $observations]);
    }

    public function evaluation(array $data, int $actorId, string $origin = 'MANUAL', ?int $importId = null): ?array
    {
        return $this->first('SP_BBF_CAPACITACION_EVALUACION_GUARDAR', [$data['id_capacitacion_participante'], $data['id_capacitacion_labor'], $data['fecha_evaluacion'], $data['valor_obtenido'], $data['valor_maximo'] ?? null, ($data['requiere_atencion'] ?? false) ? 1 : 0, $data['observaciones'] ?? null, $actorId, $origin, $importId]);
    }

    public function result(array $data, int $actorId): ?array
    {
        return $this->first('SP_BBF_CAPACITACION_RESULTADO_REGISTRAR', [$data['id_capacitacion_participante'], $data['fecha_resultado'] ?? null, $data['puntaje_final'] ?? null, $data['puntaje_minimo'] ?? null, $data['resultado'] ?? null, array_key_exists('requiere_reinduccion', $data) ? (int) $data['requiere_reinduccion'] : null, array_key_exists('requiere_compromiso', $data) ? (int) $data['requiere_compromiso'] : null, $data['regla_aplicada'] ?? null, $data['observaciones'] ?? null, $actorId]);
    }

    public function confirmEmployee(int $actorId, int $participantId, ?string $observation): ?array
    {
        return $this->first('SP_BBF_CAPACITACION_CONFIRMAR_EMPLEADO', [$actorId, $participantId, $observation]);
    }

    public function confirmHr(int $actorId, int $participantId, ?string $observation): ?array
    {
        return $this->first('SP_BBF_CAPACITACION_CONFIRMAR_RRHH', [$actorId, $participantId, $observation]);
    }

    public function myRecords(int $actorId): array
    {
        return $this->call('SP_BBF_CAPACITACION_MIS_REGISTROS_LISTAR', [$actorId]);
    }

    public function alerts(?int $employeeId): array
    {
        return $this->call('SP_BBF_CAPACITACION_ALERTAS_LISTAR', [$employeeId]);
    }

    public function commitments(?int $employeeId, ?string $status): array
    {
        return $this->call('SP_BBF_CAPACITACION_COMPROMISOS_LISTAR', [$employeeId, $status]);
    }

    public function commitment(int $id): ?array
    {
        return $this->first('SP_BBF_CAPACITACION_COMPROMISO_OBTENER', [$id]);
    }

    public function createCommitment(array $data, int $actorId): ?array
    {
        return $this->first('SP_BBF_CAPACITACION_COMPROMISO_CREAR', [$data['id_capacitacion_resultado'], $data['fecha_compromiso'] ?? null, $data['fecha_limite'] ?? null, $data['motivo'], $data['compromisos_empleado'] ?? null, $data['observaciones'] ?? null, $actorId]);
    }

    public function updateCommitment(int $id, array $data, int $actorId): ?array
    {
        return $this->first('SP_BBF_CAPACITACION_COMPROMISO_ACTUALIZAR', [$id, $data['estado'], $data['documento_url'] ?? null, $data['documento_ruta'] ?? null, $data['firma_url'] ?? null, $data['observaciones'] ?? null, $actorId]);
    }

    public function sessionEvidences(int $sessionId): array
    {
        try {
            return $this->call('SP_BBF_CAPACITACION_EVIDENCIAS_LISTAR', [$sessionId]);
        } catch (\Throwable $exception) {
            if (! str_contains($exception->getMessage(), '1305') && ! str_contains($exception->getMessage(), 'does not exist')) {
                throw $exception;
            }

            return DB::table('bbf_capacitacion_evidencias')
                ->where('ID_CAPACITACION_SESION', $sessionId)
                ->orderByDesc('CREATED_AT')
                ->orderByDesc('ID_CAPACITACION_EVIDENCIA')
                ->get()
                ->map(fn ($row): array => (array) $row)
                ->all();
        }
    }

    public function evidence(int $sessionId, int $evidenceId): ?array
    {
        try {
            return $this->first('SP_BBF_CAPACITACION_EVIDENCIA_OBTENER', [$sessionId, $evidenceId]);
        } catch (\Throwable $exception) {
            if (! str_contains($exception->getMessage(), '1305') && ! str_contains($exception->getMessage(), 'does not exist')) {
                throw $exception;
            }

            return DB::table('bbf_capacitacion_evidencias')
                ->where('ID_CAPACITACION_SESION', $sessionId)
                ->where('ID_CAPACITACION_EVIDENCIA', $evidenceId)
                ->first();
        }
    }

    public function createEvidence(int $sessionId, array $data, int $actorId): ?array
    {
        return $this->first('SP_BBF_CAPACITACION_EVIDENCIA_CREAR', [
            $sessionId,
            $data['tipo_evidencia'] ?? 'OTRA',
            $data['nombre_archivo'],
            $data['nombre_original'] ?? null,
            $data['archivo_url'] ?? null,
            $data['archivo_ruta'] ?? null,
            $data['mime_type'] ?? null,
            $data['peso_bytes'] ?? null,
            $actorId,
        ]);
    }

    public function deleteEvidence(int $sessionId, int $evidenceId): ?array
    {
        return $this->first('SP_BBF_CAPACITACION_EVIDENCIA_ELIMINAR', [$sessionId, $evidenceId]);
    }

    public function createImport(int $sessionId, array $file, int $actorId): ?array
    {
        return $this->first('SP_BBF_CAPACITACION_IMPORTACION_CREAR', [$sessionId, $file['nombre_archivo'], $file['nombre_original'], $file['ruta'], $file['mime'], $file['peso'], $actorId]);
    }

    public function addImportError(int $id, array $error): void
    {
        $this->call('SP_BBF_CAPACITACION_IMPORTACION_ERROR_AGREGAR', [$id, $error['hoja'] ?? null, $error['celda'] ?? null, $error['fila'] ?? null, $error['empleado'] ?? null, $error['labor'] ?? null, $error['valor'] ?? null, $error['codigo'], $error['mensaje']]);
    }

    public function finishImport(int $id, string $status, int $total, int $valid, string $summary): ?array
    {
        return $this->first('SP_BBF_CAPACITACION_IMPORTACION_FINALIZAR', [$id, $status, $total, $valid, $summary]);
    }

    private function multi(string $procedure, array $parameters): array
    {
        $statement = DB::connection()->getPdo()->prepare('CALL '.$procedure.'('.implode(',', array_fill(0, count($parameters), '?')).')');
        $statement->execute($parameters);
        $sets = [];
        try {
            do {
                if ($statement->columnCount() > 0) {
                    $sets[] = array_map(static fn (array $row): array => array_change_key_case($row, CASE_LOWER), $statement->fetchAll(PDO::FETCH_ASSOC));
                }
            } while ($statement->nextRowset());
        } finally {
            $statement->closeCursor();
        }

        return ['session' => $sets[0][0] ?? null, 'participants' => $sets[1] ?? [], 'evaluations' => $sets[2] ?? []];
    }
}
