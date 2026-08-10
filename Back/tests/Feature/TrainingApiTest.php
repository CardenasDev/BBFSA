<?php

namespace Tests\Feature;

use App\Services\JwtService;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Tests\TestCase;

class TrainingApiTest extends TestCase
{
    public function test_tasks_are_read_from_stored_procedure_and_normalized(): void
    {
        DB::shouldReceive('select')->once()->with('CALL SP_BBF_CAPACITACION_LABORES_LISTAR(?)', [0])->andReturn([(object) ['ID_CAPACITACION_LABOR' => 1, 'CODIGO' => 'DESBOTONE', 'NOMBRE' => 'Desbotone', 'ACTIVO' => 1]]);
        $this->withToken($this->token(['CAPACITACIONES_VER']))->getJson('/api/trainings/tasks')->assertOk()->assertJsonPath('data.0.codigo', 'DESBOTONE')->assertJsonPath('data.0.activo', true);
    }

    public function test_employee_confirmation_requires_employee_permission(): void
    {
        $this->withToken($this->token([]))->postJson('/api/trainings/participants/8/confirm', [])->assertForbidden();
    }

    public function test_hr_confirmation_reuses_administration_permission(): void
    {
        $this->withToken($this->token([]))->postJson('/api/trainings/participants/8/confirm-by-hr', [])->assertForbidden();
    }

    public function test_evaluation_validates_daily_value(): void
    {
        $this->withToken($this->token(['CAPACITACIONES_EVALUAR']))->postJson('/api/trainings/evaluations', ['id_capacitacion_participante' => 1, 'id_capacitacion_labor' => 1, 'fecha_evaluacion' => '2026-08-03', 'valor_obtenido' => -1])->assertUnprocessable()->assertJsonValidationErrors(['valor_obtenido']);
    }

    public function test_import_accepts_only_xlsx(): void
    {
        $this->withToken($this->token(['CAPACITACIONES_IMPORTAR']))->post('/api/trainings/sessions/1/import', ['archivo' => UploadedFile::fake()->create('matrix.csv', 10, 'text/csv')], ['Accept' => 'application/json'])->assertUnprocessable()->assertJsonValidationErrors(['archivo']);
    }

    public function test_commitment_generation_data_is_read_from_stored_procedure(): void
    {
        DB::shouldReceive('select')->once()->with('CALL SP_BBF_CAPACITACION_COMPROMISO_OBTENER(?)', [7])->andReturn([(object) [
            'ID_CAPACITACION_COMPROMISO' => 7,
            'EMPLEADO' => 'Angie Villarra',
            'CARGO' => 'Operario',
            'RESULTADO' => 'NO_APROBADO',
        ]]);

        $this->withToken($this->token(['CAPACITACIONES_COMPROMISOS']))
            ->getJson('/api/trainings/commitments/7')
            ->assertOk()
            ->assertJsonPath('data.id_capacitacion_compromiso', 7)
            ->assertJsonPath('data.empleado', 'Angie Villarra');
    }

    private function token(array $permissions): string
    {
        return app(JwtService::class)->encode(['id_usuario' => 99, 'id_sesion' => 1, 'correo' => 'rrhh@example.com', 'nombre_usuario' => 'rrhh', 'tipo_usuario' => 'ADMIN', 'roles' => [], 'permisos' => $permissions])['token'];
    }
}
