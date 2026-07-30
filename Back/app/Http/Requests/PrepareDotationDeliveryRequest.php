<?php

namespace App\Http\Requests;

use Illuminate\Validation\Rule;

class PrepareDotationDeliveryRequest extends ApiRequest
{
    protected function prepareForValidation(): void
    {
        if ($this->has('origen_evidencia') && is_string($this->input('origen_evidencia'))) {
            $this->merge(['origen_evidencia' => strtoupper(trim($this->input('origen_evidencia')))]);
        }
    }

    public function rules(): array
    {
        return [
            'fecha_entrega' => ['required', 'date'],
            'origen_evidencia' => ['required', 'string', Rule::in(['ARCHIVO', 'URL'])],
            'evidencia_nombre_archivo' => ['nullable', 'string', 'max:255'],
            'evidencia_archivo' => [
                'required_if:origen_evidencia,ARCHIVO',
                'prohibited_if:origen_evidencia,URL',
                'file', 'max:5120', 'mimes:pdf,jpg,jpeg,png,webp,doc,docx',
            ],
            'evidencia_url' => [
                'required_if:origen_evidencia,URL',
                'prohibited_if:origen_evidencia,ARCHIVO',
                'url', 'max:500',
            ],
        ];
    }
}
