<?php

namespace App\Http\Controllers\Api;

use App\Http\Requests\AddEvaluationEmployeeRequest;
use App\Http\Requests\SaveEvaluationScoresRequest;
use App\Http\Requests\StoreEvaluationRequest;
use App\Services\EvaluationService;
use Dedoc\Scramble\Attributes\Group;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

#[Group('Evaluaciones', 'Evaluaciones semanales de labores agrícolas, asignación de empleados y panel gerencial.', weight: 9)]
class EvaluationController extends ApiController
{
    public function __construct(private readonly EvaluationService $evaluation) {}

    /** Listar evaluaciones semanales. */
    public function index(Request $request): JsonResponse
    {
        $filters = $request->validate([
            'anio' => ['nullable', 'integer', 'min:2000', 'max:2100'],
            'numero_semana' => ['nullable', 'integer', 'between:1,53'],
            'estado' => ['nullable', 'in:BORRADOR,EN_PROCESO,COMPLETADA,CERRADA'],
        ]);

        return $this->success($this->evaluation->evaluations($filters), 'Evaluaciones consultadas correctamente');
    }

    /** Crear una evaluación semanal. */
    public function store(StoreEvaluationRequest $request): JsonResponse
    {
        return $this->success(
            $this->evaluation->create($request->validated(), $this->actorId($request), $this->context($request)),
            'Evaluación creada correctamente',
            201
        );
    }

    /** Obtener el detalle de una evaluación y sus empleados. */
    public function show(int $id): JsonResponse
    {
        return $this->success($this->evaluation->show($id), 'Evaluación consultada correctamente');
    }

    /** Agregar un empleado individual a la evaluación. */
    public function addEmployee(AddEvaluationEmployeeRequest $request, int $id): JsonResponse
    {
        $data = $request->validated();

        return $this->success(
            $this->evaluation->addEmployee($id, (int) $data['id_empleado'], $data['observaciones'] ?? null, $this->actorId($request), $this->context($request)),
            'Empleado agregado correctamente',
            201
        );
    }

    /** Agregar todos los empleados activos a la evaluación. */
    public function addAllActiveEmployees(Request $request, int $id): JsonResponse
    {
        return $this->success(
            $this->evaluation->addAllActiveEmployees($id, $this->actorId($request), $this->context($request)),
            'Empleados activos procesados correctamente'
        );
    }

    /** Quitar un empleado de la evaluación. */
    public function removeEmployee(Request $request, int $evaluationId, int $employeeId): JsonResponse
    {
        return $this->success(
            $this->evaluation->removeEmployee($evaluationId, $employeeId, $this->actorId($request), $this->context($request)),
            'Empleado retirado correctamente'
        );
    }

    /** Registrar o actualizar calificaciones individuales o en lote. */
    public function saveScores(SaveEvaluationScoresRequest $request, int $id): JsonResponse
    {
        return $this->success(
            $this->evaluation->saveScores($id, $request->validated('calificaciones'), $this->actorId($request), $this->context($request)),
            'Calificaciones registradas correctamente'
        );
    }

    /** Obtener el panel gerencial de labores agrícolas. */
    public function managementPanel(int $id): JsonResponse
    {
        return $this->success($this->evaluation->managementPanel($id), 'Panel gerencial consultado correctamente');
    }

    /** Obtener el catálogo de labores agrícolas parametrizadas. */
    public function labors(Request $request): JsonResponse
    {
        $request->validate(['incluir_inactivas' => ['nullable', 'boolean']]);

        return $this->success(
            $this->evaluation->labors($request->boolean('incluir_inactivas')),
            'Labores consultadas correctamente'
        );
    }
}
