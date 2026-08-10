<?php

namespace Tests\Unit;

use App\Repositories\TrainingRepository;
use App\Services\AuditService;
use App\Services\TrainingService;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\File;
use Mockery;
use OpenSpout\Common\Entity\Row;
use OpenSpout\Writer\XLSX\Writer;
use Tests\TestCase;

class TrainingImportServiceTest extends TestCase
{
    protected function tearDown(): void
    {
        File::deleteDirectory(public_path('uploads/trainings/'.now()->format('Ym')));
        Mockery::close();
        parent::tearDown();
    }

    public function test_weekly_matrix_is_applied_only_to_an_exact_session_participant(): void
    {
        $path = tempnam(sys_get_temp_dir(), 'training_matrix_');
        $writer = new Writer;
        $writer->openToFile($path);
        $writer->addRow(Row::fromValues(['', '', 'ROSAURA']));
        $writer->addRow(Row::fromValues(['CODIGO EMPLEADO', '', 'lu', 'ma', 'mi', 'ju', 'vi']));
        $writer->addRow(Row::fromValues(['Desbotone', '', 50, null, null, null, null]));
        $writer->addRow(Row::fromValues(['TOTALES']));
        $writer->close();

        $repository = Mockery::mock(TrainingRepository::class);
        $audit = Mockery::mock(AuditService::class);
        $repository->shouldReceive('createImport')->once()->andReturn(['id_capacitacion_importacion' => 21]);
        $repository->shouldReceive('sessionDetail')->once()->with(4)->andReturn(['session' => ['id_capacitacion' => 1, 'fecha_inicio' => '2026-08-03'], 'participants' => [['id_capacitacion_participante' => 9, 'empleado' => 'Rosaura']], 'evaluations' => []]);
        $repository->shouldReceive('attachedTasks')->once()->with(1, false)->andReturn([['id_capacitacion_labor' => 1, 'nombre' => 'Desbotone', 'activo' => 1]]);
        $repository->shouldReceive('evaluation')->once()->with(Mockery::on(fn (array $row): bool => $row['id_capacitacion_participante'] === 9 && $row['fecha_evaluacion'] === '2026-08-03' && $row['valor_obtenido'] === 50.0), 99, 'EXCEL', 21)->andReturn(['id_capacitacion_evaluacion' => 1]);
        $repository->shouldReceive('finishImport')->once()->with(21, 'IMPORTADA', 1, 1, Mockery::type('string'))->andReturn(['id_capacitacion_importacion' => 21, 'estado' => 'IMPORTADA']);
        $audit->shouldReceive('record')->once();

        $result = (new TrainingService($repository, $audit))->importMatrix(4, new UploadedFile($path, 'semana-32.xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', null, true), 99, []);
        self::assertSame(1, $result['aplicados']);
    }
}
