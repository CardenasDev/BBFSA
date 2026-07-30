<?php

namespace Tests\Feature;

use App\Services\DotationService;
use App\Services\JwtService;
use Mockery\MockInterface;
use PHPUnit\Framework\Attributes\DataProvider;
use Tests\TestCase;

class DotationQuotationExportApiTest extends TestCase
{
    public function test_export_route_returns_xlsx_with_filters(): void
    {
        $path = tempnam(sys_get_temp_dir(), 'bbf_dotation_export_route_');
        file_put_contents($path, 'xlsx-test-content');

        $this->mock(DotationService::class, function (MockInterface $mock) use ($path): void {
            $mock->shouldReceive('exportQuotation')->once()->with(5, 9, 12)->andReturn([
                'path' => $path,
                'filename' => 'cotizacion-dotacion-20260729-120000.xlsx',
            ]);
        });

        $this->withToken($this->token(['DOTACIONES_ADMIN_VER']))
            ->get('/api/dotations/quotation/export?id_area=5&id_cargo=9&id_empleado=12')
            ->assertOk()
            ->assertHeader('content-type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
            ->assertDownload('cotizacion-dotacion-20260729-120000.xlsx');
    }

    #[DataProvider('invalidFilters')]
    public function test_export_rejects_invalid_filters(string $query, string $field): void
    {
        $this->withToken($this->token(['DOTACIONES_ADMIN_VER']))
            ->getJson('/api/dotations/quotation/export?'.$query)
            ->assertUnprocessable()
            ->assertJsonValidationErrors([$field]);
    }

    public static function invalidFilters(): array
    {
        return [
            'non numeric' => ['id_area=abc', 'id_area'],
            'negative' => ['id_cargo=-1', 'id_cargo'],
        ];
    }

    public function test_zero_and_empty_filters_are_converted_to_null(): void
    {
        $path = tempnam(sys_get_temp_dir(), 'bbf_dotation_export_route_');
        file_put_contents($path, 'xlsx-test-content');

        $this->mock(DotationService::class, function (MockInterface $mock) use ($path): void {
            $mock->shouldReceive('exportQuotation')->once()->with(null, null, null)->andReturn([
                'path' => $path,
                'filename' => 'cotizacion-dotacion.xlsx',
            ]);
        });

        $this->withToken($this->token(['DOTACIONES_ADMIN_VER']))
            ->get('/api/dotations/quotation/export?id_area=0&id_cargo=&id_empleado=00')
            ->assertOk();
    }

    public function test_export_requires_authentication(): void
    {
        $this->getJson('/api/dotations/quotation/export')->assertUnauthorized();
    }

    public function test_export_requires_admin_dotation_permission(): void
    {
        $this->withToken($this->token([]))
            ->getJson('/api/dotations/quotation/export')
            ->assertForbidden();
    }

    private function token(array $permissions): string
    {
        return app(JwtService::class)->encode([
            'id_usuario' => 99,
            'id_sesion' => 1,
            'correo' => 'rrhh@example.com',
            'nombre_usuario' => 'rrhh',
            'tipo_usuario' => 'ADMIN',
            'roles' => [],
            'permisos' => $permissions,
        ])['token'];
    }
}
