<?php

namespace App\Http\Requests;

use Illuminate\Contracts\Validation\Validator;

class CreateMedicalExamRequest extends ApiRequest
{
    public function rules(): array
    {
        return [
            'id_tipo_examen_medico' => ['required', 'integer'],
            'fecha_examen' => ['required', 'date'],
            'entidad_realiza' => ['nullable', 'string', 'max:200'],
            'resultado_general' => ['nullable', 'string', 'max:250'],
            'fecha_vencimiento' => ['nullable', 'date', 'after_or_equal:fecha_examen'],
            'archivo_url' => ['nullable', 'string', 'max:500'],
            'archivo' => ['nullable', 'file', 'max:5120', 'mimes:pdf,jpg,jpeg,png,webp,doc,docx'],
            'observaciones' => ['nullable', 'string'],
        ];
    }

    public function withValidator(Validator $validator): void
    {
        $validator->after(function (Validator $validator): void {
            $url = $this->input('archivo_url');
            $hasUrl = is_string($url) && trim($url) !== '';

            if ($hasUrl && $this->hasFile('archivo')) {
                $validator->errors()->add('archivo', 'Seleccione un archivo físico o una URL externa, no ambos.');
            }
        });
    }

    public function messages(): array
    {
        return [
            'archivo.max' => 'El archivo no debe superar 5 MB.',
            'archivo.mimes' => 'El archivo debe ser PDF, JPG, JPEG, PNG, WEBP, DOC o DOCX.',
        ];
    }
}
