<?php

namespace Tests\Unit;

use App\Repositories\TrainingRepository;
use App\Services\AuditService;
use App\Services\TrainingService;
use Mockery;
use PHPUnit\Framework\TestCase;

class TrainingServiceTest extends TestCase
{
    protected function tearDown(): void
    {
        Mockery::close();
        parent::tearDown();
    }

    public function test_employee_confirmation_passes_authenticated_actor_to_protected_sp(): void
    {
        $repository = Mockery::mock(TrainingRepository::class);
        $audit = Mockery::mock(AuditService::class);
        $repository->shouldReceive('confirmEmployee')->once()->with(77, 12, 'Recibida')->andReturn(['id_capacitacion_participante' => 12, 'confirmo_recibido' => 1]);
        $audit->shouldReceive('record')->once();
        $result = (new TrainingService($repository, $audit))->confirmEmployee(12, 'Recibida', 77, []);
        self::assertTrue($result['confirmo_recibido']);
    }

    public function test_catalog_boolean_fields_are_exposed_as_booleans(): void
    {
        $repository = Mockery::mock(TrainingRepository::class);
        $audit = Mockery::mock(AuditService::class);
        $repository->shouldReceive('tasks')->with(false)->andReturn([['id_capacitacion_labor' => 1, 'activo' => 1]]);
        $result = (new TrainingService($repository, $audit))->tasks();
        self::assertTrue($result[0]['activo']);
    }
}
