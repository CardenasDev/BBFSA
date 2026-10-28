<?php

namespace App\Http\Requests;

class AddEvaluationEmployeeRequest extends ApiRequest
{
    public function rules(): array
    {
        return [
            'id_empleado' => ['required', 'integer', 'min:1'],
            'observaciones' => ['nullable', 'string'],
        ];
    }
}
