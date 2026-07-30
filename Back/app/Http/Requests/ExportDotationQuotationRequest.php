<?php

namespace App\Http\Requests;

class ExportDotationQuotationRequest extends ApiRequest
{
    protected function prepareForValidation(): void
    {
        $filters = [];

        foreach (['id_area', 'id_cargo', 'id_empleado'] as $filter) {
            if (! $this->query->has($filter)) {
                continue;
            }

            $value = $this->query($filter);
            if ($value === null || trim((string) $value) === '' || (is_numeric($value) && (float) $value === 0.0)) {
                $filters[$filter] = null;
            }
        }

        if ($filters !== []) {
            $this->merge($filters);
        }
    }

    public function rules(): array
    {
        return [
            'id_area' => ['nullable', 'integer', 'min:1'],
            'id_cargo' => ['nullable', 'integer', 'min:1'],
            'id_empleado' => ['nullable', 'integer', 'min:1'],
        ];
    }
}
