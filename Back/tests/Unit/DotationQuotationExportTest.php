<?php

namespace Tests\Unit;

use App\Exceptions\ApiException;
use App\Repositories\DotationRepository;
use App\Services\AuditService;
use App\Services\DotationService;
use DateTimeInterface;
use Mockery;
use OpenSpout\Reader\XLSX\Reader;
use PHPUnit\Framework\Attributes\DataProvider;
use Tests\TestCase;

class DotationQuotationExportTest extends TestCase
{
    public function test_export_preserves_columns_and_types_and_represents_missing_data(): void
    {
        $delivered = $this->row();
        $withoutDelivery = $this->row([
            'numero_documento' => '0000456',
            'talla_actual' => null,
            'fecha_ultima_entrega' => null,
            'talla_ultima_entrega' => null,
            'cantidad_ultima_entrega' => null,
            'tipo_ultima_entrega' => null,
        ]);

        $export = $this->serviceReturning([$delivered, $withoutDelivery], 5, 9, 12)
            ->exportQuotation(5, 9, 12);

        try {
            [$sheetName, $rows] = $this->readWorkbook($export['path']);
            $this->assertSame(DotationService::QUOTATION_REPORT_SHEET, $sheetName);
            $this->assertSame(array_keys(DotationService::QUOTATION_REPORT_COLUMNS), $rows[0]);
            $columns = array_flip(array_values(DotationService::QUOTATION_REPORT_COLUMNS));
            $this->assertSame('001234', $rows[1][$columns['numero_documento']]);
            $this->assertSame('Camisa jean bordada', $rows[1][$columns['articulo']]);
            $this->assertSame('Especifica', $rows[1][$columns['origen_talla']]);
            $this->assertInstanceOf(DateTimeInterface::class, $rows[1][$columns['fecha_ultima_entrega']]);
            $this->assertSame(2, $rows[1][$columns['cantidad_ultima_entrega']]);
            $this->assertSame('0000456', $rows[2][$columns['numero_documento']]);
            $this->assertSame('Sin talla registrada', $rows[2][$columns['talla_actual']]);
            $this->assertSame('Sin entrega previa', $rows[2][$columns['fecha_ultima_entrega']]);
            $this->assertSame('', $rows[2][$columns['talla_ultima_entrega']]);
            $this->assertSame('', $rows[2][$columns['cantidad_ultima_entrega']]);
            $this->assertSame('', $rows[2][$columns['tipo_ultima_entrega']]);
        } finally {
            @unlink($export['path']);
        }
    }

    public function test_export_without_results_returns_controlled_not_found(): void
    {
        $this->expectException(ApiException::class);
        $this->expectExceptionMessage('No se encontró información de dotación');

        $this->serviceReturning([])->exportQuotation(null, null, null);
    }

    #[DataProvider('filterCases')]
    public function test_export_supports_each_optional_filter(?int $areaId, ?int $positionId, ?int $employeeId): void
    {
        $export = $this->serviceReturning([$this->row()], $areaId, $positionId, $employeeId)
            ->exportQuotation($areaId, $positionId, $employeeId);

        try {
            $this->assertFileExists($export['path']);
        } finally {
            @unlink($export['path']);
        }
    }

    public static function filterCases(): array
    {
        return [
            'without filters' => [null, null, null],
            'by area' => [5, null, null],
            'by position' => [null, 9, null],
            'by employee' => [null, null, 12],
        ];
    }

    private function serviceReturning(
        array $rows,
        ?int $areaId = null,
        ?int $positionId = null,
        ?int $employeeId = null,
    ): DotationService {
        $repository = Mockery::mock(DotationRepository::class);
        $repository->shouldReceive('quotationReport')
            ->once()
            ->with($areaId, $positionId, $employeeId)
            ->andReturn($rows);

        return new DotationService($repository, Mockery::mock(AuditService::class));
    }

    private function row(array $overrides = []): array
    {
        return array_replace([
            'numero_documento' => '001234',
            'nombre_completo' => 'Ana Pérez',
            'area' => 'Cultivo',
            'cargo' => 'Operaria',
            'articulo' => 'Camisa jean bordada',
            'tipo_dotacion' => 'Camisa',
            'talla_actual' => 'M',
            'origen_talla' => 'ESPECIFICA',
            'fecha_ultima_entrega' => '2026-07-15',
            'talla_ultima_entrega' => 'S',
            'cantidad_ultima_entrega' => '2',
            'tipo_ultima_entrega' => 'ORDINARIA',
            'estado_informacion' => 'COMPLETA',
            'observaciones_talla' => 'Talla actualizada',
            'observaciones_ultima_entrega' => null,
        ], $overrides);
    }

    private function readWorkbook(string $path): array
    {
        $reader = new Reader;
        $reader->open($path);

        try {
            foreach ($reader->getSheetIterator() as $sheet) {
                $rows = [];
                foreach ($sheet->getRowIterator() as $row) {
                    $rows[] = array_map(
                        static fn ($cell) => $cell->getValue() ?? '',
                        $row->getCells(),
                    );
                }

                return [$sheet->getName(), $rows];
            }
        } finally {
            $reader->close();
        }

        return ['', []];
    }
}
