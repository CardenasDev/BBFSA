<?php

namespace App\Http\Requests;

use Illuminate\Validation\Rule;

class UpdateUserRequest extends ApiRequest
{
    public function rules(): array
    {
        $userId = (int) $this->route('id');

        return [
            'id_empleado' => ['nullable', 'integer', 'min:1'],
            'numero_documento_empleado' => ['nullable', 'string', 'max:50'],
            'nombre_usuario' => [
                'required',
                'string',
                'max:100',
                Rule::unique('bbf_usuarios', 'NOMBRE_USUARIO')->ignore($userId, 'ID_USUARIO'),
            ],
            'correo' => [
                'required',
                'email:rfc',
                'max:150',
                Rule::unique('bbf_usuarios', 'CORREO')->ignore($userId, 'ID_USUARIO'),
            ],
            'tipo_usuario' => ['required', Rule::in(['EMPLEADO', 'PERSONAL_AUTORIZADO', 'ADMIN'])],
            'tipo_autenticacion' => ['required', Rule::in(['LOCAL', 'DOMINIO_EMPRESA'])],
            'requiere_cambio_password' => ['nullable', 'boolean'],
            'correo_verificado' => ['nullable', 'boolean'],
        ];
    }

    public function messages(): array
    {
        return [
            'nombre_usuario.required' => 'El nombre de usuario es obligatorio.',
            'nombre_usuario.unique' => 'El nombre de usuario ya existe.',
            'correo.required' => 'El correo es obligatorio.',
            'correo.unique' => 'El correo ya esta registrado.',
            'correo.email' => 'El correo debe ser una direccion valida.',
            'tipo_usuario.in' => 'El tipo de usuario no es valido.',
            'tipo_autenticacion.in' => 'El tipo de autenticacion no es valido.',
        ];
    }
}
