<?php

namespace Tests\Feature;

use App\Services\JwtService;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Route;
use Tests\TestCase;

class ContractingApiTest extends TestCase
{
    public function test_contracting_routes_are_registered(): void
    {
        $routes = collect(Route::getRoutes())
            ->filter(fn ($route): bool => str_starts_with($route->uri(), 'api/contracting'))
            ->map(fn ($route): string => implode('|', $route->methods()).' '.$route->uri())
            ->values()
            ->all();

        $this->assertEqualsCanonicalizing([
            'GET|HEAD api/contracting/employees',
            'GET|HEAD api/contracting/contract-templates',
            'GET|HEAD api/contracting/contracts/{employeeContractId}/generation-data',
            'POST api/contracting/contracts/{employeeContractId}/sign',
            'GET|HEAD api/contracting/employees/{employeeId}/profile',
            'POST api/contracting/employees/{employeeId}/profile',
            'GET|HEAD api/contracting/employees/{employeeId}/contracts',
            'POST api/contracting/employees/{employeeId}/contracts',
            'GET|HEAD api/contracting/employees/{employeeId}/social-security',
            'POST api/contracting/employees/{employeeId}/social-security',
            'GET|HEAD api/contracting/employees/{employeeId}/medical-exams',
            'POST api/contracting/employees/{employeeId}/medical-exams',
            'GET|HEAD api/contracting/employees/{employeeId}/documents',
            'POST api/contracting/employees/{employeeId}/documents',
            'GET|HEAD api/contracting/alerts',
        ], $routes);
    }

    public function test_contracting_routes_require_jwt(): void
    {
        foreach ($this->contractingEndpoints() as [$method, $uri]) {
            $this->json($method, $uri)
                ->assertUnauthorized()
                ->assertJson([
                    'success' => false,
                    'message' => 'Token de acceso requerido.',
                ]);
        }
    }

    public function test_contracting_routes_require_expected_permissions(): void
    {
        foreach ($this->contractingEndpoints() as [$method, $uri]) {
            $this->withToken($this->tokenWithPermissions([]))
                ->json($method, $uri)
                ->assertForbidden()
                ->assertJsonPath('success', false)
                ->assertJsonPath('message', 'No tiene el permiso requerido para esta operación.');
        }
    }

    public function test_save_profile_accepts_create_or_edit_permission(): void
    {
        DB::shouldReceive('select')
            ->once()
            ->with('CALL SP_BBF_CONTRATACION_FICHA_GUARDAR(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)', [
                5,
                null,
                null,
                null,
                73,
                73001,
                25,
                25126,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
            ])
            ->andReturn([(object) ['ID_EMPLEADO' => 5, 'ESTADO_FICHA' => 'INCOMPLETA']]);

        $this->withToken($this->tokenWithPermissions(['CONTRATACION_CREAR']))
            ->postJson('/api/contracting/employees/5/profile', [
                'id_departamento_nacimiento' => 73,
                'id_municipio_nacimiento' => 73001,
                'id_departamento_residencia' => 25,
                'id_municipio_residencia' => 25126,
            ])
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.id_empleado', 5)
            ->assertJsonPath('data.estado_ficha', 'INCOMPLETA');
    }

    public function test_contracting_validations_work(): void
    {
        $this->withToken($this->tokenWithPermissions(['CONTRATACION_EDITAR']))
            ->postJson('/api/contracting/employees/5/profile', [
                'correo_personal' => 'no-es-email',
                'numero_carpeta' => str_repeat('A', 51),
                'genero' => str_repeat('A', 21),
                'fecha_expedicion_documento' => 'no-es-fecha',
                'personas_vivienda' => -1,
                'menores_estudian' => 'no-es-booleano',
            ])
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'correo_personal',
                'numero_carpeta',
                'genero',
                'fecha_expedicion_documento',
                'personas_vivienda',
                'menores_estudian',
            ]);

        $this->withToken($this->tokenWithPermissions(['CONTRATACION_CREAR']))
            ->postJson('/api/contracting/employees/5/contracts', [])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['id_tipo_contrato', 'fecha_inicio']);

        $this->withToken($this->tokenWithPermissions(['CONTRATACION_CREAR']))
            ->postJson('/api/contracting/employees/5/contracts', [
                'fecha_inicio' => '2026-06-24',
                'tipo_cargo_contrato' => 'NO_VALIDO',
                'prorroga_dias' => -1,
                'auxilio_transporte' => 'no-es-booleano',
            ])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['tipo_cargo_contrato', 'prorroga_dias', 'auxilio_transporte']);

        $this->withToken($this->tokenWithPermissions(['CONTRATACION_SEGURIDAD_SOCIAL_EDITAR']))
            ->postJson('/api/contracting/employees/5/social-security', [
                'fecha_afiliacion_eps' => 'no-fecha',
            ])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['fecha_afiliacion_eps']);

        $this->withToken($this->tokenWithPermissions(['CONTRATACION_EXAMENES_CREAR']))
            ->postJson('/api/contracting/employees/5/medical-exams', [])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['id_tipo_examen_medico', 'fecha_examen']);

        $this->withToken($this->tokenWithPermissions(['CONTRATACION_DOCUMENTOS_SUBIR']))
            ->postJson('/api/contracting/employees/5/documents', [])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['id_tipo_documento_laboral', 'nombre_archivo', 'archivo_url']);

        $this->withToken($this->tokenWithPermissions(['CONTRATACION_ALERTAS_VER']))
            ->getJson('/api/contracting/alerts?dias_antes=-1')
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['dias_antes']);

    }

    public function test_profile_get_maps_new_fields_from_sp(): void
    {
        DB::shouldReceive('select')
            ->once()
            ->with('CALL SP_BBF_CONTRATACION_FICHA_OBTENER(?)', [5])
            ->andReturn([(object) [
                'ID_EMPLEADO' => 5,
                'ESTADO_FICHA' => 'INCOMPLETA',
                'FECHA_NACIMIENTO' => '1998-04-10',
                'NACIONALIDAD' => 'Colombiana',
                'ID_DEPARTAMENTO_NACIMIENTO' => 73,
                'ID_MUNICIPIO_NACIMIENTO' => 73001,
                'ID_DEPARTAMENTO_RESIDENCIA' => 25,
                'ID_MUNICIPIO_RESIDENCIA' => 25126,
                'DEPARTAMENTO_NACIMIENTO' => 'Tolima',
                'LUGAR_NACIMIENTO' => 'Ibague',
                'DEPARTAMENTO_RESIDENCIA' => 'Cundinamarca',
                'CIUDAD_RESIDENCIA' => 'Cajica',
                'DIRECCION_RESIDENCIA' => 'Calle 1',
                'TELEFONO_ALTERNO' => '3001234567',
                'CORREO_PERSONAL' => 'ana@example.com',
                'NUMERO_CARPETA' => 'CARP-001',
                'GENERO' => 'FEMENINO',
                'FECHA_EXPEDICION_DOCUMENTO' => '2016-05-20',
                'PERSONAS_VIVIENDA' => 4,
                'MENORES_ESTUDIAN' => 1,
            ]]);

        $this->withToken($this->tokenWithPermissions(['CONTRATACION_VER']))
            ->getJson('/api/contracting/employees/5/profile')
            ->assertOk()
            ->assertJsonPath('data.id_empleado', 5)
            ->assertJsonPath('data.estado_ficha', 'INCOMPLETA')
            ->assertJsonPath('data.fecha_nacimiento', '1998-04-10')
            ->assertJsonPath('data.nacionalidad', 'Colombiana')
            ->assertJsonPath('data.id_departamento_nacimiento', 73)
            ->assertJsonPath('data.id_municipio_nacimiento', 73001)
            ->assertJsonPath('data.id_departamento_residencia', 25)
            ->assertJsonPath('data.id_municipio_residencia', 25126)
            ->assertJsonPath('data.departamento_nacimiento', 'Tolima')
            ->assertJsonPath('data.lugar_nacimiento', 'Ibague')
            ->assertJsonPath('data.departamento_residencia', 'Cundinamarca')
            ->assertJsonPath('data.ciudad_residencia', 'Cajica')
            ->assertJsonPath('data.direccion_residencia', 'Calle 1')
            ->assertJsonPath('data.telefono_alterno', '3001234567')
            ->assertJsonPath('data.correo_personal', 'ana@example.com')
            ->assertJsonPath('data.numero_carpeta', 'CARP-001')
            ->assertJsonPath('data.genero', 'FEMENINO')
            ->assertJsonPath('data.fecha_expedicion_documento', '2016-05-20')
            ->assertJsonPath('data.personas_vivienda', 4)
            ->assertJsonPath('data.menores_estudian', 1);
    }

    public function test_employees_endpoint_uses_sp_and_maps_snake_case_response(): void
    {
        DB::shouldReceive('select')
            ->once()
            ->with('CALL SP_BBF_CONTRATACION_LISTAR_EMPLEADOS(?,?,?,?)', ['Ana', 1, 2, 'ACTIVO'])
            ->andReturn([
                (object) [
                    'ID_EMPLEADO' => 5,
                    'NUMERO_DOCUMENTO' => '123456789',
                    'NOMBRE_COMPLETO' => 'Ana Perez',
                    'ESTADO_FICHA' => 'COMPLETA',
                    'FECHA_INGRESO' => '2026-06-24',
                    'AUXILIO_TRANSPORTE' => 1,
                    'PERIODO_PAGO' => 'Quincenal',
                    'LUGAR_LABORES' => 'Finca principal',
                    'NUMERO_CONTRATO' => 'CT-2026-001',
                    'TIPO_CARGO_CONTRATO' => 'OPERATIVO',
                    'PRORROGA_DIAS' => 30,
                ],
            ]);

        $this->withToken($this->tokenWithPermissions(['CONTRATACION_VER']))
            ->getJson('/api/contracting/employees?texto_busqueda=Ana&id_area=1&id_cargo=2&estado_empleado=ACTIVO')
            ->assertOk()
            ->assertExactJson([
                'success' => true,
                'message' => 'Empleados de contratacion consultados correctamente',
                'data' => [[
                    'id_empleado' => 5,
                    'numero_documento' => '123456789',
                    'nombre_completo' => 'Ana Perez',
                    'estado_ficha' => 'COMPLETA',
                    'fecha_ingreso' => '2026-06-24',
                    'auxilio_transporte' => 1,
                    'periodo_pago' => 'Quincenal',
                    'lugar_labores' => 'Finca principal',
                    'numero_contrato' => 'CT-2026-001',
                    'tipo_cargo_contrato' => 'OPERATIVO',
                    'prorroga_dias' => 30,
                ]],
            ]);
    }

    public function test_create_contract_endpoint_uses_real_sp_parameter_order(): void
    {
        DB::shouldReceive('select')
            ->once()
            ->with('CALL SP_BBF_CONTRATACION_CONTRATO_CREAR(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)', [
                5,
                1,
                9,
                2,
                3,
                '2026-06-24',
                '2026-12-24',
                6,
                2500000,
                1,
                'Quincenal',
                'Finca principal',
                'CT-2026-001',
                'OPERATIVO',
                'Corte y empaque de flores',
                30,
                'Cumplir las funciones asignadas al cargo.',
                'Tiempo completo',
                60,
                'ACTIVO',
                '/contratos/5.pdf',
                'Contrato inicial',
                99,
            ])
            ->andReturn([(object) [
                'ID_EMPLEADO_CONTRATO' => 7,
                'ID_EMPLEADO' => 5,
                'ID_PLANTILLA_CONTRATO' => 9,
                'ESTADO_CONTRATO' => 'ACTIVO',
                'FECHA_INICIO' => '2026-06-24',
                'FECHA_FIN' => '2026-12-24',
                'AUXILIO_TRANSPORTE' => 1,
                'PERIODO_PAGO' => 'Quincenal',
                'LUGAR_LABORES' => 'Finca principal',
                'NUMERO_CONTRATO' => 'CT-2026-001',
                'TIPO_CARGO_CONTRATO' => 'OPERATIVO',
            ]]);

        $this->withToken($this->tokenWithPermissions(['CONTRATACION_CREAR']))
            ->postJson('/api/contracting/employees/5/contracts', [
                'id_tipo_contrato' => 1,
                'id_plantilla_contrato' => 9,
                'id_area' => 2,
                'id_cargo' => 3,
                'fecha_inicio' => '2026-06-24',
                'fecha_fin' => '2026-12-24',
                'duracion_meses' => 6,
                'salario_base' => 2500000,
                'auxilio_transporte' => true,
                'periodo_pago' => 'Quincenal',
                'lugar_labores' => 'Finca principal',
                'numero_contrato' => 'CT-2026-001',
                'tipo_cargo_contrato' => 'OPERATIVO',
                'objeto_obra_labor' => 'Corte y empaque de flores',
                'prorroga_dias' => 30,
                'clausula_funciones' => 'Cumplir las funciones asignadas al cargo.',
                'jornada_laboral' => 'Tiempo completo',
                'periodo_prueba_dias' => 60,
                'estado_contrato' => 'ACTIVO',
                'archivo_contrato_url' => '/contratos/5.pdf',
                'observaciones' => 'Contrato inicial',
            ])
            ->assertCreated()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.id_empleado_contrato', 7)
            ->assertJsonPath('data.id_plantilla_contrato', 9)
            ->assertJsonPath('data.auxilio_transporte', 1)
            ->assertJsonPath('data.numero_contrato', 'CT-2026-001')
            ->assertJsonPath('data.tipo_cargo_contrato', 'OPERATIVO');
    }

    public function test_contracts_endpoint_returns_new_contract_fields(): void
    {
        DB::shouldReceive('select')
            ->once()
            ->with('CALL SP_BBF_CONTRATACION_CONTRATOS_LISTAR(?)', [5])
            ->andReturn([(object) [
                'ID_EMPLEADO_CONTRATO' => 7,
                'ID_EMPLEADO' => 5,
                'ID_PLANTILLA_CONTRATO' => 9,
                'NOMBRE_PLANTILLA' => 'Contrato administrativo',
                'CODIGO_FORMATO' => 'ADM-001',
                'VERSION_FORMATO' => '1.0',
                'FECHA_VIGENCIA' => '2026-01-01',
                'ARCHIVO_PLANTILLA_URL' => '/plantillas/adm.docx',
                'ARCHIVO_PLANTILLA_RUTA' => 'templates/adm.docx',
                'FORMATO_SALIDA_DEFAULT' => 'PDF',
                'CONFIG_CAMPOS_JSON' => '{"salario":true}',
                'VALORES_DEFAULT_JSON' => '{"periodo_pago":"Mensual"}',
                'ESTADO_CONTRATO' => 'ACTIVO',
                'FECHA_INICIO' => '2026-06-24',
                'FECHA_FIN' => '2026-12-24',
                'AUXILIO_TRANSPORTE' => 0,
                'PERIODO_PAGO' => 'Mensual',
                'LUGAR_LABORES' => 'Sede administrativa',
                'NUMERO_CONTRATO' => 'CT-2026-002',
                'TIPO_CARGO_CONTRATO' => 'ADMINISTRATIVO',
                'OBJETO_OBRA_LABOR' => 'Gestion administrativa',
                'PRORROGA_DIAS' => 0,
                'CLAUSULA_FUNCIONES' => 'Funciones administrativas del cargo.',
                'FECHA_FIRMA' => '2026-07-24',
                'CONTRATO_FIRMADO' => 1,
            ]]);

        $this->withToken($this->tokenWithPermissions(['CONTRATACION_HISTORIAL_VER']))
            ->getJson('/api/contracting/employees/5/contracts')
            ->assertOk()
            ->assertJsonPath('data.0.id_empleado_contrato', 7)
            ->assertJsonPath('data.0.id_plantilla_contrato', 9)
            ->assertJsonPath('data.0.nombre_plantilla', 'Contrato administrativo')
            ->assertJsonPath('data.0.codigo_formato', 'ADM-001')
            ->assertJsonPath('data.0.formato_salida_default', 'PDF')
            ->assertJsonPath('data.0.config_campos.salario', true)
            ->assertJsonPath('data.0.valores_default.periodo_pago', 'Mensual')
            ->assertJsonPath('data.0.auxilio_transporte', 0)
            ->assertJsonPath('data.0.periodo_pago', 'Mensual')
            ->assertJsonPath('data.0.lugar_labores', 'Sede administrativa')
            ->assertJsonPath('data.0.numero_contrato', 'CT-2026-002')
            ->assertJsonPath('data.0.tipo_cargo_contrato', 'ADMINISTRATIVO')
            ->assertJsonPath('data.0.objeto_obra_labor', 'Gestion administrativa')
            ->assertJsonPath('data.0.prorroga_dias', 0)
            ->assertJsonPath('data.0.clausula_funciones', 'Funciones administrativas del cargo.')
            ->assertJsonPath('data.0.fecha_firma', '2026-07-24')
            ->assertJsonPath('data.0.contrato_firmado', 1);
    }

    public function test_contract_template_endpoints_and_generation_data_use_expected_stored_procedures(): void
    {
        DB::shouldReceive('select')->once()
            ->with('CALL SP_BBF_CONTRATO_PLANTILLAS_LISTAR(?,?,?)', [1, 'OPERATIVO', 1])
            ->andReturn([(object) [
                'ID_PLANTILLA_CONTRATO' => 9,
                'NOMBRE_PLANTILLA' => 'Contrato operativo',
                'CONFIG_CAMPOS_JSON' => '{"objeto":true}',
                'VALORES_DEFAULT_JSON' => '{"formato":"PDF"}',
            ]]);
        DB::shouldReceive('select')->once()
            ->with('CALL SP_BBF_CONTRATACION_CONTRATO_DATOS_GENERAR(?)', [7])
            ->andReturn([(object) [
                'ID_EMPLEADO_CONTRATO' => 7,
                'ID_EMPLEADO' => 5,
                'NOMBRE_COMPLETO' => 'Ana Perez',
                'RAZON_SOCIAL' => 'FINCA BARRO BLANCO FARMS',
                'NIT' => '900.747.203-1',
                'DIRECCION_EMPRESA' => 'Vereda San José finca Barro Barro Blanco',
                'CORREO_EMPRESA' => 'BARROBLANCOFARMS@GMAIL.COM',
                'ID_PLANTILLA_CONTRATO' => 9,
                'NOMBRE_PLANTILLA' => 'Contrato operativo',
                'FORMATO_SALIDA_DEFAULT' => 'PDF',
                'FECHA_GENERACION' => '2026-07-09',
                'FECHA_INICIO' => '2026-07-23',
                'FECHA_FIN' => '2026-07-31',
                'DURACION_MESES' => 3,
                'VALORES_DEFAULT_JSON' => '{"termino_inicial_contrato":"TRES (03) MESES"}',
                'CONFIG_CAMPOS_JSON' => '{"nombre":true}',
            ]]);

        $this->withToken($this->tokenWithPermissions(['CONTRATACION_VER']))
            ->getJson('/api/contracting/contract-templates?id_tipo_contrato=1&tipo_cargo_contrato=OPERATIVO')
            ->assertOk()
            ->assertJsonPath('data.0.id_plantilla_contrato', 9)
            ->assertJsonPath('data.0.config_campos.objeto', true)
            ->assertJsonPath('data.0.valores_default.formato', 'PDF');

        $this->withToken($this->tokenWithPermissions(['CONTRATACION_VER']))
            ->getJson('/api/contracting/contracts/7/generation-data')
            ->assertOk()
            ->assertJsonPath('data.empresa.razonSocial', 'BARRO BLANCO FARMS S.A.S')
            ->assertJsonPath('data.empresa.nit', '900747203-1')
            ->assertJsonPath('data.empresa.domicilio', 'VEREDA SAN JOSE FINCA BARRO BLANCO')
            ->assertJsonPath('data.empresa.correo', 'barroblancofarms@gmail.com')
            ->assertJsonPath('data.contrato.id_empleado_contrato', 7)
            ->assertJsonPath('data.empleado.nombre_completo', 'Ana Perez')
            ->assertJsonPath('data.parametros.plantilla.id_plantilla_contrato', 9)
            ->assertJsonPath('data.parametros.plantilla.config_campos.nombre', true)
            ->assertJsonPath('data.parametros.plantilla.formato_salida_default', 'PDF')
            ->assertJsonPath('data.parametros.reemplazos.FECHA_FIN_TEXTO', '23 de octubre de 2026');
    }

    public function test_alerts_endpoint_accepts_dias_antes(): void
    {
        DB::shouldReceive('select')->once()
            ->with('CALL SP_BBF_CONTRATACION_ALERTAS_LISTAR(?)', [45])
            ->andReturn([(object) [
                'ID_EMPLEADO_CONTRATO' => 7,
                'ID_EMPLEADO' => 5,
                'NOMBRE_COMPLETO' => 'Ana Perez',
                'DIAS_PARA_VENCER' => 12,
                'TIPO_ALERTA' => 'PROXIMO_VENCER',
            ]]);

        $this->withToken($this->tokenWithPermissions(['CONTRATACION_ALERTAS_VER']))
            ->getJson('/api/contracting/alerts?dias_antes=45')
            ->assertOk()
            ->assertJsonPath('data.0.id_empleado_contrato', 7)
            ->assertJsonPath('data.0.dias_para_vencer', 12)
            ->assertJsonPath('data.0.tipo_alerta', 'PROXIMO_VENCER');
    }

    public function test_sign_contract_with_external_url(): void
    {
        DB::shouldReceive('select')->once()
            ->with('CALL SP_BBF_CONTRATACION_CONTRATO_FIRMADO_REGISTRAR(?,?,?,?,?,?,?,?,?,?)', [
                7,
                '2026-07-24',
                'Contrato firmado',
                null,
                'https://example.com/contrato-firmado.pdf',
                null,
                null,
                null,
                'Firmado externamente',
                99,
            ])
            ->andReturn([(object) [
                'ID_EMPLEADO_CONTRATO' => 7,
                'ID_EMPLEADO' => 5,
                'NUMERO_CONTRATO' => 'CT-007',
                'FECHA_FIRMA' => '2026-07-24',
                'ID_EMPLEADO_DOCUMENTO' => 21,
                'NOMBRE_ARCHIVO' => 'Contrato firmado',
                'NOMBRE_ORIGINAL' => null,
                'ARCHIVO_URL' => 'https://example.com/contrato-firmado.pdf',
                'ARCHIVO_RUTA' => null,
                'ESTADO_DOCUMENTO' => 'CARGADO',
                'OBSERVACIONES' => 'Firmado externamente',
                'ESTADO_FIRMA' => 'FIRMADO',
            ]]);

        $this->withToken($this->tokenWithPermissions(['CONTRATACION_EDITAR']))
            ->postJson('/api/contracting/contracts/7/sign', [
                'fecha_firma' => '2026-07-24',
                'origen' => 'URL',
                'url' => 'https://example.com/contrato-firmado.pdf',
                'observaciones' => 'Firmado externamente',
            ])
            ->assertOk()
            ->assertJsonPath('data.id_empleado_contrato', 7)
            ->assertJsonPath('data.estado_firma', 'FIRMADO')
            ->assertJsonPath('data.archivo_url', 'https://example.com/contrato-firmado.pdf');
    }

    public function test_sign_contract_with_physical_file(): void
    {
        DB::shouldReceive('select')->once()
            ->withArgs(function (string $sql, array $parameters): bool {
                return $sql === 'CALL SP_BBF_CONTRATACION_CONTRATO_FIRMADO_REGISTRAR(?,?,?,?,?,?,?,?,?,?)'
                    && $parameters[0] === 7
                    && $parameters[1] === '2026-07-24'
                    && $parameters[2] === 'firmado.pdf'
                    && $parameters[3] === 'firmado.pdf'
                    && $parameters[4] === null
                    && str_starts_with($parameters[5], 'uploads/contracts/7/documents/')
                    && $parameters[6] === 'application/pdf'
                    && $parameters[8] === 'Firma presencial'
                    && $parameters[9] === 99;
            })
            ->andReturn([(object) [
                'ID_EMPLEADO_CONTRATO' => 7,
                'ID_EMPLEADO' => 5,
                'FECHA_FIRMA' => '2026-07-24',
                'ID_EMPLEADO_DOCUMENTO' => 21,
                'NOMBRE_ARCHIVO' => 'firmado.pdf',
                'NOMBRE_ORIGINAL' => 'firmado.pdf',
                'ESTADO_DOCUMENTO' => 'CARGADO',
                'ESTADO_FIRMA' => 'FIRMADO',
            ]]);

        $response = $this->withToken($this->tokenWithPermissions(['CONTRATACION_EDITAR']))
            ->post('/api/contracting/contracts/7/sign', [
                'fecha_firma' => '2026-07-24',
                'origen' => 'ARCHIVO',
                'observaciones' => 'Firma presencial',
                'archivo' => UploadedFile::fake()->create('firmado.pdf', 128, 'application/pdf'),
            ]);

        $response->assertOk()->assertJsonPath('data.estado_firma', 'FIRMADO');
        File::deleteDirectory(public_path('uploads/contracts/7'));
    }

    public function test_sign_contract_validates_required_and_exclusive_origin_fields(): void
    {
        $token = $this->tokenWithPermissions(['CONTRATACION_EDITAR']);

        $this->withToken($token)->postJson('/api/contracting/contracts/7/sign', [
            'origen' => 'URL',
            'url' => 'https://example.com/firmado.pdf',
        ])->assertUnprocessable()->assertJsonValidationErrors('fecha_firma');

        $this->withToken($token)->postJson('/api/contracting/contracts/7/sign', [
            'fecha_firma' => '2026-07-24',
            'origen' => 'ARCHIVO',
        ])->assertUnprocessable()->assertJsonValidationErrors('archivo');

        $this->withToken($token)->postJson('/api/contracting/contracts/7/sign', [
            'fecha_firma' => '2026-07-24',
            'origen' => 'URL',
        ])->assertUnprocessable()->assertJsonValidationErrors('url');

        $this->withToken($token)->post('/api/contracting/contracts/7/sign', [
            'fecha_firma' => '2026-07-24',
            'origen' => 'ARCHIVO',
            'url' => 'https://example.com/firmado.pdf',
            'archivo' => UploadedFile::fake()->create('firmado.pdf', 1, 'application/pdf'),
        ])->assertUnprocessable()->assertJsonValidationErrors('url');
    }

    public function test_sign_contract_deletes_new_file_when_stored_procedure_returns_no_result(): void
    {
        File::deleteDirectory(public_path('uploads/contracts/404'));

        DB::shouldReceive('select')->once()
            ->withArgs(fn (string $sql, array $parameters): bool => $sql === 'CALL SP_BBF_CONTRATACION_CONTRATO_FIRMADO_REGISTRAR(?,?,?,?,?,?,?,?,?,?)'
                && $parameters[0] === 404
                && str_starts_with($parameters[5], 'uploads/contracts/404/documents/')
            )
            ->andReturn([]);

        $this->withToken($this->tokenWithPermissions(['CONTRATACION_EDITAR']))
            ->post('/api/contracting/contracts/404/sign', [
                'fecha_firma' => '2026-07-24',
                'origen' => 'ARCHIVO',
                'archivo' => UploadedFile::fake()->create('firmado.pdf', 1, 'application/pdf'),
            ])
            ->assertUnprocessable()
            ->assertJsonPath('message', 'No fue posible registrar el contrato firmado.');

        $this->assertFalse(File::isDirectory(public_path('uploads/contracts/404/documents'))
            && count(File::files(public_path('uploads/contracts/404/documents'))) > 0);
        File::deleteDirectory(public_path('uploads/contracts/404'));
    }

    public function test_health_employees_and_dotations_routes_still_exist(): void
    {
        $this->getJson('/api/health')->assertOk();
        $this->assertNotNull(Route::getRoutes()->match(request()->create('/api/employees', 'GET')));
        $this->assertNotNull(Route::getRoutes()->match(request()->create('/api/dotations/deliveries', 'GET')));
    }

    private function contractingEndpoints(): array
    {
        return [
            ['GET', '/api/contracting/employees'],
            ['GET', '/api/contracting/contract-templates'],
            ['GET', '/api/contracting/contracts/7/generation-data'],
            ['POST', '/api/contracting/contracts/7/sign'],
            ['GET', '/api/contracting/employees/5/profile'],
            ['POST', '/api/contracting/employees/5/profile'],
            ['GET', '/api/contracting/employees/5/contracts'],
            ['POST', '/api/contracting/employees/5/contracts'],
            ['GET', '/api/contracting/employees/5/social-security'],
            ['POST', '/api/contracting/employees/5/social-security'],
            ['GET', '/api/contracting/employees/5/medical-exams'],
            ['POST', '/api/contracting/employees/5/medical-exams'],
            ['GET', '/api/contracting/employees/5/documents'],
            ['POST', '/api/contracting/employees/5/documents'],
            ['GET', '/api/contracting/alerts'],
        ];
    }

    private function tokenWithPermissions(array $permissions): string
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
