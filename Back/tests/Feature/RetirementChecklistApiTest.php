<?php

namespace Tests\Feature;

use App\Repositories\CertificateRepository;
use App\Repositories\ContractingRepository;
use App\Repositories\EmployeeRepository;
use App\Repositories\RetirementRepository;
use App\Services\JwtService;
use Carbon\CarbonImmutable;
use Tests\TestCase;

class RetirementChecklistApiTest extends TestCase
{
    private const URL = '/api/contracting/employees/5/certificates/checklist';

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

    public function test_routes_authenticate_before_reading_sources(): void
    {
        $this->mock(EmployeeRepository::class)->shouldNotReceive('find');
        $this->mock(CertificateRepository::class)->shouldNotReceive('listAllFormats', 'getFormat');
        $this->mock(RetirementRepository::class)->shouldNotReceive('detail');
        foreach ([self::GENERATE, self::DOWNLOAD] as $url) {
            $this->postJson($url, ['id_retiro' => 3])->assertUnauthorized();
            $this->withToken($this->token([]))->postJson($url, ['id_retiro' => 3])->assertForbidden();
            $this->flushHeaders();
        }
        $this->getJson(self::URL)->assertUnauthorized();
        $this->withToken($this->token([]))->getJson(self::URL)->assertForbidden();
    }

    public function test_available_catalog_returns_only_checklist_format(): void
    {
        $this->employee();
        $format = $this->format();
        $this->mock(CertificateRepository::class)->shouldReceive('listAllFormats')->once()->with('2026-10-06')->andReturn([
            $format,
            array_replace($format, ['clave_formato' => 'CERTIFICADO_LABORAL_ACTIVO', 'clave_renderizador' => 'certificado-laboral-activo-funciones']),
            array_replace($format, ['clave_renderizador' => 'otro']),
        ]);
        $this->authorized()->getJson(self::URL)->assertOk()->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.clave_formato', 'CONSTANCIA_ENTREGA_RETIRO')
            ->assertJsonPath('data.0.codigo_formato', 'BBTH-F-004')
            ->assertJsonMissingPath('data.0.firmantes_json');
    }

    public function test_generation_returns_official_checklist_data(): void
    {
        $this->complete();
        $this->authorized()->postJson(self::GENERATE, ['id_retiro' => 3])->assertOk()
            ->assertJsonPath('data.fecha_expedicion', '2026-10-06')
            ->assertJsonPath('data.empleado.nombre_completo', 'Ana Perez')
            ->assertJsonPath('data.contrato.cargo', 'Supervisor de Calidad')
            ->assertJsonPath('data.retiro.motivo_retiro', 'Renuncia voluntaria')
            ->assertJsonPath('data.retiro.fecha_retiro', '2026-10-01')
            ->assertJsonPath('data.firmantes.0.nombre', 'Nombre configurado')
            ->assertJsonMissingPath('data.salario')
            ->assertJsonMissingPath('data.afiliaciones');
    }

    public function test_missing_and_cancelled_retirement_are_rejected(): void
    {
        $this->employee(3);
        $retirements = $this->mock(RetirementRepository::class);
        $retirements->shouldReceive('detail')->with(3)->twice()->andReturn(['retirement' => null]);
        $this->authorized()->postJson(self::GENERATE, ['id_retiro' => 3])->assertNotFound();
        $this->authorized()->postJson(self::DOWNLOAD, ['id_retiro' => 3])->assertNotFound();
        $retirements->shouldReceive('detail')->with(4)->once()->andReturn(['retirement' => $this->retirement(['estado' => 'CANCELADO'])]);
        $this->authorized()->postJson(self::GENERATE, ['id_retiro' => 4])->assertUnprocessable()->assertJsonValidationErrors('retiro');
    }

    public function test_foreign_retirement_is_not_disclosed(): void
    {
        $this->employee();
        $this->mock(RetirementRepository::class)->shouldReceive('detail')->with(3)->once()
            ->andReturn(['retirement' => $this->retirement(['id_empleado' => 9])]);
        $this->authorized()->postJson(self::GENERATE, ['id_retiro' => 3])->assertNotFound();
    }

    public function test_request_validation_requires_retirement_id(): void
    {
        $this->mock(EmployeeRepository::class)->shouldNotReceive('find');
        foreach ([self::GENERATE, self::DOWNLOAD] as $url) {
            $this->authorized()->postJson($url, [])->assertUnprocessable()->assertJsonValidationErrors('id_retiro');
            $this->authorized()->postJson($url, ['id_retiro' => 0])->assertUnprocessable()->assertJsonValidationErrors('id_retiro');
        }
    }

    public function test_missing_official_fields_are_actionable(): void
    {
        $this->employee();
        $this->mock(RetirementRepository::class)->shouldReceive('detail')->with(3)->once()
            ->andReturn(['retirement' => $this->retirement(['cargo' => '', 'motivo_retiro' => null, 'fecha_retiro' => '2099-01-01'])]);
        $repository = $this->mock(ContractingRepository::class);
        $repository->shouldReceive('listContracts')->zeroOrMoreTimes()->withAnyArgs()->andReturn([]);
        $repository->shouldReceive('getCurrentParameter')->zeroOrMoreTimes()->andReturn(null);
        $this->mock(CertificateRepository::class)->shouldReceive('getFormat')
            ->with('CONSTANCIA_ENTREGA_RETIRO', '2026-10-06')->once()->andReturn($this->format());
        $this->authorized()->postJson(self::GENERATE, ['id_retiro' => 3])->assertUnprocessable()
            ->assertJsonValidationErrors(['cargo', 'motivo_retiro', 'fecha_retiro']);
    }

    public function test_download_returns_a_real_pdf_with_checklist_content(): void
    {
        $this->complete();
        $response = $this->authorized()->postJson(self::DOWNLOAD, ['id_retiro' => 3]);
        $response->assertOk()
            ->assertHeader('Content-Type', 'application/pdf')
            ->assertHeader('Content-Disposition', 'attachment; filename="BBTH-F-004-PAZ-Y-SALVO-ENTREGA-RETIRO.pdf"')
            ->assertHeader('Cache-Control', 'no-store, private');
        $content = $response->getContent();
        $this->assertStringStartsWith('%PDF-1.4', $content);
        $this->assertStringContainsString(mb_convert_encoding('hacer entrega formal de los documentos', 'Windows-1252', 'UTF-8'), $content);
        $this->assertStringContainsString(mb_convert_encoding('Certificado laboral:', 'Windows-1252', 'UTF-8'), $content);
        $this->assertStringContainsString('Ana Perez', $content);
    }

    private function complete(): void
    {
        $this->employee();
        $this->mock(RetirementRepository::class)->shouldReceive('detail')->with(3)->once()
            ->andReturn(['retirement' => $this->retirement()]);
        $repository = $this->mock(ContractingRepository::class);
        $repository->shouldReceive('listContracts')->zeroOrMoreTimes()->with(5)->andReturn([
            ['estado_contrato' => 'ACTIVO', 'cargo' => 'Supervisor de Calidad', 'tipo_contrato' => 'Obra o labor'],
        ]);
        $repository->shouldReceive('getProfile')->zeroOrMoreTimes()->with(5)->andReturn(['lugar_expedicion_documento' => 'Ciudad configurada']);
        foreach ([
            'DOC_EMPRESA_RAZON_SOCIAL' => ['tipo_dato' => 'TEXTO', 'valor' => 'Empresa configurada'],
            'DOC_EMPRESA_CIUDAD' => ['tipo_dato' => 'TEXTO', 'valor' => 'Ciudad configurada'],
            'DOC_FIRMANTE_F004' => ['tipo_dato' => 'JSON', 'valor' => '{"nombre":"Nombre configurado","cargo":"Cargo configurado","telefono":"Teléfono configurado"}'],
        ] as $code => $row) {
            $repository->shouldReceive('getCurrentParameter')->zeroOrMoreTimes()->with($code, '2026-10-06')->andReturn($row);
        }
        $this->mock(CertificateRepository::class)->shouldReceive('getFormat')
            ->with('CONSTANCIA_ENTREGA_RETIRO', '2026-10-06')->once()->andReturn($this->format());
    }

    private function retirement(array $changes = []): array
    {
        return array_replace([
            'id_empleado' => 5, 'estado' => 'COMPLETADO', 'empleado' => 'Ana Perez',
            'numero_documento' => '123', 'fecha_ingreso' => '2023-01-16', 'fecha_retiro' => '2026-10-01',
            'cargo' => 'Supervisor de Calidad', 'motivo_retiro' => 'Renuncia voluntaria',
            'id_empleado_contrato' => 7,
        ], $changes);
    }

    private function employee(int $times = 1, array $changes = []): void
    {
        $this->mock(EmployeeRepository::class)->shouldReceive('find')->with(5)->times($times)->andReturn(array_replace([
            'nombres' => 'Ana', 'apellidos' => 'Perez', 'tipo_documento' => 'Cédula',
            'numero_documento' => '123', 'fecha_ingreso' => '2023-01-16',
        ], $changes));
    }

    private function format(): array
    {
        return ['clave_formato' => 'CONSTANCIA_ENTREGA_RETIRO', 'variante' => 'GENERAL',
            'clave_renderizador' => 'constancia-entrega-retiro', 'codigo_formato' => 'BBTH-F-004',
            'firmantes_json' => '[{"codigo_parametro":"DOC_FIRMANTE_F004"}]', 'control_documental_json' => '{"version":"1"}'];
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
