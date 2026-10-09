<?php

namespace Tests\Feature;

use App\Repositories\CertificateRepository;
use App\Repositories\ContractingRepository;
use App\Repositories\EmployeeRepository;
use App\Services\JwtService;
use Carbon\CarbonImmutable;
use Illuminate\Support\Facades\DB;
use Tests\TestCase;

class CertificateApiTest extends TestCase
{
    private const URL = '/api/contracting/employees/5/certificates';

    private const GENERATE = self::URL.'/CERTIFICADO_LABORAL_ACTIVO/generation-data';

    private const DOWNLOAD = self::URL.'/CERTIFICADO_LABORAL_ACTIVO/download';

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

    public function test_both_routes_authenticate_before_reading_sources(): void
    {
        $this->mock(EmployeeRepository::class)->shouldNotReceive('find');
        $this->mock(CertificateRepository::class)->shouldNotReceive('listFormats', 'getFormat');
        $this->mock(ContractingRepository::class)->shouldNotReceive('getContractGenerationData');
        foreach ([self::URL, self::GENERATE.'?id_empleado_contrato=7', self::DOWNLOAD.'?id_empleado_contrato=7'] as $url) {
            $this->getJson($url)->assertUnauthorized();
            $this->withToken($this->token([]))->getJson($url)->assertForbidden();
            $this->flushHeaders();
        }
    }

    public function test_available_catalog_excludes_other_keys_variants_and_renderers(): void
    {
        $this->employee();
        $format = $this->format();
        $this->mock(CertificateRepository::class)->shouldReceive('listFormats')->once()->with('2026-10-06')->andReturn([
            $format, array_replace($format, ['clave_formato' => 'OTRO']),
            array_replace($format, ['variante' => 'OTRA']), array_replace($format, ['clave_renderizador' => 'otro']),
        ]);
        $this->authorized()->getJson(self::URL)->assertOk()->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.clave_renderizador', 'certificado-laboral-activo-funciones')
            ->assertJsonMissingPath('data.0.firmantes_json');
    }

    public function test_disabled_initial_catalog_stays_empty(): void
    {
        $this->employee();
        $this->mock(CertificateRepository::class)->shouldReceive('listFormats')->once()->andReturn([]);
        $this->authorized()->getJson(self::URL)->assertOk()->assertJsonPath('data', []);
    }

    public function test_generation_returns_only_official_certificate_data_and_bogota_date(): void
    {
        $this->complete();
        $response = $this->authorized()->getJson(self::GENERATE.'?id_empleado_contrato=7')->assertOk()
            ->assertJsonPath('data.fecha_expedicion', '2026-10-06')
            ->assertJsonPath('data.empleado.fecha_ingreso', '2020-02-03')
            ->assertJsonPath('data.contrato.cargo', 'Cargo del contrato')
            ->assertJsonPath('data.funciones', ['Primera función, conserva la coma.', 'Segunda función.'])
            ->assertJsonPath('data.firmantes.0.nombre', 'Nombre configurado')
            ->assertJsonPath('data.empleado.lugar_expedicion_documento', 'Ciudad configurada');
        foreach (['salario_base', 'fecha_nacimiento', 'direccion_residencia', 'correo', 'estado_contrato'] as $private) {
            $this->assertStringNotContainsString('"'.$private.'"', $response->getContent());
        }
    }

    public function test_download_returns_a_real_pdf_with_the_official_certificate_content(): void
    {
        $this->complete();
        $response = $this->authorized()
            ->withHeader('Accept', 'application/json')
            ->get(self::DOWNLOAD.'?id_empleado_contrato=7');
        $response->assertOk()
            ->assertHeader('Content-Type', 'application/pdf')
            ->assertHeader('Content-Disposition', 'attachment; filename="BBTH-F-002-CERTIFICADO-LABORAL.pdf"')
            ->assertHeader('Cache-Control', 'no-store, private')
            ->assertHeader('Pragma', 'no-cache')
            ->assertHeader('Expires', '0');

        $this->assertStringStartsWith('%PDF-1.4', $response->getContent());
        $this->assertStringContainsString('Ana Perez', $response->getContent());
        $this->assertStringContainsString('SUSCRITA TALENTO HUMANO', $response->getContent());
    }

    public function test_missing_employee_and_non_active_employee_are_rejected_on_both_routes(): void
    {
        $employees = $this->mock(EmployeeRepository::class);
        $employees->shouldReceive('find')->with(5)->twice()->andReturn(null);
        foreach ([self::URL, self::GENERATE.'?id_empleado_contrato=7'] as $url) {
            $this->authorized()->getJson($url)->assertNotFound();
        }
        $employees->shouldReceive('find')->with(5)->twice()->andReturn(['estado_empleado' => 'RETIRADO']);
        foreach ([self::URL, self::GENERATE.'?id_empleado_contrato=7'] as $url) {
            $this->authorized()->getJson($url)->assertUnprocessable()->assertJsonValidationErrors('estado_empleado');
        }
    }

    public function test_contract_query_validation_and_unknown_format_do_not_read_contracts(): void
    {
        $this->mock(ContractingRepository::class)->shouldNotReceive('getContractGenerationData');
        foreach (['', '?id_empleado_contrato=abc', '?id_empleado_contrato=0', '?id_empleado_contrato[]=7'] as $query) {
            $this->authorized()->getJson(self::GENERATE.$query)->assertUnprocessable()->assertJsonValidationErrors('id_empleado_contrato');
        }
        $this->authorized()->getJson(self::URL.'/OTRO/generation-data?id_empleado_contrato=7')->assertNotFound();
    }

    public function test_foreign_or_missing_contract_never_exposes_its_data(): void
    {
        $this->employee(2);
        $this->mock(ContractingRepository::class)->shouldReceive('getContractGenerationData')->with(7)->twice()
            ->andReturn(['id_empleado' => 9, 'nombre_completo' => 'Privado'], null);
        for ($i = 0; $i < 2; $i++) {
            $this->authorized()->getJson(self::GENERATE.'?id_empleado_contrato=7')->assertNotFound()->assertJsonMissing(['nombre_completo' => 'Privado']);
        }
    }

    public function test_inactive_future_expired_and_invalid_contract_dates_are_rejected(): void
    {
        $cases = [['estado_contrato' => 'ANULADO'], ['fecha_inicio' => '2026-10-07'],
            ['fecha_fin' => '2026-10-05'], ['fecha_inicio' => '2026-02-30'], ['fecha_fin' => 'inválida']];
        $this->employee(count($cases));
        $contracts = $this->mock(ContractingRepository::class);
        $contracts->shouldReceive('getContractGenerationData')->with(7)->times(count($cases))
            ->andReturn(...array_map(fn ($change) => array_replace($this->contract(), $change), $cases));
        foreach ($cases as $_) {
            $this->authorized()->getJson(self::GENERATE.'?id_empleado_contrato=7')->assertUnprocessable()->assertJsonValidationErrors('contrato');
        }
    }

    public function test_missing_official_identity_cargo_and_functions_are_explicit(): void
    {
        $this->complete(['nombre_completo' => '', 'nombres' => '', 'apellidos' => '', 'tipo_documento' => '', 'numero_documento' => '', 'fecha_ingreso' => null],
            ['cargo' => '', 'clausula_funciones' => "-\n•\n"]);
        $this->authorized()->getJson(self::GENERATE.'?id_empleado_contrato=7')->assertUnprocessable()
            ->assertJsonValidationErrors(['nombre_completo', 'tipo_documento', 'numero_documento', 'fecha_ingreso', 'cargo', 'funciones']);
    }

    public function test_missing_or_invalid_configuration_is_explicit(): void
    {
        $this->complete([], [], ['DOC_EMPRESA_RAZON_SOCIAL' => null, 'DOC_EMPRESA_CIUDAD' => ['tipo_dato' => 'JSON', 'valor' => '{}'],
            'DOC_FIRMANTE_F002' => ['tipo_dato' => 'JSON', 'valor' => 'invalido']]);
        $this->authorized()->getJson(self::GENERATE.'?id_empleado_contrato=7')->assertUnprocessable()
            ->assertJsonValidationErrors(['DOC_EMPRESA_RAZON_SOCIAL', 'DOC_EMPRESA_CIUDAD', 'DOC_FIRMANTE_F002']);
    }

    public function test_signer_reference_structure_and_required_fields_are_validated(): void
    {
        $this->complete([], [], [], ['firmantes_json' => '{}']);
        $this->authorized()->getJson(self::GENERATE.'?id_empleado_contrato=7')->assertUnprocessable()->assertJsonValidationErrors('firmantes_json');
    }

    public function test_signer_fields_are_required(): void
    {
        $this->complete([], [], ['DOC_FIRMANTE_F002' => ['tipo_dato' => 'JSON', 'valor' => '{"nombre":"Persona"}']]);
        $this->authorized()->getJson(self::GENERATE.'?id_empleado_contrato=7')->assertUnprocessable()
            ->assertJsonValidationErrors(['DOC_FIRMANTE_F002.cargo', 'DOC_FIRMANTE_F002.telefono']);
    }

    public function test_catalog_repository_calls_existing_sps_and_normalizes_columns(): void
    {
        DB::shouldReceive('select')->once()->with('CALL SP_BBF_DOCUMENTO_FORMATOS_LISTAR(?,?)', ['EMPLEADO', '2026-10-06'])
            ->andReturn([(object) ['CLAVE_FORMATO' => 'CERTIFICADO_LABORAL_ACTIVO']]);
        DB::shouldReceive('select')->once()->with('CALL SP_BBF_DOCUMENTO_FORMATO_OBTENER(?,?,?)', ['CERTIFICADO_LABORAL_ACTIVO', 'GENERAL', '2026-10-06'])
            ->andReturn([(object) ['VARIANTE' => 'GENERAL']]);
        $repository = new CertificateRepository;
        $this->assertSame([['clave_formato' => 'CERTIFICADO_LABORAL_ACTIVO']], $repository->listFormats('2026-10-06'));
        $this->assertSame(['variante' => 'GENERAL'], $repository->getFormat('CERTIFICADO_LABORAL_ACTIVO', '2026-10-06'));
    }

    private function complete(array $employee = [], array $contract = [], array $parameters = [], array $format = []): void
    {
        $this->employee(1, $employee);
        $this->mock(CertificateRepository::class)->shouldReceive('getFormat')->once()->with('CERTIFICADO_LABORAL_ACTIVO', '2026-10-06')
            ->andReturn(array_replace($this->format(), $format));
        $repository = $this->mock(ContractingRepository::class);
        $repository->shouldReceive('getContractGenerationData')->once()->with(7)->andReturn(array_replace($this->contract(), $contract));
        $repository->shouldReceive('getProfile')->zeroOrMoreTimes()->with(5)->andReturn(['lugar_expedicion_documento' => 'Ciudad configurada', 'direccion_residencia' => 'Privado']);
        foreach (array_replace([
            'DOC_EMPRESA_RAZON_SOCIAL' => ['tipo_dato' => 'TEXTO', 'valor' => 'Empresa configurada'],
            'DOC_EMPRESA_CIUDAD' => ['tipo_dato' => 'TEXTO', 'valor' => 'Ciudad configurada'],
            'DOC_FIRMANTE_F002' => ['tipo_dato' => 'JSON', 'valor' => '{"nombre":"Nombre configurado","cargo":"Cargo configurado","telefono":"Teléfono configurado"}'],
        ], $parameters) as $code => $row) {
            $repository->shouldReceive('getCurrentParameter')->zeroOrMoreTimes()->with($code, '2026-10-06')->andReturn($row);
        }
    }

    private function employee(int $times = 1, array $changes = []): void
    {
        $this->mock(EmployeeRepository::class)->shouldReceive('find')->with(5)->times($times)->andReturn(array_replace([
            'estado_empleado' => 'ACTIVO', 'nombre_completo' => 'Ana Perez', 'tipo_documento' => 'Cédula',
            'numero_documento' => '123', 'fecha_ingreso' => '2020-02-03', 'cargo' => 'Cargo actual distinto',
            'fecha_nacimiento' => '1990-01-01',
        ], $changes));
    }

    private function contract(): array
    {
        return ['id_empleado' => 5, 'estado_contrato' => 'ACTIVO', 'fecha_inicio' => '2026-01-01', 'fecha_fin' => null,
            'cargo' => 'Cargo del contrato', 'clausula_funciones' => "1. Primera función, conserva la coma.\n• Segunda función.",
            'salario_base' => 12345, 'fecha_nacimiento' => '1990-01-01', 'direccion_residencia' => 'Privado'];
    }

    private function format(): array
    {
        return ['clave_formato' => 'CERTIFICADO_LABORAL_ACTIVO', 'variante' => 'GENERAL', 'clave_renderizador' => 'certificado-laboral-activo-funciones',
            'codigo_formato' => 'BBTH-F-002', 'firmantes_json' => '[{"codigo_parametro":"DOC_FIRMANTE_F002"}]', 'control_documental_json' => '{"version":"1"}'];
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
