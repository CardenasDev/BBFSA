<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class SaveDepartmentRequest extends FormRequest
{
    public function authorize(): bool { return true; }
    public function rules(): array { return ['codigo_dane'=>['required','regex:/^\d{2}$/'],'nombre'=>['required','string','max:150'],'activo'=>['sometimes','boolean']]; }
}
