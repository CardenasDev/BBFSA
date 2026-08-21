<?php

namespace App\Http\Requests;

use Illuminate\Validation\Rule;

class UpdateDotationEvidenceRequest extends ApiRequest
{
    protected function prepareForValidation(): void
    {
        if (is_string($this->input('origen_evidencia'))) {
            $this->merge(['origen_evidencia' => strtoupper(trim($this->input('origen_evidencia')))]);
        }
    }

    public function rules(): array
    {
        return [
            'origen_evidencia' => ['required', Rule::in(['ARCHIVO', 'URL'])],
            'evidencia_nombre_archivo' => ['nullable', 'string', 'max:255'],
            'evidencia_archivo' => ['required_if:origen_evidencia,ARCHIVO', 'prohibited_if:origen_evidencia,URL', 'nullable', 'file', 'max:5120', 'mimes:pdf,jpg,jpeg,png,webp,doc,docx'],
            'evidencia_url' => ['required_if:origen_evidencia,URL', 'prohibited_if:origen_evidencia,ARCHIVO', 'nullable', 'url:http,https', 'max:500'],
        ];
    }

    public function messages(): array
    {
        return [
            'evidencia_archivo.max' => 'El archivo de evidencia no debe superar 5 MB.',
            'evidencia_archivo.mimes' => 'La evidencia debe ser pdf, jpg, jpeg, png, webp, doc o docx.',
        ];
    }
}
