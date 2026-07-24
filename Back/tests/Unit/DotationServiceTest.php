<?php

namespace Tests\Unit;

use App\Exceptions\ApiException;
use App\Repositories\DotationRepository;
use App\Services\AuditService;
use App\Services\DotationService;
use Mockery;
use Tests\TestCase;

class DotationServiceTest extends TestCase
{
    public function test_creates_ordinary_delivery_with_exact_combination_and_employee_sizes(): void
    {
        [$service, $repository, $audit] = $this->service();
        $this->expectCatalogs($repository);
        $repository->shouldReceive('combinationDetails')->once()->with(1)->andReturn($this->combination());
        $repository->shouldReceive('createDelivery')->once()->with(5, '2026-07-24', 'ORDINARIA', 1, 99, null)->andReturn(20);
        $repository->shouldReceive('addDeliveryDetail')->times(3);
        $audit->shouldReceive('record')->once();

        $result = $service->createDelivery([
            'id_empleado' => 5,
            'fecha_entrega' => '2026-07-24',
            'tipo_entrega' => 'ORDINARIA',
            'id_dotacion_combinacion' => 1,
            'detalles' => $this->details(),
        ], 99, []);

        $this->assertSame(['id_dotacion_entrega' => 20], $result);
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
            'detalles' => $details,
        ], 99, []);
    }

    public function test_creates_extraordinary_delivery_without_combination(): void
    {
        [$service, $repository, $audit] = $this->service();
        $this->expectCatalogs($repository);
        $repository->shouldReceive('createDelivery')->once()->with(5, '2026-07-24', 'EXTRAORDINARIA', null, 99, null)->andReturn(21);
        $repository->shouldReceive('addDeliveryDetail')->once()->with(21, 3, 25, 1, null);
        $audit->shouldReceive('record')->once();

        $result = $service->createDelivery([
            'id_empleado' => 5,
            'fecha_entrega' => '2026-07-24',
            'tipo_entrega' => 'EXTRAORDINARIA',
            'id_dotacion_combinacion' => null,
            'detalles' => [$this->details()[2]],
        ], 99, []);

        $this->assertSame(['id_dotacion_entrega' => 21], $result);
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
