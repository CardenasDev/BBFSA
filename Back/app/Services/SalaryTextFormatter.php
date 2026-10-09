<?php

namespace App\Services;

use InvalidArgumentException;

/** Conversión exacta de DECIMAL(12,2), sin aritmética flotante. */
class SalaryTextFormatter
{
    public function format(mixed $value): array
    {
        if ((! is_string($value) && ! is_int($value)) || ! preg_match('/^\d{1,10}(?:\.\d{1,2})?$/D', (string) $value)) {
            throw new InvalidArgumentException('Salario decimal inválido.');
        }
        [$whole, $fraction] = array_pad(explode('.', (string) $value), 2, '');
        $number = (int) $whole;
        $cents = (int) str_pad($fraction, 2, '0');
        if ($number === 0 && $cents === 0) { throw new InvalidArgumentException('El salario debe ser mayor que cero.'); }
        $digits = preg_replace('/\B(?=(\d{3})+(?!\d))/', '.', (string) $number);

        return ['decimal' => $number.'.'.sprintf('%02d', $cents),
            'cifra' => '$'.$digits.','.sprintf('%02d', $cents),
            'letras' => $this->words($number).($number > 0 && $number % 1000000 === 0 ? ' de' : '').($number === 1 ? ' peso colombiano' : ' pesos colombianos').($cents ? ' con '.$this->words($cents).($cents === 1 ? ' centavo' : ' centavos') : '')];
    }

    private function words(int $n): string
    {
        $small = ['cero', 'un', 'dos', 'tres', 'cuatro', 'cinco', 'seis', 'siete', 'ocho', 'nueve', 'diez', 'once', 'doce', 'trece', 'catorce', 'quince', 'dieciséis', 'diecisiete', 'dieciocho', 'diecinueve', 'veinte', 'veintiún', 'veintidós', 'veintitrés', 'veinticuatro', 'veinticinco', 'veintiséis', 'veintisiete', 'veintiocho', 'veintinueve'];
        if ($n < 30) { return $small[$n]; }
        if ($n < 100) { return [3 => 'treinta', 'cuarenta', 'cincuenta', 'sesenta', 'setenta', 'ochenta', 'noventa'][intdiv($n, 10)].($n % 10 ? ' y '.$this->words($n % 10) : ''); }
        if ($n === 100) { return 'cien'; }
        if ($n < 1000) { return [1 => 'ciento', 'doscientos', 'trescientos', 'cuatrocientos', 'quinientos', 'seiscientos', 'setecientos', 'ochocientos', 'novecientos'][intdiv($n, 100)].($n % 100 ? ' '.$this->words($n % 100) : ''); }
        if ($n < 1000000) { return (intdiv($n, 1000) === 1 ? '' : $this->words(intdiv($n, 1000)).' ').'mil'.($n % 1000 ? ' '.$this->words($n % 1000) : ''); }
        return (intdiv($n, 1000000) === 1 ? 'un millón' : $this->words(intdiv($n, 1000000)).' millones').($n % 1000000 ? ' '.$this->words($n % 1000000) : '');
    }
}
