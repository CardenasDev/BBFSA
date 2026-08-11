<?php

namespace App\Http\Requests;

use Illuminate\Validation\Rule;

class SaveLaborDocumentRequest extends ApiRequest
{
    public function rules(): array
    {
        return [
            'id_tipo_documento_laboral' => ['nullable', 'integer', 'min:1'],
            'nombre' => ['required', 'string', 'max:150'],
            'descripcion' => ['nullable', 'string'],
            'obligatorio' => ['nullable', 'boolean'],
            'requiere_vencimiento' => ['nullable', 'boolean'],
            'aplica_aspirante' => ['nullable', 'boolean'],
            'aplica_contratacion' => ['nullable', 'boolean'],
            'aplica_retiro' => ['nullable', 'boolean'],
            'activo' => ['nullable', 'boolean'],
        ];
    }

    public function messages(): array
    {
        return [
            'nombre.required' => 'El nombre del documento laboral es obligatorio.',
        ];
    }
}
