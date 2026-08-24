<?php

namespace App\Http\Requests;

class MarkNotificationReadRequest extends ApiRequest
{
    public function rules(): array
    {
        return ['read' => ['required', 'boolean']];
    }
}
