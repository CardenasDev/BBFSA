<?php

namespace Tests\Unit;

use App\Exceptions\ApiException;
use App\Repositories\DotationRepository;
use App\Services\AuditService;
use App\Services\DotationService;
use DateTimeInterface;
use Mockery;
use OpenSpout\Reader\XLSX\Reader;
use OpenSpout\Common\Entity\Cell\StringCell;
use Tests\TestCase;

class DotationPurchaseQuotationExportTest extends TestCase
{
    public function test_export_contains_grouped_summary_and_employee_detail_with_correct_types(): void
    {
        $repository = Mockery::mock(DotationRepository::class);
        $repository->shouldReceive('purchaseQuotationReport')->once()->with(5, 9, null)->andReturn([
            $this->row(['cantidad' => 2]),
            $this->row([
                'id_dotacion_entrega' => 32,
                'numero_documento' => '0000456',
                'nombre_completo' => 'Luis Gómez',
                'tipo_dotacion' => 'Pantalón',
                'talla' => '32',
                'cantidad' => 3,
            ]),
        ]);
        $service = new DotationService($repository, Mockery::mock(AuditService::class));

        $export = $service->exportPurchaseQuotation(5, 9, null);
        try {
            $sheets = $this->readWorkbook($export['path']);
            $this->assertSame(['Resumen de compra', 'Detalle por empleado'], array_keys($sheets));
            $this->assertCount(2, $sheets);
            $this->assertSame(['Prenda', 'Talla', 'Cantidad total'], $sheets['Resumen de compra'][0]);
            $this->assertSame(2, $sheets['Resumen de compra'][1][2]);
            $this->assertSame(3, $sheets['Resumen de compra'][2][2]);
            $this->assertSame(
                ['Documento', 'Empleado', 'Prenda', 'Talla', 'Cantidad', 'ID solicitud', 'Fecha solicitud', 'Fecha requerida', 'Área', 'Cargo', 'Tipo de entrega', 'Combinación', 'Observaciones', 'Observaciones detalle', 'Estado'],
                $sheets['Detalle por empleado'][0],
            );
            $this->assertSame(['001234', 'Ana Pérez', 'Camisa', 'M', 2], array_slice($sheets['Detalle por empleado'][1], 0, 5));
            $this->assertSame(['0000456', 'Luis Gómez', 'Pantalón', '32', 3], array_slice($sheets['Detalle por empleado'][2], 0, 5));
            $this->assertInstanceOf(DateTimeInterface::class, $sheets['Detalle por empleado'][1][6]);
            $this->assertSame('POR_COMPRAR', $sheets['Detalle por empleado'][1][14]);
            $detailCells = $this->readDetailCells($export['path']);
            $this->assertInstanceOf(StringCell::class, $detailCells[1][0]);
            $this->assertSame('0000456', $detailCells[2][0]->getValue());
            $this->assertInstanceOf(StringCell::class, $detailCells[2][1]);
        } finally {
            @unlink($export['path']);
        }
    }

    public function test_export_without_purchase_requests_returns_404(): void
    {
        $repository = Mockery::mock(DotationRepository::class);
        $repository->shouldReceive('purchaseQuotationReport')->once()->andReturn([]);
        $service = new DotationService($repository, Mockery::mock(AuditService::class));

        $this->expectException(ApiException::class);
        $this->expectExceptionMessage('No hay solicitudes por comprar');
        $service->exportPurchaseQuotation(null, null, null);
    }

    private function row(array $overrides = []): array
    {
        return array_replace([
            'id_dotacion_entrega' => 31,
            'fecha_solicitud' => '2026-08-01',
            'fecha_requerida' => '2026-08-10',
            'numero_documento' => '001234',
            'nombre_completo' => 'Ana Pérez',
            'area' => 'Cultivo',
            'cargo' => 'Operaria',
            'tipo_entrega' => 'ORDINARIA',
            'nombre_combinacion' => 'Operativo',
            'tipo_dotacion' => 'Camisa',
            'talla' => 'M',
            'cantidad' => 2,
            'observaciones_solicitud' => 'Prioritaria',
            'estado' => 'POR_COMPRAR',
        ], $overrides);
    }

    private function readWorkbook(string $path): array
    {
        $reader = new Reader;
        $reader->open($path);
        $sheets = [];
        try {
            foreach ($reader->getSheetIterator() as $sheet) {
                foreach ($sheet->getRowIterator() as $row) {
                    $sheets[$sheet->getName()][] = array_map(
                        static fn ($cell) => $cell->getValue() ?? '',
                        $row->getCells(),
                    );
                }
            }
        } finally {
            $reader->close();
        }
        return $sheets;
    }

    private function readDetailCells(string $path): array
    {
        $reader = new Reader;
        $reader->open($path);
        try {
            foreach ($reader->getSheetIterator() as $sheet) {
                if ($sheet->getName() !== 'Detalle por empleado') {
                    continue;
                }
                $rows = [];
                foreach ($sheet->getRowIterator() as $row) {
                    $rows[] = $row->getCells();
                }
                return $rows;
            }
        } finally {
            $reader->close();
        }
        return [];
    }
}
