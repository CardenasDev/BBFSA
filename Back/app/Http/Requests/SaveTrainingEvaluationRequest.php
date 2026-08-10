<?php

namespace App\Http\Requests;

class SaveTrainingEvaluationRequest extends ApiRequest
{
    public function rules(): array
    {
        return ['id_capacitacion_participante' => ['required', 'integer', 'min:1'], 'id_capacitacion_labor' => ['required', 'integer', 'min:1'], 'fecha_evaluacion' => ['required', 'date'], 'valor_obtenido' => ['required', 'numeric', 'min:0'], 'valor_maximo' => ['nullable', 'numeric', 'min:0'], 'requiere_atencion' => ['nullable', 'boolean'], 'observaciones' => ['nullable', 'string', 'max:500']];
    }
}
