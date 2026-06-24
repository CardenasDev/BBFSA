<?php

namespace App\Http\Requests;

class AssignRoleRequest extends ApiRequest
{
    public function rules(): array
    {
        return ['id_rol' => ['required', 'integer', 'min:1']];
    }
}
