<?php

namespace App\Services;

use App\Repositories\AuditRepository;
use Illuminate\Support\Facades\Log;
use Throwable;

class AuditService
{
    public function __construct(private readonly AuditRepository $repository) {}

    public function record(
        ?int $userId,
        string $module,
        string $action,
        string $entity,
        ?int $entityId,
        mixed $before = null,
        mixed $after = null,
        array $context = [],
    ): void {
        try {
            $this->repository->create([
                'id_usuario' => $userId,
                'modulo' => $module,
                'accion' => $action,
                'entidad' => $entity,
                'entidad_id' => $entityId,
                'datos_anteriores' => $before === null ? null : json_encode($before, JSON_UNESCAPED_UNICODE | JSON_THROW_ON_ERROR),
                'datos_nuevos' => $after === null ? null : json_encode($after, JSON_UNESCAPED_UNICODE | JSON_THROW_ON_ERROR),
                'ip_origen' => $context['ip'] ?? null,
                'user_agent' => isset($context['user_agent']) ? mb_substr($context['user_agent'], 0, 500) : null,
            ]);
        } catch (Throwable $e) {
            Log::error('No se pudo registrar el evento de auditoría.', [
                'action' => $action,
                'entity' => $entity,
                'exception' => $e->getMessage(),
            ]);
        }
    }
}
