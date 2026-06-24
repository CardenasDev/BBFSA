<?php

namespace App\Http\Requests;

class CreateDotationDeliveryRequest extends ApiRequest
{
    public function rules(): array
    {
        return [
            'id_empleado' => ['required', 'integer'],
            'fecha_entrega' => ['required', 'date'],
            'observaciones' => ['nullable', 'string'],
            'detalles' => ['required', 'array', 'min:1'],
            'detalles.*.id_tipo_dotacion' => ['required', 'integer'],
            'detalles.*.id_talla_dotacion' => ['nullable', 'integer'],
            'detalles.*.cantidad' => ['required', 'integer', 'min:1'],
            'detalles.*.observaciones' => ['nullable', 'string', 'max:250'],
        ];
    }
}
