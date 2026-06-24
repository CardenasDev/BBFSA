<?php

namespace App\Http\Requests;

class SaveMyDotationSizeRequest extends ApiRequest
{
    public function rules(): array
    {
        return [
            'id_tipo_dotacion' => ['required', 'integer'],
            'id_talla_dotacion' => ['nullable', 'integer'],
            'observaciones' => ['nullable', 'string', 'max:250'],
        ];
    }
}
