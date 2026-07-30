<?php

namespace Tests\Feature;

use App\Services\BulkLoadEmployeeService;
use Illuminate\Http\UploadedFile;
use Mockery\MockInterface;
use Tests\TestCase;

class BulkLoadEmployeeApiTest extends TestCase
{
    public function test_template_route_returns_xlsx(): void
    {
        $path = tempnam(sys_get_temp_dir(), 'bulk_route_');
        file_put_contents($path, 'xlsx');
        $this->mock(BulkLoadEmployeeService::class, function (MockInterface $mock) use ($path): void {
            $mock->shouldReceive('template')->once()->andReturn(['path' => $path, 'filename' => 'plantilla.xlsx']);
        });

        $this->withoutMiddleware()->get('/api/bulk-load/employees/template')
            ->assertOk()->assertHeader('content-type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    }

    public function test_validate_returns_structured_summary(): void
    {
        $file = UploadedFile::fake()->create('empleados.xlsx', 10, 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        $result = ['total' => 2, 'valid' => 1, 'invalid' => 1, 'warnings' => [], 'errors' => [['row' => 3, 'field' => 'area', 'message' => 'Inválida']], '_rows' => [['private']]];
        $this->mock(BulkLoadEmployeeService::class, function (MockInterface $mock) use ($result): void {
            $mock->shouldReceive('validate')->once()->andReturn($result);
            $mock->shouldReceive('publicResult')->once()->andReturn(collect($result)->except('_rows')->all());
        });

        $this->withoutMiddleware()->post('/api/bulk-load/employees/validate', ['file' => $file])
            ->assertOk()->assertJsonPath('data.invalid', 1)->assertJsonMissing(['_rows']);
    }
}
