<?php

namespace App\Http\Requests;

use Illuminate\Validation\Rule;

class ChangeApplicantStatusRequest extends ApiRequest
{
    public function rules(): array
    {
        return [
            'estado_aspirante' => [
                'required',
                'string',
                Rule::in(['REGISTRADO', 'EN_REVISION', 'APROBADO_CONTRATACION', 'RECHAZADO', 'CONVERTIDO_EMPLEADO', 'CANCELADO']),
            ],
            'observaciones' => ['nullable', 'string'],
        ];
    }
}
