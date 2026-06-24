<?php

namespace App\Http\Requests;

class CreateMedicalExamRequest extends ApiRequest
{
    public function rules(): array
    {
        return [
            'id_tipo_examen_medico' => ['required', 'integer'],
            'fecha_examen' => ['required', 'date'],
            'entidad_realiza' => ['nullable', 'string', 'max:200'],
            'resultado_general' => ['nullable', 'string', 'max:250'],
            'fecha_vencimiento' => ['nullable', 'date', 'after_or_equal:fecha_examen'],
            'archivo_url' => ['nullable', 'string', 'max:500'],
            'observaciones' => ['nullable', 'string'],
        ];
    }
}
