<?php

namespace App\Http\Requests;

class SaveSocialSecurityRequest extends ApiRequest
{
    public function rules(): array
    {
        return [
            'id_eps' => ['nullable', 'integer'],
            'id_arl' => ['nullable', 'integer'],
            'id_fondo_pension' => ['nullable', 'integer'],
            'id_fondo_cesantias' => ['nullable', 'integer'],
            'id_caja_compensacion' => ['nullable', 'integer'],
            'fecha_afiliacion_eps' => ['nullable', 'date'],
            'fecha_afiliacion_arl' => ['nullable', 'date'],
            'fecha_afiliacion_pension' => ['nullable', 'date'],
            'fecha_afiliacion_cesantias' => ['nullable', 'date'],
            'fecha_afiliacion_caja' => ['nullable', 'date'],
            'observaciones' => ['nullable', 'string'],
        ];
    }
}
