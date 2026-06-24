<?php

namespace App\Services;

use App\Exceptions\ApiException;
use App\Repositories\EmployeeRepository;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Log;

class EmployeeService
{
    public function __construct(
        private readonly EmployeeRepository $employees,
        private readonly AuditService $audit,
    ) {}

    public function list(?string $status, ?int $areaId, ?int $positionId, ?string $search): array
    {
        return $this->employees->list($status, $areaId, $positionId, $search);
    }

    public function find(int $employeeId): array
    {
        return $this->employees->find($employeeId) ?? throw new ApiException('Empleado no encontrado.', 404);
    }

    public function findByDocument(string $document): array
    {
        return $this->employees->findByDocument($document) ?? throw new ApiException('Empleado no encontrado para el documento indicado.', 404);
    }

    public function create(array $data, int $actorId, array $context): array
    {
        $employeeId = $this->employees->create($data);
        if ($employeeId < 1) {
            throw new ApiException('No fue posible crear el empleado.', 500);
        }

        $employee = $this->find($employeeId);
        $this->audit->record($actorId, 'EMPLEADOS', 'CREAR', 'EMPLEADO', $employeeId, null, $employee, $context);

        return $employee;
    }

    public function update(int $employeeId, array $data, int $actorId, array $context): array
    {
        $before = $this->find($employeeId);
        $this->employees->update($employeeId, $data);
        $after = $this->find($employeeId);
        $this->audit->record($actorId, 'EMPLEADOS', 'ACTUALIZAR', 'EMPLEADO', $employeeId, $before, $after, $context);

        return $after;
    }

    public function uploadPhoto(int $employeeId, UploadedFile $photo): array
    {
        $employee = $this->employees->find($employeeId);
        if (! $employee) {
            throw new ApiException('Empleado no encontrado', 404);
        }

        $directory = public_path('uploads/employees');
        if (! File::isDirectory($directory)) {
            File::makeDirectory($directory, 0755, true);
        }

        $extension = strtolower($photo->getClientOriginalExtension() ?: $photo->extension());
        $filename = sprintf('employee_%d_%s.%s', $employeeId, now()->format('YmdHis'), $extension);
        $photo->move($directory, $filename);

        $photoUrl = '/uploads/employees/'.$filename;

        try {
            $affected = $this->employees->updatePhotoUrl($employeeId, $photoUrl, $employee);
        } catch (\Throwable $exception) {
            $this->deleteUploadedPhoto($photoUrl);
            throw $exception;
        }

        if ($affected < 1) {
            $this->deleteUploadedPhoto($photoUrl);
            throw new ApiException('No fue posible actualizar la foto del empleado.', 422);
        }

        $this->deletePreviousPhoto($employee['foto_url'] ?? null, $photoUrl);

        return [
            'id_empleado' => $employeeId,
            'foto_url' => $photoUrl,
        ];
    }

    public function changeStatus(int $employeeId, string $status, ?string $retirementDate, int $actorId, array $context): array
    {
        $before = $this->find($employeeId);
        $affected = $this->employees->changeStatus($employeeId, $status, $retirementDate);
        if ($affected < 1) {
            throw new ApiException('No fue posible cambiar el estado del empleado.', 422);
        }

        $after = $this->find($employeeId);
        $this->audit->record($actorId, 'EMPLEADOS', 'CAMBIAR_ESTADO', 'EMPLEADO', $employeeId, $before, $after, $context);

        return $after;
    }

    public function deleteLogical(int $employeeId, int $actorId, array $context): array
    {
        $before = $this->find($employeeId);
        $affected = $this->employees->deleteLogical($employeeId);
        if ($affected < 1) {
            throw new ApiException('El empleado no existe o ya fue eliminado.', 404);
        }

        $after = ['id_empleado' => $employeeId, 'eliminado' => true];
        $this->audit->record($actorId, 'EMPLEADOS', 'ELIMINAR', 'EMPLEADO', $employeeId, $before, $after, $context);

        return $after;
    }

    private function deletePreviousPhoto(?string $previousUrl, string $newUrl): void
    {
        if (! $previousUrl || $previousUrl === $newUrl || ! $this->isEmployeeUploadPath($previousUrl)) {
            return;
        }

        $this->deleteUploadedPhoto($previousUrl);
    }

    private function deleteUploadedPhoto(string $photoUrl): void
    {
        if (! $this->isEmployeeUploadPath($photoUrl)) {
            return;
        }

        $path = public_path('uploads/employees/'.basename($photoUrl));
        try {
            if (File::exists($path)) {
                File::delete($path);
            }
        } catch (\Throwable $exception) {
            Log::warning('No fue posible eliminar la foto anterior del empleado.', [
                'path' => $path,
                'error' => $exception->getMessage(),
            ]);
        }
    }

    private function isEmployeeUploadPath(string $photoUrl): bool
    {
        return str_starts_with($photoUrl, '/uploads/employees/')
            || str_starts_with($photoUrl, 'uploads/employees/');
    }
}
