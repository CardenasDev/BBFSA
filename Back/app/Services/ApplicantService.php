<?php

namespace App\Services;

use App\Exceptions\ApiException;
use App\Repositories\ApplicantRepository;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Str;
use Throwable;

class ApplicantService
{
    private const APPROVED_FOR_CONTRACTING = 'APROBADO_CONTRATACION';

    public function __construct(
        private readonly ApplicantRepository $applicants,
        private readonly AuditService $audit,
    ) {}

    public function listApplicants(array $filters): array
    {
        return $this->applicants->listApplicants(
            $this->blankToNull($filters['search'] ?? null),
            $this->blankToNull($filters['status'] ?? null),
            $this->nullableInt($filters['area_id'] ?? null),
            $this->nullableInt($filters['position_id'] ?? null),
        );
    }

    public function getApplicant(int $applicantId): array
    {
        return $this->applicants->getApplicant($applicantId)
            ?? throw new ApiException('Aspirante no encontrado.', 404);
    }

    public function createApplicant(array $data, int $userId, array $context): array
    {
        $payload = $this->normalizeData($data);
        $created = $this->applicants->createApplicant($payload, $userId);

        if (! $created) {
            throw new ApiException('No fue posible registrar el aspirante.', 422);
        }

        $this->audit->record($userId, 'ASPIRANTES', 'ASPIRANTE_CREAR', 'ASPIRANTE', $this->rowInt($created, 'id_aspirante'), null, [
            'request' => $payload,
            'result' => $created,
        ], $context);

        return $created;
    }

    public function updateApplicant(int $applicantId, array $data, int $userId, array $context): array
    {
        $payload = $this->normalizeData($data);
        $updated = $this->applicants->updateApplicant($applicantId, $payload);

        if (! $updated) {
            throw new ApiException('No fue posible actualizar el aspirante.', 422);
        }

        $this->audit->record($userId, 'ASPIRANTES', 'ASPIRANTE_ACTUALIZAR', 'ASPIRANTE', $applicantId, null, [
            'request' => $payload,
            'result' => $updated,
        ], $context);

        return $updated;
    }

    public function changeStatus(int $applicantId, array $data, int $userId, array $context): array
    {
        $changed = $this->applicants->changeStatus(
            $applicantId,
            $data['estado_aspirante'],
            $this->blankToNull($data['observaciones'] ?? null),
            $userId,
        );

        if (! $changed) {
            throw new ApiException('No fue posible cambiar el estado del aspirante.', 422);
        }

        $this->audit->record($userId, 'ASPIRANTES', 'ASPIRANTE_CAMBIAR_ESTADO', 'ASPIRANTE', $applicantId, null, [
            'estado_anterior' => $changed['estado_anterior'] ?? null,
            'estado_nuevo' => $changed['estado_nuevo'] ?? $data['estado_aspirante'],
            'result' => $changed,
        ], $context);

        return $changed;
    }

    public function approveForContracting(int $applicantId, ?string $observations, int $userId, array $context): array
    {
        $changed = $this->applicants->changeStatus(
            $applicantId,
            self::APPROVED_FOR_CONTRACTING,
            $this->blankToNull($observations),
            $userId,
        );

        if (! $changed) {
            throw new ApiException('No fue posible aprobar el aspirante para contratacion.', 422);
        }

        $this->audit->record($userId, 'ASPIRANTES', 'ASPIRANTE_APROBAR_CONTRATACION', 'ASPIRANTE', $applicantId, null, [
            'estado_anterior' => $changed['estado_anterior'] ?? null,
            'estado_nuevo' => $changed['estado_nuevo'] ?? self::APPROVED_FOR_CONTRACTING,
            'result' => $changed,
        ], $context);

        return $changed;
    }

    public function listDocuments(int $applicantId): array
    {
        return $this->applicants->listDocuments($applicantId);
    }

    public function registerDocument(int $applicantId, array $data, int $userId, array $context): array
    {
        $payload = $this->buildDocumentPayload($applicantId, $this->normalizeData($data));
        $storedPath = $payload['archivo_ruta'] ?? null;

        try {
            $registered = $this->applicants->registerDocument($applicantId, $payload, $userId);
        } catch (Throwable $exception) {
            $this->deleteApplicantDocument($storedPath);
            throw $exception;
        }

        if (! $registered) {
            $this->deleteApplicantDocument($storedPath);
            throw new ApiException('No fue posible registrar el documento del aspirante.', 422);
        }

        $this->audit->record($userId, 'ASPIRANTES', 'ASPIRANTE_DOCUMENTO_REGISTRAR', 'ASPIRANTE_DOCUMENTO', $this->rowInt($registered, 'id_aspirante_documento'), null, [
            'id_aspirante' => $applicantId,
            'id_tipo_documento_laboral' => $payload['id_tipo_documento_laboral'],
            'estado_documento' => $payload['estado_documento'],
            'archivo_url' => $payload['archivo_url'],
            'archivo_ruta' => $payload['archivo_ruta'],
            'tipo_origen_archivo' => $payload['tipo_origen_archivo'],
            'result' => $registered,
        ], $context);

        return $registered;
    }

    public function listStatusHistory(int $applicantId): array
    {
        return $this->applicants->listStatusHistory($applicantId);
    }

    public function convertToEmployee(int $applicantId, array $data, int $userId, array $context): array
    {
        $payload = $this->normalizeData($data);
        $converted = $this->applicants->convertToEmployee($applicantId, $payload, $userId);

        if (! $converted) {
            throw new ApiException('No fue posible convertir el aspirante en empleado.', 422);
        }

        $this->audit->record($userId, 'ASPIRANTES', 'ASPIRANTE_CONVERTIR_EMPLEADO', 'ASPIRANTE', $applicantId, null, [
            'id_aspirante' => $applicantId,
            'id_empleado' => $converted['id_empleado'] ?? null,
            'estado_aspirante' => $converted['estado_aspirante'] ?? null,
            'estado_ficha' => $converted['estado_ficha'] ?? null,
            'request' => $payload,
            'result' => $converted,
        ], $context);

        return $converted;
    }

    private function normalizeData(array $data): array
    {
        return array_map(function (mixed $value): mixed {
            if (is_array($value)) {
                return $this->normalizeData($value);
            }

            return is_string($value) ? $this->blankToNull($value) : $value;
        }, $data);
    }

    private function blankToNull(?string $value): ?string
    {
        if ($value === null || trim($value) === '') {
            return null;
        }

        return $value;
    }

    private function nullableInt(mixed $value): ?int
    {
        if ($value === null || $value === '') {
            return null;
        }

        return (int) $value;
    }

    private function rowInt(array $row, string $key): ?int
    {
        if (! array_key_exists($key, $row) || $row[$key] === null || $row[$key] === '') {
            return null;
        }

        return (int) $row[$key];
    }

    private function buildDocumentPayload(int $applicantId, array $data): array
    {
        $status = $data['estado_documento'] ?? 'CARGADO';
        $url = $this->blankToNull($data['archivo_url'] ?? null);
        $name = $this->blankToNull($data['nombre_archivo'] ?? null);
        $observations = $this->blankToNull($data['observaciones'] ?? null);

        if ($status === 'PENDIENTE') {
            return [
                'id_tipo_documento_laboral' => $data['id_tipo_documento_laboral'],
                'nombre_archivo' => $name ?? 'Documento pendiente',
                'nombre_original' => null,
                'archivo_url' => null,
                'archivo_ruta' => null,
                'mime_type' => null,
                'peso_bytes' => null,
                'estado_documento' => 'PENDIENTE',
                'observaciones' => $observations,
                'tipo_origen_archivo' => 'SIN_ARCHIVO',
            ];
        }

        $file = $data['archivo'] ?? null;
        if ($file instanceof UploadedFile) {
            $metadata = $this->storeApplicantDocument($applicantId, $file);

            return [
                'id_tipo_documento_laboral' => $data['id_tipo_documento_laboral'],
                'nombre_archivo' => $name ?? $metadata['nombre_original'],
                'nombre_original' => $metadata['nombre_original'],
                'archivo_url' => null,
                'archivo_ruta' => $metadata['archivo_ruta'],
                'mime_type' => $metadata['mime_type'],
                'peso_bytes' => $metadata['peso_bytes'],
                'estado_documento' => $status,
                'observaciones' => $observations,
                'tipo_origen_archivo' => 'FISICO',
            ];
        }

        if ($url !== null) {
            return [
                'id_tipo_documento_laboral' => $data['id_tipo_documento_laboral'],
                'nombre_archivo' => $name ?? 'Documento aspirante',
                'nombre_original' => null,
                'archivo_url' => $url,
                'archivo_ruta' => null,
                'mime_type' => null,
                'peso_bytes' => null,
                'estado_documento' => $status,
                'observaciones' => $observations,
                'tipo_origen_archivo' => 'URL',
            ];
        }

        throw new ApiException('Debe registrar una URL externa o cargar un archivo físico.', 422);
    }

    private function storeApplicantDocument(int $applicantId, UploadedFile $file): array
    {
        $relativeDirectory = "uploads/applicants/{$applicantId}/documents";
        $directory = public_path($relativeDirectory);

        if (! File::isDirectory($directory)) {
            File::makeDirectory($directory, 0755, true);
        }

        $originalName = $file->getClientOriginalName();
        $mimeType = $file->getMimeType();
        $size = $file->getSize();
        $baseName = pathinfo($originalName, PATHINFO_FILENAME);
        $safeName = Str::slug($baseName) ?: 'documento';
        $extension = strtolower($file->getClientOriginalExtension() ?: $file->extension() ?: 'bin');
        $filename = sprintf('%s_%s.%s', now()->format('Ymd_His'), $safeName, $extension);

        $file->move($directory, $filename);

        return [
            'nombre_original' => $originalName,
            'archivo_ruta' => "{$relativeDirectory}/{$filename}",
            'mime_type' => $mimeType,
            'peso_bytes' => $size,
        ];
    }

    private function deleteApplicantDocument(?string $relativePath): void
    {
        if (! $relativePath || ! str_starts_with($relativePath, 'uploads/applicants/')) {
            return;
        }

        $path = public_path($relativePath);

        if (File::exists($path)) {
            File::delete($path);
        }
    }
}
