<?php

namespace Tests\Unit;

use App\Services\SalaryTextFormatter;
use InvalidArgumentException;
use PHPUnit\Framework\TestCase;

class SalaryTextFormatterTest extends TestCase
{
    public function test_exact_decimal_and_spanish_words(): void
    {
        $formatter = new SalaryTextFormatter;
        $this->assertSame(['decimal' => '1750905.00', 'cifra' => '$1.750.905,00', 'letras' => 'un millón setecientos cincuenta mil novecientos cinco pesos colombianos'], $formatter->format('1750905.00'));
        $this->assertSame('veintiún pesos colombianos con un centavo', $formatter->format('21.01')['letras']);
        $this->assertSame('$9.999.999.999,99', $formatter->format('9999999999.99')['cifra']);
        $this->assertSame('nueve mil novecientos noventa y nueve millones novecientos noventa y nueve mil novecientos noventa y nueve pesos colombianos con noventa y nueve centavos', $formatter->format('9999999999.99')['letras']);
        $this->assertSame('un millón de pesos colombianos', $formatter->format('1000000')['letras']);
    }

    public function test_rejects_binary_floats_and_excess_precision(): void
    {
        foreach ([1.25, '1.001', '-1', '0', null, '10000000000', '1e3'] as $value) {
            try {
                (new SalaryTextFormatter)->format($value);
                $this->fail('Aceptó un salario inválido.');
            } catch (InvalidArgumentException) {
                $this->addToAssertionCount(1);
            }
        }
    }
}
