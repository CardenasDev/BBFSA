<?php

namespace App\Http\Requests;

use Illuminate\Validation\Rule;

class SaveSystemParameterRequest extends ApiRequest
{
    public function rules(): array
    {
        return [
            'id_parametro' => ['nullable', 'integer', 'min:1'],
            'codigo' => ['required', 'string', 'max:100'],
            'nombre' => ['required', 'string', 'max:150'],
            'grupo' => ['nullable', 'string', 'max:100'],
            'descripcion' => ['nullable', 'string'],
            'tipo_dato' => ['required', 'string', Rule::in(['TEXTO', 'NUMERICO', 'FECHA', 'BOOLEANO', 'JSON'])],
            'valor' => ['nullable'],
            'unidad_medida' => ['nullable', 'string', 'max:50'],
            'vigencia_desde' => ['required', 'date'],
            'vigencia_hasta' => ['nullable', 'date', 'after_or_equal:vigencia_desde'],
            'activo' => ['nullable', 'boolean'],
            'editable' => ['nullable', 'boolean'],
        ];
    }

    public function messages(): array
    {
        return [
            'codigo.required' => 'El codigo del parametro es obligatorio.',
            'nombre.required' => 'El nombre del parametro es obligatorio.',
            'tipo_dato.in' => 'El tipo de dato no es válido.',
            'vigencia_desde.required' => 'La fecha de inicio de vigencia es obligatoria.',
            'vigencia_hasta.after_or_equal' => 'La vigencia final no puede ser anterior a la inicial.',
        ];
    }
}
