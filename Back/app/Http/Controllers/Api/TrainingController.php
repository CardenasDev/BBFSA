<?php

namespace App\Http\Controllers\Api;

use App\Http\Requests\AttachTrainingTaskRequest;
use App\Http\Requests\CreateTrainingCommitmentRequest;
use App\Http\Requests\CreateTrainingSessionRequest;
use App\Http\Requests\ImportTrainingMatrixRequest;
use App\Http\Requests\SaveTrainingEvaluationRequest;
use App\Http\Requests\SaveTrainingRequest;
use App\Http\Requests\SaveTrainingResultRequest;
use App\Http\Requests\SaveTrainingTaskRequest;
use App\Http\Requests\UpdateTrainingCommitmentRequest;
use App\Services\TrainingService;
use Dedoc\Scramble\Attributes\Group;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

#[Group('Capacitaciones', 'Capacitaciones, evaluaciones semanales, confirmaciones y compromisos.', weight: 8)]
class TrainingController extends ApiController
{
    public function __construct(private readonly TrainingService $training) {}

    /** Listar labores disponibles para evaluacion. */
    public function tasks(Request $request): JsonResponse
    {
        $request->validate(['incluir_inactivas' => ['nullable', 'boolean']]);

        return $this->success($this->training->tasks($request->boolean('incluir_inactivas')), 'Labores consultadas correctamente');
    }

    /** Crear o actualizar una labor. */
    public function saveTask(SaveTrainingTaskRequest $request): JsonResponse
    {
        return $this->success($this->training->saveTask($request->validated(), $this->actorId($request), $this->context($request)), 'Labor guardada correctamente', 201);
    }

    /** Listar las labores configuradas para una capacitacion. */
    public function attachedTasks(Request $request, int $trainingId): JsonResponse
    {
        $request->validate(['incluir_inactivas' => ['nullable', 'boolean']]);

        return $this->success($this->training->attachedTasks($trainingId, $request->boolean('incluir_inactivas')), 'Labores asociadas consultadas correctamente');
    }

    /** Listar el catalogo de capacitaciones. */
    public function index(Request $request): JsonResponse
    {
        $request->validate(['tipo' => ['nullable', 'in:CAPACITACION,INDUCCION,REINDUCCION,EVALUACION_REINDUCCION'], 'incluir_inactivas' => ['nullable', 'boolean']]);

        return $this->success($this->training->trainings($request->input('tipo'), $request->boolean('incluir_inactivas')), 'Capacitaciones consultadas correctamente');
    }

    /** Crear o actualizar una capacitacion y su regla de evaluacion. */
    public function save(SaveTrainingRequest $request): JsonResponse
    {
        return $this->success($this->training->saveTraining($request->validated(), $this->actorId($request), $this->context($request)), 'Capacitacion guardada correctamente', 201);
    }

    /** Asociar una labor a una capacitacion. */
    public function attachTask(AttachTrainingTaskRequest $request): JsonResponse
    {
        return $this->success($this->training->attachTask($request->validated(), $this->actorId($request), $this->context($request)), 'Labor asociada correctamente');
    }

    /** Crear una sesion por periodo; la semana ISO se calcula en base de datos. */
    public function createSession(CreateTrainingSessionRequest $request): JsonResponse
    {
        return $this->success($this->training->createSession($request->validated(), $this->actorId($request), $this->context($request)), 'Sesion creada correctamente', 201);
    }

    /** Listar sesiones por capacitacion, estado o fechas. */
    public function sessions(Request $request): JsonResponse
    {
        $data = $request->validate(['id_capacitacion' => ['nullable', 'integer', 'min:1'], 'anio' => ['nullable', 'integer', 'min:2000', 'max:2100'], 'semana' => ['nullable', 'integer', 'between:1,53'], 'estado' => ['nullable', 'in:BORRADOR,PROGRAMADA,EN_EJECUCION,CERRADA,ANULADA']]);

        return $this->success($this->training->sessions($data), 'Sesiones consultadas correctamente');
    }

    /** Consultar cabecera, participantes y evaluaciones diarias de una sesion. */
    public function session(int $sessionId): JsonResponse
    {
        return $this->success($this->training->session($sessionId), 'Detalle de sesion consultado correctamente');
    }

    /** Cambiar el estado de una sesion. */
    public function changeStatus(Request $request, int $sessionId): JsonResponse
    {
        $data = $request->validate(['estado' => ['required', 'in:BORRADOR,PROGRAMADA,EN_EJECUCION,CERRADA,ANULADA']]);

        return $this->success($this->training->status($sessionId, $data['estado'], $this->actorId($request), $this->context($request)), 'Estado actualizado correctamente');
    }

    /** Asociar un empleado activo a la sesion. */
    public function participant(Request $request, int $sessionId): JsonResponse
    {
        $data = $request->validate(['id_empleado' => ['required', 'integer', 'min:1'], 'observaciones' => ['nullable', 'string']]);

        return $this->success($this->training->participant($sessionId, $data['id_empleado'], $data['observaciones'] ?? null, $this->actorId($request), $this->context($request)), 'Participante asociado correctamente', 201);
    }

    /** Registrar asistencia o novedad del participante. */
    public function attendance(Request $request, int $participantId): JsonResponse
    {
        $data = $request->validate(['estado' => ['required', 'in:PENDIENTE,ASISTIO,NO_ASISTIO,JUSTIFICADO,INCAPACITADO'], 'observaciones' => ['nullable', 'string']]);

        return $this->success($this->training->attendance($participantId, $data['estado'], $data['observaciones'] ?? null, $this->actorId($request), $this->context($request)), 'Asistencia registrada correctamente');
    }

    /** Guardar o reemplazar la evaluacion diaria de una labor. */
    public function evaluation(SaveTrainingEvaluationRequest $request): JsonResponse
    {
        return $this->success($this->training->evaluation($request->validated(), $this->actorId($request), $this->context($request)), 'Evaluacion guardada correctamente');
    }

    /** Consolidar el resultado final con minimo y regla aplicados. */
    public function result(SaveTrainingResultRequest $request): JsonResponse
    {
        return $this->success($this->training->result($request->validated(), $this->actorId($request), $this->context($request)), 'Resultado registrado correctamente');
    }

    /** Confirmar personalmente una capacitacion del empleado autenticado. */
    public function confirm(Request $request, int $participantId): JsonResponse
    {
        $data = $request->validate(['observacion' => ['nullable', 'string', 'max:500']]);

        return $this->success($this->training->confirmEmployee($participantId, $data['observacion'] ?? null, $this->actorId($request), $this->context($request)), 'Capacitacion confirmada correctamente');
    }

    /** Registrar confirmacion presencial por personal autorizado. */
    public function confirmHr(Request $request, int $participantId): JsonResponse
    {
        $data = $request->validate(['observacion' => ['nullable', 'string', 'max:500']]);

        return $this->success($this->training->confirmHr($participantId, $data['observacion'] ?? null, $this->actorId($request), $this->context($request)), 'Confirmacion presencial registrada correctamente');
    }

    /** Consultar capacitaciones y resultados del empleado autenticado. */
    public function mine(Request $request): JsonResponse
    {
        return $this->success($this->training->myRecords($this->actorId($request)), 'Mis capacitaciones consultadas correctamente');
    }

    /** Consultar evaluaciones pendientes y resultados no aprobados. */
    public function alerts(Request $request): JsonResponse
    {
        $data = $request->validate(['id_empleado' => ['nullable', 'integer', 'min:1']]);

        return $this->success($this->training->alerts($data['id_empleado'] ?? null), 'Alertas consultadas correctamente');
    }

    /** Listar cartas y procesos de compromiso. */
    public function commitments(Request $request): JsonResponse
    {
        $data = $request->validate(['id_empleado' => ['nullable', 'integer', 'min:1'], 'estado' => ['nullable', 'in:BORRADOR,PENDIENTE_FIRMA,FIRMADO,CUMPLIDO,INCUMPLIDO,ANULADO']]);

        return $this->success($this->training->commitments($data['id_empleado'] ?? null, $data['estado'] ?? null), 'Compromisos consultados correctamente');
    }

    /** Obtener los datos completos para generar la carta BBTH-F-013. */
    public function commitment(int $commitmentId): JsonResponse
    {
        return $this->success($this->training->commitment($commitmentId), 'Compromiso consultado correctamente');
    }

    /** Crear compromiso desde un resultado no aprobado. */
    public function createCommitment(CreateTrainingCommitmentRequest $request): JsonResponse
    {
        return $this->success($this->training->createCommitment($request->validated(), $this->actorId($request), $this->context($request)), 'Compromiso creado correctamente', 201);
    }

    /** Actualizar estado y referencias del documento de compromiso. */
    public function updateCommitment(UpdateTrainingCommitmentRequest $request, int $commitmentId): JsonResponse
    {
        return $this->success($this->training->updateCommitment($commitmentId, $request->validated(), $this->actorId($request), $this->context($request)), 'Compromiso actualizado correctamente');
    }

    /** Importar la matriz semanal XLSX. Los nombres ambiguos o no encontrados se reportan y no se aplican parcialmente. */
    public function import(ImportTrainingMatrixRequest $request, int $sessionId): JsonResponse
    {
        return $this->success($this->training->importMatrix($sessionId, $request->file('archivo'), $this->actorId($request), $this->context($request)), 'Archivo procesado correctamente');
    }
}
