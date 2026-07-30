<?php

namespace Tests\Unit;

use App\Repositories\ReturnRepository;
use Illuminate\Support\Facades\DB;
use Tests\TestCase;

class ReturnRepositoryTest extends TestCase
{
    public function test_create_sends_one_call_with_json_details_and_evidence(): void
    {
        DB::shouldReceive('select')->once()->withArgs(function (string $sql, array $parameters): bool {
            return $sql === 'CALL SP_BBF_DEVOLUCION_CREAR(?,?,?,?,?,?,?,?,?)'
                && $parameters[0] === 'DOTACION'
                && $parameters[6] === 99
                && json_decode($parameters[7], true)[0]['id_detalle'] === 7
                && json_decode($parameters[8], true)[0]['tipo_evidencia'] === 'FOTO';
        })->andReturn([(object) ['ID_DEVOLUCION' => 12, 'ESTADO' => 'REGISTRADA']]);

        $result = (new ReturnRepository)->create([
            'type' => 'DOTACION',
            'employee_id' => 5,
            'delivery_id' => 6,
            'return_date' => '2026-07-20',
            'reason' => 'Cambio',
            'observations' => null,
        ], 99, [
            ['id_detalle' => 7, 'cantidad' => 1, 'estado_elemento' => 'BUENO'],
        ], [
            ['tipo_evidencia' => 'FOTO'],
        ]);

        $this->assertSame(12, $result['id_devolucion']);
    }

    public function test_list_passes_null_optional_filters_in_one_call(): void
    {
        DB::shouldReceive('select')->once()
            ->with('CALL SP_BBF_DEVOLUCIONES_LISTAR(?,?,?,?,?)', ['HERRAMIENTA', null, null, null, null])
            ->andReturn([]);

        $this->assertSame([], (new ReturnRepository)->list(['type' => 'HERRAMIENTA']));
    }
}
