<?php

namespace App\Http\Requests;

use Illuminate\Validation\Rule;

class ListAvailableReturnsRequest extends ApiRequest
{
    protected function prepareForValidation(): void
    {
        $this->merge([
            'type' => is_string($this->input('type')) ? strtoupper(trim($this->input('type'))) : $this->input('type'),
        ]);
    }

    public function rules(): array
    {
        return [
            'type' => ['required', Rule::in(['DOTACION', 'HERRAMIENTA'])],
            'employee_id' => ['required', 'integer', 'min:1'],
        ];
    }
}
