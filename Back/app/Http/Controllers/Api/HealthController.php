<?php

namespace App\Http\Controllers\Api;

use Dedoc\Scramble\Attributes\Group;
use Illuminate\Http\JsonResponse;

#[Group('Health', 'Estado operativo de la API.', weight: 0)]
class HealthController extends ApiController
{
    /**
     * Estado de la API
     *
     * Confirma que el backend está disponible. No verifica ni modifica datos de negocio.
     */
    public function __invoke(): JsonResponse
    {
        return $this->success([
            'app' => config('app.name'),
            'status' => 'ok',
        ], 'API funcionando correctamente');
    }
}
