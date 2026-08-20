<?php

namespace App\Http\Requests;

use Illuminate\Validation\Rule;

class SaveDotationArticleRequest extends ApiRequest
{
    public function rules(): array
    {
        return [
            'id_dotacion_articulo' => ['nullable', 'integer', 'min:1'],
            'id_tipo_dotacion' => ['required', 'integer', 'min:1'],
            'nombre' => ['required', 'string', 'max:200'],
            'descripcion' => ['nullable', 'string'],
            'genero' => ['nullable', 'string', Rule::in(['HOMBRE', 'MUJER', 'UNISEX', 'NO_APLICA'])],
            'unidad_medida' => ['nullable', 'string', Rule::in(['UNIDAD', 'PAR', 'JUEGO'])],
            'activo' => ['nullable', 'boolean'],
        ];
    }

    public function messages(): array
    {
        return [
            'id_tipo_dotacion.required' => 'La familia técnica (id_tipo_dotacion) es obligatoria.',
            'nombre.required' => 'El nombre del artículo es obligatorio.',
        ];
    }
}
