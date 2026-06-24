<?php

namespace App\Http\Requests;

class RefreshTokenRequest extends ApiRequest
{
    public function rules(): array
    {
        return ['refresh_token' => ['required', 'string', 'size:64']];
    }
}
