<?php

namespace Tests\Unit;

use App\Repositories\ReturnRepository;
use App\Services\AuditService;
use App\Services\ReturnService;
use Tests\TestCase;

class ReturnServiceTest extends TestCase
{
    public function test_list_normalizes_empty_filters_to_null_through_omission(): void
    {
        $repository = \Mockery::mock(ReturnRepository::class);
        $audit = \Mockery::mock(AuditService::class);
        $repository->shouldReceive('list')->once()->with([
            'type' => 'DOTACION',
            'employee_id' => 5,
        ])->andReturn([]);

        $service = new ReturnService($repository, $audit);

        $this->assertSame([], $service->list([
            'type' => 'DOTACION',
            'employee_id' => 5,
            'status' => '',
            'date_from' => null,
            'date_to' => null,
        ]));
    }
}
