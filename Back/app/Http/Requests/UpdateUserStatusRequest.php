<?php

namespace App\Http\Requests;

use Illuminate\Validation\Rule;

class UpdateUserStatusRequest extends ApiRequest
{
    public function rules(): array
    {
        return ['estado' => ['required', Rule::in(['ACTIVO', 'INACTIVO', 'BLOQUEADO', 'ELIMINADO'])]];
    }
}
