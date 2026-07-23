<?php

namespace App\Http\Requests;

use Illuminate\Validation\Rule;

class StoreEmployeeRequest extends ApiRequest
{
    public function rules(): array
    {
        return [
            'id_tipo_documento' => ['nullable', 'integer', Rule::exists('bbf_tipos_documento', 'ID_TIPO_DOCUMENTO')],
            'numero_documento' => ['required', 'string', 'max:50', Rule::unique('bbf_empleados', 'NUMERO_DOCUMENTO')],
            'nombres' => ['required', 'string', 'max:150'],
            'apellidos' => ['required', 'string', 'max:150'],
            'correo' => ['nullable', 'email:rfc', 'max:150'],
            'telefono' => ['nullable', 'string', 'max:50'],
            'foto_url' => ['nullable', 'string', 'max:500'],
            'id_area' => ['nullable', 'integer', Rule::exists('bbf_areas', 'ID_AREA')],
            'id_cargo' => ['nullable', 'integer', Rule::exists('bbf_cargos', 'ID_CARGO')],
            'id_tipo_contrato' => ['nullable', 'integer', Rule::exists('bbf_tipos_contrato', 'ID_TIPO_CONTRATO')],
            'fecha_ingreso' => ['nullable', 'date'],
            'fecha_retiro' => ['nullable', 'date'],
            'estado_empleado' => ['required', Rule::in(EmployeeStatus::values())],
            'observaciones' => ['nullable', 'string'],
        ];
    }

    public function messages(): array
    {
        return [
            'numero_documento.required' => 'El numero de documento es obligatorio.',
            'numero_documento.unique' => 'El numero de documento ya existe.',
            'nombres.required' => 'Los nombres son obligatorios.',
            'apellidos.required' => 'Los apellidos son obligatorios.',
            'correo.email' => 'El correo debe ser una direccion valida.',
            'estado_empleado.in' => 'El estado laboral no es valido.',
            '*.exists' => 'El catalogo seleccionado no existe.',
        ];
    }
}
