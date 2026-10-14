<?php

namespace Tests\Feature;

use App\Repositories\CertificateRepository;
use App\Repositories\ContractingRepository;
use App\Repositories\EmployeeRepository;
use App\Services\JwtService;
use Carbon\CarbonImmutable;
use Tests\TestCase;

class ContractNonRenewalApiTest extends TestCase
{
    private const URL = '/api/contracting/employees/5/certificates/non-renewal';

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
        return ['id_empleado_contrato' => 7, 'nit_empresa' => '900747203'];
    }

    public function test_routes_authenticate_before_reading_sources(): void
    {
        $this->mock(EmployeeRepository::class)->shouldNotReceive('find');
        $this->mock(CertificateRepository::class)->shouldNotReceive('listAllFormats', 'getFormat');
        $this->mock(ContractingRepository::class)->shouldNotReceive('getContractGenerationData');
        foreach ([self::GENERATE, self::DOWNLOAD] as $url) {
            $this->postJson($url, $this->request())->assertUnauthorized();
            $this->withToken($this->token([]))->postJson($url, $this->request())->assertForbidden();
            $this->flushHeaders();
        }
        $this->getJson(self::URL)->assertUnauthorized();
        $this->withToken($this->token([]))->getJson(self::URL)->assertForbidden();
    }

    public function test_available_catalog_returns_only_non_renewal_format(): void
    {
        $this->employee();
        $format = $this->format();
        $this->mock(CertificateRepository::class)->shouldReceive('listAllFormats')->once()->with('2026-10-06')->andReturn([
            $format,
            array_replace($format, ['clave_formato' => 'CESANTIAS_VIVIENDA', 'clave_renderizador' => 'carta-retiro-cesantias-vivienda']),
            array_replace($format, ['clave_renderizador' => 'otro']),
        ]);
        $this->authorized()->getJson(self::URL)->assertOk()->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.clave_formato', 'NO_RENOVACION_CONTRATO')
            ->assertJsonPath('data.0.codigo_formato', 'BBTH-F-015')
            ->assertJsonMissingPath('data.0.firmantes_json');
    }

    public function test_generation_returns_official_non_renewal_data(): void
    {
        $this->complete();
        $this->authorized()->postJson(self::GENERATE, $this->request())->assertOk()
            ->assertJsonPath('data.fecha_expedicion', '2026-10-06')
            ->assertJsonPath('data.empleado.nombre_completo', 'Ana Perez')
            ->assertJsonPath('data.contrato.tipo_contrato', 'Fijo')
            ->assertJsonPath('data.contrato.fecha_inicio', '2026-05-01')
            ->assertJsonPath('data.contrato.fecha_fin', '2026-08-01')
            ->assertJsonPath('data.nit_empresa', '900747203')
            ->assertJsonPath('data.firmantes.0.nombre', 'Nombre configurado');
    }

    public function test_non_fixed_term_contract_is_rejected(): void
    {
        $this->employee();
        $repository = $this->mock(ContractingRepository::class);
        $repository->shouldReceive('getContractGenerationData')->with(7)->once()
            ->andReturn($this->contract(['tipo_contrato' => 'Indefinido']));
        $repository->shouldReceive('getCurrentParameter')->zeroOrMoreTimes()->andReturn(null);
        $this->mock(CertificateRepository::class)->shouldReceive('getFormat')
            ->with('NO_RENOVACION_CONTRATO', '2026-10-06')->once()->andReturn($this->format());
        $this->authorized()->postJson(self::GENERATE, $this->request())
            ->assertUnprocessable()->assertJsonValidationErrors('tipo_contrato');
    }

    public function test_contract_without_end_date_is_rejected(): void
    {
        $this->employee();
        $repository = $this->mock(ContractingRepository::class);
        $repository->shouldReceive('getContractGenerationData')->with(7)->once()
            ->andReturn($this->contract(['fecha_fin' => null]));
        $repository->shouldReceive('getCurrentParameter')->zeroOrMoreTimes()->andReturn(null);
        $this->mock(CertificateRepository::class)->shouldReceive('getFormat')
            ->with('NO_RENOVACION_CONTRATO', '2026-10-06')->once()->andReturn($this->format());
        $this->authorized()->postJson(self::GENERATE, $this->request())
            ->assertUnprocessable()->assertJsonValidationErrors('fecha_fin');
    }

    public function test_foreign_and_inactive_contracts_are_rejected(): void
    {
        $this->employee(3);
        $repository = $this->mock(ContractingRepository::class);
        $repository->shouldReceive('getContractGenerationData')->with(7)->twice()
            ->andReturn(['id_empleado' => 9, 'estado_contrato' => 'ACTIVO', 'tipo_contrato' => 'Fijo']);
        $this->mock(CertificateRepository::class)->shouldReceive('getFormat')->zeroOrMoreTimes()->andReturn($this->format());
        $this->authorized()->postJson(self::GENERATE, $this->request())->assertNotFound();
        $this->authorized()->postJson(self::DOWNLOAD, $this->request())->assertNotFound();
        $repository->shouldReceive('getContractGenerationData')->with(8)->once()
            ->andReturn($this->contract(['estado_contrato' => 'ANULADO']));
        $this->authorized()->postJson(self::GENERATE, ['id_empleado_contrato' => 8, 'nit_empresa' => '900747203'])
            ->assertUnprocessable()->assertJsonValidationErrors('contrato');
    }

    public function test_request_validation_requires_contract_and_nit(): void
    {
        $this->mock(EmployeeRepository::class)->shouldNotReceive('find');
        foreach ([self::GENERATE, self::DOWNLOAD] as $url) {
            $this->authorized()->postJson($url, [])->assertUnprocessable()
                ->assertJsonValidationErrors(['id_empleado_contrato', 'nit_empresa']);
            $this->authorized()->postJson($url, ['id_empleado_contrato' => 0, 'nit_empresa' => 'ABC'])
                ->assertUnprocessable()->assertJsonValidationErrors(['id_empleado_contrato', 'nit_empresa']);
        }
    }

    public function test_download_returns_a_real_pdf_with_non_renewal_content(): void
    {
        $this->complete();
        $response = $this->authorized()->postJson(self::DOWNLOAD, $this->request());
        $response->assertOk()
            ->assertHeader('Content-Type', 'application/pdf')
            ->assertHeader('Content-Disposition', 'attachment; filename="BBTH-F-015-NO-RENOVACION-CONTRATO.pdf"')
            ->assertHeader('Cache-Control', 'no-store, private');
        $content = $response->getContent();
        $this->assertStringStartsWith('%PDF-1.4', $content);
        $this->assertStringContainsString(mb_convert_encoding('no renovación de contrato de trabajo', 'Windows-1252', 'UTF-8'), $content);
        $this->assertStringContainsString('900747203', $content);
        $this->assertStringContainsString('Ana Perez', $content);
    }

    private function complete(): void
    {
        $this->employee();
        $repository = $this->mock(ContractingRepository::class);
        $repository->shouldReceive('getContractGenerationData')->with(7)->once()->andReturn($this->contract());
        foreach ([
            'DOC_EMPRESA_RAZON_SOCIAL' => ['tipo_dato' => 'TEXTO', 'valor' => 'Empresa configurada'],
            'DOC_EMPRESA_CIUDAD' => ['tipo_dato' => 'TEXTO', 'valor' => 'Ciudad configurada'],
            'DOC_FIRMANTE_F015' => ['tipo_dato' => 'JSON', 'valor' => '{"nombre":"Nombre configurado","cargo":"Cargo configurado","telefono":"Teléfono configurado"}'],
        ] as $code => $row) {
            $repository->shouldReceive('getCurrentParameter')->zeroOrMoreTimes()->with($code, '2026-10-06')->andReturn($row);
        }
        $this->mock(CertificateRepository::class)->shouldReceive('getFormat')
            ->with('NO_RENOVACION_CONTRATO', '2026-10-06')->once()->andReturn($this->format());
    }

    private function contract(array $changes = []): array
    {
        return array_replace([
            'id_empleado' => 5, 'estado_contrato' => 'ACTIVO', 'tipo_contrato' => 'Fijo',
            'fecha_inicio' => '2026-05-01', 'fecha_fin' => '2026-08-01',
        ], $changes);
    }

    private function employee(int $times = 1, array $changes = []): void
    {
        $this->mock(EmployeeRepository::class)->shouldReceive('find')->with(5)->times($times)->andReturn(array_replace([
            'nombres' => 'Ana', 'apellidos' => 'Perez',
        ], $changes));
    }

    private function format(): array
    {
        return ['clave_formato' => 'NO_RENOVACION_CONTRATO', 'variante' => 'GENERAL',
            'clave_renderizador' => 'carta-no-renovacion-contrato', 'codigo_formato' => 'BBTH-F-015',
            'firmantes_json' => '[{"codigo_parametro":"DOC_FIRMANTE_F015"}]', 'control_documental_json' => '{"version":"1"}'];
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
