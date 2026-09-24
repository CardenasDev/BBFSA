<?php

namespace App\Http\Requests;

use Illuminate\Validation\Rule;

class StoreTrainingEvidenceRequest extends ApiRequest
{
    public function prepareForValidation(): void
    {
        if (is_string($this->input('tipo_evidencia'))) {
            $this->merge(['tipo_evidencia' => strtoupper(trim($this->input('tipo_evidencia')))]);
        }
    }

    public function rules(): array
    {
        return [
            'tipo_evidencia' => ['nullable', Rule::in(['ASISTENCIA', 'CONFIRMACION', 'EVALUACION', 'FIRMA', 'COMPROMISO', 'OTRA'])],
            'archivo' => ['required', 'file', 'max:10240', 'mimes:pdf,jpg,jpeg,png'],
        ];
    }
}
