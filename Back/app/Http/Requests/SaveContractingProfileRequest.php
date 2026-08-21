<?php

namespace App\Http\Requests;

class SaveContractingProfileRequest extends ApiRequest
{
    public function rules(): array
    {
        return [
            'numero_carpeta' => ['nullable', 'string', 'max:50'],
            'genero' => ['nullable', 'string', 'max:20'],
            'fecha_expedicion_documento' => ['nullable', 'date'],
            'lugar_expedicion_documento' => ['nullable', 'string', 'max:150'],
            'id_departamento_nacimiento' => ['nullable', 'integer', 'min:1'],
            'id_municipio_nacimiento' => ['nullable', 'integer', 'min:1'],
            'id_departamento_residencia' => ['nullable', 'integer', 'min:1'],
            'id_municipio_residencia' => ['nullable', 'integer', 'min:1'],
            'direccion_residencia' => ['nullable', 'string', 'max:250'],
            'telefono_alterno' => ['nullable', 'string', 'max:50'],
            'correo_personal' => ['nullable', 'email', 'max:150'],
            'estado_civil' => ['nullable', 'string', 'in:SOLTERO,CASADO,UNION_LIBRE,SEPARADO,DIVORCIADO,VIUDO,OTRO'],
            'nivel_educativo' => ['nullable', 'string', 'in:PRIMARIA,BACHILLER,TECNICO,TECNOLOGO,PROFESIONAL,POSGRADO,NINGUNO,OTRO'],
            'personas_a_cargo' => ['nullable', 'integer', 'min:0'],
            'numero_hijos' => ['nullable', 'integer', 'min:0'],
            'personas_vivienda' => ['nullable', 'integer', 'min:0'],
            'menores_estudian' => ['nullable', 'boolean'],
            'observaciones' => ['nullable', 'string'],
            'contacto_emergencia' => ['nullable', 'array'],
            'contacto_emergencia.nombre_completo' => ['nullable', 'string', 'max:200'],
            'contacto_emergencia.parentesco' => ['nullable', 'string', 'max:100'],
            'contacto_emergencia.telefono' => ['nullable', 'string', 'max:50'],
            'contacto_emergencia.telefono_alterno' => ['nullable', 'string', 'max:50'],
            'contacto_emergencia.direccion' => ['nullable', 'string', 'max:250'],
            'contacto_emergencia.observaciones' => ['nullable', 'string', 'max:500'],
        ];
    }
}
