<?php

namespace Tests\Unit;

use App\Repositories\DotationRepository;
use Illuminate\Support\Facades\DB;
use Tests\TestCase;

class DotationRepositoryTest extends TestCase
{
    public function test_types_calls_stored_procedure_and_normalizes_columns(): void
    {
        DB::shouldReceive('select')
            ->once()
            ->with('CALL SP_BBF_DOTACION_TIPOS_LISTAR(?)', [1])
            ->andReturn([
                (object) [
                    'ID_TIPO_DOTACION' => 1,
                    'NOMBRE' => 'Camisa',
                    'REQUIERE_TALLA' => 1,
                    'ACTIVO' => 1,
                ],
            ]);

        $rows = app(DotationRepository::class)->types(true);

        $this->assertSame(1, $rows[0]['id_tipo_dotacion']);
        $this->assertSame('Camisa', $rows[0]['nombre']);
        $this->assertSame(1, $rows[0]['requiere_talla']);
        $this->assertArrayNotHasKey('ID_TIPO_DOTACION', $rows[0]);
    }

    public function test_sizes_calls_stored_procedure_with_parameters_in_order(): void
    {
        DB::shouldReceive('select')
            ->once()
            ->with('CALL SP_BBF_DOTACION_TALLAS_LISTAR(?,?)', [1, 0])
            ->andReturn([]);

        app(DotationRepository::class)->sizes(1, false);
    }

    public function test_articles_calls_stored_procedure_with_filters_in_order(): void
    {
        DB::shouldReceive('select')
            ->once()
            ->with('CALL SP_BBF_DOTACION_ARTICULOS_LISTAR(?,?,?)', [2, 'MUJER', 0])
            ->andReturn([(object) ['ID_DOTACION_ARTICULO' => 12, 'ARTICULO' => 'Pantalón Mujer Drill']]);

        $rows = app(DotationRepository::class)->articles(2, 'MUJER', false);

        $this->assertSame(12, $rows[0]['id_dotacion_articulo']);
        $this->assertSame('Pantalón Mujer Drill', $rows[0]['articulo']);
    }

    public function test_combinations_call_expected_stored_procedures(): void
    {
        DB::shouldReceive('select')
            ->once()
            ->with('CALL SP_BBF_DOTACION_COMBINACIONES_LISTAR()', [])
            ->andReturn([]);

        DB::shouldReceive('select')
            ->once()
            ->with('CALL SP_BBF_DOTACION_COMBINACION_DETALLE_LISTAR(?)', [2])
            ->andReturn([]);

        $repository = app(DotationRepository::class);
        $repository->combinations();
        $repository->combinationDetails(2);
    }

    public function test_save_my_size_calls_stored_procedure_with_authenticated_user_first(): void
    {
        DB::shouldReceive('select')
            ->once()
            ->with('CALL SP_BBF_DOTACION_MI_TALLA_ARTICULO_GUARDAR(?,?,?,?)', [
                99,
                1,
                3,
                'Talla confirmada',
            ])
            ->andReturn([(object) ['ID_EMPLEADO_DOTACION_ARTICULO_TALLA' => 10]]);

        $row = app(DotationRepository::class)->saveMySize(99, 1, 3, 'Talla confirmada');

        $this->assertSame(10, $row['id_empleado_dotacion_articulo_talla']);
    }

    public function test_my_deliveries_calls_stored_procedure_with_authenticated_user(): void
    {
        DB::shouldReceive('select')
            ->once()
            ->with('CALL SP_BBF_DOTACION_MIS_ENTREGAS_LISTAR(?)', [99])
            ->andReturn([]);

        app(DotationRepository::class)->myDeliveries(99);
    }

    public function test_confirm_delivery_received_calls_stored_procedure_with_parameters_in_order(): void
    {
        DB::shouldReceive('select')
            ->once()
            ->with('CALL SP_BBF_DOTACION_ENTREGA_CONFIRMAR_RECIBIDO(?,?,?,?)', [
                99,
                7,
                'Recibido completo',
                '/firmas/entrega-7.png',
            ])
            ->andReturn([(object) ['ID_DOTACION_ENTREGA' => 7]]);

        $row = app(DotationRepository::class)->confirmDeliveryReceived(99, 7, 'Recibido completo', '/firmas/entrega-7.png');

        $this->assertSame(7, $row['id_dotacion_entrega']);
    }

    public function test_confirm_delivery_by_hr_calls_dedicated_stored_procedure(): void
    {
        DB::shouldReceive('select')
            ->once()
            ->with('CALL SP_BBF_DOTACION_ENTREGA_CONFIRMAR_POR_RRHH(?,?,?)', [
                99,
                7,
                'Entrega presencial',
            ])
            ->andReturn([(object) ['ID_DOTACION_ENTREGA' => 7, 'ESTADO' => 'ENTREGADA']]);

        $row = app(DotationRepository::class)->confirmDeliveryByHr(99, 7, 'Entrega presencial');

        $this->assertSame('ENTREGADA', $row['estado']);
    }

    public function test_employee_history_calls_stored_procedure_with_employee_id(): void
    {
        DB::shouldReceive('select')
            ->once()
            ->with('CALL SP_BBF_DOTACION_HISTORIAL_EMPLEADO(?)', [5])
            ->andReturn([]);

        app(DotationRepository::class)->employeeHistory(5);
    }

    public function test_delete_delivery_calls_stored_procedure_with_parameters_in_order(): void
    {
        DB::shouldReceive('select')
            ->once()
            ->with('CALL SP_BBF_DOTACION_ENTREGA_ELIMINAR_LOGICO(?,?,?)', [
                7,
                99,
                'Registro creado por error',
            ])
            ->andReturn([(object) ['ID_DOTACION_ENTREGA' => 7, 'ELIMINADO' => 1]]);

        $row = app(DotationRepository::class)->deleteDelivery(7, 99, 'Registro creado por error');

        $this->assertSame(7, $row['id_dotacion_entrega']);
        $this->assertSame(1, $row['eliminado']);
    }

    public function test_create_delivery_and_detail_call_stored_procedures_with_parameters_in_order(): void
    {
        DB::shouldReceive('select')
            ->once()
            ->with('CALL SP_BBF_DOTACION_ENTREGA_CREAR_V2(?,?,?,?,?,?,?,?,?,?,?,?,?)', [
                5,
                '2026-06-23',
                'ORDINARIA',
                1,
                99,
                'Entrega inicial',
                'REGISTRADA',
                'Evidencia entrega',
                null,
                'https://example.com/evidencia.jpg',
                null,
                null,
                null,
            ])
            ->andReturn([(object) ['ID_DOTACION_ENTREGA' => 7]]);

        DB::shouldReceive('select')
            ->once()
            ->with('CALL SP_BBF_DOTACION_ENTREGA_DETALLE_AGREGAR_V2(?,?,?,?,?,?)', [
                7,
                41,
                1,
                3,
                2,
                'Camisas institucionales',
            ])
            ->andReturn([]);

        $repository = app(DotationRepository::class);
        $deliveryId = $repository->createDelivery(
            5,
            '2026-06-23',
            'ORDINARIA',
            1,
            99,
            'Entrega inicial',
            'REGISTRADA',
            'Evidencia entrega',
            null,
            'https://example.com/evidencia.jpg',
            null,
            null,
            null,
        );
        $repository->addDeliveryDetail($deliveryId, 41, 1, 3, 2, 'Camisas institucionales');

        $this->assertSame(7, $deliveryId);
    }

    public function test_list_methods_call_expected_stored_procedures(): void
    {
        DB::shouldReceive('select')
            ->once()
            ->with('CALL SP_BBF_DOTACION_EMPLEADOS_LISTAR(?,?,?)', ['Ana', 1, 2])
            ->andReturn([]);

        DB::shouldReceive('select')
            ->once()
            ->with('CALL SP_BBF_DOTACION_TALLAS_EMPLEADO_LISTAR(?)', [5])
            ->andReturn([]);

        DB::shouldReceive('select')
            ->once()
            ->with('CALL SP_BBF_DOTACION_ENTREGAS_LISTAR(?,?,?)', [5, '2026-06-01', '2026-06-23'])
            ->andReturn([]);

        DB::shouldReceive('select')
            ->once()
            ->with('CALL SP_BBF_DOTACION_ENTREGA_DETALLE_LISTAR(?)', [7])
            ->andReturn([]);

        $repository = app(DotationRepository::class);
        $repository->employees('Ana', 1, 2);
        $repository->employeeSizes(5);
        $repository->deliveries(5, '2026-06-01', '2026-06-23');
        $repository->deliveryDetails(7);
    }

    public function test_quotation_report_calls_stored_procedure_with_optional_filters(): void
    {
        DB::shouldReceive('select')
            ->once()
            ->with('CALL SP_BBF_DOTACION_COTIZACION_LISTAR(?,?,?)', [5, 9, 12])
            ->andReturn([(object) ['ID_EMPLEADO' => 12]]);

        $rows = app(DotationRepository::class)->quotationReport(5, 9, 12);

        $this->assertSame(12, $rows[0]['id_empleado']);
    }

    public function test_purchase_quotation_and_prepare_call_new_procedures_in_exact_order(): void
    {
        DB::shouldReceive('select')->once()
            ->with('CALL SP_BBF_DOTACION_COTIZACION_POR_COMPRAR_LISTAR(?,?,?)', [5, 9, 12])
            ->andReturn([(object) ['ID_DOTACION_ENTREGA' => 31]]);
        DB::shouldReceive('select')->once()
            ->with('CALL SP_BBF_DOTACION_POR_COMPRAR_PREPARAR_ENTREGA(?,?,?,?,?,?,?,?,?)', [
                31, '2026-08-12', 99, null, null, 'https://example.com/evidence.jpg', null, null, null,
            ])->andReturn([(object) ['ID_DOTACION_ENTREGA' => 31, 'ESTADO' => 'REGISTRADA']]);

        $repository = app(DotationRepository::class);
        $this->assertSame(31, $repository->purchaseQuotationReport(5, 9, 12)[0]['id_dotacion_entrega']);
        $this->assertSame('REGISTRADA', $repository->prepareDelivery(
            31, '2026-08-12', 99, null, null, 'https://example.com/evidence.jpg', null, null, null,
        )['estado']);
    }
}
