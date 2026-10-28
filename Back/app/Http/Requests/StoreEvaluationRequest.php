<?php

namespace App\Http\Requests;

class StoreEvaluationRequest extends ApiRequest
{
    public function rules(): array
    {
        return [
            'anio' => ['required', 'integer', 'min:2000', 'max:2100'],
            'numero_semana' => ['required', 'integer', 'between:1,53'],
            'nombre_semana' => ['nullable', 'string', 'max:100'],
            'fecha_inicio' => ['required', 'date'],
            'fecha_fin' => ['nullable', 'date', 'after_or_equal:fecha_inicio'],
            'observaciones' => ['nullable', 'string'],
        ];
    }
}
