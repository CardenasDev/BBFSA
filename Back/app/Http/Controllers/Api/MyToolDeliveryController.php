<?php

namespace App\Http\Controllers\Api;

use App\Services\ToolService;
use Dedoc\Scramble\Attributes\Group;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

#[Group('Mis herramientas', 'Entregas de herramientas del empleado autenticado.', weight: 9)]
class MyToolDeliveryController extends ApiController
{
    public function __construct(private readonly ToolService $tools) {}

    /**
     * Listar mis entregas de herramientas
     *
     * Obtiene únicamente las entregas del empleado asociado al usuario JWT.
     *
     * @response array{success: bool, message: string, data: list<array{id_entrega: int, fecha_entrega: string, estado: string, observaciones: string|null, fecha_confirmacion: string|null, total_herramientas: int}>}
     */
    public function index(Request $request): JsonResponse
    {
        return $this->success(
            $this->tools->getMyDeliveries($this->actorId($request)),
            'Mis entregas de herramientas consultadas correctamente',
        );
    }

    /**
     * Consultar mi entrega de herramientas
     *
     * Retorna cabecera y detalle solamente si la entrega pertenece al empleado autenticado.
     *
     * @response array{success: bool, message: string, data: array{id_entrega: int, fecha_entrega: string, estado: string, observaciones: string|null, fecha_confirmacion: string|null, herramientas: list<array{id_detalle: int, id_herramienta: int, herramienta: string, cantidad: int, observaciones: string|null}>}}
     */
    public function show(Request $request, int $id): JsonResponse
    {
        return $this->success(
            $this->tools->getMyDelivery($this->actorId($request), $id),
            'Entrega de herramientas consultada correctamente',
        );
    }

    /**
     * Confirmar recepción de mi entrega
     *
     * Confirma una entrega pendiente únicamente si pertenece al empleado autenticado. No recibe payload.
     */
    public function confirm(Request $request, int $id): JsonResponse
    {
        return $this->success(
            $this->tools->confirmMyDelivery($this->actorId($request), $id, $this->context($request)),
            'Recepción confirmada correctamente.',
        );
    }
}
