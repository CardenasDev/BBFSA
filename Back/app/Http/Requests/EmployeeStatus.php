<?php

namespace App\Http\Requests;

final class EmployeeStatus
{
    public static function values(): array
    {
        return [
            'ACTIVO',
            'RETIRADO',
            'SUSPENDIDO',
            'INCAPACITADO',
            'EN_PROCESO_RETIRO',
        ];
    }
}
