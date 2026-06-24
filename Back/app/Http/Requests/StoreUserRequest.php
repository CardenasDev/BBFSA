<?php

namespace App\Http\Requests;

use Illuminate\Validation\Rule;
use Illuminate\Validation\Rules\Password;

class StoreUserRequest extends ApiRequest
{
    public function rules(): array
    {
        return [
            'id_empleado' => ['nullable', 'integer', 'min:1'],
            'numero_documento_empleado' => ['nullable', 'required_if:tipo_usuario,EMPLEADO', 'string', 'max:50'],
            'nombre_usuario' => ['required', 'string', 'max:100'],
            'correo' => ['required', 'email:rfc', 'max:150'],
            'password' => ['required', 'max:255', Password::min(8)->letters()->numbers()],
            'tipo_usuario' => ['required', Rule::in(['EMPLEADO', 'PERSONAL_AUTORIZADO', 'ADMIN'])],
            'tipo_autenticacion' => ['required', Rule::in(['LOCAL', 'DOMINIO_EMPRESA'])],
            'requiere_cambio_password' => ['required', 'boolean'],
            'correo_verificado' => ['required', 'boolean'],
        ];
    }

    public function messages(): array
    {
        return [
            'numero_documento_empleado.required_if' => 'El documento del empleado es obligatorio para usuarios de tipo EMPLEADO.',
            'tipo_usuario.in' => 'El tipo de usuario no es valido.',
        ];
    }
}
