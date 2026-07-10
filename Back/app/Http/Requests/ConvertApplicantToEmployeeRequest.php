<?php

namespace App\Http\Requests;

class ConvertApplicantToEmployeeRequest extends ApiRequest
{
    public function rules(): array
    {
        return [
            'id_tipo_contrato' => ['nullable', 'integer'],
            'fecha_ingreso' => ['nullable', 'date'],
            'observaciones' => ['nullable', 'string'],
        ];
    }
}
