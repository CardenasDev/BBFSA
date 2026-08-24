<?php

namespace Tests\Unit;

use App\Repositories\NoveltyRepository;
use Illuminate\Support\Facades\DB;
use Tests\TestCase;

class NoveltyRepositoryTest extends TestCase
{
    public function test_creates_general_novelty_with_database_contract(): void
    {
        DB::shouldReceive('select')->once()->with('CALL SP_BBF_NOVEDAD_CREAR(?,?,?,?,?,?,?)', [5, 'PERMISO', '2026-08-21', '2026-08-21', 'Cita', null, 99])->andReturn([(object) ['ID_NOVEDAD' => 8]]);
        $result = (new NoveltyRepository)->create(['employee_id'=>5,'type'=>'PERMISO','start_date'=>'2026-08-21','end_date'=>'2026-08-21','reason'=>'Cita'], 99);
        self::assertSame(8, $result['id_novedad']);
    }

    public function test_creates_disability_with_fifteen_parameters(): void
    {
        DB::shouldReceive('select')->once()->withArgs(fn(string $sql,array $p): bool => $sql==='CALL SP_BBF_INCAPACIDAD_CREAR(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)' && $p[0]===5 && $p[5]===3 && $p[13]===null && $p[14]===99)->andReturn([(object)['ID_NOVEDAD'=>9,'ID_INCAPACIDAD'=>4,'NUMERO_DIAS'=>3]]);
        $result=(new NoveltyRepository)->createDisability(['employee_id'=>5,'start_date'=>'2026-08-21','end_date'=>'2026-08-23','eps_id'=>3,'origin'=>'ENFERMEDAD_GENERAL'],99);
        self::assertSame(3,$result['numero_dias']);
    }

    public function test_list_preserves_optional_filter_positions(): void
    {
        DB::shouldReceive('select')->once()->with('CALL SP_BBF_NOVEDADES_LISTAR(?,?,?,?,?)',[5,'INCAPACIDAD',null,null,null])->andReturn([]);
        self::assertSame([], (new NoveltyRepository)->list(['employee_id'=>5,'type'=>'INCAPACIDAD']));
    }

    public function test_saves_disability_tracking_with_database_contract(): void
    {
        DB::shouldReceive('select')->once()->withArgs(fn(string $sql,array $p): bool =>
            $sql==='CALL SP_BBF_INCAPACIDAD_SEGUIMIENTO_GUARDAR(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)'
            && $p[0]===9 && $p[1]===3 && $p[9]===150000.0 && $p[16]===99
        )->andReturn([(object)['ID_NOVEDAD'=>9,'ESTADO_SEGUIMIENTO'=>'EN_TRAMITE']]);

        $result=(new NoveltyRepository)->saveDisabilityTracking(9,[
            'responsible_entity_id'=>3,'days_paid_company'=>2,'days_payable_entity'=>3,
            'transcription_status'=>'TRANSCRITA','payment_request_status'=>'RADICADA',
            'disability_value'=>150000.0,'entity_received_value'=>0,'company_paid_worker_value'=>50000,
            'worker_paid_value'=>50000,'tracking_status'=>'EN_TRAMITE',
        ],99);
        self::assertSame('EN_TRAMITE',$result['estado_seguimiento']);
    }

    public function test_lists_disability_tracking_preserving_filter_positions(): void
    {
        DB::shouldReceive('select')->once()->with('CALL SP_BBF_INCAPACIDADES_SEGUIMIENTO_LISTAR(?,?,?,?,?)',[5,null,'PENDIENTE',null,null])->andReturn([]);
        self::assertSame([], (new NoveltyRepository)->listDisabilityTracking(['employee_id'=>5,'tracking_status'=>'PENDIENTE']));
    }
}
