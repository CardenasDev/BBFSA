<?php

namespace App\Http\Requests;

class ListContractTemplatesRequest extends ApiRequest
{
    public function rules(): array
    {
        return [
            'id_tipo_contrato' => ['nullable', 'integer'],
            'solo_activas' => ['nullable', 'boolean'],
        ];
    }
}
