<?php

namespace Tests\Feature;

use App\Repositories\CertificateRepository;
use App\Repositories\ContractingRepository;
use App\Repositories\EmployeeRepository;
use App\Repositories\RetirementRepository;
use App\Services\JwtService;
use Carbon\CarbonImmutable;
use Tests\TestCase;

class ResignationAcceptanceApiTest extends TestCase
{
    private const URL = '/api/contracting/employees/5/certificates/acceptance';

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
            $this->postJson($url, ['id_retiro' => 3, 'fecha_presentacion_renuncia' => '2026-09-01'])->assertUnauthorized();
            $this->withToken($this->token([]))->postJson($url, ['id_retiro' => 3, 'fecha_presentacion_renuncia' => '2026-09-01'])->assertForbidden();
            $this->flushHeaders();
        }
        $this->getJson(self::URL)->assertUnauthorized();
        $this->withToken($this->token([]))->getJson(self::URL)->assertForbidden();
    }

    public function test_available_catalog_returns_only_acceptance_format(): void
    {
        $this->employee();
        $format = $this->format();
        $this->mock(CertificateRepository::class)->shouldReceive('listAllFormats')->once()->with('2026-10-06')->andReturn([
            $format,
            array_replace($format, ['clave_formato' => 'CERTIFICADO_LABORAL_ACTIVO', 'clave_renderizador' => 'certificado-laboral-activo-funciones']),
            array_replace($format, ['clave_renderizador' => 'otro']),
        ]);
        $this->authorized()->getJson(self::URL)->assertOk()->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.clave_formato', 'ACEPTACION_RENUNCIA')
            ->assertJsonPath('data.0.codigo_formato', 'BBTH-F-005')
            ->assertJsonMissingPath('data.0.firmantes_json');
    }

    public function test_generation_returns_official_acceptance_data(): void
    {
        $this->complete();
        $this->authorized()->postJson(self::GENERATE, ['id_retiro' => 3, 'fecha_presentacion_renuncia' => '2026-09-01'])->assertOk()
            ->assertJsonPath('data.fecha_expedicion', '2026-10-06')
            ->assertJsonPath('data.empleado.nombre_completo', 'Ana Perez')
            ->assertJsonPath('data.contrato.cargo', 'Supervisor de Calidad')
            ->assertJsonPath('data.retiro.motivo_retiro', 'Renuncia voluntaria')
            ->assertJsonPath('data.retiro.fecha_retiro', '2026-10-01')
            ->assertJsonPath('data.retiro.fecha_presentacion_renuncia', '2026-09-01')
            ->assertJsonPath('data.advertencias', [])
            ->assertJsonPath('data.firmantes.0.nombre', 'Nombre configurado');
    }

    public function test_acceptance_pending_is_reported_without_blocking(): void
    {
        $this->employee();
        $this->mock(RetirementRepository::class)->shouldReceive('detail')->with(3)->once()
            ->andReturn(['retirement' => $this->retirement(), 'activities' => [
                ['codigo' => 'ACEPTACION_RENUNCIA', 'estado' => 'PENDIENTE', 'fecha_cumplimiento' => null],
            ]]);
        $repository = $this->mock(ContractingRepository::class);
        $repository->shouldReceive('listContracts')->zeroOrMoreTimes()->withAnyArgs()->andReturn([
            ['estado_contrato' => 'ACTIVO', 'cargo' => 'Supervisor de Calidad'],
        ]);
        $repository->shouldReceive('getProfile')->zeroOrMoreTimes()->with(5)->andReturn([]);
        foreach ([
            'DOC_EMPRESA_RAZON_SOCIAL' => ['tipo_dato' => 'TEXTO', 'valor' => 'Empresa configurada'],
            'DOC_EMPRESA_CIUDAD' => ['tipo_dato' => 'TEXTO', 'valor' => 'Ciudad configurada'],
            'DOC_FIRMANTE_F005' => ['tipo_dato' => 'JSON', 'valor' => '{"nombre":"Nombre configurado","cargo":"Cargo configurado","telefono":"Teléfono configurado"}'],
        ] as $code => $row) {
            $repository->shouldReceive('getCurrentParameter')->zeroOrMoreTimes()->with($code, '2026-10-06')->andReturn($row);
        }
        $this->mock(CertificateRepository::class)->shouldReceive('getFormat')
            ->with('ACEPTACION_RENUNCIA', '2026-10-06')->once()->andReturn($this->format());
        $this->authorized()->postJson(self::GENERATE, ['id_retiro' => 3, 'fecha_presentacion_renuncia' => '2026-09-01'])->assertOk()
            ->assertJsonPath('data.advertencias.0', 'La actividad de aceptación de renuncia no está registrada como completada en el proceso de retiro.');
    }

    public function test_non_resignation_motive_is_rejected(): void
    {
        $this->employee();
        $this->mock(RetirementRepository::class)->shouldReceive('detail')->with(3)->once()
            ->andReturn(['retirement' => $this->retirement([
                'motivo_retiro' => 'Despido con justa causa', 'codigo_motivo' => 'DESPIDO_JUSTA_CAUSA', 'requiere_renuncia' => 0,
            ]), 'activities' => []]);
        $repository = $this->mock(ContractingRepository::class);
        $repository->shouldReceive('listContracts')->zeroOrMoreTimes()->withAnyArgs()->andReturn([]);
        $repository->shouldReceive('getCurrentParameter')->zeroOrMoreTimes()->andReturn(null);
        $this->mock(CertificateRepository::class)->shouldReceive('getFormat')
            ->with('ACEPTACION_RENUNCIA', '2026-10-06')->once()->andReturn($this->format());
        $this->authorized()->postJson(self::GENERATE, ['id_retiro' => 3, 'fecha_presentacion_renuncia' => '2026-09-01'])
            ->assertUnprocessable()->assertJsonValidationErrors('motivo_retiro');
    }

    public function test_missing_and_cancelled_retirement_are_rejected(): void
    {
        $this->employee(3);
        $retirements = $this->mock(RetirementRepository::class);
        $retirements->shouldReceive('detail')->with(3)->twice()->andReturn(['retirement' => null]);
        $this->authorized()->postJson(self::GENERATE, ['id_retiro' => 3, 'fecha_presentacion_renuncia' => '2026-09-01'])->assertNotFound();
        $this->authorized()->postJson(self::DOWNLOAD, ['id_retiro' => 3, 'fecha_presentacion_renuncia' => '2026-09-01'])->assertNotFound();
        $retirements->shouldReceive('detail')->with(4)->once()->andReturn(['retirement' => $this->retirement(['estado' => 'CANCELADO'])]);
        $this->authorized()->postJson(self::GENERATE, ['id_retiro' => 4, 'fecha_presentacion_renuncia' => '2026-09-01'])
            ->assertUnprocessable()->assertJsonValidationErrors('retiro');
    }

    public function test_foreign_retirement_is_not_disclosed(): void
    {
        $this->employee();
        $this->mock(RetirementRepository::class)->shouldReceive('detail')->with(3)->once()
            ->andReturn(['retirement' => $this->retirement(['id_empleado' => 9])]);
        $this->authorized()->postJson(self::GENERATE, ['id_retiro' => 3, 'fecha_presentacion_renuncia' => '2026-09-01'])->assertNotFound();
    }

    public function test_request_validation_requires_retirement_and_presentation_date(): void
    {
        $this->mock(EmployeeRepository::class)->shouldNotReceive('find');
        foreach ([self::GENERATE, self::DOWNLOAD] as $url) {
            $this->authorized()->postJson($url, [])->assertUnprocessable()->assertJsonValidationErrors(['id_retiro', 'fecha_presentacion_renuncia']);
            $this->authorized()->postJson($url, ['id_retiro' => 0, 'fecha_presentacion_renuncia' => 'no-es-fecha'])
                ->assertUnprocessable()->assertJsonValidationErrors(['id_retiro', 'fecha_presentacion_renuncia']);
        }
    }

    public function test_future_presentation_date_is_rejected(): void
    {
        $this->complete();
        $this->authorized()->postJson(self::GENERATE, ['id_retiro' => 3, 'fecha_presentacion_renuncia' => '2026-12-01'])
            ->assertUnprocessable()->assertJsonValidationErrors('fecha_presentacion_renuncia');
    }

    public function test_missing_official_fields_are_actionable(): void
    {
        $this->employee();
        $this->mock(RetirementRepository::class)->shouldReceive('detail')->with(3)->once()
            ->andReturn(['retirement' => $this->retirement(['cargo' => '', 'fecha_retiro' => null]), 'activities' => []]);
        $repository = $this->mock(ContractingRepository::class);
        $repository->shouldReceive('listContracts')->zeroOrMoreTimes()->withAnyArgs()->andReturn([]);
        $repository->shouldReceive('getCurrentParameter')->zeroOrMoreTimes()->andReturn(null);
        $this->mock(CertificateRepository::class)->shouldReceive('getFormat')
            ->with('ACEPTACION_RENUNCIA', '2026-10-06')->once()->andReturn($this->format());
        $this->authorized()->postJson(self::GENERATE, ['id_retiro' => 3, 'fecha_presentacion_renuncia' => '2026-09-01'])->assertUnprocessable()
            ->assertJsonValidationErrors(['cargo', 'fecha_retiro']);
    }

    public function test_download_returns_a_real_pdf_with_acceptance_content(): void
    {
        $this->complete();
        $response = $this->authorized()->postJson(self::DOWNLOAD, ['id_retiro' => 3, 'fecha_presentacion_renuncia' => '2026-09-01']);
        $response->assertOk()
            ->assertHeader('Content-Type', 'application/pdf')
            ->assertHeader('Content-Disposition', 'attachment; filename="BBTH-F-005-CARTA-ACEPTACION-RENUNCIA.pdf"')
            ->assertHeader('Cache-Control', 'no-store, private');
        $content = $response->getContent();
        $this->assertStringStartsWith('%PDF-1.4', $content);
        $this->assertStringContainsString(mb_convert_encoding('RF. Carta de Aceptación de Renuncia', 'Windows-1252', 'UTF-8'), $content);
        $this->assertStringContainsString(mb_convert_encoding('acepta la renuncia', 'Windows-1252', 'UTF-8'), $content);
        $this->assertStringContainsString('Ana Perez', $content);
    }

    private function complete(): void
    {
        $this->employee();
        $this->mock(RetirementRepository::class)->shouldReceive('detail')->with(3)->once()
            ->andReturn(['retirement' => $this->retirement(), 'activities' => [
                ['codigo' => 'CARTA_RENUNCIA', 'estado' => 'COMPLETADA', 'fecha_cumplimiento' => '2026-09-01 10:00:00'],
                ['codigo' => 'ACEPTACION_RENUNCIA', 'estado' => 'COMPLETADA', 'fecha_cumplimiento' => '2026-09-05 10:00:00'],
            ]]);
        $repository = $this->mock(ContractingRepository::class);
        $repository->shouldReceive('listContracts')->zeroOrMoreTimes()->withAnyArgs()->andReturn([
            ['estado_contrato' => 'ACTIVO', 'cargo' => 'Supervisor de Calidad'],
        ]);
        $repository->shouldReceive('getProfile')->zeroOrMoreTimes()->with(5)->andReturn([]);
        foreach ([
            'DOC_EMPRESA_RAZON_SOCIAL' => ['tipo_dato' => 'TEXTO', 'valor' => 'Empresa configurada'],
            'DOC_EMPRESA_CIUDAD' => ['tipo_dato' => 'TEXTO', 'valor' => 'Ciudad configurada'],
            'DOC_FIRMANTE_F005' => ['tipo_dato' => 'JSON', 'valor' => '{"nombre":"Nombre configurado","cargo":"Cargo configurado","telefono":"Teléfono configurado"}'],
        ] as $code => $row) {
            $repository->shouldReceive('getCurrentParameter')->zeroOrMoreTimes()->with($code, '2026-10-06')->andReturn($row);
        }
        $this->mock(CertificateRepository::class)->shouldReceive('getFormat')
            ->with('ACEPTACION_RENUNCIA', '2026-10-06')->once()->andReturn($this->format());
    }

    private function retirement(array $changes = []): array
    {
        return array_replace([
            'id_empleado' => 5, 'estado' => 'COMPLETADO', 'empleado' => 'Ana Perez',
            'numero_documento' => '123', 'fecha_ingreso' => '2023-01-16', 'fecha_retiro' => '2026-10-01',
            'cargo' => 'Supervisor de Calidad', 'motivo_retiro' => 'Renuncia voluntaria',
            'codigo_motivo' => 'RENUNCIA_VOLUNTARIA', 'requiere_renuncia' => 1,
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
        return ['clave_formato' => 'ACEPTACION_RENUNCIA', 'variante' => 'GENERAL',
            'clave_renderizador' => 'carta-aceptacion-renuncia', 'codigo_formato' => 'BBTH-F-005',
            'firmantes_json' => '[{"codigo_parametro":"DOC_FIRMANTE_F005"}]', 'control_documental_json' => '{"version":"1"}'];
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
