<?php

namespace App\Http\Requests;

class UpdateDomainStateRequest extends ApiRequest
{
    public function rules(): array
    {
        return [
            'activo' => ['required', 'boolean'],
        ];
    }
}
