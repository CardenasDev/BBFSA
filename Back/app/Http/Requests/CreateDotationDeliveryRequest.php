<?php

namespace App\Http\Requests;

use Illuminate\Validation\Rule;

class CreateDotationDeliveryRequest extends ApiRequest
{
    protected function prepareForValidation(): void
    {
        if ($this->has('tipo_entrega') && is_string($this->input('tipo_entrega'))) {
            $this->merge(['tipo_entrega' => strtoupper(trim($this->input('tipo_entrega')))]);
        }
        if ($this->has('origen_evidencia') && is_string($this->input('origen_evidencia'))) {
            $this->merge(['origen_evidencia' => strtoupper(trim($this->input('origen_evidencia')))]);
        }
    }

    public function rules(): array
    {
        return [
            'id_empleado' => ['required', 'integer', 'min:1'],
            'fecha_entrega' => ['required', 'date'],
            'tipo_entrega' => ['required', 'string', Rule::in(['ORDINARIA', 'EXTRAORDINARIA'])],
            'id_dotacion_combinacion' => [
                'nullable',
                'integer',
                'min:1',
                'required_if:tipo_entrega,ORDINARIA',
                'prohibited_if:tipo_entrega,EXTRAORDINARIA',
            ],
            'observaciones' => ['nullable', 'string'],
            'origen_evidencia' => ['required', 'string', Rule::in(['ARCHIVO', 'URL'])],
            'evidencia_nombre_archivo' => ['nullable', 'string', 'max:255'],
            'evidencia_archivo' => [
                'required_if:origen_evidencia,ARCHIVO',
                'prohibited_if:origen_evidencia,URL',
                'file',
                'max:5120',
                'mimes:pdf,jpg,jpeg,png,webp,doc,docx',
            ],
            'evidencia_url' => [
                'required_if:origen_evidencia,URL',
                'prohibited_if:origen_evidencia,ARCHIVO',
                'url',
                'max:500',
            ],
            'detalles' => ['required', 'array', 'min:1'],
            'detalles.*.id_tipo_dotacion' => ['required', 'integer', 'min:1'],
            'detalles.*.id_talla_dotacion' => ['nullable', 'integer', 'min:1'],
            'detalles.*.cantidad' => ['required', 'integer', 'min:1'],
            'detalles.*.observaciones' => ['nullable', 'string', 'max:250'],
        ];
    }

    public function messages(): array
    {
        return [
            'evidencia_archivo.max' => 'El archivo de evidencia no debe superar 5 MB.',
            'evidencia_archivo.mimes' => 'La evidencia debe ser de tipo pdf, jpg, jpeg, png, webp, doc o docx.',
        ];
    }
}
