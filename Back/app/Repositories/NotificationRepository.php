<?php

namespace App\Repositories;

class NotificationRepository extends StoredProcedureRepository
{
    public function synchronize(): void
    {
        $this->call('SP_BBF_NOTIFICACIONES_SINCRONIZAR');
    }

    public function list(int $userId, bool $unreadOnly, int $limit): array
    {
        return $this->call('SP_BBF_NOTIFICACIONES_LISTAR', [$userId, $unreadOnly ? 1 : 0, $limit]);
    }

    public function summary(int $userId): array
    {
        return $this->first('SP_BBF_NOTIFICACIONES_RESUMEN', [$userId]) ?? [];
    }

    public function markRead(int $notificationId, int $userId, bool $read): array
    {
        return $this->first('SP_BBF_NOTIFICACION_MARCAR_LEIDA', [$notificationId, $userId, $read ? 1 : 0]) ?? [];
    }

    public function archive(int $notificationId, int $userId): void
    {
        $this->call('SP_BBF_NOTIFICACION_ARCHIVAR', [$notificationId, $userId]);
    }

    public function resolve(int $notificationId, int $userId): array
    {
        return $this->first('SP_BBF_NOTIFICACION_RESOLVER', [$notificationId, $userId]) ?? [];
    }

}
