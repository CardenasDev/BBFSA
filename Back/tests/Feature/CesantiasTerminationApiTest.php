<?php

namespace Tests\Feature;

use App\Repositories\CertificateRepository;
use App\Repositories\ContractingRepository;
use App\Repositories\EmployeeRepository;
use App\Services\JwtService;
use Carbon\CarbonImmutable;
use Tests\TestCase;

class CesantiasTerminationApiTest extends TestCase
{
    private const URL = '/api/contracting/employees/5/certificates/cesantias-fin-contrato';

    private const GENERATE = self::URL.'/generation-data';

    private const DOWNLOAD = self::URL.'/download';

    protected function setUp(): void
    {
        parent::setUp();
        CarbonImmutable::setTestNow(CarbonImmutable::parse('2026-10-07 02:00:00', 'UTC'));
    }

    protected function tearDown(): void
    {
        CarbonImmutable::setTestNow();
        parent::tearDown();
    }

    private function request(): array
    {
        return [
            'fecha_desde' => '2024-06-01', 'fecha_hasta' => '2026-08-12',
            'nit_empresa' => '900747203-1', 'correo_contacto' => 'contacto@example.com', 'telefono_contacto' => '3153188486',
        ];
    }

    public function test_routes_authenticate_before_reading_sources(): void
    {
        $this->mock(EmployeeRepository::class)->shouldNotReceive('find');
        $this->mock(CertificateRepository::class)->shouldNotReceive('listAllFormats', 'getFormat');
        $this->mock(ContractingRepository::class)->shouldNotReceive('getSocialSecurity');
        foreach ([self::GENERATE, self::DOWNLOAD] as $url) {
            $this->postJson($url, $this->request())->assertUnauthorized();
            $this->withToken($this->token([]))->postJson($url, $this->request())->assertForbidden();
            $this->flushHeaders();
        }
        $this->getJson(self::URL)->assertUnauthorized();
        $this->withToken($this->token([]))->getJson(self::URL)->assertForbidden();
    }

    public function test_available_catalog_returns_only_termination_format(): void
    {
        $this->employee();
        $format = $this->format();
        $this->mock(CertificateRepository::class)->shouldReceive('listAllFormats')->once()->with('2026-10-06')->andReturn([
            $format,
            array_replace($format, ['clave_formato' => 'CESANTIAS_VIVIENDA', 'clave_renderizador' => 'carta-retiro-cesantias-vivienda']),
            array_replace($format, ['clave_renderizador' => 'otro']),
        ]);
        $this->authorized()->getJson(self::URL)->assertOk()->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.clave_formato', 'CESANTIAS_FIN_CONTRATO')
            ->assertJsonPath('data.0.codigo_formato', 'BBTH-F-012')
            ->assertJsonMissingPath('data.0.firmantes_json');
    }

    public function test_generation_returns_official_termination_data(): void
    {
        $this->complete();
        $this->authorized()->postJson(self::GENERATE, $this->request())->assertOk()
            ->assertJsonPath('data.fecha_expedicion', '2026-10-06')
            ->assertJsonPath('data.empleado.nombre_completo', 'Ana Perez')
            ->assertJsonPath('data.fondo_cesantias', 'PORVENIR')
            ->assertJsonPath('data.solicitud.fecha_desde', '2024-06-01')
            ->assertJsonPath('data.solicitud.fecha_hasta', '2026-08-12')
            ->assertJsonPath('data.solicitud.nit_empresa', '900747203-1')
            ->assertJsonPath('data.solicitud.correo_contacto', 'contacto@example.com')
            ->assertJsonPath('data.solicitud.telefono_contacto', '3153188486')
            ->assertJsonPath('data.firmantes.0.nombre', 'Nombre configurado');
    }

    public function test_request_validation_rejects_missing_and_invalid_fields(): void
    {
        $this->mock(EmployeeRepository::class)->shouldNotReceive('find');
        foreach ([self::GENERATE, self::DOWNLOAD] as $url) {
            $this->authorized()->postJson($url, [])->assertUnprocessable()
                ->assertJsonValidationErrors(['fecha_desde', 'fecha_hasta', 'nit_empresa', 'correo_contacto', 'telefono_contacto']);
            $this->authorized()->postJson($url, [
                'fecha_desde' => 'no-es-fecha', 'fecha_hasta' => '2026-13-40',
                'nit_empresa' => 'ABC', 'correo_contacto' => 'no-es-correo', 'telefono_contacto' => '12',
            ])->assertUnprocessable()->assertJsonValidationErrors(['fecha_desde', 'fecha_hasta', 'nit_empresa', 'correo_contacto', 'telefono_contacto']);
        }
    }

    public function test_inverted_and_future_period_are_rejected(): void
    {
        $this->complete(2);
        $this->authorized()->postJson(self::GENERATE, array_replace($this->request(), ['fecha_desde' => '2026-08-12', 'fecha_hasta' => '2024-06-01']))
            ->assertUnprocessable()->assertJsonValidationErrors('fecha_hasta');
        $this->authorized()->postJson(self::GENERATE, array_replace($this->request(), ['fecha_hasta' => '2027-01-01']))
            ->assertUnprocessable()->assertJsonValidationErrors('fecha_hasta');
    }

    public function test_missing_fund_and_identity_are_actionable(): void
    {
        $this->employee();
        $repository = $this->mock(ContractingRepository::class);
        $repository->shouldReceive('getSocialSecurity')->with(5)->once()->andReturn(['fondo_cesantias' => '']);
        $repository->shouldReceive('getCurrentParameter')->zeroOrMoreTimes()->andReturn(null);
        $this->mock(CertificateRepository::class)->shouldReceive('getFormat')
            ->with('CESANTIAS_FIN_CONTRATO', '2026-10-06')->once()->andReturn($this->format());
        $this->authorized()->postJson(self::GENERATE, $this->request())->assertUnprocessable()
            ->assertJsonValidationErrors('fondo_cesantias');
    }

    public function test_download_returns_a_real_pdf_with_termination_content(): void
    {
        $this->complete();
        $response = $this->authorized()->postJson(self::DOWNLOAD, $this->request());
        $response->assertOk()
            ->assertHeader('Content-Type', 'application/pdf')
            ->assertHeader('Content-Disposition', 'attachment; filename="BBTH-F-012-CARTA-RETIRO-CESANTIAS-FIN-CONTRATO.pdf"')
            ->assertHeader('Cache-Control', 'no-store, private');
        $content = $response->getContent();
        $this->assertStringStartsWith('%PDF-1.4', $content);
        $this->assertStringContainsString(mb_convert_encoding('ASUNTO: Retiro Total de Cesantías', 'Windows-1252', 'UTF-8'), $content);
        $this->assertStringContainsString('PORVENIR', $content);
        $this->assertStringContainsString('900747203-1', $content);
        $this->assertStringContainsString('Ana Perez', $content);
    }

    private function complete(int $finds = 1): void
    {
        $this->employee($finds);
        $repository = $this->mock(ContractingRepository::class);
        $repository->shouldReceive('getSocialSecurity')->with(5)->times($finds)->andReturn(['fondo_cesantias' => 'PORVENIR']);
        $repository->shouldReceive('getProfile')->zeroOrMoreTimes()->with(5)->andReturn(['lugar_expedicion_documento' => 'Gachancipa']);
        foreach ([
            'DOC_EMPRESA_RAZON_SOCIAL' => ['tipo_dato' => 'TEXTO', 'valor' => 'Empresa configurada'],
            'DOC_EMPRESA_CIUDAD' => ['tipo_dato' => 'TEXTO', 'valor' => 'Ciudad configurada'],
            'DOC_FIRMANTE_F012' => ['tipo_dato' => 'JSON', 'valor' => '{"nombre":"Nombre configurado","cargo":"Cargo configurado","telefono":"Teléfono configurado"}'],
        ] as $code => $row) {
            $repository->shouldReceive('getCurrentParameter')->zeroOrMoreTimes()->with($code, '2026-10-06')->andReturn($row);
        }
        $this->mock(CertificateRepository::class)->shouldReceive('getFormat')
            ->with('CESANTIAS_FIN_CONTRATO', '2026-10-06')->times($finds)->andReturn($this->format());
    }

    private function employee(int $times = 1, array $changes = []): void
    {
        $this->mock(EmployeeRepository::class)->shouldReceive('find')->with(5)->times($times)->andReturn(array_replace([
            'nombres' => 'Ana', 'apellidos' => 'Perez', 'tipo_documento' => 'Cédula',
            'numero_documento' => '123',
        ], $changes));
    }

    private function format(): array
    {
        return ['clave_formato' => 'CESANTIAS_FIN_CONTRATO', 'variante' => 'GENERAL',
            'clave_renderizador' => 'carta-retiro-cesantias-fin-contrato', 'codigo_formato' => 'BBTH-F-012',
            'firmantes_json' => '[{"codigo_parametro":"DOC_FIRMANTE_F012"}]', 'control_documental_json' => '{"version":"1"}'];
    }

    private function authorized(): static
    {
        return $this->withToken($this->token(['CONTRATACION_VER']));
    }

    private function token(array $permissions): string
    {
        return app(JwtService::class)->encode(['id_usuario' => 99, 'id_sesion' => 1, 'correo' => 'rrhh@example.com',
            'nombre_usuario' => 'rrhh', 'tipo_usuario' => 'ADMIN', 'roles' => [], 'permisos' => $permissions])['token'];
    }
}
