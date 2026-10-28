<?php

namespace Tests\Feature;

use App\Services\JwtService;
use Illuminate\Support\Facades\DB;
use Mockery;
use PDO;
use PDOStatement;
use Tests\TestCase;

class EvaluationApiTest extends TestCase
{
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

    public function test_evaluation_can_be_created(): void
    {
        DB::shouldReceive('select')->once()
            ->with('CALL SP_BBF_EVALUACION_CREAR(?,?,?,?,?,?,?)', [1, null, 2026, '2026-10-26', '2026-11-01', null, 99])
            ->andReturn([(object) [
                'ID_EVALUACION' => 1,
                'ANIO' => 2026,
                'NUMERO_SEMANA' => 1,
                'ESTADO' => 'BORRADOR',
            ]]);

        DB::shouldReceive('statement')
            ->with('INSERT IGNORE INTO `bbf_evaluacion_metas_finca` (`ID_EVALUACION`, `ID_EVALUACION_LABOR`, `META_CAMAS`, `ID_REGISTRADO_POR`) SELECT ?, `ID_EVALUACION_LABOR`, ?, ? FROM `bbf_evaluacion_labores` WHERE `ACTIVO` = 1', Mockery::any())
            ->andReturn(true);

        DB::shouldReceive('select')
            ->with('CALL SP_BBF_LOG_AUDITORIA_CREAR(?,?,?,?,?,?,?,?,?)', Mockery::any())
            ->andReturn([]);

        $this->withToken($this->token(['EVALUACIONES_CREAR']))
            ->postJson('/api/evaluations', [
                'anio' => 2026,
                'numero_semana' => 1,
                'fecha_inicio' => '2026-10-26',
                'fecha_fin' => '2026-11-01',
            ])
            ->assertCreated()
            ->assertJsonPath('data.id_evaluacion', 1);
    }

    public function test_all_active_employees_can_be_added(): void
    {
        DB::shouldReceive('transaction')->once()->andReturnUsing(static fn (callable $callback) => $callback());
        DB::shouldReceive('select')->once()
            ->with('CALL SP_BBF_EVALUACION_AGREGAR_EMPLEADOS_TODOS(?, ?, @p_insertados, @p_omitidos_duplicados, @p_mensaje)', [1, 99])
            ->andReturn([(object) [
                'ID_EVALUACION_EMPLEADO' => 1,
                'ID_EMPLEADO' => 3,
                'ESTADO_EVALUACION' => 'PENDIENTE',
            ]]);
        DB::shouldReceive('select')->once()
            ->with('SELECT @p_insertados AS insertados, @p_omitidos_duplicados AS omitidos_duplicados, @p_mensaje AS mensaje')
            ->andReturn([(object) [
                'insertados' => 74,
                'omitidos_duplicados' => 0,
                'mensaje' => 'Proceso completado',
            ]]);

        DB::shouldReceive('select')
            ->with('CALL SP_BBF_LOG_AUDITORIA_CREAR(?,?,?,?,?,?,?,?,?)', Mockery::any())
            ->andReturn([]);

        $this->withToken($this->token(['EVALUACIONES_EDITAR']))
            ->postJson('/api/evaluations/1/employees/add-all')
            ->assertOk()
            ->assertJsonPath('data.insertados', 74);
    }

    public function test_scores_can_be_registered(): void
    {
        DB::shouldReceive('transaction')->once()->andReturnUsing(static fn (callable $callback) => $callback());
        DB::shouldReceive('select')->once()
            ->with('CALL SP_BBF_EVALUACION_REGISTRAR_CALIFICACIONES(?,?,?,?,?,?,?)', [1, 3, 1, 10, 50, 'test', 99])
            ->andReturn([(object) [
                'ID_EVALUACION_DETALLE' => 1,
                'VALOR_OBTENIDO' => 10,
            ]]);

        DB::shouldReceive('select')
            ->with('CALL SP_BBF_LOG_AUDITORIA_CREAR(?,?,?,?,?,?,?,?,?)', Mockery::any())
            ->andReturn([]);

        $this->withToken($this->token(['EVALUACIONES_EDITAR']))
            ->postJson('/api/evaluations/1/scores', [
                'calificaciones' => [
                    [
                        'id_empleado' => 3,
                        'id_evaluacion_labor' => 1,
                        'valor_obtenido' => 10,
                        'valor_maximo' => 50,
                        'observaciones' => 'test',
                    ],
                ],
            ])
            ->assertOk()
            ->assertJsonPath('data.scores.0.id_evaluacion_detalle', 1);
    }

    public function test_management_panel_can_be_queried(): void
    {
        $evaluationRow = (object) [
            'ID_EVALUACION' => 1,
            'ANIO' => 2026,
            'NUMERO_SEMANA' => 1,
            'ESTADO' => 'EN_PROCESO',
            'ELIMINADO' => 0,
        ];

        $builder = Mockery::mock();
        $builder->shouldReceive('where')->andReturnSelf();
        $builder->shouldReceive('first')->andReturn($evaluationRow);
        DB::shouldReceive('table')->once()->with('bbf_evaluaciones')->andReturn($builder);

        $statement = Mockery::mock(PDOStatement::class);
        $statement->shouldReceive('execute')->once()->with([1]);
        $statement->shouldReceive('columnCount')->andReturn(10, 1);
        $statement->shouldReceive('fetchAll')->andReturn(
            [[
                'ID_EVALUACION_LABOR' => 1,
                'CODIGO' => 'DESBOTONE',
                'NOMBRE' => 'Desbotone',
                'CAMAS_EJECUTADAS' => 10,
                'META_CAMAS' => 1168,
                'ESTADO_LABOR' => 'En Proceso',
            ]],
            [[
                'TOTAL_CAMAS_EJECUTADAS' => 10,
                'TOTAL_META_CAMAS' => 1168,
                'PORCENTAJE_COBERTURA_GLOBAL' => 0.86,
                'TOTAL_EMPLEADOS' => 74,
            ]]
        );
        $statement->shouldReceive('nextRowset')->andReturn(true, false);
        $statement->shouldReceive('closeCursor')->once();

        $pdo = Mockery::mock(PDO::class);
        $pdo->shouldReceive('prepare')->once()->with('CALL SP_BBF_EVALUACION_PANEL_GERENCIAL_OBTENER(?)')->andReturn($statement);

        $connection = Mockery::mock();
        $connection->shouldReceive('getPdo')->andReturn($pdo);
        DB::shouldReceive('connection')->andReturn($connection);

        $this->withToken($this->token(['EVALUACIONES_VER']))
            ->getJson('/api/evaluations/1/management-panel')
            ->assertOk()
            ->assertJsonPath('data.labores.0.codigo', 'DESBOTONE')
            ->assertJsonPath('data.resumen.total_camas_ejecutadas', 10);
    }
}
