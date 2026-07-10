<?php

namespace App\Http\Requests;

class GetContractTemplateByTypeRequest extends ApiRequest
{
    public function rules(): array
    {
        return [
            'id_tipo_contrato' => ['required', 'integer'],
            'tipo_cargo_contrato' => ['nullable', 'string', 'in:ADMINISTRATIVO,OPERATIVO,OTRO'],
        ];
    }
}
