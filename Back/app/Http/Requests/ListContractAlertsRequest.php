<?php

namespace App\Http\Requests;

class ListContractAlertsRequest extends ApiRequest
{
    public function rules(): array
    {
        return [
            'dias_antes' => ['nullable', 'integer', 'min:1', 'max:365'],
        ];
    }
}
