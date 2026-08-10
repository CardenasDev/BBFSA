<?php

namespace App\Http\Requests;

class ImportTrainingMatrixRequest extends ApiRequest
{
    public function rules(): array
    {
        return ['archivo' => ['required', 'file', 'mimes:xlsx', 'max:10240']];
    }
}
