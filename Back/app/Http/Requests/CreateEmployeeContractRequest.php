<?php

namespace App\Http\Requests;

class CreateEmployeeContractRequest extends ApiRequest
{
    public function rules(): array
    {
        return [
            'id_tipo_contrato' => ['nullable', 'integer'],
            'id_area' => ['nullable', 'integer'],
            'id_cargo' => ['nullable', 'integer'],
            'fecha_inicio' => ['required', 'date'],
            'fecha_fin' => ['nullable', 'date', 'after_or_equal:fecha_inicio'],
            'duracion_meses' => ['nullable', 'integer', 'min:0'],
            'salario_base' => ['nullable', 'numeric', 'min:0'],
            'auxilio_transporte' => ['nullable', 'boolean'],
            'periodo_pago' => ['nullable', 'string', 'max:100'],
            'lugar_labores' => ['nullable', 'string', 'max:250'],
            'numero_contrato' => ['nullable', 'string', 'max:100'],
            'tipo_cargo_contrato' => ['nullable', 'string', 'in:ADMINISTRATIVO,OPERATIVO,OTRO'],
            'objeto_obra_labor' => ['nullable', 'string'],
            'prorroga_dias' => ['nullable', 'integer', 'min:0'],
            'clausula_funciones' => ['nullable', 'string'],
            'jornada_laboral' => ['nullable', 'string', 'max:150'],
            'periodo_prueba_dias' => ['nullable', 'integer', 'min:0'],
            'estado_contrato' => ['nullable', 'string', 'in:ACTIVO,VENCIDO,RENOVADO,FINALIZADO,ANULADO'],
            'archivo_contrato_url' => ['nullable', 'string', 'max:500'],
            'observaciones' => ['nullable', 'string'],
        ];
    }
}
