<?php

namespace App\Http\Requests;

class SaveTrainingTaskRequest extends ApiRequest
{
    public function rules(): array
    {
        return ['id_capacitacion_labor' => ['nullable', 'integer', 'min:1'], 'codigo' => ['required', 'string', 'max:50', 'regex:/^[A-Z0-9_]+$/'], 'nombre' => ['required', 'string', 'max:150'], 'descripcion' => ['nullable', 'string', 'max:500'], 'orden' => ['nullable', 'integer', 'min:0'], 'activo' => ['nullable', 'boolean']];
    }
}
