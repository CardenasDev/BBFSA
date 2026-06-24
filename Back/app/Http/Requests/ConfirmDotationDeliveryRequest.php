<?php

namespace App\Http\Requests;

class ConfirmDotationDeliveryRequest extends ApiRequest
{
    public function rules(): array
    {
        return [
            'observacion_confirmacion' => ['nullable', 'string', 'max:500'],
            'firma_url' => ['nullable', 'string', 'max:500'],
        ];
    }
}
