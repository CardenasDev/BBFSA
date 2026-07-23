<?php

namespace Tests\Feature;

use App\Services\JwtService;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Route;
use Mockery;
use Tests\TestCase;

class AuthApiTest extends TestCase
{
    public function test_cors_allows_local_angular_origins_and_required_headers(): void
    {
        $this->assertContains('http://localhost:4200', config('cors.allowed_origins'));
        $this->assertContains('http://127.0.0.1:4200', config('cors.allowed_origins'));
        $this->assertSame(['api/*'], config('cors.paths'));
        $this->assertEqualsCanonicalizing(
            ['OPTIONS', 'GET', 'POST', 'PUT', 'PATCH', 'DELETE'],
            config('cors.allowed_methods'),
        );
        $this->assertEqualsCanonicalizing(
            ['Authorization', 'Content-Type', 'Accept', 'X-Requested-With', 'Origin'],
            config('cors.allowed_headers'),
        );
        $this->assertNotContains('*', config('cors.allowed_origins'));
    }

    public function test_health_check_returns_expected_payload(): void
    {
        $this->getJson('/api/health')
            ->assertOk()
            ->assertExactJson([
                'success' => true,
                'message' => 'API funcionando correctamente',
                'data' => [
                    'app' => 'BBF SisAdmin API',
                    'status' => 'ok',
                ],
            ]);
    }

    public function test_openapi_document_contains_all_routes_and_bearer_security(): void
    {
        $document = json_decode(file_get_contents(base_path('api.json')), true, 512, JSON_THROW_ON_ERROR);
        $expectedPaths = [
            '/applicants',
            '/applicants/{applicantId}',
            '/applicants/{applicantId}/approve-contracting',
            '/applicants/{applicantId}/convert-to-employee',
            '/applicants/{applicantId}/documents',
            '/applicants/{applicantId}/status',
            '/applicants/{applicantId}/status-history',
            '/health',
            '/auth/login',
            '/auth/refresh',
            '/auth/logout',
            '/auth/logout-all',
            '/auth/me',
            '/auth/change-password',
            '/catalogs/areas',
            '/catalogs/contract-types',
            '/catalogs/document-types',
            '/catalogs/labor-document-types',
            '/catalogs/positions',
            '/contracting/alerts',
            '/contracting/employees',
            '/contracting/employees/{employeeId}/contracts',
            '/contracting/employees/{employeeId}/documents',
            '/contracting/employees/{employeeId}/medical-exams',
            '/contracting/employees/{employeeId}/profile',
            '/contracting/employees/{employeeId}/social-security',
            '/employees',
            '/employees/by-document/{document}',
            '/employees/{id}',
            '/employees/{id}/estado',
            '/employees/{id}/photo',
            '/users',
            '/users/{id}',
            '/users/{id}/estado',
            '/users/{id}/status',
            '/users/{id}/roles',
            '/users/{id}/roles/{roleId}',
            '/users/{id}/permissions',
            '/roles',
            '/roles/{id}',
            '/roles/{id}/estado',
            '/roles/{id}/permissions',
            '/roles/{id}/permissions/{permissionId}',
            '/domains',
            '/domains/{id}/estado',
            '/dotations/deliveries',
            '/dotations/deliveries/{deliveryId}',
            '/dotations/deliveries/{deliveryId}/confirm',
            '/dotations/deliveries/{deliveryId}/details',
            '/dotations/employees',
            '/dotations/employees/{employeeId}/history',
            '/dotations/employees/{employeeId}/sizes',
            '/dotations/my-deliveries',
            '/dotations/my-sizes',
            '/dotations/sizes',
            '/dotations/types',
            '/permissions',
        ];

        $this->assertSame('3.1.0', $document['openapi']);
        $this->assertEqualsCanonicalizing($expectedPaths, array_keys($document['paths']));
        $this->assertSame('http', $document['components']['securitySchemes']['bearerAuth']['type']);
        $this->assertSame('bearer', $document['components']['securitySchemes']['bearerAuth']['scheme']);
        $this->assertSame([['bearerAuth' => []]], $document['security']);
        $this->assertSame([], $document['paths']['/auth/login']['post']['security']);
        $this->assertArrayHasKey('get', $document['paths']['/catalogs/areas']);
        $this->assertArrayHasKey('get', $document['paths']['/catalogs/positions']);
        $this->assertArrayHasKey('get', $document['paths']['/catalogs/contract-types']);
        $this->assertArrayHasKey('get', $document['paths']['/catalogs/document-types']);
        $this->assertArrayHasKey('get', $document['paths']['/catalogs/labor-document-types']);
        $this->assertArrayHasKey('get', $document['paths']['/applicants']);
        $this->assertArrayHasKey('post', $document['paths']['/applicants']);
        $this->assertArrayHasKey('post', $document['paths']['/applicants/{applicantId}/documents']);
        $this->assertArrayHasKey('post', $document['paths']['/applicants/{applicantId}/convert-to-employee']);
        $this->assertArrayHasKey('get', $document['paths']['/employees/by-document/{document}']);
        $this->assertArrayHasKey('post', $document['paths']['/employees/{id}/photo']);
        $this->assertArrayHasKey('get', $document['paths']['/users']);
        $this->assertArrayHasKey('post', $document['paths']['/users']);
        $this->assertArrayHasKey('patch', $document['paths']['/users/{id}']);
        $this->assertArrayHasKey('get', $document['paths']['/users/{id}/roles']);
        $this->assertArrayHasKey('post', $document['paths']['/users/{id}/roles']);
        $this->assertArrayHasKey('get', $document['paths']['/dotations/types']);
        $this->assertArrayHasKey('post', $document['paths']['/dotations/deliveries']);
        $this->assertArrayHasKey('delete', $document['paths']['/dotations/deliveries/{deliveryId}']);
        $this->assertArrayHasKey('get', $document['paths']['/dotations/my-deliveries']);
        $this->assertArrayHasKey('post', $document['paths']['/dotations/deliveries/{deliveryId}/confirm']);
        $this->assertArrayHasKey('get', $document['paths']['/dotations/employees/{employeeId}/history']);
        $this->assertArrayHasKey('get', $document['paths']['/contracting/employees']);
        $this->assertArrayHasKey('post', $document['paths']['/contracting/employees/{employeeId}/profile']);
        $this->assertArrayHasKey('post', $document['paths']['/contracting/employees/{employeeId}/contracts']);
        $this->assertArrayHasKey('get', $document['paths']['/contracting/alerts']);

        $deliveryItemProperties = $document['paths']['/dotations/deliveries']['get']['responses']['200']['content']['application/json']['schema']['properties']['data']['items']['properties'];
        $this->assertArrayHasKey('fecha_confirmacion', $deliveryItemProperties);
        $this->assertArrayHasKey('observacion_confirmacion', $deliveryItemProperties);
        $this->assertArrayHasKey('firma_url', $deliveryItemProperties);
        $this->assertArrayHasKey('id_confirmado_por', $deliveryItemProperties);
        $this->assertArrayHasKey('confirmado_por', $deliveryItemProperties);

        $historyItemProperties = $document['paths']['/dotations/employees/{employeeId}/history']['get']['responses']['200']['content']['application/json']['schema']['properties']['data']['items']['properties'];
        $this->assertArrayHasKey('tipo_dotacion', $historyItemProperties);
        $this->assertArrayHasKey('cantidad', $historyItemProperties);
        $this->assertArrayHasKey('fecha_confirmacion', $historyItemProperties);
        $this->assertArrayHasKey('observacion_confirmacion', $historyItemProperties);
        $this->assertArrayHasKey('observaciones_detalle', $historyItemProperties);
    }

    public function test_login_validation_uses_standard_json_format(): void
    {
        $response = $this->postJson('/api/auth/login', []);

        $response->assertUnprocessable()
            ->assertJsonPath('success', false)
            ->assertJsonPath('message', 'Los datos enviados no son válidos.')
            ->assertJsonValidationErrors(['usuario', 'password']);
    }

    public function test_login_normalizes_email_or_username_before_querying(): void
    {
        DB::shouldReceive('select')
            ->once()
            ->with('CALL SP_BBF_LOGIN_OBTENER_USUARIO(?)', ['admin@example.com'])
            ->andReturn([]);

        $this->postJson('/api/auth/login', [
            'usuario' => '  Admin@Example.COM  ',
            'password' => 'not-a-real-password',
        ])->assertUnauthorized()
            ->assertJsonPath('message', 'Credenciales incorrectas.');
    }

    public function test_protected_route_requires_bearer_token(): void
    {
        $this->getJson('/api/auth/me')
            ->assertUnauthorized()
            ->assertJson([
                'success' => false,
                'message' => 'Token de acceso requerido.',
            ]);
    }

    public function test_permission_middleware_rejects_missing_permission(): void
    {
        $token = app(JwtService::class)->encode([
            'id_usuario' => 99,
            'id_sesion' => 1,
            'correo' => 'test@example.com',
            'nombre_usuario' => 'test',
            'tipo_usuario' => 'TEST',
            'roles' => [],
            'permisos' => [],
        ])['token'];

        $this->withToken($token)->getJson('/api/users')
            ->assertForbidden()
            ->assertJsonPath('success', false);
    }

    public function test_document_types_catalog_uses_stored_procedure_and_returns_expected_payload(): void
    {
        DB::shouldReceive('select')
            ->once()
            ->with('CALL SP_BBF_TIPOS_DOCUMENTO_LISTAR(?)', [0])
            ->andReturn([
                (object) [
                    'ID_TIPO_DOCUMENTO' => 1,
                    'NOMBRE' => 'Cedula de ciudadania',
                    'ACTIVO' => 1,
                    'CREATED_AT' => '2026-01-01 00:00:00',
                    'UPDATED_AT' => null,
                ],
            ]);

        $token = app(JwtService::class)->encode([
            'id_usuario' => 99,
            'id_sesion' => 1,
            'correo' => 'rrhh@example.com',
            'nombre_usuario' => 'rrhh',
            'tipo_usuario' => 'ADMIN',
            'roles' => [],
            'permisos' => ['EMPLEADOS_VER'],
        ])['token'];

        $this->withToken($token)->getJson('/api/catalogs/document-types?solo_activos=false')
            ->assertOk()
            ->assertExactJson([
                'success' => true,
                'message' => 'Tipos de documento consultados correctamente',
                'data' => [
                    [
                        'id_tipo_documento' => 1,
                        'nombre' => 'Cedula de ciudadania',
                        'activo' => true,
                    ],
                ],
            ]);
    }

    public function test_employee_catalogs_use_stored_procedures_and_return_expected_payloads(): void
    {
        DB::shouldReceive('select')
            ->once()
            ->with('CALL SP_BBF_AREAS_LISTAR(?)', [1])
            ->andReturn([
                (object) [
                    'ID_AREA' => 1,
                    'NOMBRE' => 'Recursos Humanos',
                    'DESCRIPCION' => 'Gestion administrativa y laboral del personal',
                    'ACTIVO' => 1,
                    'CREATED_AT' => '2026-01-01 00:00:00',
                    'UPDATED_AT' => null,
                ],
            ]);

        DB::shouldReceive('select')
            ->once()
            ->with('CALL SP_BBF_CARGOS_LISTAR(?)', [1])
            ->andReturn([
                (object) [
                    'ID_CARGO' => 1,
                    'NOMBRE' => 'Administrador',
                    'DESCRIPCION' => 'Responsable de la administracion general',
                    'ACTIVO' => 1,
                    'CREATED_AT' => '2026-01-01 00:00:00',
                    'UPDATED_AT' => null,
                ],
            ]);

        DB::shouldReceive('select')
            ->once()
            ->with('CALL SP_BBF_TIPOS_CONTRATO_LISTAR(?)', [1])
            ->andReturn([
                (object) [
                    'ID_TIPO_CONTRATO' => 1,
                    'NOMBRE' => 'Indefinido',
                    'DESCRIPCION' => 'Contrato laboral a termino indefinido',
                    'ACTIVO' => 1,
                    'CREATED_AT' => '2026-01-01 00:00:00',
                    'UPDATED_AT' => null,
                ],
            ]);

        $token = app(JwtService::class)->encode([
            'id_usuario' => 99,
            'id_sesion' => 1,
            'correo' => 'rrhh@example.com',
            'nombre_usuario' => 'rrhh',
            'tipo_usuario' => 'ADMIN',
            'roles' => [],
            'permisos' => ['EMPLEADOS_CREAR'],
        ])['token'];

        $this->withToken($token)->getJson('/api/catalogs/areas')
            ->assertOk()
            ->assertExactJson([
                'success' => true,
                'message' => 'Areas consultadas correctamente',
                'data' => [[
                    'id_area' => 1,
                    'nombre' => 'Recursos Humanos',
                    'descripcion' => 'Gestion administrativa y laboral del personal',
                    'activo' => true,
                ]],
            ]);

        $this->withToken($token)->getJson('/api/catalogs/positions')
            ->assertOk()
            ->assertExactJson([
                'success' => true,
                'message' => 'Cargos consultados correctamente',
                'data' => [[
                    'id_cargo' => 1,
                    'nombre' => 'Administrador',
                    'descripcion' => 'Responsable de la administracion general',
                    'activo' => true,
                ]],
            ]);

        $this->withToken($token)->getJson('/api/catalogs/contract-types')
            ->assertOk()
            ->assertExactJson([
                'success' => true,
                'message' => 'Tipos de contrato consultados correctamente',
                'data' => [[
                    'id_tipo_contrato' => 1,
                    'nombre' => 'Indefinido',
                    'descripcion' => 'Contrato laboral a termino indefinido',
                    'activo' => true,
                ]],
            ]);
    }

    public function test_labor_document_types_catalog_route_exists_and_requires_jwt(): void
    {
        $this->assertNotNull(Route::getRoutes()->match(request()->create('/api/catalogs/labor-document-types', 'GET')));

        $this->getJson('/api/catalogs/labor-document-types')
            ->assertUnauthorized()
            ->assertJson([
                'success' => false,
                'message' => 'Token de acceso requerido.',
            ]);
    }

    public function test_labor_document_types_catalog_uses_stored_procedure_filters_and_maps_response(): void
    {
        DB::shouldReceive('select')
            ->once()
            ->with('CALL SP_BBF_TIPOS_DOCUMENTO_LABORAL_LISTAR(?,?,?,?)', [1, 1, null, null])
            ->andReturn([
                (object) [
                    'ID_TIPO_DOCUMENTO_LABORAL' => 1,
                    'NOMBRE' => 'Hoja de vida',
                    'DESCRIPCION' => 'Hoja de vida del empleado',
                    'OBLIGATORIO' => 1,
                    'REQUIERE_VENCIMIENTO' => 0,
                    'APLICA_ASPIRANTE' => 1,
                    'APLICA_CONTRATACION' => 1,
                    'APLICA_RETIRO' => 0,
                    'ACTIVO' => 1,
                ],
            ]);

        $this->withToken($this->tokenWithPermissions(['ASPIRANTES_DOCUMENTOS_VER']))
            ->getJson('/api/catalogs/labor-document-types?active=1&applies_applicant=1')
            ->assertOk()
            ->assertExactJson([
                'success' => true,
                'message' => 'Tipos de documento laboral consultados correctamente',
                'data' => [[
                    'id_tipo_documento_laboral' => 1,
                    'nombre' => 'Hoja de vida',
                    'descripcion' => 'Hoja de vida del empleado',
                    'obligatorio' => true,
                    'requiere_vencimiento' => false,
                    'aplica_aspirante' => true,
                    'aplica_contratacion' => true,
                    'aplica_retiro' => false,
                    'activo' => true,
                ]],
            ]);
    }

    public function test_employee_photo_upload_requires_image(): void
    {
        $this->withToken($this->tokenWithPermissions(['EMPLEADOS_EDITAR']))
            ->postJson('/api/employees/10/photo', [])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['photo']);
    }

    public function test_employee_photo_upload_rejects_invalid_file(): void
    {
        $file = UploadedFile::fake()->create('document.txt', 1, 'text/plain');

        $this->withToken($this->tokenWithPermissions(['EMPLEADOS_EDITAR']))
            ->post('/api/employees/10/photo', ['photo' => $file])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['photo']);
    }

    public function test_employee_photo_upload_stores_file_and_updates_photo_url_with_stored_procedure(): void
    {
        $capturedPhotoUrl = null;
        DB::shouldReceive('select')
            ->once()
            ->with('CALL SP_BBF_EMPLEADOS_OBTENER_POR_ID(?)', [10])
            ->andReturn([$this->employeeRow()]);

        DB::shouldReceive('select')
            ->once()
            ->with('CALL SP_BBF_EMPLEADOS_ACTUALIZAR(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)', Mockery::on(function (array $parameters) use (&$capturedPhotoUrl): bool {
                $capturedPhotoUrl = $parameters[7] ?? null;

                return count($parameters) === 15
                    && $parameters[0] === 10
                    && $parameters[6] === '3194400951'
                    && is_string($capturedPhotoUrl)
                    && preg_match('#^/uploads/employees/employee_10_\d{14}\.png$#', $capturedPhotoUrl) === 1
                    && $parameters[8] === 2;
            }))
            ->andReturn([(object) ['FILAS_AFECTADAS' => 1]]);

        $file = UploadedFile::fake()->createWithContent('photo.png', base64_decode(
            'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/p9sAAAAASUVORK5CYII='
        ));
        $response = $this->withToken($this->tokenWithPermissions(['EMPLEADOS_EDITAR']))
            ->post('/api/employees/10/photo', ['photo' => $file]);

        $response->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('message', 'Foto de empleado cargada correctamente')
            ->assertJsonPath('data.id_empleado', 10)
            ->assertJsonPath('data.foto_url', $capturedPhotoUrl);

        $path = public_path('uploads/employees/'.basename((string) $capturedPhotoUrl));
        $this->assertFileExists($path);
        @unlink($path);
    }

    public function test_jwt_rejects_a_modified_signature(): void
    {
        $jwt = app(JwtService::class);
        $token = $jwt->encode(['id_usuario' => 1])['token'];
        $parts = explode('.', $token);
        $parts[1] = rtrim(strtr(base64_encode('{"id_usuario":2}'), '+/', '-_'), '=');

        $this->expectException(\RuntimeException::class);
        $jwt->decode(implode('.', $parts));
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

    private function employeeRow(): object
    {
        return (object) [
            'ID_EMPLEADO' => 10,
            'ID_TIPO_DOCUMENTO' => 1,
            'TIPO_DOCUMENTO' => 'Cedula de ciudadania',
            'NUMERO_DOCUMENTO' => '123456789',
            'NOMBRES' => 'Juan',
            'APELLIDOS' => 'Barco',
            'NOMBRE_COMPLETO' => 'Juan Barco',
            'CORREO' => 'jc@email.com',
            'TELEFONO' => '3194400951',
            'FOTO_URL' => null,
            'ID_AREA' => 2,
            'AREA' => 'Cultivo',
            'ID_CARGO' => 3,
            'CARGO' => 'Operario',
            'ID_TIPO_CONTRATO' => 4,
            'TIPO_CONTRATO' => 'Obra o labor',
            'FECHA_INGRESO' => '2026-06-01',
            'FECHA_RETIRO' => null,
            'ESTADO_EMPLEADO' => 'ACTIVO',
            'OBSERVACIONES' => 'Empleado test',
        ];
    }
}
