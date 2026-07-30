<?php

namespace App\Http\Requests;

class BulkLoadEmployeeFileRequest extends ApiRequest
{
    public function rules(): array
    {
        return [
            'file' => [
                'required', 'file', 'max:'.config('bulk_load.max_file_kb', 5120),
                'extensions:xlsx',
                'mimetypes:application/vnd.openxmlformats-officedocument.spreadsheetml.sheet,application/zip,application/octet-stream',
            ],
        ];
    }

    public function messages(): array
    {
        return [
            'file.required' => 'Debes adjuntar un archivo XLSX.',
            'file.extensions' => 'El archivo debe tener extensión XLSX.',
            'file.mimetypes' => 'El archivo no corresponde a un XLSX válido.',
            'file.max' => 'El archivo supera el tamaño máximo permitido.',
        ];
    }
}
