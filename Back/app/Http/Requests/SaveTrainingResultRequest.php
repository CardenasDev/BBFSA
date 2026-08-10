<?php

namespace App\Http\Requests;

class SaveTrainingResultRequest extends ApiRequest
{
    public function rules(): array
    {
        return ['id_capacitacion_participante' => ['required', 'integer', 'min:1'], 'fecha_resultado' => ['nullable', 'date'], 'puntaje_final' => ['nullable', 'numeric', 'min:0'], 'puntaje_minimo' => ['nullable', 'numeric', 'min:0'], 'resultado' => ['nullable', 'in:PENDIENTE,APROBADO,NO_APROBADO,REQUIERE_REINDUCCION'], 'requiere_reinduccion' => ['nullable', 'boolean'], 'requiere_compromiso' => ['nullable', 'boolean'], 'regla_aplicada' => ['nullable', 'string', 'max:500'], 'observaciones' => ['nullable', 'string']];
    }
}
