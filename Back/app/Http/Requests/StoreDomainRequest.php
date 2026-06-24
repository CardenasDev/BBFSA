<?php

namespace App\Http\Requests;

class StoreDomainRequest extends ApiRequest
{
    public function rules(): array
    {
        return [
            'dominio' => ['required', 'string', 'max:255', 'regex:/^@?[A-Za-z0-9.-]+$/'],
        ];
    }
}
