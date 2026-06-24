<?php

namespace Tests\Unit;

use App\Repositories\EmployeeRepository;
use Illuminate\Support\Facades\DB;
use Tests\TestCase;

class EmployeeRepositoryTest extends TestCase
{
    public function test_create_sends_photo_url_to_stored_procedure_in_expected_position(): void
    {
        DB::shouldReceive('select')
            ->once()
            ->with('CALL SP_BBF_EMPLEADOS_CREAR(?,?,?,?,?,?,?,?,?,?,?,?,?,?)', [
                1,
                '123456789',
                'Juan',
                'Barco',
                'jc@email.com',
                '3194400951',
                '/uploads/employees/empleado_123456789.jpg',
                2,
                3,
                4,
                '2026-06-01',
                null,
                'ACTIVO',
                'Empleado test',
            ])
            ->andReturn([(object) ['ID_EMPLEADO' => 10]]);

        $employeeId = app(EmployeeRepository::class)->create($this->employeePayload());

        $this->assertSame(10, $employeeId);
    }

    public function test_update_sends_photo_url_to_stored_procedure_in_expected_position(): void
    {
        DB::shouldReceive('select')
            ->once()
            ->with('CALL SP_BBF_EMPLEADOS_ACTUALIZAR(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)', [
                10,
                1,
                '123456789',
                'Juan',
                'Barco',
                'jc@email.com',
                '3194400951',
                '/uploads/employees/empleado_123456789.jpg',
                2,
                3,
                4,
                '2026-06-01',
                null,
                'ACTIVO',
                'Empleado test',
            ])
            ->andReturn([(object) ['FILAS_AFECTADAS' => 1]]);

        $affected = app(EmployeeRepository::class)->update(10, $this->employeePayload());

        $this->assertSame(1, $affected);
    }

    public function test_list_maps_photo_url_from_stored_procedure_response(): void
    {
        DB::shouldReceive('select')
            ->once()
            ->with('CALL SP_BBF_EMPLEADOS_LISTAR(?,?,?,?)', ['ACTIVO', null, null, null])
            ->andReturn([$this->employeeRow()]);

        $employees = app(EmployeeRepository::class)->list('ACTIVO', null, null, null);

        $this->assertSame('/uploads/employees/empleado_123456789.jpg', $employees[0]['foto_url']);
    }

    public function test_find_maps_photo_url_from_stored_procedure_response(): void
    {
        DB::shouldReceive('select')
            ->once()
            ->with('CALL SP_BBF_EMPLEADOS_OBTENER_POR_ID(?)', [10])
            ->andReturn([$this->employeeRow()]);

        $employee = app(EmployeeRepository::class)->find(10);

        $this->assertSame('/uploads/employees/empleado_123456789.jpg', $employee['foto_url']);
    }

    public function test_find_by_document_maps_photo_url_from_stored_procedure_response(): void
    {
        DB::shouldReceive('select')
            ->once()
            ->with('CALL SP_BBF_EMPLEADOS_OBTENER_POR_DOCUMENTO(?)', ['123456789'])
            ->andReturn([$this->employeeRow()]);

        $employee = app(EmployeeRepository::class)->findByDocument('123456789');

        $this->assertSame('/uploads/employees/empleado_123456789.jpg', $employee['foto_url']);
    }

    private function employeePayload(): array
    {
        return [
            'id_tipo_documento' => 1,
            'numero_documento' => '123456789',
            'nombres' => 'Juan',
            'apellidos' => 'Barco',
            'correo' => 'jc@email.com',
            'telefono' => '3194400951',
            'foto_url' => '/uploads/employees/empleado_123456789.jpg',
            'id_area' => 2,
            'id_cargo' => 3,
            'id_tipo_contrato' => 4,
            'fecha_ingreso' => '2026-06-01',
            'fecha_retiro' => null,
            'estado_empleado' => 'ACTIVO',
            'observaciones' => 'Empleado test',
        ];
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
            'FOTO_URL' => '/uploads/employees/empleado_123456789.jpg',
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
