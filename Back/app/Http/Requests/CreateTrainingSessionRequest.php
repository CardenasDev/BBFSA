<?php

namespace App\Http\Requests;

class CreateTrainingSessionRequest extends ApiRequest
{
    public function rules(): array
    {
        return ['id_capacitacion' => ['required', 'integer', 'min:1'], 'fecha_inicio' => ['required', 'date'], 'fecha_fin' => ['required', 'date', 'after_or_equal:fecha_inicio'], 'id_instructor_usuario' => ['nullable', 'integer', 'min:1'], 'instructor_externo' => ['nullable', 'string', 'max:200'], 'lugar' => ['nullable', 'string', 'max:250'], 'observaciones' => ['nullable', 'string']];
    }
}
