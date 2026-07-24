<?php

namespace Tests\Unit;

use App\Repositories\EmployeeRepository;
use App\Services\AuditService;
use App\Services\EmployeeService;
use DateTimeInterface;
use Mockery;
use OpenSpout\Reader\XLSX\Reader;
use Tests\TestCase;

class EmployeeExportTest extends TestCase
{
    public function test_export_with_data_preserves_column_order_and_cell_types(): void
    {
        $row = array_fill_keys(array_values(EmployeeService::ACTIVE_REPORT_COLUMNS), 'OK');
        $row['numero_carpeta'] = '0007';
        $row['documento'] = '001234567890123456';
        $row['celular'] = '03001234567';
        $row['salario'] = '1850000.50';
        foreach ($this->dateAliases() as $alias) {
            $row[$alias] = '2026-07-23';
        }
        $row['observaciones'] = null;

        $export = $this->serviceReturning([$row])->exportActiveEmployees();

        try {
            [$sheetName, $rows] = $this->readWorkbook($export['path']);

            $this->assertSame(EmployeeService::ACTIVE_REPORT_SHEET, $sheetName);
            $this->assertCount(2, $rows);
            $this->assertSame(array_keys(EmployeeService::ACTIVE_REPORT_COLUMNS), $rows[0]);
            $this->assertSame('0007', $rows[1][0]);
            $this->assertSame('001234567890123456', $rows[1][3]);
            $this->assertInstanceOf(DateTimeInterface::class, $rows[1][4]);
            $this->assertSame('03001234567', $rows[1][13]);
            $this->assertSame(1850000.5, $rows[1][19]);
            $this->assertSame('', $rows[1][47]);
        } finally {
            @unlink($export['path']);
        }
    }

    public function test_export_without_data_generates_only_headers(): void
    {
        $export = $this->serviceReturning([])->exportActiveEmployees();

        try {
            [, $rows] = $this->readWorkbook($export['path']);

            $this->assertCount(1, $rows);
            $this->assertCount(50, $rows[0]);
            $this->assertSame(array_keys(EmployeeService::ACTIVE_REPORT_COLUMNS), $rows[0]);
        } finally {
            @unlink($export['path']);
        }
    }

    public function test_export_rejects_a_row_when_an_expected_alias_is_missing(): void
    {
        $this->expectException(\UnexpectedValueException::class);
        $this->expectExceptionMessage('numero_carpeta');

        $this->serviceReturning([['documento' => '123']])->exportActiveEmployees();
    }

    private function serviceReturning(array $rows): EmployeeService
    {
        $repository = Mockery::mock(EmployeeRepository::class);
        $repository->shouldReceive('getActiveEmployeesReport')->once()->andReturn($rows);

        return new EmployeeService($repository, Mockery::mock(AuditService::class));
    }

    private function readWorkbook(string $path): array
    {
        $reader = new Reader();
        $reader->open($path);

        try {
            foreach ($reader->getSheetIterator() as $sheet) {
                $rows = [];
                foreach ($sheet->getRowIterator() as $row) {
                    $rows[] = array_map(
                        static fn ($cell) => $cell->getValue(),
                        $row->getCells(),
                    );
                }

                return [$sheet->getName(), $rows];
            }
        } finally {
            $reader->close();
        }

        return [null, []];
    }

    private function dateAliases(): array
    {
        return [
            'fecha_expedicion_documento',
            'fecha_ingreso',
            'fecha_nacimiento',
            'fecha_finalizacion_contrato',
            'ultimo_examen_medico',
            'contrato_arrendamiento',
            'bateria_riesgo_psicosocial',
            'ultima_entrega_dotaciones',
        ];
    }
}
