<?php

namespace App\Http\Requests;

class SaveNoveltyTypeRequest extends ApiRequest
{
    public function rules(): array
    {
        return [
            'nombre' => ['required', 'string', 'max:150'],
            'descripcion' => ['nullable', 'string', 'max:500'],
            'requiere_fecha_fin' => ['nullable', 'boolean'],
            'requiere_soporte' => ['nullable', 'boolean'],
            'es_incapacidad' => ['nullable', 'boolean'],
            'activo' => ['nullable', 'boolean'],
        ];
    }

    public function messages(): array
    {
        return ['nombre.required' => 'El nombre del tipo de novedad es obligatorio.'];
    }
}
