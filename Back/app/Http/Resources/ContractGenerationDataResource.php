<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ContractGenerationDataResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'empresa' => is_array($this->resource['empresa'] ?? null) ? $this->resource['empresa'] : [],
            'empleado' => is_array($this->resource['empleado'] ?? null) ? $this->resource['empleado'] : [],
            'contrato' => is_array($this->resource['contrato'] ?? null) ? $this->resource['contrato'] : [],
            'firmas' => is_array($this->resource['firmas'] ?? null) ? $this->resource['firmas'] : [],
            'parametros' => is_array($this->resource['parametros'] ?? null) ? $this->resource['parametros'] : [],
        ];
    }
}
