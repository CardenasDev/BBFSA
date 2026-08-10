<?php

namespace App\Http\Requests;

class CreateTrainingCommitmentRequest extends ApiRequest
{
    public function rules(): array
    {
        return ['id_capacitacion_resultado' => ['required', 'integer', 'min:1'], 'fecha_compromiso' => ['nullable', 'date'], 'fecha_limite' => ['nullable', 'date', 'after_or_equal:fecha_compromiso'], 'motivo' => ['required', 'string'], 'compromisos_empleado' => ['nullable', 'string'], 'observaciones' => ['nullable', 'string']];
    }
}
