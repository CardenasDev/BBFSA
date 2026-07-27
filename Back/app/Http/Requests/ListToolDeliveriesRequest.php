<?php

namespace App\Http\Requests;

use Illuminate\Validation\Rule;

class ListToolDeliveriesRequest extends ApiRequest
{
    public function rules(): array
    {
        return [
            'id_empleado' => ['nullable', 'integer', 'min:1'],
            'estado' => ['nullable', 'string', Rule::in(['pendiente', 'confirmada'])],
        ];
    }
}
