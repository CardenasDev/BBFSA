<?php

namespace App\Services;

use App\Exceptions\ApiException;
use App\Repositories\EvaluationRepository;
use Illuminate\Support\Facades\DB;
use Throwable;

class EvaluationService
{
    public function __construct(
        private readonly EvaluationRepository $repository,
        private readonly AuditService $audit,
    ) {}

    public function labors(bool $includeInactive = false): array
    {
        return $this->repository->labors($includeInactive);
    }

    public function evaluations(array $filters = []): array
    {
        return $this->repository->evaluations($filters);
    }

    public function create(array $data, int $actor, array $context): array
    {
        $row = $this->repository->create($data, $actor);
        if (! $row) {
            throw new ApiException('No fue posible crear la evaluación.', 422);
        }

        $this->repository->ensureDefaultMetas((int) ($row['id_evaluacion'] ?? 0), $actor);

        $this->audit->record($actor, 'EVALUACIONES', 'CREAR', 'EVALUACION', $row['id_evaluacion'] ?? null, null, $row, $context);

        return $row;
    }

    public function show(int $id): array
    {
        $evaluation = $this->repository->find($id);
        if (! $evaluation) {
            throw new ApiException('La evaluación no existe.', 404);
        }

        return [
            'evaluation' => $evaluation,
            'employees' => $this->repository->employees($id),
        ];
    }

    public function addEmployee(int $evaluationId, int $employeeId, ?string $observations, int $actor, array $context): array
    {
        $row = $this->repository->addEmployee($evaluationId, $employeeId, $observations, $actor);
        if (! $row) {
            throw new ApiException('No fue posible agregar el empleado.', 422);
        }

        $this->audit->record($actor, 'EVALUACIONES', 'AGREGAR_EMPLEADO', 'EVALUACION', $evaluationId, null, $row, $context);

        return $row;
    }

    public function addAllActiveEmployees(int $evaluationId, int $actor, array $context): array
    {
        $result = DB::transaction(fn () => $this->repository->addAllActiveEmployees($evaluationId, $actor));

        $this->audit->record($actor, 'EVALUACIONES', 'AGREGAR_EMPLEADOS_TODOS', 'EVALUACION', $evaluationId, null, $result, $context);

        return $result;
    }

    public function removeEmployee(int $evaluationId, int $employeeId, int $actor, array $context): array
    {
        $deleted = $this->repository->removeEmployee($evaluationId, $employeeId);
        if ($deleted < 1) {
            throw new ApiException('No fue posible quitar el empleado de la evaluación.', 422);
        }

        $this->audit->record($actor, 'EVALUACIONES', 'QUITAR_EMPLEADO', 'EVALUACION', $evaluationId, null, ['id_empleado' => $employeeId], $context);

        return ['deleted' => $deleted];
    }

    public function saveScores(int $evaluationId, array $scores, int $actor, array $context): array
    {
        $saved = DB::transaction(fn () => $this->repository->saveScores($evaluationId, $scores, $actor));

        $this->audit->record($actor, 'EVALUACIONES', 'REGISTRAR_CALIFICACIONES', 'EVALUACION', $evaluationId, null, $saved, $context);

        return ['scores' => $saved];
    }

    public function managementPanel(int $evaluationId): array
    {
        $evaluation = $this->repository->find($evaluationId);
        if (! $evaluation) {
            throw new ApiException('La evaluación no existe.', 404);
        }

        $panel = $this->repository->managementPanel($evaluationId);

        return [
            'evaluation' => $evaluation,
            'labores' => $panel['labores'],
            'resumen' => $panel['resumen'],
        ];
    }
}
