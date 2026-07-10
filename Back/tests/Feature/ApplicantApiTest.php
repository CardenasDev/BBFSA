<?php

namespace Tests\Feature;

use App\Services\JwtService;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Route;
use Tests\TestCase;

class ApplicantApiTest extends TestCase
{
    protected function tearDown(): void
    {
        File::deleteDirectory(public_path('uploads/applicants/99999'));

        parent::tearDown();
    }

    public function test_applicant_routes_are_registered(): void
    {
        $routes = collect(Route::getRoutes())
            ->filter(fn ($route): bool => str_starts_with($route->uri(), 'api/applicants'))
            ->map(fn ($route): string => implode('|', $route->methods()).' '.$route->uri())
            ->values()
            ->all();

        $this->assertEqualsCanonicalizing([
            'GET|HEAD api/applicants',
            'POST api/applicants',
            'GET|HEAD api/applicants/{applicantId}',
            'PUT api/applicants/{applicantId}',
            'PATCH api/applicants/{applicantId}/status',
            'POST api/applicants/{applicantId}/approve-contracting',
            'GET|HEAD api/applicants/{applicantId}/documents',
            'POST api/applicants/{applicantId}/documents',
            'GET|HEAD api/applicants/{applicantId}/status-history',
            'POST api/applicants/{applicantId}/convert-to-employee',
        ], $routes);
    }

    public function test_applicants_index_requires_jwt(): void
    {
        $this->getJson('/api/applicants')
            ->assertUnauthorized()
            ->assertJson([
                'success' => false,
                'message' => 'Token de acceso requerido.',
            ]);
    }

    public function test_applicant_routes_require_expected_permissions(): void
    {
        foreach ($this->applicantEndpoints() as [$method, $uri]) {
            $this->withToken($this->tokenWithPermissions([]))
                ->json($method, $uri)
                ->assertForbidden()
                ->assertJsonPath('success', false);
        }
    }

    public function test_create_applicant_validates_required_fields(): void
    {
        $this->withToken($this->tokenWithPermissions(['ASPIRANTES_CREAR']))
            ->postJson('/api/applicants', [])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['numero_documento', 'nombres', 'apellidos']);
    }

    public function test_create_applicant_requires_create_permission(): void
    {
        $this->withToken($this->tokenWithPermissions(['ASPIRANTES_VER']))
            ->postJson('/api/applicants', $this->applicantPayload())
            ->assertForbidden();
    }

    public function test_update_applicant_requires_edit_permission(): void
    {
        $this->withToken($this->tokenWithPermissions(['ASPIRANTES_VER']))
            ->putJson('/api/applicants/5', $this->applicantPayload())
            ->assertForbidden();
    }

    public function test_change_status_validates_allowed_status(): void
    {
        $this->withToken($this->tokenWithPermissions(['ASPIRANTES_CAMBIAR_ESTADO']))
            ->patchJson('/api/applicants/5/status', [
                'estado_aspirante' => 'NO_VALIDO',
            ])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['estado_aspirante']);
    }

    public function test_approve_contracting_uses_fixed_approved_status(): void
    {
        DB::shouldReceive('select')
            ->once()
            ->with('CALL SP_BBF_ASPIRANTES_CAMBIAR_ESTADO(?,?,?,?)', [
                5,
                'APROBADO_CONTRATACION',
                'Aprobado por RRHH',
                99,
            ])
            ->andReturn([(object) [
                'ID_ASPIRANTE' => 5,
                'ESTADO_ANTERIOR' => 'EN_REVISION',
                'ESTADO_NUEVO' => 'APROBADO_CONTRATACION',
            ]]);

        $this->withToken($this->tokenWithPermissions(['ASPIRANTES_APROBAR_CONTRATACION']))
            ->postJson('/api/applicants/5/approve-contracting', [
                'estado_aspirante' => 'RECHAZADO',
                'observaciones' => 'Aprobado por RRHH',
            ])
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('message', 'Aspirante aprobado para contratacion correctamente')
            ->assertJsonPath('data.estado_nuevo', 'APROBADO_CONTRATACION');
    }

    public function test_list_documents_requires_documents_view_permission(): void
    {
        $this->withToken($this->tokenWithPermissions(['ASPIRANTES_VER']))
            ->getJson('/api/applicants/5/documents')
            ->assertForbidden();
    }

    public function test_register_document_validates_required_fields(): void
    {
        $this->withToken($this->tokenWithPermissions(['ASPIRANTES_DOCUMENTOS_SUBIR']))
            ->postJson('/api/applicants/5/documents', [])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['id_tipo_documento_laboral', 'archivo_origen']);
    }

    public function test_register_document_accepts_external_url(): void
    {
        DB::shouldReceive('select')
            ->once()
            ->with('CALL SP_BBF_ASPIRANTES_DOCUMENTO_REGISTRAR(?,?,?,?,?,?,?,?,?,?,?)', [
                5,
                1,
                'Hoja de vida externa',
                null,
                'https://example.com/hoja-vida.pdf',
                null,
                null,
                null,
                'CARGADO',
                null,
                99,
            ])
            ->andReturn([(object) [
                'ID_ASPIRANTE_DOCUMENTO' => 2,
                'ID_ASPIRANTE' => 5,
                'ESTADO_DOCUMENTO' => 'CARGADO',
                'NOMBRE_ARCHIVO' => 'Hoja de vida externa',
                'NOMBRE_ORIGINAL' => null,
                'ARCHIVO_URL' => 'https://example.com/hoja-vida.pdf',
                'ARCHIVO_RUTA' => null,
                'MIME_TYPE' => null,
                'PESO_BYTES' => null,
                'TIPO_ORIGEN_ARCHIVO' => 'URL',
            ]]);

        $this->withToken($this->tokenWithPermissions(['ASPIRANTES_DOCUMENTOS_SUBIR']))
            ->postJson('/api/applicants/5/documents', [
                'id_tipo_documento_laboral' => 1,
                'nombre_archivo' => 'Hoja de vida externa',
                'archivo_url' => 'https://example.com/hoja-vida.pdf',
            ])
            ->assertCreated()
            ->assertJsonPath('success', true)
            ->assertJsonPath('message', 'Documento del aspirante registrado correctamente')
            ->assertJsonPath('data.estado_documento', 'CARGADO')
            ->assertJsonPath('data.archivo_url', 'https://example.com/hoja-vida.pdf')
            ->assertJsonPath('data.archivo_ruta', null)
            ->assertJsonPath('data.tipo_origen_archivo', 'URL');
    }

    public function test_register_document_accepts_physical_file_multipart(): void
    {
        $applicantId = 99999;

        DB::shouldReceive('select')
            ->once()
            ->with(
                'CALL SP_BBF_ASPIRANTES_DOCUMENTO_REGISTRAR(?,?,?,?,?,?,?,?,?,?,?)',
                \Mockery::on(function (array $parameters) use ($applicantId): bool {
                    return $parameters[0] === $applicantId
                        && $parameters[1] === 1
                        && $parameters[2] === 'Hoja de vida'
                        && $parameters[3] === 'hoja_vida.pdf'
                        && $parameters[4] === null
                        && str_starts_with($parameters[5], "uploads/applicants/{$applicantId}/documents/")
                        && $parameters[6] === 'application/pdf'
                        && is_int($parameters[7])
                        && $parameters[7] > 0
                        && $parameters[8] === 'CARGADO'
                        && $parameters[9] === 'Archivo fisico'
                        && $parameters[10] === 99;
                }),
            )
            ->andReturnUsing(fn (string $query, array $parameters): array => [(object) [
                'ID_ASPIRANTE_DOCUMENTO' => 3,
                'ID_ASPIRANTE' => $parameters[0],
                'ESTADO_DOCUMENTO' => $parameters[8],
                'NOMBRE_ARCHIVO' => $parameters[2],
                'NOMBRE_ORIGINAL' => $parameters[3],
                'ARCHIVO_URL' => $parameters[4],
                'ARCHIVO_RUTA' => $parameters[5],
                'MIME_TYPE' => $parameters[6],
                'PESO_BYTES' => $parameters[7],
                'TIPO_ORIGEN_ARCHIVO' => 'FISICO',
            ]]);

        $response = $this->withToken($this->tokenWithPermissions(['ASPIRANTES_DOCUMENTOS_SUBIR']))
            ->post("/api/applicants/{$applicantId}/documents", [
                'id_tipo_documento_laboral' => 1,
                'nombre_archivo' => 'Hoja de vida',
                'archivo' => UploadedFile::fake()->create('hoja_vida.pdf', 128, 'application/pdf'),
                'estado_documento' => 'CARGADO',
                'observaciones' => 'Archivo fisico',
            ])
            ->assertCreated()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.estado_documento', 'CARGADO')
            ->assertJsonPath('data.nombre_original', 'hoja_vida.pdf')
            ->assertJsonPath('data.archivo_url', null)
            ->assertJsonPath('data.mime_type', 'application/pdf')
            ->assertJsonPath('data.tipo_origen_archivo', 'FISICO');

        $this->assertTrue(File::exists(public_path($response->json('data.archivo_ruta'))));
    }

    public function test_register_document_accepts_pending_without_file_or_url(): void
    {
        DB::shouldReceive('select')
            ->once()
            ->with('CALL SP_BBF_ASPIRANTES_DOCUMENTO_REGISTRAR(?,?,?,?,?,?,?,?,?,?,?)', [
                5,
                1,
                'Documento pendiente',
                null,
                null,
                null,
                null,
                null,
                'PENDIENTE',
                'Pendiente de carga',
                99,
            ])
            ->andReturn([(object) [
                'ID_ASPIRANTE_DOCUMENTO' => 4,
                'ID_ASPIRANTE' => 5,
                'ESTADO_DOCUMENTO' => 'PENDIENTE',
                'NOMBRE_ARCHIVO' => 'Documento pendiente',
                'NOMBRE_ORIGINAL' => null,
                'ARCHIVO_URL' => null,
                'ARCHIVO_RUTA' => null,
                'MIME_TYPE' => null,
                'PESO_BYTES' => null,
                'TIPO_ORIGEN_ARCHIVO' => 'SIN_ARCHIVO',
            ]]);

        $this->withToken($this->tokenWithPermissions(['ASPIRANTES_DOCUMENTOS_SUBIR']))
            ->postJson('/api/applicants/5/documents', [
                'id_tipo_documento_laboral' => 1,
                'estado_documento' => 'PENDIENTE',
                'observaciones' => 'Pendiente de carga',
            ])
            ->assertCreated()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.estado_documento', 'PENDIENTE')
            ->assertJsonPath('data.nombre_archivo', 'Documento pendiente')
            ->assertJsonPath('data.archivo_url', null)
            ->assertJsonPath('data.archivo_ruta', null)
            ->assertJsonPath('data.tipo_origen_archivo', 'SIN_ARCHIVO');
    }

    public function test_register_document_rejects_loaded_without_url_or_file(): void
    {
        $this->withToken($this->tokenWithPermissions(['ASPIRANTES_DOCUMENTOS_SUBIR']))
            ->postJson('/api/applicants/5/documents', [
                'id_tipo_documento_laboral' => 1,
                'nombre_archivo' => 'Hoja de vida',
                'archivo_url' => '   ',
                'estado_documento' => 'CARGADO',
            ])
            ->assertUnprocessable()
            ->assertJsonPath('success', false)
            ->assertJsonPath('message', 'Debe registrar una URL externa o cargar un archivo físico.');
    }

    public function test_register_document_validates_file_max_size(): void
    {
        $this->withToken($this->tokenWithPermissions(['ASPIRANTES_DOCUMENTOS_SUBIR']))
            ->post('/api/applicants/5/documents', [
                'id_tipo_documento_laboral' => 1,
                'nombre_archivo' => 'Hoja de vida',
                'archivo' => UploadedFile::fake()->create('hoja_vida.pdf', 5121, 'application/pdf'),
            ])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['archivo']);
    }

    public function test_register_document_validates_allowed_extensions(): void
    {
        $this->withToken($this->tokenWithPermissions(['ASPIRANTES_DOCUMENTOS_SUBIR']))
            ->post('/api/applicants/5/documents', [
                'id_tipo_documento_laboral' => 1,
                'nombre_archivo' => 'Hoja de vida',
                'archivo' => UploadedFile::fake()->create('hoja_vida.exe', 10, 'application/octet-stream'),
            ])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['archivo']);
    }

    public function test_list_documents_returns_new_file_origin_fields(): void
    {
        DB::shouldReceive('select')
            ->once()
            ->with('CALL SP_BBF_ASPIRANTES_DOCUMENTOS_LISTAR(?)', [5])
            ->andReturn([(object) [
                'ID_ASPIRANTE_DOCUMENTO' => 7,
                'ID_ASPIRANTE' => 5,
                'NOMBRE_ARCHIVO' => 'Hoja de vida',
                'NOMBRE_ORIGINAL' => 'hoja_vida.pdf',
                'ARCHIVO_URL' => null,
                'ARCHIVO_RUTA' => 'uploads/applicants/5/documents/hoja_vida.pdf',
                'MIME_TYPE' => 'application/pdf',
                'PESO_BYTES' => 123456,
                'TIPO_ORIGEN_ARCHIVO' => 'FISICO',
            ]]);

        $this->withToken($this->tokenWithPermissions(['ASPIRANTES_DOCUMENTOS_VER']))
            ->getJson('/api/applicants/5/documents')
            ->assertOk()
            ->assertJsonPath('data.0.archivo_url', null)
            ->assertJsonPath('data.0.archivo_ruta', 'uploads/applicants/5/documents/hoja_vida.pdf')
            ->assertJsonPath('data.0.nombre_original', 'hoja_vida.pdf')
            ->assertJsonPath('data.0.tipo_origen_archivo', 'FISICO');
    }

    public function test_convert_to_employee_requires_convert_permission(): void
    {
        $this->withToken($this->tokenWithPermissions(['ASPIRANTES_VER']))
            ->postJson('/api/applicants/5/convert-to-employee', [
                'id_tipo_contrato' => 1,
                'fecha_ingreso' => '2026-06-24',
            ])
            ->assertForbidden();
    }

    public function test_convert_to_employee_maps_new_sp_response_fields(): void
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

        $this->withToken($this->tokenWithPermissions(['ASPIRANTES_CONVERTIR_EMPLEADO']))
            ->postJson('/api/applicants/5/convert-to-employee', [
                'id_tipo_contrato' => 1,
                'fecha_ingreso' => '2026-06-24',
                'observaciones' => 'Conversion a empleado',
            ])
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('message', 'Aspirante convertido en empleado correctamente')
            ->assertJsonPath('data.id_aspirante', 5)
            ->assertJsonPath('data.id_empleado', 10)
            ->assertJsonPath('data.estado_aspirante', 'CONVERTIDO_EMPLEADO')
            ->assertJsonPath('data.estado_ficha', 'INCOMPLETA');
    }

    private function applicantEndpoints(): array
    {
        return [
            ['GET', '/api/applicants'],
            ['GET', '/api/applicants/5'],
            ['POST', '/api/applicants'],
            ['PUT', '/api/applicants/5'],
            ['PATCH', '/api/applicants/5/status'],
            ['POST', '/api/applicants/5/approve-contracting'],
            ['GET', '/api/applicants/5/documents'],
            ['POST', '/api/applicants/5/documents'],
            ['GET', '/api/applicants/5/status-history'],
            ['POST', '/api/applicants/5/convert-to-employee'],
        ];
    }

    private function applicantPayload(): array
    {
        return [
            'id_tipo_documento' => 1,
            'numero_documento' => '123456789',
            'nombres' => 'Ana',
            'apellidos' => 'Perez',
            'correo' => 'ana@example.com',
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
