<?php

namespace App\Http\Requests;

class SaveEvaluationScoresRequest extends ApiRequest
{
    public function rules(): array
    {
        return [
            'calificaciones' => ['required', 'array', 'min:1'],
            'calificaciones.*.id_empleado' => ['required', 'integer', 'min:1'],
            'calificaciones.*.id_evaluacion_labor' => ['required', 'integer', 'min:1'],
            'calificaciones.*.valor_obtenido' => ['required', 'numeric', 'min:0'],
            'calificaciones.*.valor_maximo' => ['nullable', 'numeric', 'min:0'],
            'calificaciones.*.observaciones' => ['nullable', 'string'],
        ];
    }
}
