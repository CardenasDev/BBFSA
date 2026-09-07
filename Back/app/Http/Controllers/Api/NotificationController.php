<?php

namespace App\Http\Controllers\Api;

use App\Http\Requests\ListNotificationsRequest;
use App\Http\Requests\MarkNotificationReadRequest;
use App\Services\NotificationService;
use Dedoc\Scramble\Attributes\Group;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

#[Group('Notificaciones', 'Alertas laborales visibles según los permisos del usuario.', weight: 9)]
class NotificationController extends ApiController
{
    public function __construct(private readonly NotificationService $service) {}

    /** Lista las notificaciones activas destinadas al usuario autenticado. */
    public function index(ListNotificationsRequest $request): JsonResponse
    {
        return $this->success($this->service->list($this->actorId($request), $request->validated()), 'Notificaciones consultadas correctamente.');
    }

    /** Obtiene los contadores del dashboard para el usuario autenticado. */
    public function summary(Request $request): JsonResponse
    {
        return $this->success($this->service->summary($this->actorId($request)), 'Resumen consultado correctamente.');
    }

    /** Marca una notificación como leída o no leída. */
    public function markRead(MarkNotificationReadRequest $request, int $id): JsonResponse
    {
        return $this->success($this->service->markRead($id, $this->actorId($request), (bool) $request->validated('read')), 'Lectura actualizada correctamente.');
    }

    /** Oculta una notificación solamente para el usuario autenticado. */
    public function archive(Request $request, int $id): JsonResponse
    {
        $this->service->archive($id, $this->actorId($request));

        return $this->success(null, 'Notificación archivada correctamente.');
    }

    /** Resuelve una notificación para todos sus destinatarios. */
    public function resolve(Request $request, int $id): JsonResponse
    {
        return $this->success($this->service->resolve($id, $this->actorId($request), $this->context($request)), 'Notificación resuelta correctamente.');
    }

}
