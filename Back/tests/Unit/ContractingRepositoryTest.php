<?php

namespace Tests\Unit;

use App\Repositories\ContractingRepository;
use Illuminate\Support\Facades\DB;
use Tests\TestCase;

class ContractingRepositoryTest extends TestCase
{
    public function test_sign_contract_calls_expected_stored_procedure(): void
    {
        DB::shouldReceive('select')->once()
            ->with('CALL SP_BBF_CONTRATACION_CONTRATO_FIRMADO_REGISTRAR(?,?,?,?,?,?,?,?,?,?)', [
                7, '2026-07-24', 'firmado.pdf', 'original.pdf', null,
                'uploads/contracts/7/documents/firmado.pdf', 'application/pdf', 1024,
                'Firma presencial', 99,
            ])
            ->andReturn([(object) ['ID_EMPLEADO_CONTRATO' => 7]]);

        $result = app(ContractingRepository::class)->signContract(7, 99, [
            'fecha_firma' => '2026-07-24',
            'nombre_archivo' => 'firmado.pdf',
            'nombre_original' => 'original.pdf',
            'archivo_url' => null,
            'archivo_ruta' => 'uploads/contracts/7/documents/firmado.pdf',
            'mime_type' => 'application/pdf',
            'peso_bytes' => 1024,
            'observaciones' => 'Firma presencial',
        ]);

        $this->assertSame(7, $result['id_empleado_contrato']);
    }

    public function test_read_methods_call_expected_stored_procedures(): void
    {
        DB::shouldReceive('select')->once()
            ->with('CALL SP_BBF_CONTRATACION_LISTAR_EMPLEADOS(?,?,?,?)', ['Ana', 1, 2, 'ACTIVO'])
            ->andReturn([(object) ['ID_EMPLEADO' => 5]]);
        DB::shouldReceive('select')->once()
            ->with('CALL SP_BBF_CONTRATACION_FICHA_OBTENER(?)', [5])
            ->andReturn([(object) [
                'ID_EMPLEADO' => 5,
                'ESTADO_FICHA' => 'INCOMPLETA',
                'FECHA_NACIMIENTO' => '1998-04-10',
                'NACIONALIDAD' => 'Colombiana',
            ]]);
        DB::shouldReceive('select')->once()
            ->with('CALL SP_BBF_CONTRATACION_CONTRATOS_LISTAR(?)', [5])
            ->andReturn([(object) [
                'ID_EMPLEADO_CONTRATO' => 7,
                'ID_PLANTILLA_CONTRATO' => 2,
                'CONFIG_CAMPOS_JSON' => '{"salario":true}',
                'VALORES_DEFAULT_JSON' => '{"formato":"PDF"}',
            ]]);
        DB::shouldReceive('select')->once()
            ->with('CALL SP_BBF_CONTRATO_PLANTILLAS_LISTAR(?,?,?)', [1, 'OPERATIVO', 1])
            ->andReturn([(object) [
                'ID_PLANTILLA_CONTRATO' => 2,
                'NOMBRE_PLANTILLA' => 'Contrato operativo',
                'CONFIG_CAMPOS_JSON' => '{"campo":"valor"}',
                'VALORES_DEFAULT_JSON' => '{"salario":0}',
            ]]);
        DB::shouldReceive('select')->once()
            ->with('CALL SP_BBF_CONTRATACION_CONTRATO_DATOS_GENERAR(?)', [7])
            ->andReturn([(object) [
                'ID_EMPLEADO_CONTRATO' => 7,
                'ID_EMPLEADO' => 5,
                'ID_PLANTILLA_CONTRATO' => 2,
                'CONFIG_CAMPOS_JSON' => '{"nombre":true}',
            ]]);
        DB::shouldReceive('select')->once()
            ->with('CALL SP_BBF_CONTRATACION_SEGURIDAD_SOCIAL_OBTENER(?)', [5])
            ->andReturn([]);
        DB::shouldReceive('select')->once()
            ->with('CALL SP_BBF_CONTRATACION_EXAMENES_LISTAR(?)', [5])
            ->andReturn([]);
        DB::shouldReceive('select')->once()
            ->with('CALL SP_BBF_CONTRATACION_DOCUMENTOS_LISTAR(?)', [5])
            ->andReturn([(object) [
                'ID_EMPLEADO_DOCUMENTO' => 21,
                'ID_EMPLEADO_CONTRATO' => 7,
                'NOMBRE_ORIGINAL' => 'firmado-original.pdf',
                'ARCHIVO_RUTA' => 'uploads/contracts/7/documents/firmado.pdf',
            ]]);
        DB::shouldReceive('select')->once()
            ->with('CALL SP_BBF_CONTRATACION_ALERTAS_LISTAR(?)', [30])
            ->andReturn([]);

        $repository = app(ContractingRepository::class);

        $rows = $repository->listEmployees('Ana', 1, 2, 'ACTIVO');
        $this->assertSame(5, $rows[0]['id_empleado']);
        $this->assertArrayNotHasKey('ID_EMPLEADO', $rows[0]);
        $profile = $repository->getProfile(5);
        $this->assertSame(5, $profile['id_empleado']);
        $this->assertSame('INCOMPLETA', $profile['estado_ficha']);
        $this->assertSame('1998-04-10', $profile['fecha_nacimiento']);
        $this->assertSame('Colombiana', $profile['nacionalidad']);
        $contract = $repository->listContracts(5)[0];
        $this->assertSame(2, $contract['id_plantilla_contrato']);
        $this->assertSame(['salario' => true], $contract['config_campos']);
        $this->assertSame(['formato' => 'PDF'], $contract['valores_default']);
        $template = $repository->listContractTemplates(['id_tipo_contrato' => 1, 'tipo_cargo_contrato' => 'OPERATIVO', 'solo_activas' => 1])[0];
        $this->assertSame(2, $template['id_plantilla_contrato']);
        $this->assertSame(['campo' => 'valor'], $template['config_campos']);
        $this->assertSame(['salario' => 0], $template['valores_default']);
        $this->assertSame(7, $repository->getContractGenerationData(7)['id_empleado_contrato']);
        $repository->getSocialSecurity(5);
        $repository->listMedicalExams(5);
        $documents = $repository->listDocuments(5);
        $this->assertSame(7, $documents[0]['id_empleado_contrato']);
        $this->assertSame('firmado-original.pdf', $documents[0]['nombre_original']);
        $this->assertSame('uploads/contracts/7/documents/firmado.pdf', $documents[0]['archivo_ruta']);
        $repository->listAlerts(30);
    }

    public function test_save_profile_calls_stored_procedure_with_real_parameter_order(): void
    {
        DB::shouldReceive('select')->once()
            ->with('CALL SP_BBF_CONTRATACION_FICHA_GUARDAR(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)', [
                5,
                'CARP-001',
                'FEMENINO',
                '2016-05-20',
                73,
                73001,
                25,
                25126,
                'Calle 1',
                '3001234567',
                'ana@example.com',
                'SOLTERO',
                'PROFESIONAL',
                1,
                0,
                4,
                1,
                'Sin novedades',
                'Carlos Perez',
                'Hermano',
                '3101111111',
                '3102222222',
                'Calle 2',
                'Llamar en emergencia',
            ])
            ->andReturn([(object) ['ID_EMPLEADO' => 5]]);

        $row = app(ContractingRepository::class)->saveProfile(5, [
            'numero_carpeta' => 'CARP-001',
            'genero' => 'FEMENINO',
            'fecha_expedicion_documento' => '2016-05-20',
            'id_departamento_nacimiento' => 73,
            'id_municipio_nacimiento' => 73001,
            'id_departamento_residencia' => 25,
            'id_municipio_residencia' => 25126,
            'direccion_residencia' => 'Calle 1',
            'telefono_alterno' => '3001234567',
            'correo_personal' => 'ana@example.com',
            'estado_civil' => 'SOLTERO',
            'nivel_educativo' => 'PROFESIONAL',
            'personas_a_cargo' => 1,
            'numero_hijos' => 0,
            'personas_vivienda' => 4,
            'menores_estudian' => true,
            'observaciones' => 'Sin novedades',
            'contacto_emergencia' => [
                'nombre_completo' => 'Carlos Perez',
                'parentesco' => 'Hermano',
                'telefono' => '3101111111',
                'telefono_alterno' => '3102222222',
                'direccion' => 'Calle 2',
                'observaciones' => 'Llamar en emergencia',
            ],
        ]);

        $this->assertSame(5, $row['id_empleado']);
    }

    public function test_save_profile_preserves_false_and_null_for_menores_estudian(): void
    {
        foreach ([[false, 0], [null, null]] as [$input, $expected]) {
            DB::shouldReceive('select')->once()
                ->withArgs(function (string $sql, array $bindings) use ($expected): bool {
                    return $sql === 'CALL SP_BBF_CONTRATACION_FICHA_GUARDAR(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)'
                        && count($bindings) === 24
                        && $bindings[16] === $expected;
                })
                ->andReturn([(object) ['ID_EMPLEADO' => 5]]);

            app(ContractingRepository::class)->saveProfile(5, ['menores_estudian' => $input]);
        }
    }

    public function test_create_contract_calls_stored_procedure_with_real_parameter_order(): void
    {
        DB::shouldReceive('select')->once()
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
                'ID_PLANTILLA_CONTRATO' => 9,
                'AUXILIO_TRANSPORTE' => 1,
                'NUMERO_CONTRATO' => 'CT-2026-001',
                'TIPO_CARGO_CONTRATO' => 'OPERATIVO',
            ]]);

        $row = app(ContractingRepository::class)->createContract(5, 99, [
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
        ]);

        $this->assertSame(7, $row['id_empleado_contrato']);
        $this->assertSame(9, $row['id_plantilla_contrato']);
        $this->assertSame(1, $row['auxilio_transporte']);
        $this->assertSame('CT-2026-001', $row['numero_contrato']);
        $this->assertSame('OPERATIVO', $row['tipo_cargo_contrato']);
    }

    public function test_create_contract_accepts_null_new_fields_and_preserves_parameter_order(): void
    {
        DB::shouldReceive('select')->once()
            ->with('CALL SP_BBF_CONTRATACION_CONTRATO_CREAR(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)', [
                5,
                null,
                null,
                null,
                null,
                '2026-06-24',
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
                99,
            ])
            ->andReturn([(object) ['ID_EMPLEADO_CONTRATO' => 8]]);

        $row = app(ContractingRepository::class)->createContract(5, 99, [
            'fecha_inicio' => '2026-06-24',
        ]);

        $this->assertSame(8, $row['id_empleado_contrato']);
    }

    public function test_save_social_security_calls_stored_procedure_with_real_parameter_order(): void
    {
        DB::shouldReceive('select')->once()
            ->with('CALL SP_BBF_CONTRATACION_SEGURIDAD_SOCIAL_GUARDAR(?,?,?,?,?,?,?,?,?,?,?,?)', [
                5,
                1,
                2,
                3,
                4,
                5,
                '2026-06-24',
                '2026-06-25',
                '2026-06-26',
                '2026-06-27',
                '2026-06-28',
                'Afiliaciones registradas',
            ])
            ->andReturn([(object) ['ID_EMPLEADO' => 5]]);

        app(ContractingRepository::class)->saveSocialSecurity(5, [
            'id_eps' => 1,
            'id_arl' => 2,
            'id_fondo_pension' => 3,
            'id_fondo_cesantias' => 4,
            'id_caja_compensacion' => 5,
            'fecha_afiliacion_eps' => '2026-06-24',
            'fecha_afiliacion_arl' => '2026-06-25',
            'fecha_afiliacion_pension' => '2026-06-26',
            'fecha_afiliacion_cesantias' => '2026-06-27',
            'fecha_afiliacion_caja' => '2026-06-28',
            'observaciones' => 'Afiliaciones registradas',
        ]);
    }

    public function test_create_medical_exam_calls_stored_procedure_with_real_parameter_order(): void
    {
        DB::shouldReceive('select')->once()
            ->with('CALL SP_BBF_CONTRATACION_EXAMEN_CREAR(?,?,?,?,?,?,?,?)', [
                5,
                1,
                '2026-06-24',
                'Clinica Norte',
                'Apto',
                '2027-06-24',
                '/examenes/5.pdf',
                'Sin restricciones',
            ])
            ->andReturn([(object) ['ID_EMPLEADO_EXAMEN_MEDICO' => 8]]);

        app(ContractingRepository::class)->createMedicalExam(5, [
            'id_tipo_examen_medico' => 1,
            'fecha_examen' => '2026-06-24',
            'entidad_realiza' => 'Clinica Norte',
            'resultado_general' => 'Apto',
            'fecha_vencimiento' => '2027-06-24',
            'archivo_url' => '/examenes/5.pdf',
            'observaciones' => 'Sin restricciones',
        ]);
    }

    public function test_register_document_calls_stored_procedure_with_real_parameter_order(): void
    {
        DB::shouldReceive('select')->once()
            ->with('CALL SP_BBF_CONTRATACION_DOCUMENTO_REGISTRAR(?,?,?,?,?,?,?,?,?,?)', [
                5,
                1,
                'contrato.pdf',
                '/documentos/contrato.pdf',
                'application/pdf',
                12345,
                '2027-06-24',
                'CARGADO',
                'Documento inicial',
                99,
            ])
            ->andReturn([(object) ['ID_EMPLEADO_DOCUMENTO_LABORAL' => 9]]);

        app(ContractingRepository::class)->registerDocument(5, 99, [
            'id_tipo_documento_laboral' => 1,
            'nombre_archivo' => 'contrato.pdf',
            'archivo_url' => '/documentos/contrato.pdf',
            'mime_type' => 'application/pdf',
            'peso_bytes' => 12345,
            'fecha_vencimiento' => '2027-06-24',
            'estado_documento' => 'CARGADO',
            'observaciones' => 'Documento inicial',
        ]);
    }
}
