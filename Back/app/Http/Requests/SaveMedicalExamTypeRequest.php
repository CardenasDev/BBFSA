<?php

namespace App\Http\Requests;

class SaveMedicalExamTypeRequest extends ApiRequest
{
    public function rules(): array
    {
        return [
            'id_tipo_examen' => ['nullable', 'integer', 'min:1'],
            'nombre' => ['required', 'string', 'max:150'],
            'descripcion' => ['nullable', 'string'],
            'activo' => ['nullable', 'boolean'],
        ];
    }

    public function messages(): array
    {
        return [
            'nombre.required' => 'El nombre del tipo de examen es obligatorio.',
        ];
    }
}
