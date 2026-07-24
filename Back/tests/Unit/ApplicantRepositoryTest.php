<?php

namespace Tests\Unit;

use App\Repositories\ApplicantRepository;
use Illuminate\Support\Facades\DB;
use Tests\TestCase;

class ApplicantRepositoryTest extends TestCase
{
    public function test_list_applicants_calls_expected_stored_procedure_and_maps_snake_case(): void
    {
        DB::shouldReceive('select')
            ->once()
            ->with('CALL SP_BBF_ASPIRANTES_LISTAR(?,?,?,?)', ['Ana', 'REGISTRADO', 1, 2])
            ->andReturn([(object) [
                'ID_ASPIRANTE' => 5,
                'NOMBRE_COMPLETO' => 'Ana Perez',
                'ESTADO_ASPIRANTE' => 'REGISTRADO',
                'TOTAL_DOCUMENTOS' => 3,
            ]]);

        $rows = app(ApplicantRepository::class)->listApplicants('Ana', 'REGISTRADO', 1, 2);

        $this->assertSame(5, $rows[0]['id_aspirante']);
        $this->assertSame('Ana Perez', $rows[0]['nombre_completo']);
        $this->assertSame('REGISTRADO', $rows[0]['estado_aspirante']);
        $this->assertSame(3, $rows[0]['total_documentos']);
        $this->assertArrayNotHasKey('ID_ASPIRANTE', $rows[0]);
    }

    public function test_get_applicant_calls_expected_stored_procedure(): void
    {
        DB::shouldReceive('select')
            ->once()
            ->with('CALL SP_BBF_ASPIRANTES_OBTENER(?)', [5])
            ->andReturn([(object) [
                'ID_ASPIRANTE' => 5,
                'ID_DEPARTAMENTO_NACIMIENTO' => 73,
                'ID_MUNICIPIO_NACIMIENTO' => 73001,
                'ID_DEPARTAMENTO_RESIDENCIA' => 25,
                'ID_MUNICIPIO_RESIDENCIA' => 25126,
                'DEPARTAMENTO_NACIMIENTO' => 'Tolima',
                'LUGAR_NACIMIENTO' => 'Ibague',
                'DEPARTAMENTO_RESIDENCIA' => 'Cundinamarca',
                'CIUDAD_RESIDENCIA' => 'Cajica',
            ]]);

        $row = app(ApplicantRepository::class)->getApplicant(5);

        $this->assertSame(5, $row['id_aspirante']);
        $this->assertSame(73, $row['id_departamento_nacimiento']);
        $this->assertSame(73001, $row['id_municipio_nacimiento']);
        $this->assertSame(25, $row['id_departamento_residencia']);
        $this->assertSame(25126, $row['id_municipio_residencia']);
        $this->assertSame('Tolima', $row['departamento_nacimiento']);
        $this->assertSame('Ibague', $row['lugar_nacimiento']);
        $this->assertSame('Cundinamarca', $row['departamento_residencia']);
        $this->assertSame('Cajica', $row['ciudad_residencia']);
    }

    public function test_create_applicant_calls_expected_stored_procedure_with_21_parameters(): void
    {
        DB::shouldReceive('select')
            ->once()
            ->with('CALL SP_BBF_ASPIRANTES_CREAR(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)', [
                1,
                '123456789',
                'Ana',
                'Perez',
                'ana@example.com',
                '3001234567',
                'Calle 1',
                '2000-01-01',
                25,
                11001,
                'Colombiana',
                25,
                25126,
                'SOLTERO',
                'PROFESIONAL',
                1,
                0,
                2,
                3,
                'Aspirante inicial',
                99,
            ])
            ->andReturn([(object) ['ID_ASPIRANTE' => 5, 'ESTADO_ASPIRANTE' => 'REGISTRADO']]);

        $row = app(ApplicantRepository::class)->createApplicant($this->applicantPayload(), 99);

        $this->assertSame(5, $row['id_aspirante']);
        $this->assertSame('REGISTRADO', $row['estado_aspirante']);
    }

    public function test_update_applicant_calls_expected_stored_procedure_with_21_parameters(): void
    {
        DB::shouldReceive('select')
            ->once()
            ->with('CALL SP_BBF_ASPIRANTES_ACTUALIZAR(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)', [
                5,
                1,
                '123456789',
                'Ana',
                'Perez',
                'ana@example.com',
                '3001234567',
                'Calle 1',
                '2000-01-01',
                25,
                11001,
                'Colombiana',
                25,
                25126,
                'SOLTERO',
                'PROFESIONAL',
                1,
                0,
                2,
                3,
                'Aspirante inicial',
            ])
            ->andReturn([(object) ['ID_ASPIRANTE' => 5]]);

        $row = app(ApplicantRepository::class)->updateApplicant(5, $this->applicantPayload());

        $this->assertSame(5, $row['id_aspirante']);
    }

    public function test_change_status_calls_expected_stored_procedure_with_4_parameters(): void
    {
        DB::shouldReceive('select')
            ->once()
            ->with('CALL SP_BBF_ASPIRANTES_CAMBIAR_ESTADO(?,?,?,?)', [5, 'EN_REVISION', 'Revision inicial', 99])
            ->andReturn([(object) [
                'ID_ASPIRANTE' => 5,
                'ESTADO_ANTERIOR' => 'REGISTRADO',
                'ESTADO_NUEVO' => 'EN_REVISION',
            ]]);

        $row = app(ApplicantRepository::class)->changeStatus(5, 'EN_REVISION', 'Revision inicial', 99);

        $this->assertSame('REGISTRADO', $row['estado_anterior']);
        $this->assertSame('EN_REVISION', $row['estado_nuevo']);
    }

    public function test_document_and_history_read_methods_call_expected_stored_procedures(): void
    {
        DB::shouldReceive('select')->once()
            ->with('CALL SP_BBF_ASPIRANTES_DOCUMENTOS_LISTAR(?)', [5])
            ->andReturn([(object) [
                'ID_ASPIRANTE_DOCUMENTO' => 7,
                'ARCHIVO_URL' => 'https://example.com/hoja-vida.pdf',
                'ARCHIVO_RUTA' => null,
                'NOMBRE_ORIGINAL' => null,
                'TIPO_ORIGEN_ARCHIVO' => 'URL',
            ]]);
        DB::shouldReceive('select')->once()
            ->with('CALL SP_BBF_ASPIRANTES_HISTORIAL_ESTADOS(?)', [5])
            ->andReturn([(object) ['ID_HISTORIAL' => 8]]);

        $repository = app(ApplicantRepository::class);

        $document = $repository->listDocuments(5)[0];
        $this->assertSame(7, $document['id_aspirante_documento']);
        $this->assertSame('https://example.com/hoja-vida.pdf', $document['archivo_url']);
        $this->assertArrayHasKey('archivo_ruta', $document);
        $this->assertArrayHasKey('nombre_original', $document);
        $this->assertSame('URL', $document['tipo_origen_archivo']);
        $this->assertSame(8, $repository->listStatusHistory(5)[0]['id_historial']);
    }

    public function test_register_document_calls_expected_stored_procedure_with_11_parameters(): void
    {
        DB::shouldReceive('select')
            ->once()
            ->with('CALL SP_BBF_ASPIRANTES_DOCUMENTO_REGISTRAR(?,?,?,?,?,?,?,?,?,?,?)', [
                5,
                1,
                'cedula.pdf',
                'cedula_original.pdf',
                '/documentos/cedula.pdf',
                null,
                'application/pdf',
                12345,
                'CARGADO',
                'Documento inicial',
                99,
            ])
            ->andReturn([(object) ['ID_ASPIRANTE_DOCUMENTO' => 7]]);

        $row = app(ApplicantRepository::class)->registerDocument(5, [
            'id_tipo_documento_laboral' => 1,
            'nombre_archivo' => 'cedula.pdf',
            'nombre_original' => 'cedula_original.pdf',
            'archivo_url' => '/documentos/cedula.pdf',
            'archivo_ruta' => null,
            'mime_type' => 'application/pdf',
            'peso_bytes' => 12345,
            'estado_documento' => 'CARGADO',
            'observaciones' => 'Documento inicial',
        ], 99);

        $this->assertSame(7, $row['id_aspirante_documento']);
    }

    public function test_convert_to_employee_calls_expected_stored_procedure_with_5_parameters(): void
    {
        DB::shouldReceive('select')
            ->once()
            ->with('CALL SP_BBF_ASPIRANTES_CONVERTIR_EMPLEADO(?,?,?,?,?)', [
                5,
                1,
                '2026-06-24',
                99,
                'Conversion a empleado',
            ])
            ->andReturn([(object) [
                'ID_ASPIRANTE' => 5,
                'ID_EMPLEADO' => 10,
                'ESTADO_ASPIRANTE' => 'CONVERTIDO_EMPLEADO',
                'ESTADO_FICHA' => 'INCOMPLETA',
            ]]);

        $row = app(ApplicantRepository::class)->convertToEmployee(5, [
            'id_tipo_contrato' => 1,
            'fecha_ingreso' => '2026-06-24',
            'observaciones' => 'Conversion a empleado',
        ], 99);

        $this->assertSame(5, $row['id_aspirante']);
        $this->assertSame(10, $row['id_empleado']);
        $this->assertSame('CONVERTIDO_EMPLEADO', $row['estado_aspirante']);
        $this->assertSame('INCOMPLETA', $row['estado_ficha']);
    }

    private function applicantPayload(): array
    {
        return [
            'id_tipo_documento' => 1,
            'numero_documento' => '123456789',
            'nombres' => 'Ana',
            'apellidos' => 'Perez',
            'correo' => 'ana@example.com',
            'telefono' => '3001234567',
            'direccion' => 'Calle 1',
            'fecha_nacimiento' => '2000-01-01',
            'id_departamento_nacimiento' => 25,
            'id_municipio_nacimiento' => 11001,
            'nacionalidad' => 'Colombiana',
            'id_departamento_residencia' => 25,
            'id_municipio_residencia' => 25126,
            'estado_civil' => 'SOLTERO',
            'nivel_educativo' => 'PROFESIONAL',
            'personas_a_cargo' => 1,
            'numero_hijos' => 0,
            'id_area_aspira' => 2,
            'id_cargo_aspira' => 3,
            'observaciones' => 'Aspirante inicial',
        ];
    }
}
