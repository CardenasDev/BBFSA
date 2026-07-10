<?php

namespace App\Http\Requests;

use App\Exceptions\ApiException;
use Illuminate\Contracts\Validation\Validator;
use Illuminate\Validation\Rule;

class RegisterApplicantDocumentRequest extends ApiRequest
{
    public function rules(): array
    {
        return [
            'id_tipo_documento_laboral' => ['required', 'integer'],
            'nombre_archivo' => ['nullable', 'string', 'max:255'],
            'archivo_url' => ['nullable', 'string', 'max:500'],
            'archivo' => ['nullable', 'file', 'max:5120', 'mimes:pdf,jpg,jpeg,png,webp,doc,docx'],
            'estado_documento' => ['nullable', 'string', Rule::in(['PENDIENTE', 'CARGADO', 'VALIDADO', 'RECHAZADO', 'VENCIDO'])],
            'observaciones' => ['nullable', 'string'],
        ];
    }

    public function withValidator(Validator $validator): void
    {
        $validator->after(function (Validator $validator): void {
            $status = $this->input('estado_documento') ?: 'CARGADO';

            if ($status === 'PENDIENTE') {
                return;
            }

            $url = $this->input('archivo_url');
            $hasExternalUrl = is_string($url) && trim($url) !== '';

            if (! $hasExternalUrl && ! $this->hasFile('archivo')) {
                $validator->errors()->add('archivo_origen', 'Debe registrar una URL externa o cargar un archivo físico.');
            }
        });
    }

    protected function failedValidation(Validator $validator): void
    {
        $errors = $validator->errors()->toArray();

        if (array_keys($errors) === ['archivo_origen']) {
            throw new ApiException('Debe registrar una URL externa o cargar un archivo físico.', 422, $errors);
        }

        parent::failedValidation($validator);
    }

    public function messages(): array
    {
        return [
            'archivo.max' => 'El archivo no debe superar 5 MB.',
            'archivo.mimes' => 'El archivo debe ser de tipo pdf, jpg, jpeg, png, webp, doc o docx.',
        ];
    }
}
