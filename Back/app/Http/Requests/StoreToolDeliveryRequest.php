<?php

namespace App\Http\Requests;

use Illuminate\Validation\Validator;

class StoreToolDeliveryRequest extends ApiRequest
{
    protected function prepareForValidation(): void
    {
        $tools = $this->input('herramientas');
        if (is_string($tools)) {
            $decoded = json_decode($tools, true);
            if (json_last_error() === JSON_ERROR_NONE) {
                $this->merge(['herramientas' => $decoded]);
            }
        }
    }

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
            'evidencias' => ['required', 'array', 'min:1'],
            'evidencias.*' => [
                'required', 'file', 'image', 'mimes:jpg,jpeg,png,webp',
                'max:'.config('tool_deliveries.evidence_max_kilobytes', 5120),
            ],
        ];
    }

    public function after(): array
    {
        return [
            function (Validator $validator): void {
                if (is_string($this->input('herramientas'))) {
                    $validator->errors()->add('herramientas', 'El detalle de herramientas debe ser un JSON válido.');
                }
            },
        ];
    }
}
