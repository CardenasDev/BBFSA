<?php

namespace App\Http\Controllers\Api;

use App\Services\KpiService;
use Dedoc\Scramble\Attributes\Group;
use Illuminate\Http\JsonResponse;

#[Group('Empleados KPI', 'Indicadores de rotacion y demografia del talento humano.', weight: 15)]
class KpiController extends ApiController
{
    public function __construct(private readonly KpiService $kpi) {}

    /**
     * Obtener Tasa de Rotacion (ultimos 3 meses) y Desglose Demografico.
     * Requiere permiso: EMPLEADOS_KPI_VER
     */
    public function rotationAndDemographics(): JsonResponse
    {
        $data = $this->kpi->rotationAndDemographics();
        return $this->success($data, 'KPI de rotacion y demografia consultado correctamente');
    }
}