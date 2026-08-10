<?php

namespace App\Http\Requests;

class UpdateTrainingCommitmentRequest extends ApiRequest
{
    public function rules(): array
    {
        return ['estado' => ['required', 'in:BORRADOR,PENDIENTE_FIRMA,FIRMADO,CUMPLIDO,INCUMPLIDO,ANULADO'], 'documento_url' => ['nullable', 'url', 'max:500'], 'documento' => ['nullable', 'file', 'mimes:pdf,doc,docx', 'max:10240'], 'firma_url' => ['nullable', 'url', 'max:500'], 'firma' => ['nullable', 'image', 'mimes:jpg,jpeg,png', 'max:5120'], 'observaciones' => ['nullable', 'string']];
    }
}
