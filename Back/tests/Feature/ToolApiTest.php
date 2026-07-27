<?php

namespace Tests\Feature;

use App\Services\JwtService;
use App\Services\AuditService;
use Illuminate\Support\Facades\DB;
use Mockery;
use Tests\TestCase;

class ToolApiTest extends TestCase
{
    public function test_tools_list_uses_active_filter_and_maps_booleans(): void
    {
        DB::shouldReceive('select')->once()
            ->with('CALL SP_BBF_HERRAMIENTAS_LISTAR(?)', [0])
            ->andReturn([(object) [
                'ID_HERRAMIENTA' => 1,
                'NOMBRE' => 'Machete',
                'DESCRIPCION' => 'Labores de cultivo',
                'ACTIVO' => 0,
            ]]);

        $this->withToken($this->token(['HERRAMIENTAS_LISTAR']))
            ->getJson('/api/tools?active=0')
            ->assertOk()
            ->assertJsonPath('data.0.id_herramienta', 1)
            ->assertJsonPath('data.0.activo', false);
    }

    public function test_create_delivery_sends_complete_detail_as_json(): void
    {
        DB::shouldReceive('select')->once()
            ->withArgs(function (string $sql, array $parameters): bool {
                $detail = json_decode($parameters[3], true);

                return $sql === 'CALL SP_BBF_HERRAMIENTAS_ENTREGA_CREAR(?,?,?,?)'
                    && $parameters[0] === 18
                    && $parameters[1] === '2026-07-27'
                    && $parameters[2] === 'Entrega inicial'
                    && $detail === [[
                        'id_herramienta' => 13,
                        'cantidad' => 2,
                        'observaciones' => 'Dos pares',
                    ]];
            })
            ->andReturn([(object) ['ID_ENTREGA' => 15]]);

        $this->withToken($this->token(['HERRAMIENTAS_ENTREGAR']))
            ->postJson('/api/tool-deliveries', [
                'id_empleado' => 18,
                'fecha_entrega' => '2026-07-27',
                'observaciones' => 'Entrega inicial',
                'herramientas' => [[
                    'id_herramienta' => 13,
                    'cantidad' => 2,
                    'observaciones' => 'Dos pares',
                ]],
            ])
            ->assertCreated()
            ->assertJsonPath('data.id_entrega', 15)
            ->assertJsonPath('data.estado', 'pendiente');
    }

    public function test_create_delivery_validates_nested_details_before_database_call(): void
    {
        DB::shouldReceive('select')->never();

        $this->withToken($this->token(['HERRAMIENTAS_ENTREGAR']))
            ->postJson('/api/tool-deliveries', [
                'id_empleado' => 18,
                'fecha_entrega' => '27/07/2026',
                'herramientas' => [['id_herramienta' => 1, 'cantidad' => 0]],
            ])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['fecha_entrega', 'herramientas.0.cantidad']);
    }

    public function test_show_delivery_combines_header_and_details(): void
    {
        DB::shouldReceive('select')->once()
            ->with('CALL SP_BBF_HERRAMIENTAS_ENTREGA_OBTENER(?)', [15])
            ->andReturn([(object) [
                'ID_ENTREGA' => 15,
                'ID_EMPLEADO' => 18,
                'NOMBRES' => 'José',
                'APELLIDOS' => 'Lagos',
                'ESTADO' => 'pendiente',
            ]]);
        DB::shouldReceive('select')->once()
            ->with('CALL SP_BBF_HERRAMIENTAS_ENTREGA_DETALLE_LISTAR(?)', [15])
            ->andReturn([(object) [
                'ID_DETALLE' => 1,
                'ID_HERRAMIENTA' => 3,
                'HERRAMIENTA' => 'Casco',
                'CANTIDAD' => 1,
                'OBSERVACIONES' => null,
            ]]);

        $this->withToken($this->token(['HERRAMIENTAS_LISTAR']))
            ->getJson('/api/tool-deliveries/15')
            ->assertOk()
            ->assertJsonPath('data.empleado', 'José Lagos')
            ->assertJsonPath('data.herramientas.0.id_herramienta', 3)
            ->assertJsonPath('data.herramientas.0.cantidad', 1);
    }

    public function test_delivery_filters_and_actions_use_expected_procedures(): void
    {
        DB::shouldReceive('select')->once()
            ->with('CALL SP_BBF_HERRAMIENTAS_ENTREGAS_LISTAR(?,?)', [18, 'pendiente'])
            ->andReturn([]);
        $this->withToken($this->token(['HERRAMIENTAS_LISTAR']))
            ->getJson('/api/tool-deliveries?id_empleado=18&estado=pendiente')
            ->assertOk();

        DB::shouldReceive('select')->once()
            ->with('CALL SP_BBF_HERRAMIENTAS_ENTREGA_CONFIRMAR(?)', [15])
            ->andReturn([]);
        $this->withToken($this->token(['HERRAMIENTAS_CONFIRMAR']))
            ->postJson('/api/tool-deliveries/15/confirm')
            ->assertOk()
            ->assertJsonPath('data.estado', 'confirmada');

        DB::shouldReceive('select')->once()
            ->with('CALL SP_BBF_HERRAMIENTAS_ENTREGA_ELIMINAR(?)', [16])
            ->andReturn([]);
        $this->withToken($this->token(['HERRAMIENTAS_ELIMINAR']))
            ->deleteJson('/api/tool-deliveries/16')
            ->assertOk()
            ->assertJsonPath('data.id_entrega', 16);
    }

    public function test_routes_require_their_specific_permission(): void
    {
        $this->withToken($this->token([]))
            ->postJson('/api/tool-deliveries/15/confirm')
            ->assertForbidden()
            ->assertJsonPath('success', false);
    }

    public function test_employee_lists_only_deliveries_from_employee_resolved_by_jwt_user(): void
    {
        $this->expectEmployeeResolution(99, 18);
        DB::shouldReceive('select')->once()
            ->with('CALL SP_BBF_HERRAMIENTAS_MIS_ENTREGAS_LISTAR(?)', [18])
            ->andReturn([(object) [
                'ID_ENTREGA' => 15,
                'FECHA_ENTREGA' => '2026-07-27',
                'ESTADO' => 'pendiente',
                'TOTAL_HERRAMIENTAS' => 3,
            ]]);

        $this->withToken($this->token(['HERRAMIENTAS_MIS_ENTREGAS_VER']))
            ->getJson('/api/my-tool-deliveries?id_empleado=999')
            ->assertOk()
            ->assertJsonPath('data.0.id_entrega', 15)
            ->assertJsonPath('data.0.total_herramientas', 3);
    }

    public function test_employee_cannot_view_another_employees_delivery(): void
    {
        $this->expectEmployeeResolution(99, 18);
        DB::shouldReceive('select')->once()
            ->with('CALL SP_BBF_HERRAMIENTAS_MI_ENTREGA_OBTENER(?,?)', [77, 18])
            ->andReturn([]);

        $this->withToken($this->token(['HERRAMIENTAS_MIS_ENTREGAS_VER']))
            ->getJson('/api/my-tool-deliveries/77')
            ->assertNotFound()
            ->assertJsonPath('success', false);
    }

    public function test_employee_can_view_own_delivery_with_details(): void
    {
        $this->expectEmployeeResolution(99, 18);
        DB::shouldReceive('select')->once()
            ->with('CALL SP_BBF_HERRAMIENTAS_MI_ENTREGA_OBTENER(?,?)', [15, 18])
            ->andReturn([(object) ['ID_ENTREGA' => 15, 'ESTADO' => 'pendiente']]);
        DB::shouldReceive('select')->once()
            ->with('CALL SP_BBF_HERRAMIENTAS_MI_ENTREGA_DETALLE_LISTAR(?,?)', [15, 18])
            ->andReturn([(object) [
                'ID_DETALLE' => 1,
                'ID_HERRAMIENTA' => 3,
                'HERRAMIENTA' => 'Casco',
                'CANTIDAD' => 1,
            ]]);

        $this->withToken($this->token(['HERRAMIENTAS_MIS_ENTREGAS_VER']))
            ->getJson('/api/my-tool-deliveries/15')
            ->assertOk()
            ->assertJsonPath('data.herramientas.0.herramienta', 'Casco');
    }

    public function test_employee_can_confirm_own_delivery(): void
    {
        $this->expectEmployeeResolution(99, 18);
        DB::shouldReceive('select')->once()
            ->with('CALL SP_BBF_HERRAMIENTAS_MI_ENTREGA_CONFIRMAR(?,?,?)', [15, 18, 99])
            ->andReturn([(object) ['ID_ENTREGA' => 15, 'ESTADO' => 'confirmada']]);
        $audit = Mockery::mock(AuditService::class);
        $audit->shouldReceive('record')->once();
        $this->app->instance(AuditService::class, $audit);

        $this->withToken($this->token(['HERRAMIENTAS_CONFIRMAR']))
            ->postJson('/api/my-tool-deliveries/15/confirm', ['id_empleado' => 999])
            ->assertOk()
            ->assertJsonPath('message', 'Recepción confirmada correctamente.')
            ->assertJsonPath('data.estado', 'confirmada');
    }

    public function test_employee_cannot_confirm_another_employees_delivery(): void
    {
        $this->expectEmployeeResolution(99, 18);
        $databaseError = new \PDOException('La entrega de herramientas no existe.', 45000);
        $databaseError->errorInfo = ['45000', 1644, 'La entrega de herramientas no existe.'];
        DB::shouldReceive('select')->once()
            ->with('CALL SP_BBF_HERRAMIENTAS_MI_ENTREGA_CONFIRMAR(?,?,?)', [77, 18, 99])
            ->andThrow(new \Illuminate\Database\QueryException(
                'mysql',
                'CALL SP_BBF_HERRAMIENTAS_MI_ENTREGA_CONFIRMAR(?,?,?)',
                [77, 18, 99],
                $databaseError,
            ));

        $this->withToken($this->token(['HERRAMIENTAS_CONFIRMAR']))
            ->postJson('/api/my-tool-deliveries/77/confirm')
            ->assertUnprocessable()
            ->assertJsonPath('success', false);
    }

    private function expectEmployeeResolution(int $userId, int $employeeId): void
    {
        DB::shouldReceive('select')->once()
            ->with('CALL SP_BBF_HERRAMIENTAS_EMPLEADO_USUARIO_OBTENER(?)', [$userId])
            ->andReturn([(object) ['ID_EMPLEADO' => $employeeId]]);
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
