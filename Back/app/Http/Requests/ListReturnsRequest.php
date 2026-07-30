<?php

namespace App\Http\Requests;

use Illuminate\Validation\Rule;

class ListReturnsRequest extends ApiRequest
{
    protected function prepareForValidation(): void
    {
        foreach (['type', 'status'] as $field) {
            if (is_string($this->input($field))) {
                $this->merge([$field => strtoupper(trim($this->input($field)))]);
            }
        }
    }

    public function rules(): array
    {
        return [
            'type' => ['nullable', Rule::in(['DOTACION', 'HERRAMIENTA'])],
            'employee_id' => ['nullable', 'integer', 'min:1'],
            'status' => ['nullable', Rule::in(['REGISTRADA', 'CONFIRMADA', 'ANULADA'])],
            'date_from' => ['nullable', 'date'],
            'date_to' => ['nullable', 'date', 'after_or_equal:date_from'],
        ];
    }
}
