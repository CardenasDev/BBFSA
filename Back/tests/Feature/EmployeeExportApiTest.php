<?php

namespace Tests\Feature;

use App\Services\EmployeeService;
use Mockery\MockInterface;
use Tests\TestCase;

class EmployeeExportApiTest extends TestCase
{
    public function test_export_route_returns_an_xlsx_download(): void
    {
        $path = tempnam(sys_get_temp_dir(), 'bbf_export_route_test_');
        file_put_contents($path, 'xlsx-test-content');

        $this->mock(EmployeeService::class, function (MockInterface $mock) use ($path): void {
            $mock->shouldReceive('exportActiveEmployees')
                ->once()
                ->andReturn([
                    'path' => $path,
                    'filename' => 'empleados_activos_20260723_120000.xlsx',
                ]);
        });

        $response = $this->withoutMiddleware()->get('/api/employees/export');

        $response->assertOk();
        $response->assertHeader(
            'content-type',
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        );
        $this->assertStringContainsString(
            '.xlsx',
            (string) $response->headers->get('content-disposition'),
        );
    }
}
