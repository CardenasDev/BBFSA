<?php

namespace App\Http\Controllers\Api;

use App\Http\Requests\CancelReturnRequest;
use App\Http\Requests\ListAvailableReturnsRequest;
use App\Http\Requests\ListReturnsRequest;
use App\Http\Requests\StoreReturnRequest;
use App\Services\ReturnService;
use Dedoc\Scramble\Attributes\Group;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

#[Group('Devoluciones', 'Devoluciones unificadas de dotaciones y herramientas.', weight: 9)]
class ReturnController extends ApiController
{
    public function __construct(private readonly ReturnService $returns) {}

    /** Listar elementos disponibles para devolución, agrupados por entrega. */
    public function available(ListAvailableReturnsRequest $request): JsonResponse
    {
        return $this->success(
            $this->returns->available($request->validated('type'), $request->integer('employee_id')),
            'Elementos disponibles consultados correctamente.',
        );
    }

    /**
     * Registrar devolución
     *
     * Recibe multipart/form-data. `details` es un arreglo JSON y `evidence[]` uno o varios archivos.
     */
    public function store(StoreReturnRequest $request): JsonResponse
    {
        return $this->success(
            $this->returns->create($request->validated(), $this->actorId($request), $this->context($request)),
            'Devolución registrada correctamente.',
            201,
        );
    }

    /** Listar devoluciones con filtros opcionales. */
    public function index(ListReturnsRequest $request): JsonResponse
    {
        return $this->success($this->returns->list($request->validated()), 'Devoluciones consultadas correctamente.');
    }

    /** Consultar cabecera, detalles y evidencias de una devolución. */
    public function show(int $id): JsonResponse
    {
        return $this->success($this->returns->get($id), 'Devolución consultada correctamente.');
    }

    /** Confirmar la recepción de una devolución registrada. */
    public function confirm(Request $request, int $id): JsonResponse
    {
        return $this->success(
            $this->returns->confirm($id, $this->actorId($request), $this->context($request)),
            'Devolución confirmada correctamente.',
        );
    }

    /** Anular lógicamente una devolución, conservando sus evidencias. */
    public function cancel(CancelReturnRequest $request, int $id): JsonResponse
    {
        return $this->success(
            $this->returns->cancel($id, $this->actorId($request), $request->validated('reason'), $this->context($request)),
            'Devolución anulada correctamente.',
        );
    }
}
