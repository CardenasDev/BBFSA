<?php

namespace Tests\Unit;

use App\Repositories\TrainingRepository;
use Illuminate\Support\Facades\DB;
use Tests\TestCase;

class TrainingRepositoryTest extends TestCase
{
    public function test_session_creation_uses_the_eight_parameter_database_contract(): void
    {
        DB::shouldReceive('select')->once()->with('CALL SP_BBF_CAPACITACION_SESION_CREAR(?,?,?,?,?,?,?,?)', [1, '2026-08-03', '2026-08-07', null, 'Instructor', 'Cultivo', null, 99])->andReturn([(object) ['ID_CAPACITACION_SESION' => 4]]);
        $result = (new TrainingRepository)->createSession(['id_capacitacion' => 1, 'fecha_inicio' => '2026-08-03', 'fecha_fin' => '2026-08-07', 'instructor_externo' => 'Instructor', 'lugar' => 'Cultivo'], 99);
        self::assertSame(4, $result['id_capacitacion_sesion']);
    }

    public function test_session_list_uses_iso_year_and_week_filters(): void
    {
        DB::shouldReceive('select')->once()->with('CALL SP_BBF_CAPACITACION_SESIONES_LISTAR(?,?,?,?)', [1, 2026, 32, 'PROGRAMADA'])->andReturn([]);
        self::assertSame([], (new TrainingRepository)->sessions(['id_capacitacion' => 1, 'anio' => 2026, 'semana' => 32, 'estado' => 'PROGRAMADA']));
    }

    public function test_task_association_uses_the_five_parameter_contract(): void
    {
        DB::shouldReceive('select')->once()->with('CALL SP_BBF_CAPACITACION_LABOR_ASOCIAR(?,?,?,?,?)', [1, 2, null, 50, 3])->andReturn([(object) ['ID_CAPACITACION_LABOR_DETALLE' => 9]]);
        $result = (new TrainingRepository)->attachTask(['id_capacitacion' => 1, 'id_capacitacion_labor' => 2, 'puntaje_maximo_labor' => 50, 'orden' => 3]);
        self::assertSame(9, $result['id_capacitacion_labor_detalle']);
    }

    public function test_attached_tasks_use_the_corrective_listing_procedure(): void
    {
        DB::shouldReceive('select')->once()->with('CALL SP_BBF_CAPACITACION_LABORES_ASOCIADAS_LISTAR(?,?)', [1, 0])->andReturn([]);
        self::assertSame([], (new TrainingRepository)->attachedTasks(1, false));
    }
}
