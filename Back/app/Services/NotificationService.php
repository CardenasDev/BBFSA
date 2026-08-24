<?php

namespace App\Services;

use App\Repositories\NotificationRepository;

class NotificationService
{
    public function __construct(
        private readonly NotificationRepository $repository,
        private readonly AuditService $audit,
    ) {}

    public function list(int $userId, array $filters): array
    {
        $this->repository->synchronize();

        return $this->repository->list(
            $userId,
            (bool) ($filters['unread_only'] ?? false),
            (int) ($filters['limit'] ?? 50),
        );
    }

    public function summary(int $userId): array
    {
        $this->repository->synchronize();

        return $this->repository->summary($userId);
    }

    public function markRead(int $id, int $userId, bool $read): array
    {
        return $this->repository->markRead($id, $userId, $read);
    }

    public function archive(int $id, int $userId): void
    {
        $this->repository->archive($id, $userId);
    }

    public function resolve(int $id, int $userId, array $context): array
    {
        $result = $this->repository->resolve($id, $userId);
        $this->audit->record($userId, 'NOTIFICACIONES', 'NOTIFICACION_RESOLVER', 'NOTIFICACION', $id, null, $result, $context);

        return $result;
    }

    public function createManual(array $data, int $userId, array $context): array
    {
        $result = $this->repository->createManual($data, $userId);
        $id = (int) ($result['id_notificacion'] ?? 0);
        $this->audit->record($userId, 'NOTIFICACIONES', 'NOTIFICACION_CREAR_MANUAL', 'NOTIFICACION', $id, null, $result, $context);

        return $result;
    }
}
