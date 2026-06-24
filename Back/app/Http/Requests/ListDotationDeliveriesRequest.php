<?php

namespace App\Http\Requests;

class ListDotationDeliveriesRequest extends ApiRequest
{
    public function rules(): array
    {
        return [
            'id_empleado' => ['nullable', 'integer'],
            'fecha_inicio' => ['nullable', 'date'],
            'fecha_fin' => ['nullable', 'date'],
        ];
    }
}
