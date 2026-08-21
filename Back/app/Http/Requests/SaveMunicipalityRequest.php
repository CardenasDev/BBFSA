<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class SaveMunicipalityRequest extends FormRequest
{
    public function authorize(): bool { return true; }
    public function rules(): array { return ['id_departamento'=>['required','integer','min:1'],'codigo_dane'=>['required','regex:/^\d{5}$/'],'nombre'=>['required','string','max:150'],'activo'=>['sometimes','boolean']]; }
}
