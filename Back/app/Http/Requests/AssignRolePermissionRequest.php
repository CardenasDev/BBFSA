<?php

namespace App\Http\Requests;

class AssignRolePermissionRequest extends ApiRequest
{
    public function rules(): array
    {
        return [
            'id_permiso' => ['required', 'integer', 'min:1'],
        ];
    }
}
