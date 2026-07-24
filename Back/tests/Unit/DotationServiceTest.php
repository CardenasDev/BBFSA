<?php

namespace Tests\Unit;

use App\Exceptions\ApiException;
use App\Repositories\DotationRepository;
use App\Services\AuditService;
use App\Services\DotationService;
use Illuminate\Http\UploadedFile;
use Mockery;
use RuntimeException;
use Tests\TestCase;

class DotationServiceTest extends TestCase
{
    public function test_creates_ordinary_delivery_with_exact_combination_and_employee_sizes(): void
    {
        [$service, $repository, $audit] = $this->service();
        $this->expectCatalogs($repository);
        $repository->shouldReceive('combinationDetails')->once()->with(1)->andReturn($this->combination());
        $repository->shouldReceive('createDelivery')->once()->with(
            5, '2026-07-24', 'ORDINARIA', 1, 99, null,
            'Evidencia entrega', null, 'https://example.com/evidencia.jpg', null, null, null,
        )->andReturn(20);
        $repository->shouldReceive('addDeliveryDetail')->times(3);
        $audit->shouldReceive('record')->once();

        $result = $service->createDelivery([
            'id_empleado' => 5,
            'fecha_entrega' => '2026-07-24',
            'tipo_entrega' => 'ORDINARIA',
            'id_dotacion_combinacion' => 1,
            'origen_evidencia' => 'URL',
            'evidencia_url' => 'https://example.com/evidencia.jpg',
            'detalles' => $this->details(),
        ], 99, []);

        $this->assertSame(20, $result['id_dotacion_entrega']);
        $this->assertSame('https://example.com/evidencia.jpg', $result['evidencia_url']);
        $this->assertNull($result['evidencia_ruta']);
    }

    public function test_rejects_ordinary_delivery_when_combination_item_is_missing(): void
    {
        [$service, $repository] = $this->service();
        $this->expectCatalogs($repository);
        $repository->shouldReceive('combinationDetails')->once()->with(1)->andReturn($this->combination());

        $this->expectException(ApiException::class);
        $this->expectExceptionMessage('Las prendas enviadas no corresponden a la combinación seleccionada.');

        $details = $this->details();
        array_pop($details);
        $service->createDelivery([
            'id_empleado' => 5,
            'fecha_entrega' => '2026-07-24',
            'tipo_entrega' => 'ORDINARIA',
            'id_dotacion_combinacion' => 1,
            'origen_evidencia' => 'URL',
            'evidencia_url' => 'https://example.com/evidencia.jpg',
            'detalles' => $details,
        ], 99, []);
    }

    public function test_rejects_size_different_from_employee_registered_size(): void
    {
        [$service, $repository] = $this->service();
        $this->expectCatalogs($repository);
        $repository->shouldReceive('combinationDetails')->once()->with(1)->andReturn($this->combination());

        $this->expectException(ApiException::class);
        $this->expectExceptionMessage('El empleado no tiene registrada la talla indicada para Chaqueta.');

        $details = $this->details();
        $details[0]['id_talla_dotacion'] = 99;
        $service->createDelivery([
            'id_empleado' => 5,
            'fecha_entrega' => '2026-07-24',
            'tipo_entrega' => 'ORDINARIA',
            'id_dotacion_combinacion' => 1,
            'origen_evidencia' => 'URL',
            'evidencia_url' => 'https://example.com/evidencia.jpg',
            'detalles' => $details,
        ], 99, []);
    }

    public function test_creates_extraordinary_delivery_without_combination(): void
    {
        [$service, $repository, $audit] = $this->service();
        $this->expectCatalogs($repository);
        $repository->shouldReceive('createDelivery')->once()->with(
            5, '2026-07-24', 'EXTRAORDINARIA', null, 99, null,
            'Evidencia entrega', null, 'https://example.com/evidencia.jpg', null, null, null,
        )->andReturn(21);
        $repository->shouldReceive('addDeliveryDetail')->once()->with(21, 3, 25, 1, null);
        $audit->shouldReceive('record')->once();

        $result = $service->createDelivery([
            'id_empleado' => 5,
            'fecha_entrega' => '2026-07-24',
            'tipo_entrega' => 'EXTRAORDINARIA',
            'id_dotacion_combinacion' => null,
            'origen_evidencia' => 'URL',
            'evidencia_url' => 'https://example.com/evidencia.jpg',
            'detalles' => [$this->details()[2]],
        ], 99, []);

        $this->assertSame(21, $result['id_dotacion_entrega']);
        $this->assertSame('EXTRAORDINARIA', $result['tipo_entrega']);
        $this->assertSame('https://example.com/evidencia.jpg', $result['evidencia_url_publica']);
    }

    public function test_deletes_new_evidence_file_when_header_creation_fails(): void
    {
        [$service, $repository] = $this->service();
        $this->expectCatalogs($repository);
        $repository->shouldReceive('combinationDetails')->once()->with(1)->andReturn($this->combination());
        $repository->shouldReceive('createDelivery')->once()->andThrow(new RuntimeException('SP error'));
        $directory = public_path('uploads/dotations/deliveries');
        $before = is_dir($directory) ? glob($directory.'/*') : [];

        try {
            $service->createDelivery([
                'id_empleado' => 5,
                'fecha_entrega' => '2026-07-24',
                'tipo_entrega' => 'ORDINARIA',
                'id_dotacion_combinacion' => 1,
                'origen_evidencia' => 'ARCHIVO',
                'evidencia_archivo' => UploadedFile::fake()->create('evidencia.pdf', 10, 'application/pdf'),
                'detalles' => $this->details(),
            ], 99, []);
            $this->fail('La creación debía fallar.');
        } catch (RuntimeException $exception) {
            $this->assertSame('SP error', $exception->getMessage());
        }

        $after = is_dir($directory) ? glob($directory.'/*') : [];
        $this->assertSame($before, $after);
    }

    public function test_deletes_new_evidence_file_when_detail_creation_fails(): void
    {
        [$service, $repository] = $this->service();
        $this->expectCatalogs($repository);
        $repository->shouldReceive('combinationDetails')->once()->with(1)->andReturn($this->combination());
        $repository->shouldReceive('createDelivery')->once()->andReturn(22);
        $repository->shouldReceive('addDeliveryDetail')->once()->andThrow(new RuntimeException('Detail error'));
        $directory = public_path('uploads/dotations/deliveries');
        $before = is_dir($directory) ? glob($directory.'/*') : [];

        try {
            $service->createDelivery([
                'id_empleado' => 5,
                'fecha_entrega' => '2026-07-24',
                'tipo_entrega' => 'ORDINARIA',
                'id_dotacion_combinacion' => 1,
                'origen_evidencia' => 'ARCHIVO',
                'evidencia_archivo' => UploadedFile::fake()->create('evidencia.pdf', 10, 'application/pdf'),
                'detalles' => $this->details(),
            ], 99, []);
            $this->fail('La creación debía fallar.');
        } catch (RuntimeException $exception) {
            $this->assertSame('Detail error', $exception->getMessage());
        }

        $after = is_dir($directory) ? glob($directory.'/*') : [];
        $this->assertSame($before, $after);
    }

    private function service(): array
    {
        $repository = Mockery::mock(DotationRepository::class);
        $audit = Mockery::mock(AuditService::class);

        return [new DotationService($repository, $audit), $repository, $audit];
    }

    private function expectCatalogs($repository): void
    {
        $repository->shouldReceive('employeeSizes')->once()->with(5)->andReturn([
            ['id_tipo_dotacion' => 7, 'id_talla_dotacion' => 30],
            ['id_tipo_dotacion' => 2, 'id_talla_dotacion' => 15],
            ['id_tipo_dotacion' => 3, 'id_talla_dotacion' => 25],
        ]);
        $repository->shouldReceive('types')->once()->with(true)->andReturn([
            ['id_tipo_dotacion' => 7, 'nombre' => 'Chaqueta', 'requiere_talla' => 1],
            ['id_tipo_dotacion' => 2, 'nombre' => 'Pantalón', 'requiere_talla' => 1],
            ['id_tipo_dotacion' => 3, 'nombre' => 'Calzado', 'requiere_talla' => 1],
        ]);
        $repository->shouldReceive('sizes')->once()->with(null, true)->andReturn([
            ['id_talla_dotacion' => 30, 'id_tipo_dotacion' => 7],
            ['id_talla_dotacion' => 15, 'id_tipo_dotacion' => 2],
            ['id_talla_dotacion' => 25, 'id_tipo_dotacion' => 3],
        ]);
    }

    private function combination(): array
    {
        return [
            ['id_tipo_dotacion' => 7, 'tipo_dotacion' => 'Chaqueta', 'cantidad' => 1],
            ['id_tipo_dotacion' => 2, 'tipo_dotacion' => 'Pantalón', 'cantidad' => 1],
            ['id_tipo_dotacion' => 3, 'tipo_dotacion' => 'Calzado', 'cantidad' => 1],
        ];
    }

    private function details(): array
    {
        return [
            ['id_tipo_dotacion' => 7, 'id_talla_dotacion' => 30, 'cantidad' => 1],
            ['id_tipo_dotacion' => 2, 'id_talla_dotacion' => 15, 'cantidad' => 1],
            ['id_tipo_dotacion' => 3, 'id_talla_dotacion' => 25, 'cantidad' => 1],
        ];
    }
}
