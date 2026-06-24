<?php

namespace App\Http\Requests;

use Illuminate\Validation\Rule;

class ChangeEmployeeStatusRequest extends ApiRequest
{
    public function rules(): array
    {
        return [
            'estado_empleado' => ['required', Rule::in(EmployeeStatus::values())],
            'fecha_retiro' => ['nullable', 'date'],
        ];
    }

    public function messages(): array
    {
        return [
            'estado_empleado.required' => 'El estado laboral es obligatorio.',
            'estado_empleado.in' => 'El estado laboral no es valido.',
            'fecha_retiro.date' => 'La fecha de retiro debe ser una fecha valida.',
        ];
    }
}
