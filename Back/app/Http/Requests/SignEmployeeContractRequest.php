<?php

namespace App\Http\Requests;

use Illuminate\Validation\Rule;

class SignEmployeeContractRequest extends ApiRequest
{
    public function rules(): array
    {
        return [
            'fecha_firma' => ['required', 'date'],
            'observaciones' => ['nullable', 'string'],
            'origen' => ['required', 'string', Rule::in(['ARCHIVO', 'URL'])],
            'nombre_archivo' => ['nullable', 'string', 'max:255'],
            'archivo' => [
                'required_if:origen,ARCHIVO',
                'prohibited_if:origen,URL',
                'file',
                'max:5120',
                'mimes:pdf,jpg,jpeg,png,webp,doc,docx',
            ],
            'url' => [
                'required_if:origen,URL',
                'prohibited_if:origen,ARCHIVO',
                'url',
                'max:500',
            ],
        ];
    }

    public function messages(): array
    {
        return [
            'archivo.max' => 'El archivo no debe superar 5 MB.',
            'archivo.mimes' => 'El archivo debe ser de tipo pdf, jpg, jpeg, png, webp, doc o docx.',
        ];
    }
}
