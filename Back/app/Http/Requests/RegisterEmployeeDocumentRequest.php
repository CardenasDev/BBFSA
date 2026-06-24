<?php

namespace App\Http\Requests;

class RegisterEmployeeDocumentRequest extends ApiRequest
{
    public function rules(): array
    {
        return [
            'id_tipo_documento_laboral' => ['required', 'integer'],
            'nombre_archivo' => ['required', 'string', 'max:255'],
            'archivo_url' => ['required', 'string', 'max:500'],
            'mime_type' => ['nullable', 'string', 'max:100'],
            'peso_bytes' => ['nullable', 'integer', 'min:0'],
            'fecha_vencimiento' => ['nullable', 'date'],
            'estado_documento' => ['nullable', 'string', 'in:PENDIENTE,CARGADO,VALIDADO,RECHAZADO,VENCIDO'],
            'observaciones' => ['nullable', 'string'],
        ];
    }
}
