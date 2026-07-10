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
            'lugar_nacimiento' => ['nullable', 'string', 'max:150'],
            'departamento_nacimiento' => ['nullable', 'string', 'max:150'],
            'nacionalidad' => ['nullable', 'string', 'max:100'],
            'ciudad_residencia' => ['nullable', 'string', 'max:150'],
            'departamento_residencia' => ['nullable', 'string', 'max:150'],
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
