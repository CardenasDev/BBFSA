<?php

namespace App\Http\Requests;

use Illuminate\Validation\Rule;

class CreateDotationDeliveryRequest extends ApiRequest
{
    protected function prepareForValidation(): void
    {
        if ($this->has('tipo_entrega') && is_string($this->input('tipo_entrega'))) {
            $this->merge(['tipo_entrega' => strtoupper(trim($this->input('tipo_entrega')))]);
        }
    }

    public function rules(): array
    {
        return [
            'id_empleado' => ['required', 'integer', 'min:1'],
            'fecha_entrega' => ['required', 'date'],
            'tipo_entrega' => ['required', 'string', Rule::in(['ORDINARIA', 'EXTRAORDINARIA'])],
            'id_dotacion_combinacion' => [
                'nullable',
                'integer',
                'min:1',
                'required_if:tipo_entrega,ORDINARIA',
                'prohibited_if:tipo_entrega,EXTRAORDINARIA',
            ],
            'observaciones' => ['nullable', 'string'],
            'detalles' => ['required', 'array', 'min:1'],
            'detalles.*.id_tipo_dotacion' => ['required', 'integer', 'min:1'],
            'detalles.*.id_talla_dotacion' => ['nullable', 'integer', 'min:1'],
            'detalles.*.cantidad' => ['required', 'integer', 'min:1'],
            'detalles.*.observaciones' => ['nullable', 'string', 'max:250'],
        ];
    }
}
