<?php

namespace App\Http\Requests;

class UpdateApplicantRequest extends ApiRequest
{
    public function rules(): array
    {
        return [
            'id_tipo_documento' => ['nullable', 'integer'],
            'numero_documento' => ['required', 'string', 'max:50'],
            'nombres' => ['required', 'string', 'max:150'],
            'apellidos' => ['required', 'string', 'max:150'],
            'correo' => ['nullable', 'email', 'max:150'],
            'telefono' => ['nullable', 'string', 'max:50'],
            'direccion' => ['nullable', 'string', 'max:250'],
            'fecha_nacimiento' => ['nullable', 'date'],
            'id_departamento_nacimiento' => ['nullable', 'integer', 'min:1'],
            'id_municipio_nacimiento' => ['nullable', 'integer', 'min:1'],
            'nacionalidad' => ['nullable', 'string', 'max:100'],
            'id_departamento_residencia' => ['nullable', 'integer', 'min:1'],
            'id_municipio_residencia' => ['nullable', 'integer', 'min:1'],
            'estado_civil' => ['nullable', 'string', 'in:SOLTERO,CASADO,UNION_LIBRE,SEPARADO,DIVORCIADO,VIUDO,OTRO'],
            'nivel_educativo' => ['nullable', 'string', 'in:PRIMARIA,BACHILLER,TECNICO,TECNOLOGO,PROFESIONAL,POSGRADO,NINGUNO,OTRO'],
            'personas_a_cargo' => ['nullable', 'integer', 'min:0'],
            'numero_hijos' => ['nullable', 'integer', 'min:0'],
            'id_area_aspira' => ['nullable', 'integer'],
            'id_cargo_aspira' => ['nullable', 'integer'],
            'observaciones' => ['nullable', 'string'],
        ];
    }
}
