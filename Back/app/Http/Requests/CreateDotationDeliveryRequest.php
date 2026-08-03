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
        $this->merge([
            'estado_inicial' => strtoupper(trim((string) $this->input('estado_inicial', 'REGISTRADA'))),
        ]);
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
            'estado_inicial' => ['required', 'string', Rule::in(['POR_COMPRAR', 'REGISTRADA'])],
            'id_dotacion_combinacion' => [
                'nullable',
                'integer',
                'min:1',
                'prohibited_if:tipo_entrega,EXTRAORDINARIA',
            ],
            'observaciones' => ['nullable', 'string'],
            'origen_evidencia' => ['required_if:estado_inicial,REGISTRADA', 'prohibited_if:estado_inicial,POR_COMPRAR', 'nullable', 'string', Rule::in(['ARCHIVO', 'URL'])],
            'evidencia_nombre_archivo' => ['prohibited_if:estado_inicial,POR_COMPRAR', 'nullable', 'string', 'max:255'],
            'evidencia_archivo' => [
                'prohibited_if:estado_inicial,POR_COMPRAR',
                'required_if:origen_evidencia,ARCHIVO',
                'prohibited_if:origen_evidencia,URL',
                'file',
                'max:5120',
                'mimes:pdf,jpg,jpeg,png,webp,doc,docx',
            ],
            'evidencia_url' => [
                'prohibited_if:estado_inicial,POR_COMPRAR',
                'required_if:origen_evidencia,URL',
                'prohibited_if:origen_evidencia,ARCHIVO',
                'url',
                'max:500',
            ],
            'detalles' => ['required', 'array', 'min:1'],
            'detalles.*.id_dotacion_articulo' => ['required', 'integer', 'min:1'],
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
            'origen_evidencia.prohibited_if' => 'Una solicitud por comprar no debe incluir origen de evidencia.',
            'evidencia_nombre_archivo.prohibited_if' => 'Una solicitud por comprar no debe incluir nombre de evidencia.',
            'evidencia_archivo.prohibited_if' => 'Una solicitud por comprar no debe incluir archivos de evidencia.',
            'evidencia_url.prohibited_if' => 'Una solicitud por comprar no debe incluir URL de evidencia.',
        ];
    }
}
