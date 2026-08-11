<?php

namespace App\Http\Requests;

class SaveDocumentTypeRequest extends ApiRequest
{
    public function rules(): array
    {
        return [
            'id_tipo_documento' => ['nullable', 'integer', 'min:1'],
            'nombre' => ['required', 'string', 'max:150'],
            'activo' => ['nullable', 'boolean'],
        ];
    }

    public function messages(): array
    {
        return [
            'nombre.required' => 'El nombre del tipo de documento es obligatorio.',
        ];
    }
}
