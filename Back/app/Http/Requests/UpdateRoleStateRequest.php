<?php

namespace App\Http\Requests;

class UpdateRoleStateRequest extends ApiRequest
{
    public function rules(): array
    {
        return [
            'activo' => ['required', 'boolean'],
        ];
    }
}
