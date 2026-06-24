<?php

namespace App\Http\Requests;

class ListDotationEmployeesRequest extends ApiRequest
{
    public function rules(): array
    {
        return [
            'texto_busqueda' => ['nullable', 'string', 'max:150'],
            'id_area' => ['nullable', 'integer'],
            'id_cargo' => ['nullable', 'integer'],
        ];
    }
}
