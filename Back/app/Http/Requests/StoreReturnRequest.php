<?php

namespace App\Http\Requests;

use Illuminate\Validation\Rule;
use Illuminate\Validation\Validator;

class StoreReturnRequest extends ApiRequest
{
    protected function prepareForValidation(): void
    {
        $details = $this->input('details');
        if (is_string($details)) {
            $decoded = json_decode($details, true);
            if (json_last_error() === JSON_ERROR_NONE) {
                $details = $decoded;
            }
        }
        if (is_array($details)) {
            foreach ($details as &$detail) {
                if (is_array($detail) && is_string($detail['estado_elemento'] ?? null)) {
                    $detail['estado_elemento'] = strtoupper(trim($detail['estado_elemento']));
                }
            }
            unset($detail);
        }

        $this->merge([
            'type' => is_string($this->input('type')) ? strtoupper(trim($this->input('type'))) : $this->input('type'),
            'details' => $details,
        ]);
    }

    public function rules(): array
    {
        return [
            'type' => ['required', Rule::in(['DOTACION', 'HERRAMIENTA'])],
            'employee_id' => ['required', 'integer', 'min:1'],
            'delivery_id' => ['required', 'integer', 'min:1'],
            'return_date' => ['required', 'date', 'before_or_equal:today'],
            'reason' => ['required', 'string', 'max:500'],
            'observations' => ['nullable', 'string', 'max:1000'],
            'details' => ['required', 'array', 'min:1'],
            'details.*.id_detalle' => ['required', 'integer', 'min:1', 'distinct:strict'],
            'details.*.cantidad' => ['required', 'integer', 'min:1'],
            'details.*.estado_elemento' => [
                'required',
                Rule::in(['BUENO', 'USADO', 'DETERIORADO', 'DANADO', 'INCOMPLETO', 'NO_FUNCIONAL']),
            ],
            'details.*.observaciones' => ['nullable', 'string', 'max:500'],
            'evidence' => ['required', 'array', 'min:1'],
            'evidence.*' => [
                'required',
                'file',
                'max:'.config('returns.max_evidence_kilobytes', 5120),
            ],
        ];
    }

    public function after(): array
    {
        return [
            function (Validator $validator): void {
                if (! is_array($this->input('details'))) {
                    $validator->errors()->add('details', 'Los detalles deben ser un JSON válido.');
                }
            },
        ];
    }

    public function messages(): array
    {
        return [
            'evidence.required' => 'Debe adjuntar al menos una evidencia.',
            'evidence.min' => 'Debe adjuntar al menos una evidencia.',
            'details.*.id_detalle.distinct' => 'No se permiten detalles repetidos.',
        ];
    }
}
