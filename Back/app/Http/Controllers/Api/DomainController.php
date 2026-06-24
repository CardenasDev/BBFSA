<?php

namespace App\Http\Controllers\Api;

use App\Http\Requests\StoreDomainRequest;
use App\Http\Requests\UpdateDomainStateRequest;
use App\Services\DomainService;
use Dedoc\Scramble\Attributes\Group;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DomainController extends ApiController
{
    public function __construct(private readonly DomainService $domains) {}

    /**
     * Listar dominios autorizados
     *
     * Retorna los dominios autorizados registrados en el sistema.
     */
    #[Group('Dominios', 'Dominios autorizados para autenticación corporativa.', weight: 5)]
    public function domains(Request $request): JsonResponse
    {
        return $this->success($this->domains->listDomains($request->boolean('solo_activos', true)));
    }

    /**
     * Crear dominio autorizado
     *
     * Registra un nuevo dominio corporativo autorizado.
     */
    #[Group('Dominios', 'Dominios autorizados para autenticación corporativa.', weight: 5)]
    public function store(StoreDomainRequest $request): JsonResponse
    {
        return $this->success($this->domains->create($request->validated()), 'Dominio autorizado creado exitosamente.', 201);
    }

    /**
     * Cambiar estado del dominio autorizado
     *
     * Activa o inactiva un dominio autorizado.
     */
    #[Group('Dominios', 'Dominios autorizados para autenticación corporativa.', weight: 5)]
    public function changeState(UpdateDomainStateRequest $request, int $id): JsonResponse
    {
        return $this->success($this->domains->changeState($id, $request->boolean('activo')), 'Estado actualizado exitosamente.');
    }
}
