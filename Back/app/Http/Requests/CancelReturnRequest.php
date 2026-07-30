<?php

namespace App\Http\Requests;

class CancelReturnRequest extends ApiRequest
{
    public function rules(): array
    {
        return ['reason' => ['required', 'string', 'max:500']];
    }
}
