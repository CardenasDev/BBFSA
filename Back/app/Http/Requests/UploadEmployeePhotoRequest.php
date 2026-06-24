<?php

namespace App\Http\Requests;

class UploadEmployeePhotoRequest extends ApiRequest
{
    public function rules(): array
    {
        return [
            'photo' => ['required', 'image', 'mimes:jpg,jpeg,png,webp', 'max:2048'],
        ];
    }

    public function messages(): array
    {
        return [
            'photo.required' => 'La foto del empleado es obligatoria.',
            'photo.image' => 'El archivo debe ser una imagen valida.',
            'photo.mimes' => 'La foto debe ser de tipo jpg, jpeg, png o webp.',
            'photo.max' => 'La foto no debe superar 2 MB.',
        ];
    }
}
