<?php

namespace App\Http\Requests;

class DeleteDotationDeliveryRequest extends ApiRequest
{
    public function rules(): array
    {
        return [
            'motivo_eliminacion' => ['nullable', 'string', 'max:500'],
        ];
    }
}
