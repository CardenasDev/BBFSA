<?php

namespace App\Http\Requests;

class SaveEmployeeDotationArticleSizeRequest extends ApiRequest
{
    public function rules(): array
    {
        return [
            'id_talla_dotacion' => ['required', 'integer', 'min:1'],
            'observaciones' => ['nullable', 'string', 'max:250'],
        ];
    }
}
