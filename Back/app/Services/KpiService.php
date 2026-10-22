<?php

namespace App\Services;

use App\Exceptions\ApiException;
use App\Repositories\KpiRepository;
use Illuminate\Support\Facades\DB;

class KpiService
{
    public function __construct(private readonly KpiRepository $repository) {}

    public function rotationAndDemographics(): array
    {
        return DB::transaction(function () {
            $result = $this->repository->getRotationAndDemographics();

            if (! $result) {
                throw new ApiException('No fue posible calcular los indicadores.', 500);
            }

            return [
                'tasa_rotacion_3m' => $result['tasa_rotacion'],
                'salidas_ultimos_3m' => $result['salidas'],
                'promedio_activos_3m' => $result['promedio_activos'],
                'ventana_inicio' => $result['ventana_inicio'],
                'ventana_fin' => $result['ventana_fin'],
                'metodo_calculo' => $result['metodo_calculo'],
                'desglose_genero' => $result['desglose_genero'],
                'fecha_calculo' => now()->toDateString(),
            ];
        });
    }
}