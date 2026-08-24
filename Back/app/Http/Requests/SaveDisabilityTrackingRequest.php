<?php

namespace App\Http\Requests;

use Illuminate\Validation\Rule;

class SaveDisabilityTrackingRequest extends ApiRequest
{
    protected function prepareForValidation(): void
    {
        foreach (['transcription_status', 'transcription_channel', 'payment_request_status', 'tracking_status'] as $field) {
            if (is_string($this->input($field))) {
                $this->merge([$field => strtoupper(trim($this->input($field)))]);
            }
        }
    }

    public function rules(): array
    {
        return [
            'responsible_entity_id' => ['nullable', 'integer', 'min:1'],
            'days_paid_company' => ['required', 'integer', 'min:0'],
            'days_payable_entity' => ['required', 'integer', 'min:0'],
            'transcription_status' => ['required', Rule::in(['NO_REQUIERE', 'PENDIENTE', 'TRANSCRITA', 'RECHAZADA'])],
            'transcription_channel' => ['nullable', Rule::in(['PLATAFORMA', 'CORREO', 'PRESENCIAL', 'OTRO'])],
            'transcription_date' => ['nullable', 'date'],
            'payment_request_status' => ['required', Rule::in(['NO_REQUIERE', 'PENDIENTE', 'RADICADA', 'EN_ESTUDIO', 'APROBADA', 'RECHAZADA', 'PAGADA_PARCIAL', 'PAGADA'])],
            'payment_request_date' => ['nullable', 'date'],
            'disability_value' => ['required', 'numeric', 'min:0'],
            'entity_received_value' => ['required', 'numeric', 'min:0'],
            'company_paid_worker_value' => ['required', 'numeric', 'min:0'],
            'worker_paid_value' => ['required', 'numeric', 'min:0'],
            'last_payment_date' => ['nullable', 'date'],
            'tracking_status' => ['required', Rule::in(['PENDIENTE', 'EN_TRAMITE', 'CERRADO', 'CANCELADO'])],
            'tracking_observations' => ['nullable', 'string', 'max:5000'],
        ];
    }
}
