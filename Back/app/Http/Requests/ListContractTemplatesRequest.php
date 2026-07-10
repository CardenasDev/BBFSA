<?php

namespace App\Http\Requests;

class ListContractTemplatesRequest extends ApiRequest
{
    public function rules(): array
    {
        return [
            'id_tipo_contrato' => ['nullable', 'integer'],
            'tipo_cargo_contrato' => ['nullable', 'string', 'in:ADMINISTRATIVO,OPERATIVO,OTRO'],
            'solo_activas' => ['nullable', 'boolean'],
        ];
    }
}
