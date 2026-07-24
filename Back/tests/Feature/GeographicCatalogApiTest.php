<?php

namespace Tests\Feature;

use App\Services\JwtService;
use Illuminate\Support\Facades\DB;
use Tests\TestCase;

class GeographicCatalogApiTest extends TestCase
{
    public function test_departments_catalog_uses_stored_procedure(): void
    {
        DB::shouldReceive('select')->once()
            ->with('CALL SP_BBF_DEPARTAMENTOS_LISTAR()', [])
            ->andReturn([
                (object) ['ID_DEPARTAMENTO' => 9, 'CODIGO_DANE' => '25', 'NOMBRE' => 'Cundinamarca', 'ACTIVO' => 1],
                (object) ['ID_DEPARTAMENTO' => 1, 'CODIGO_DANE' => '05', 'NOMBRE' => 'Antioquia', 'ACTIVO' => 1],
                (object) ['ID_DEPARTAMENTO' => 3, 'CODIGO_DANE' => '08', 'NOMBRE' => 'Atlantico', 'ACTIVO' => 0],
            ]);

        $this->withToken($this->token(['ASPIRANTES_VER']))
            ->getJson('/api/catalogs/departments')
            ->assertOk()
            ->assertJsonPath('data.0.id_departamento', 1)
            ->assertJsonPath('data.0.codigo_dane', '05')
            ->assertJsonPath('data.1.id_departamento', 9)
            ->assertJsonPath('data.1.codigo_dane', '25')
            ->assertJsonCount(2, 'data');
    }

    public function test_municipalities_catalog_uses_department_binding(): void
    {
        DB::shouldReceive('select')->once()
            ->with('CALL SP_BBF_MUNICIPIOS_LISTAR_POR_DEPARTAMENTO(?)', [1])
            ->andReturn([
                (object) ['ID_MUNICIPIO' => 2, 'ID_DEPARTAMENTO' => 1, 'CODIGO_DANE' => '05002', 'NOMBRE' => 'Abejorral', 'ACTIVO' => 1],
                (object) ['ID_MUNICIPIO' => 1, 'ID_DEPARTAMENTO' => 1, 'CODIGO_DANE' => '05001', 'NOMBRE' => 'Medellin', 'ACTIVO' => 1],
                (object) ['ID_MUNICIPIO' => 99, 'ID_DEPARTAMENTO' => 2, 'CODIGO_DANE' => '08001', 'NOMBRE' => 'Barranquilla', 'ACTIVO' => 1],
                (object) ['ID_MUNICIPIO' => 3, 'ID_DEPARTAMENTO' => 1, 'CODIGO_DANE' => '05004', 'NOMBRE' => 'Abriaqui', 'ACTIVO' => 0],
            ]);

        $this->withToken($this->token(['CONTRATACION_VER']))
            ->getJson('/api/catalogs/departments/1/municipalities')
            ->assertOk()
            ->assertJsonPath('data.0.id_municipio', 2)
            ->assertJsonPath('data.0.id_departamento', 1)
            ->assertJsonPath('data.1.id_municipio', 1)
            ->assertJsonCount(2, 'data');
    }

    public function test_dane_code_is_passed_as_internal_id_without_translation(): void
    {
        DB::shouldReceive('select')->once()
            ->with('CALL SP_BBF_MUNICIPIOS_LISTAR_POR_DEPARTAMENTO(?)', [25])
            ->andReturn([]);

        $this->withToken($this->token(['ASPIRANTES_VER']))
            ->getJson('/api/catalogs/departments/25/municipalities')
            ->assertOk()
            ->assertJsonCount(0, 'data');
    }

    public function test_invalid_department_route_values_fail_without_calling_database(): void
    {
        DB::shouldReceive('select')->never();

        $this->withToken($this->token(['ASPIRANTES_VER']))
            ->getJson('/api/catalogs/departments/0/municipalities')
            ->assertNotFound();

        $this->withToken($this->token(['ASPIRANTES_VER']))
            ->getJson('/api/catalogs/departments/no-numero/municipalities')
            ->assertNotFound();
    }

    public function test_social_security_catalog_validates_type_before_calling_repository(): void
    {
        $this->withToken($this->token(['CONTRATACION_SEGURIDAD_SOCIAL_VER']))
            ->getJson('/api/catalogs/social-security-entities?type=INVALIDO')
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['type']);

        DB::shouldReceive('select')->once()
            ->with('CALL SP_BBF_ENTIDADES_SEGURIDAD_SOCIAL_LISTAR(?)', ['EPS'])
            ->andReturn([(object) ['ID_ENTIDAD_SEGURIDAD_SOCIAL' => 1, 'TIPO' => 'EPS', 'NOMBRE' => 'Nueva EPS', 'CODIGO' => 'EPS001', 'ACTIVO' => 1]]);

        $this->withToken($this->token(['CONTRATACION_SEGURIDAD_SOCIAL_VER']))
            ->getJson('/api/catalogs/social-security-entities?type=EPS')
            ->assertOk()
            ->assertJsonPath('data.0.id_entidad_seguridad_social', 1)
            ->assertJsonPath('data.0.tipo', 'EPS');
    }

    public function test_medical_exam_types_catalog_uses_stored_procedure(): void
    {
        DB::shouldReceive('select')->once()
            ->with('CALL SP_BBF_TIPOS_EXAMEN_MEDICO_LISTAR()', [])
            ->andReturn([(object) ['ID_TIPO_EXAMEN_MEDICO' => 1, 'NOMBRE' => 'Ingreso', 'DESCRIPCION' => 'Examen de ingreso', 'ACTIVO' => 1]]);

        $this->withToken($this->token(['CONTRATACION_EXAMENES_VER']))
            ->getJson('/api/catalogs/medical-exam-types')
            ->assertOk()
            ->assertJsonPath('data.0.id_tipo_examen_medico', 1);
    }

    private function token(array $permissions): string
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
