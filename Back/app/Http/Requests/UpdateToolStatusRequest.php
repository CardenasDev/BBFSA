<?php

namespace App\Http\Requests;

class UpdateToolStatusRequest extends ApiRequest
{
    public function rules(): array
    {
        return ['activo' => ['required', 'boolean']];
    }
}
