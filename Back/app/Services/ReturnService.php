<?php

namespace App\Services;

use App\Exceptions\ApiException;
use App\Repositories\ReturnRepository;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;
use Throwable;

class ReturnService
{
    public function __construct(
        private readonly ReturnRepository $returns,
        private readonly AuditService $audit,
    ) {}

    public function available(string $type, int $employeeId): array
    {
        $rows = array_values(array_filter(
            $this->returns->available($type, $employeeId),
            static fn (array $row): bool => (int) ($row['cantidad_disponible'] ?? 0) > 0,
        ));
        $deliveries = [];
        foreach ($rows as $row) {
            $deliveryId = (int) $row['id_entrega'];
            if (! isset($deliveries[$deliveryId])) {
                $deliveries[$deliveryId] = [
                    'tipo_devolucion' => $row['tipo_devolucion'] ?? $type,
                    'id_entrega' => $deliveryId,
                    'id_empleado' => (int) $row['id_empleado'],
                    'fecha_entrega' => $row['fecha_entrega'],
                    'items' => [],
                ];
            }
            $deliveries[$deliveryId]['items'][] = $row;
        }

        return array_values($deliveries);
    }

    public function create(array $data, int $actorId, array $context): array
    {
        $files = $data['evidence'];
        $storedPaths = [];
        $evidence = [];

        try {
            foreach ($files as $file) {
                $metadata = $this->validateAndStore($file);
                $storedPaths[] = $metadata['archivo_ruta'];
                $evidence[] = $metadata;
            }
            if ($data['type'] === 'HERRAMIENTA'
                && ! collect($evidence)->contains(fn (array $item): bool => $item['tipo_evidencia'] === 'FOTO')) {
                throw new ApiException('Las devoluciones de herramientas requieren al menos una fotografía válida.', 422);
            }

            $created = $this->returns->create($data, $actorId, $data['details'], $evidence);
            if (! $created) {
                throw new ApiException('No fue posible registrar la devolución.', 500);
            }
        } catch (Throwable $exception) {
            $this->deleteStored($storedPaths);
            Log::error('Falló el registro de una devolución; se compensaron sus archivos.', [
                'tipo_devolucion' => $data['type'],
                'id_entrega' => $data['delivery_id'],
                'exception' => $exception->getMessage(),
            ]);
            throw $exception;
        }

        $result = [
            'id_devolucion' => (int) ($created['id_devolucion'] ?? 0),
            'estado' => strtoupper((string) ($created['estado'] ?? 'REGISTRADA')),
        ];
        $this->audit->record($actorId, 'DEVOLUCIONES', 'DEVOLUCION_CREAR', 'DEVOLUCION', $result['id_devolucion'], null, [
            'tipo_devolucion' => $data['type'],
            'id_devolucion' => $result['id_devolucion'],
        ], $context);

        return $result;
    }

    public function confirm(int $returnId, int $actorId, array $context): array
    {
        $current = $this->get($returnId);
        $row = $this->returns->confirm($returnId, $actorId);
        if (! $row) {
            throw new ApiException('No fue posible confirmar la devolución.', 422);
        }
        $result = ['id_devolucion' => $returnId, 'estado' => strtoupper((string) ($row['estado'] ?? 'CONFIRMADA'))];
        $this->audit->record($actorId, 'DEVOLUCIONES', 'DEVOLUCION_CONFIRMAR', 'DEVOLUCION', $returnId, null, [
            ...$result,
            'tipo_devolucion' => $row['tipo_devolucion'] ?? $current['return']['tipo_devolucion'] ?? null,
        ], $context);

        return $result;
    }

    public function list(array $filters): array
    {
        return $this->returns->list(array_filter($filters, static fn ($value): bool => $value !== null && $value !== '' && $value !== 0));
    }

    public function get(int $returnId): array
    {
        $result = $this->returns->get($returnId);
        if ($result['return'] === null) {
            throw new ApiException('Devolución no encontrada.', 404);
        }

        return $result;
    }

    public function cancel(int $returnId, int $actorId, string $reason, array $context): array
    {
        $current = $this->get($returnId);
        $row = $this->returns->cancel($returnId, $actorId, $reason);
        if (! $row) {
            throw new ApiException('No fue posible anular la devolución.', 422);
        }
        $result = ['id_devolucion' => $returnId, 'estado' => strtoupper((string) ($row['estado'] ?? 'ANULADA'))];
        $this->audit->record($actorId, 'DEVOLUCIONES', 'DEVOLUCION_ANULAR', 'DEVOLUCION', $returnId, null, [
            ...$result,
            'tipo_devolucion' => $row['tipo_devolucion'] ?? $current['return']['tipo_devolucion'] ?? null,
            'motivo_anulacion' => $reason,
        ], $context);

        return $result;
    }

    private function validateAndStore(mixed $candidate): array
    {
        if (! $candidate instanceof UploadedFile || ! $candidate->isValid()) {
            throw new ApiException('Uno de los archivos de evidencia no es válido.', 422);
        }
        $mime = strtolower((string) $candidate->getMimeType());
        $extension = strtolower($candidate->getClientOriginalExtension());
        $allowedExtensions = config('returns.allowed_extensions', []);
        $allowedMimes = config('returns.allowed_mime_types', []);
        $extensionMimes = config("returns.extension_mime_types.{$extension}", []);

        if (! in_array($extension, $allowedExtensions, true)
            || ! in_array($mime, $allowedMimes, true)
            || ! in_array($mime, $extensionMimes, true)) {
            throw new ApiException('El tipo real de uno de los archivos no coincide con su extensión o no está permitido.', 422);
        }
        $directory = 'uploads/returns/'.now()->format('Ym');
        File::ensureDirectoryExists(public_path($directory), 0755, true);
        $filename = Str::uuid()->toString().'.'.$extension;
        $original = $candidate->getClientOriginalName();
        $size = $candidate->getSize();
        $candidate->move(public_path($directory), $filename);

        return [
            'tipo_evidencia' => str_starts_with($mime, 'image/') ? 'FOTO' : 'DOCUMENTO',
            'nombre_archivo' => $filename,
            'nombre_original' => $original,
            'archivo_url' => null,
            'archivo_ruta' => "{$directory}/{$filename}",
            'mime_type' => $mime,
            'peso_bytes' => $size,
        ];
    }

    private function deleteStored(array $relativePaths): void
    {
        foreach ($relativePaths as $relativePath) {
            if (is_string($relativePath) && str_starts_with($relativePath, 'uploads/returns/')) {
                File::delete(public_path($relativePath));
            }
        }
    }
}
