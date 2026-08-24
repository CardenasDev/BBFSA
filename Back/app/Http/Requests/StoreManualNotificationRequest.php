<?php

namespace App\Http\Requests;

use Illuminate\Validation\Rule;

class StoreManualNotificationRequest extends ApiRequest
{
    protected function prepareForValidation(): void
    {
        foreach (['type_code', 'priority'] as $field) {
            if (is_string($this->input($field))) {
                $this->merge([$field => strtoupper(trim($this->input($field)))]);
            }
        }
    }

    public function rules(): array
    {
        return [
            'type_code' => ['required', 'string', 'max:80'],
            'employee_id' => ['nullable', 'integer', 'min:1'],
            'recipient_user_id' => ['nullable', 'integer', 'min:1'],
            'title' => ['required', 'string', 'max:220'],
            'message' => ['required', 'string', 'max:1000'],
            'priority' => ['nullable', Rule::in(['BAJA', 'MEDIA', 'ALTA', 'CRITICA'])],
            'event_date' => ['nullable', 'date'],
            'due_date' => ['nullable', 'date', 'after_or_equal:event_date'],
            'action_url' => ['nullable', 'string', 'max:500'],
        ];
    }
}
