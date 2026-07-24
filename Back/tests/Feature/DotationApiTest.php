<?php

namespace Tests\Feature;

use App\Services\JwtService;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Route;
use Tests\TestCase;

class DotationApiTest extends TestCase
{
    public function test_dotation_routes_are_registered(): void
    {
        $routes = collect(Route::getRoutes())
            ->filter(fn ($route): bool => str_starts_with($route->uri(), 'api/dotations/'))
            ->map(fn ($route): string => implode('|', $route->methods()).' '.$route->uri())
            ->values()
            ->all();

        $this->assertEqualsCanonicalizing([
            'GET|HEAD api/dotations/types',
            'GET|HEAD api/dotations/sizes',
            'GET|HEAD api/dotations/combinations',
            'GET|HEAD api/dotations/combinations/{combinationId}',
            'GET|HEAD api/dotations/my-sizes',
            'POST api/dotations/my-sizes',
            'GET|HEAD api/dotations/my-deliveries',
            'GET|HEAD api/dotations/employees',
            'GET|HEAD api/dotations/employees/{employeeId}/history',
            'GET|HEAD api/dotations/employees/{employeeId}/sizes',
            'POST api/dotations/deliveries',
            'GET|HEAD api/dotations/deliveries',
            'DELETE api/dotations/deliveries/{deliveryId}',
            'POST api/dotations/deliveries/{deliveryId}/confirm',
            'GET|HEAD api/dotations/deliveries/{deliveryId}/details',
        ], $routes);
    }

    public function test_dotation_endpoints_require_jwt(): void
    {
        $this->getJson('/api/dotations/types')
            ->assertUnauthorized()
            ->assertJson([
                'success' => false,
                'message' => 'Token de acceso requerido.',
            ]);
    }

    public function test_employee_history_endpoint_requires_jwt(): void
    {
        $this->getJson('/api/dotations/employees/5/history')
            ->assertUnauthorized()
            ->assertJson([
                'success' => false,
                'message' => 'Token de acceso requerido.',
            ]);
    }

    public function test_delete_delivery_endpoint_requires_jwt(): void
    {
        $this->deleteJson('/api/dotations/deliveries/7')
            ->assertUnauthorized()
            ->assertJson([
                'success' => false,
                'message' => 'Token de acceso requerido.',
            ]);
    }

    public function test_delete_delivery_endpoint_requires_permission(): void
    {
        $this->withToken($this->tokenWithPermissions([]))
            ->deleteJson('/api/dotations/deliveries/7')
            ->assertForbidden()
            ->assertJsonPath('success', false)
            ->assertJsonPath('message', 'No tiene el permiso requerido para esta operación.');
    }

    public function test_my_deliveries_endpoint_requires_jwt(): void
    {
        $this->getJson('/api/dotations/my-deliveries')
            ->assertUnauthorized()
            ->assertJson([
                'success' => false,
                'message' => 'Token de acceso requerido.',
            ]);
    }

    public function test_confirm_delivery_received_endpoint_requires_jwt(): void
    {
        $this->postJson('/api/dotations/deliveries/7/confirm')
            ->assertUnauthorized()
            ->assertJson([
                'success' => false,
                'message' => 'Token de acceso requerido.',
            ]);
    }

    public function test_save_my_size_validates_required_fields(): void
    {
        $this->withToken($this->tokenWithPermissions(['DOTACIONES_MIS_TALLAS_EDITAR']))
            ->postJson('/api/dotations/my-sizes', [])
            ->assertUnprocessable()
            ->assertJsonPath('success', false)
            ->assertJsonValidationErrors(['id_tipo_dotacion']);
    }

    public function test_create_delivery_requires_details(): void
    {
        $this->withToken($this->tokenWithPermissions(['DOTACIONES_ENTREGAS_CREAR']))
            ->postJson('/api/dotations/deliveries', [
                'id_empleado' => 5,
                'fecha_entrega' => '2026-06-23',
            ])
            ->assertUnprocessable()
            ->assertJsonPath('success', false)
            ->assertJsonValidationErrors(['detalles']);
    }

    public function test_ordinary_delivery_requires_combination(): void
    {
        $this->withToken($this->tokenWithPermissions(['DOTACIONES_ENTREGAS_CREAR']))
            ->postJson('/api/dotations/deliveries', [
                'id_empleado' => 5,
                'fecha_entrega' => '2026-07-24',
                'tipo_entrega' => 'ORDINARIA',
                'detalles' => [[
                    'id_tipo_dotacion' => 7,
                    'id_talla_dotacion' => 30,
                    'cantidad' => 1,
                ]],
            ])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['id_dotacion_combinacion']);
    }

    public function test_extraordinary_delivery_rejects_combination(): void
    {
        $this->withToken($this->tokenWithPermissions(['DOTACIONES_ENTREGAS_CREAR']))
            ->postJson('/api/dotations/deliveries', [
                'id_empleado' => 5,
                'fecha_entrega' => '2026-07-24',
                'tipo_entrega' => 'EXTRAORDINARIA',
                'id_dotacion_combinacion' => 1,
                'detalles' => [[
                    'id_tipo_dotacion' => 7,
                    'id_talla_dotacion' => 30,
                    'cantidad' => 1,
                ]],
            ])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['id_dotacion_combinacion']);
    }

    public function test_create_delivery_rejects_zero_quantity(): void
    {
        $this->withToken($this->tokenWithPermissions(['DOTACIONES_ENTREGAS_CREAR']))
            ->postJson('/api/dotations/deliveries', [
                'id_empleado' => 5,
                'fecha_entrega' => '2026-07-24',
                'tipo_entrega' => 'EXTRAORDINARIA',
                'detalles' => [[
                    'id_tipo_dotacion' => 7,
                    'cantidad' => 0,
                ]],
            ])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['detalles.0.cantidad']);
    }

    public function test_confirm_delivery_received_validates_confirmation_observation_max_length(): void
    {
        $this->withToken($this->tokenWithPermissions(['DOTACIONES_MIS_ENTREGAS_CONFIRMAR']))
            ->postJson('/api/dotations/deliveries/7/confirm', [
                'observacion_confirmacion' => str_repeat('a', 501),
            ])
            ->assertUnprocessable()
            ->assertJsonPath('success', false)
            ->assertJsonValidationErrors(['observacion_confirmacion']);
    }

    public function test_confirm_delivery_received_validates_signature_url_max_length(): void
    {
        $this->withToken($this->tokenWithPermissions(['DOTACIONES_MIS_ENTREGAS_CONFIRMAR']))
            ->postJson('/api/dotations/deliveries/7/confirm', [
                'firma_url' => str_repeat('a', 501),
            ])
            ->assertUnprocessable()
            ->assertJsonPath('success', false)
            ->assertJsonValidationErrors(['firma_url']);
    }

    public function test_delete_delivery_validates_deletion_reason_max_length(): void
    {
        $this->withToken($this->tokenWithPermissions(['DOTACIONES_ENTREGAS_ELIMINAR']))
            ->deleteJson('/api/dotations/deliveries/7', [
                'motivo_eliminacion' => str_repeat('a', 501),
            ])
            ->assertUnprocessable()
            ->assertJsonPath('success', false)
            ->assertJsonValidationErrors(['motivo_eliminacion']);
    }

    public function test_types_endpoint_uses_stored_procedure_and_maps_sql_columns_to_json(): void
    {
        DB::shouldReceive('select')
            ->once()
            ->with('CALL SP_BBF_DOTACION_TIPOS_LISTAR(?)', [1])
            ->andReturn([
                (object) [
                    'ID_TIPO_DOTACION' => 1,
                    'NOMBRE' => 'Camisa',
                    'DESCRIPCION' => 'Camisa institucional',
                    'REQUIERE_TALLA' => 1,
                    'ACTIVO' => 1,
                    'CREATED_AT' => '2026-06-23 00:00:00',
                    'UPDATED_AT' => null,
                ],
            ]);

        $this->withToken($this->tokenWithPermissions(['DOTACIONES_CATALOGOS_VER']))
            ->getJson('/api/dotations/types')
            ->assertOk()
            ->assertExactJson([
                'success' => true,
                'message' => 'Tipos de dotación consultados correctamente',
                'data' => [[
                    'id_tipo_dotacion' => 1,
                    'nombre' => 'Camisa',
                    'descripcion' => 'Camisa institucional',
                    'requiere_talla' => true,
                    'activo' => true,
                ]],
            ]);
    }

    public function test_combinations_endpoint_uses_stored_procedure_and_maps_response(): void
    {
        DB::shouldReceive('select')
            ->once()
            ->with('CALL SP_BBF_DOTACION_COMBINACIONES_LISTAR()', [])
            ->andReturn([
                (object) [
                    'ID_DOTACION_COMBINACION' => 1,
                    'CODIGO' => 'DOT-01',
                    'NOMBRE' => 'Chaqueta, pantalon y zapatos',
                    'DESCRIPCION' => 'Dotacion estandar',
                    'ACTIVO' => 1,
                ],
            ]);

        $this->withToken($this->tokenWithPermissions(['DOTACIONES_CATALOGOS_VER']))
            ->getJson('/api/dotations/combinations')
            ->assertOk()
            ->assertJsonPath('data.0.id_dotacion_combinacion', 1)
            ->assertJsonPath('data.0.codigo', 'DOT-01')
            ->assertJsonPath('data.0.activo', true);
    }

    public function test_combination_details_endpoint_uses_stored_procedure_and_maps_response(): void
    {
        DB::shouldReceive('select')
            ->once()
            ->with('CALL SP_BBF_DOTACION_COMBINACION_DETALLE_LISTAR(?)', [1])
            ->andReturn([
                (object) [
                    'ID_DOTACION_COMBINACION_DETALLE' => 1,
                    'ID_DOTACION_COMBINACION' => 1,
                    'CODIGO_COMBINACION' => 'DOT-01',
                    'COMBINACION' => 'Chaqueta, pantalon y zapatos',
                    'ID_TIPO_DOTACION' => 7,
                    'TIPO_DOTACION' => 'Chaqueta',
                    'REQUIERE_TALLA' => 1,
                    'CANTIDAD' => 1,
                    'ORDEN' => 1,
                    'ACTIVO' => 1,
                ],
            ]);

        $this->withToken($this->tokenWithPermissions(['DOTACIONES_CATALOGOS_VER']))
            ->getJson('/api/dotations/combinations/1')
            ->assertOk()
            ->assertJsonPath('data.0.codigo_combinacion', 'DOT-01')
            ->assertJsonPath('data.0.tipo_dotacion', 'Chaqueta')
            ->assertJsonPath('data.0.requiere_talla', true)
            ->assertJsonPath('data.0.cantidad', 1);
    }

    public function test_deliveries_endpoint_maps_confirmation_fields(): void
    {
        DB::shouldReceive('select')
            ->once()
            ->with('CALL SP_BBF_DOTACION_ENTREGAS_LISTAR(?,?,?)', [5, null, null])
            ->andReturn([
                (object) [
                    'ID_DOTACION_ENTREGA' => 1,
                    'ID_EMPLEADO' => 5,
                    'NUMERO_DOCUMENTO' => '123456789',
                    'NOMBRE_COMPLETO' => 'Ana Perez',
                    'FECHA_ENTREGA' => '2026-06-23',
                    'FECHA_CONFIRMACION' => '2026-06-23 18:30:00',
                    'ESTADO' => 'ENTREGADA',
                    'OBSERVACIONES' => 'Entrega inicial',
                    'OBSERVACION_CONFIRMACION' => 'Recibido completo y en buen estado.',
                    'FIRMA_URL' => null,
                    'ID_REGISTRADO_POR' => 1,
                    'REGISTRADO_POR' => 'admin',
                    'ID_CONFIRMADO_POR' => 8,
                    'CONFIRMADO_POR' => 'empleado01',
                    'CREATED_AT' => '2026-06-23 00:00:00',
                    'UPDATED_AT' => '2026-06-23 18:30:00',
                ],
            ]);

        $this->withToken($this->tokenWithPermissions(['DOTACIONES_ENTREGAS_VER']))
            ->getJson('/api/dotations/deliveries?id_empleado=5')
            ->assertOk()
            ->assertExactJson([
                'success' => true,
                'message' => 'Entregas de dotación consultadas correctamente',
                'data' => [[
                    'id_dotacion_entrega' => 1,
                    'id_empleado' => 5,
                    'numero_documento' => '123456789',
                    'nombre_completo' => 'Ana Perez',
                    'fecha_entrega' => '2026-06-23',
                    'tipo_entrega' => 'ORDINARIA',
                    'id_dotacion_combinacion' => null,
                    'codigo_combinacion' => null,
                    'nombre_combinacion' => null,
                    'fecha_confirmacion' => '2026-06-23 18:30:00',
                    'estado' => 'ENTREGADA',
                    'observaciones' => 'Entrega inicial',
                    'observacion_confirmacion' => 'Recibido completo y en buen estado.',
                    'firma_url' => null,
                    'id_registrado_por' => 1,
                    'registrado_por' => 'admin',
                    'id_confirmado_por' => 8,
                    'confirmado_por' => 'empleado01',
                    'created_at' => '2026-06-23 00:00:00',
                    'updated_at' => '2026-06-23 18:30:00',
                ]],
            ]);
    }

    public function test_delete_delivery_endpoint_maps_success_response(): void
    {
        DB::shouldReceive('select')
            ->once()
            ->with('CALL SP_BBF_DOTACION_ENTREGA_ELIMINAR_LOGICO(?,?,?)', [
                7,
                99,
                'Registro creado por error',
            ])
            ->andReturn([
                (object) [
                    'ID_DOTACION_ENTREGA' => 7,
                    'ELIMINADO' => 1,
                    'ESTADO' => 'ANULADA',
                    'FECHA_ELIMINACION' => '2026-06-23 18:30:00',
                ],
            ]);

        $this->withToken($this->tokenWithPermissions(['DOTACIONES_ENTREGAS_ELIMINAR']))
            ->deleteJson('/api/dotations/deliveries/7', [
                'motivo_eliminacion' => 'Registro creado por error',
            ])
            ->assertOk()
            ->assertExactJson([
                'success' => true,
                'message' => 'Entrega de dotaciÃ³n eliminada correctamente',
                'data' => [
                    'id_dotacion_entrega' => 7,
                    'eliminado' => true,
                    'estado' => 'ANULADA',
                    'fecha_eliminacion' => '2026-06-23 18:30:00',
                ],
            ]);
    }

    public function test_employee_history_endpoint_maps_sql_columns_to_json(): void
    {
        DB::shouldReceive('select')
            ->once()
            ->with('CALL SP_BBF_DOTACION_HISTORIAL_EMPLEADO(?)', [5])
            ->andReturn([
                (object) [
                    'ID_DOTACION_ENTREGA' => 3,
                    'ID_EMPLEADO' => 5,
                    'NUMERO_DOCUMENTO' => '206231',
                    'NOMBRE_COMPLETO' => 'Alfredo Gomez',
                    'AREA' => 'Cultivo',
                    'CARGO' => 'Operario',
                    'FECHA_ENTREGA' => '2026-06-23',
                    'FECHA_CONFIRMACION' => null,
                    'ESTADO' => 'REGISTRADA',
                    'OBSERVACIONES_ENTREGA' => 'Entrega inicial',
                    'OBSERVACION_CONFIRMACION' => null,
                    'FIRMA_URL' => null,
                    'ID_REGISTRADO_POR' => 1,
                    'REGISTRADO_POR' => 'Super AD',
                    'ID_CONFIRMADO_POR' => null,
                    'CONFIRMADO_POR' => null,
                    'ID_DOTACION_ENTREGA_DETALLE' => 4,
                    'ID_TIPO_DOTACION' => 1,
                    'TIPO_DOTACION' => 'Delantal',
                    'ID_TALLA_DOTACION' => 5,
                    'TALLA' => 'L',
                    'CANTIDAD' => 2,
                    'OBSERVACIONES_DETALLE' => 'Me falto el blanco',
                    'CREATED_AT' => '2026-06-23 00:00:00',
                    'UPDATED_AT' => '2026-06-23 00:00:00',
                ],
            ]);

        $this->withToken($this->tokenWithPermissions(['DOTACIONES_EMPLEADO_VER']))
            ->getJson('/api/dotations/employees/5/history')
            ->assertOk()
            ->assertExactJson([
                'success' => true,
                'message' => 'Historial de dotaciones del empleado consultado correctamente',
                'data' => [[
                    'id_dotacion_entrega' => 3,
                    'id_empleado' => 5,
                    'numero_documento' => '206231',
                    'nombre_completo' => 'Alfredo Gomez',
                    'area' => 'Cultivo',
                    'cargo' => 'Operario',
                    'fecha_entrega' => '2026-06-23',
                    'tipo_entrega' => 'ORDINARIA',
                    'id_dotacion_combinacion' => null,
                    'codigo_combinacion' => null,
                    'nombre_combinacion' => null,
                    'fecha_confirmacion' => null,
                    'estado' => 'REGISTRADA',
                    'observaciones_entrega' => 'Entrega inicial',
                    'observacion_confirmacion' => null,
                    'firma_url' => null,
                    'id_registrado_por' => 1,
                    'registrado_por' => 'Super AD',
                    'id_confirmado_por' => null,
                    'confirmado_por' => null,
                    'id_dotacion_entrega_detalle' => 4,
                    'id_tipo_dotacion' => 1,
                    'tipo_dotacion' => 'Delantal',
                    'id_talla_dotacion' => 5,
                    'talla' => 'L',
                    'cantidad' => 2,
                    'observaciones_detalle' => 'Me falto el blanco',
                    'created_at' => '2026-06-23 00:00:00',
                    'updated_at' => '2026-06-23 00:00:00',
                ]],
            ]);
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
