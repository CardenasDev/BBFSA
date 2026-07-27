<?php

namespace App\Http\Requests;

class StoreToolDeliveryRequest extends ApiRequest
{
    public function rules(): array
    {
        return [
            'id_empleado' => ['required', 'integer', 'min:1'],
            'fecha_entrega' => ['required', 'date_format:Y-m-d'],
            'observaciones' => ['nullable', 'string', 'max:1000'],
            'herramientas' => ['required', 'array', 'min:1'],
            'herramientas.*.id_herramienta' => ['required', 'integer', 'min:1'],
            'herramientas.*.cantidad' => ['required', 'integer', 'min:1'],
            'herramientas.*.observaciones' => ['nullable', 'string', 'max:1000'],
        ];
    }
}
