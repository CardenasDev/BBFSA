<?php

namespace App\Http\Requests;

class AttachTrainingTaskRequest extends ApiRequest
{
    public function rules(): array
    {
        return ['id_capacitacion' => ['required', 'integer', 'min:1'], 'id_capacitacion_labor' => ['required', 'integer', 'min:1'], 'puntaje_minimo_labor' => ['nullable', 'numeric', 'min:0'], 'puntaje_maximo_labor' => ['nullable', 'numeric', 'gt:puntaje_minimo_labor'], 'orden' => ['nullable', 'integer', 'min:0'], 'activo' => ['nullable', 'boolean']];
    }
}
