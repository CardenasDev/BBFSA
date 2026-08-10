<?php

namespace App\Http\Requests;

class SaveTrainingRequest extends ApiRequest
{
    public function rules(): array
    {
        return ['id_capacitacion' => ['nullable', 'integer', 'min:1'], 'codigo' => ['required', 'string', 'max:50', 'regex:/^[A-Z0-9_-]+$/'], 'nombre' => ['required', 'string', 'max:200'], 'descripcion' => ['nullable', 'string'], 'tipo' => ['required', 'in:CAPACITACION,INDUCCION,REINDUCCION,EVALUACION_REINDUCCION'], 'requiere_evaluacion' => ['nullable', 'boolean'], 'requiere_confirmacion' => ['nullable', 'boolean'], 'puntaje_minimo' => ['nullable', 'numeric', 'min:0'], 'puntaje_maximo' => ['nullable', 'numeric', 'gt:puntaje_minimo'], 'regla_calculo' => ['nullable', 'string', 'max:500'], 'generar_compromiso_no_aprobado' => ['nullable', 'boolean'], 'dias_para_evaluar' => ['nullable', 'integer', 'min:0'], 'activo' => ['nullable', 'boolean']];
    }
}
