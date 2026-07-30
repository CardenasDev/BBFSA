<?php

namespace App\Http\Controllers\Api;

use App\Http\Requests\ListToolDeliveriesRequest;
use App\Http\Requests\StoreToolDeliveryRequest;
use App\Http\Requests\StoreToolRequest;
use App\Http\Requests\UpdateToolStatusRequest;
use App\Services\ToolService;
use Dedoc\Scramble\Attributes\Group;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

#[Group('Herramientas', 'Catálogo y entregas de herramientas a empleados.', weight: 8)]
class ToolController extends ApiController
{
    public function __construct(private readonly ToolService $tools) {}

    /**
     * Listar herramientas
     *
     * Consulta el catálogo. Use `active=0` para incluir herramientas inactivas.
     *
     * @response array{success: bool, message: string, data: list<array{id_herramienta: int, nombre: string, descripcion: string|null, activo: bool}>}
     */
    public function index(Request $request): JsonResponse
    {
        return $this->success(
            $this->tools->tools($request->boolean('active', true)),
            'Herramientas consultadas correctamente',
        );
    }

    /**
     * Crear herramienta
     *
     * Registra una herramienta en el catálogo.
     */
    public function store(StoreToolRequest $request): JsonResponse
    {
        return $this->success($this->tools->createTool($request->validated()), 'Herramienta creada correctamente', 201);
    }

    /**
     * Actualizar herramienta
     *
     * Actualiza nombre y descripción de una herramienta.
     */
    public function update(StoreToolRequest $request, int $id): JsonResponse
    {
        return $this->success($this->tools->updateTool($id, $request->validated()), 'Herramienta actualizada correctamente');
    }

    /**
     * Activar o inactivar herramienta
     *
     * Cambia el estado activo del elemento de catálogo sin eliminarlo.
     */
    public function changeStatus(UpdateToolStatusRequest $request, int $id): JsonResponse
    {
        return $this->success(
            $this->tools->changeToolStatus($id, $request->boolean('activo')),
            'Estado de la herramienta actualizado correctamente',
        );
    }

    /**
     * Registrar entrega de herramientas
     *
     * Crea una entrega pendiente con una o varias herramientas. El detalle completo se envía como JSON al procedimiento almacenado.
     *
     * @response array{success: bool, message: string, data: array{id_entrega: int, estado: string}}
     */
    public function storeDelivery(StoreToolDeliveryRequest $request): JsonResponse
    {
        $data = $request->validated();
        $data['evidencias'] = $request->file('evidencias', []);

        return $this->success(
            $this->tools->createDelivery($data),
            'Entrega de herramientas registrada correctamente',
            201,
        );
    }

    /**
     * Listar entregas de herramientas
     *
     * Permite filtrar por `id_empleado` y por estado `pendiente` o `confirmada`.
     */
    public function deliveries(ListToolDeliveriesRequest $request): JsonResponse
    {
        return $this->success(
            $this->tools->deliveries(
                $request->integer('id_empleado') ?: null,
                $request->validated('estado'),
            ),
            'Entregas de herramientas consultadas correctamente',
        );
    }

    /**
     * Consultar entrega completa
     *
     * Retorna en una sola respuesta la cabecera y todas las herramientas entregadas.
     *
     * @response array{success: bool, message: string, data: array{id_entrega: int, id_empleado: int, numero_documento: string, nombres: string, apellidos: string, empleado: string, fecha_entrega: string, estado: string, observaciones: string|null, fecha_confirmacion: string|null, herramientas: list<array{id_detalle: int, id_herramienta: int, herramienta: string, cantidad: int, observaciones: string|null}>}}
     */
    public function showDelivery(int $id): JsonResponse
    {
        return $this->success($this->tools->delivery($id), 'Entrega de herramientas consultada correctamente');
    }

    /**
     * Confirmar entrega
     *
     * Confirma una entrega pendiente. No recibe el estado desde el cliente.
     */
    public function confirmDelivery(int $id): JsonResponse
    {
        return $this->success($this->tools->confirmDelivery($id), 'Entrega de herramientas confirmada correctamente');
    }

    /**
     * Eliminar entrega pendiente
     *
     * El procedimiento almacenado rechaza la eliminación de entregas confirmadas.
     */
    public function deleteDelivery(int $id): JsonResponse
    {
        return $this->success($this->tools->deleteDelivery($id), 'Entrega de herramientas eliminada correctamente');
    }
}
