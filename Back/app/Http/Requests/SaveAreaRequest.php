<?php

namespace App\Http\Requests;

class SaveAreaRequest extends ApiRequest
{
    public function rules(): array
    {
        return [
            'id_area' => ['nullable', 'integer', 'min:1'],
            'nombre' => ['required', 'string', 'max:150'],
            'descripcion' => ['nullable', 'string'],
            'activo' => ['nullable', 'boolean'],
        ];
    }

    public function messages(): array
    {
        return [
            'nombre.required' => 'El nombre del área es obligatorio.',
        ];
    }
}
