<?php

namespace Tests\Feature;

use App\Services\JwtService;
use Illuminate\Support\Facades\DB;
use Tests\TestCase;

class CatalogContractTypesApiTest extends TestCase
{
    public function test_contract_types_catalog_lists_active_contracts_for_selector(): void
    {
        DB::shouldReceive('select')->once()
            ->with('CALL SP_BBF_TIPOS_CONTRATO_LISTAR(?)', [1])
            ->andReturn([
                (object) ['ID_TIPO_CONTRATO' => 2, 'NOMBRE' => 'Indefinido', 'DESCRIPCION' => 'Contrato indefinido', 'ACTIVO' => 1],
                (object) ['ID_TIPO_CONTRATO' => 3, 'NOMBRE' => 'Fijo', 'DESCRIPCION' => 'Contrato fijo', 'ACTIVO' => 1],
                (object) ['ID_TIPO_CONTRATO' => 4, 'NOMBRE' => 'Obra o labor', 'DESCRIPCION' => 'Contrato por obra o labor', 'ACTIVO' => 1],
            ]);

        $response = $this->withToken($this->tokenWithPermissions(['EMPLEADOS_VER']))
            ->getJson('/api/catalogs/contract-types');

        $response->assertOk()
            ->assertJsonPath('data.0.id_tipo_contrato', 2)
            ->assertJsonPath('data.1.id_tipo_contrato', 3)
            ->assertJsonPath('data.2.id_tipo_contrato', 4);

        $ids = collect($response->json('data'))->pluck('id_tipo_contrato')->all();
        $this->assertSame([2, 3, 4], $ids);
    }

    public function test_contract_types_catalog_can_include_inactive_when_requested(): void
    {
        DB::shouldReceive('select')->once()
            ->with('CALL SP_BBF_TIPOS_CONTRATO_LISTAR(?)', [0])
            ->andReturn([
                (object) ['ID_TIPO_CONTRATO' => 1, 'NOMBRE' => 'QA Contrato', 'DESCRIPCION' => 'Inactivo', 'ACTIVO' => 0],
                (object) ['ID_TIPO_CONTRATO' => 2, 'NOMBRE' => 'Indefinido', 'DESCRIPCION' => 'Contrato indefinido', 'ACTIVO' => 1],
            ]);

        $response = $this->withToken($this->tokenWithPermissions(['EMPLEADOS_VER']))
            ->getJson('/api/catalogs/contract-types?solo_activos=0');

        $response->assertOk()
            ->assertJsonPath('data.0.id_tipo_contrato', 1)
            ->assertJsonPath('data.0.activo', false)
            ->assertJsonPath('data.1.id_tipo_contrato', 2)
            ->assertJsonPath('data.1.activo', true);
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
