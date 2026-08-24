<?php

namespace App\Http\Requests;

class ListNotificationsRequest extends ApiRequest
{
    protected function prepareForValidation(): void
    {
        if ($this->has('unread_only')) {
            $this->merge(['unread_only' => $this->boolean('unread_only')]);
        }
    }

    public function rules(): array
    {
        return [
            'unread_only' => ['sometimes', 'boolean'],
            'limit' => ['sometimes', 'integer', 'min:1', 'max:200'],
        ];
    }
}
