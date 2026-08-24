<?php

namespace App\Http\Requests;

use Illuminate\Validation\Rule;

class ListDisabilityTrackingRequest extends ApiRequest
{
    protected function prepareForValidation(): void
    {
        if (is_string($this->input('tracking_status'))) {
            $this->merge(['tracking_status' => strtoupper(trim($this->input('tracking_status')))]);
        }
    }

    public function rules(): array
    {
        return [
            'employee_id' => ['nullable', 'integer', 'min:1'],
            'responsible_entity_id' => ['nullable', 'integer', 'min:1'],
            'tracking_status' => ['nullable', Rule::in(['PENDIENTE', 'EN_TRAMITE', 'CERRADO', 'CANCELADO'])],
            'date_from' => ['nullable', 'date'],
            'date_to' => ['nullable', 'date', 'after_or_equal:date_from'],
        ];
    }
}
