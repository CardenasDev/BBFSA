<?php

namespace App\Http\Requests;

use Illuminate\Validation\Rule;

class SaveSocialSecurityEntityRequest extends ApiRequest
{
    private const TYPES = ['EPS', 'ARL', 'PENSION', 'CESANTIAS', 'CAJA_COMPENSACION'];

    public function rules(): array
    {
        return [
            'id_entidad' => ['nullable', 'integer', 'min:1'],
            'tipo_entidad' => ['required', 'string', Rule::in(self::TYPES)],
            'nombre' => ['required', 'string', 'max:150'],
            'nit' => ['nullable', 'string', 'max:50'],
            'activo' => ['nullable', 'boolean'],
        ];
    }

    public function messages(): array
    {
        return [
            'tipo_entidad.in' => 'El tipo de entidad no es válido.',
            'nombre.required' => 'El nombre de la entidad es obligatorio.',
        ];
    }
}
