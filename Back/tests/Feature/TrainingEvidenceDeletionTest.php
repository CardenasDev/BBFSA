<?php

namespace Tests\Feature;

use App\Services\JwtService;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\File;
use Tests\TestCase;

class TrainingEvidenceDeletionTest extends TestCase
{
    private string $testPublic;
    private string $originalPublic;

    public function createApplication()
    {
        // Keep requests independent of the developer's hosting URL and caches.
        $overrides = [
            'APP_URL' => 'http://localhost',
            'APP_CONFIG_CACHE' => sys_get_temp_dir().'/bbf-evidence-no-config.php',
            'APP_ROUTES_CACHE' => sys_get_temp_dir().'/bbf-evidence-no-routes.php',
        ];
        $previous = [];
        foreach ($overrides as $key => $value) {
            $previous[$key] = [getenv($key), $_ENV[$key] ?? null, $_SERVER[$key] ?? null];
            putenv($key.'='.$value);
            $_ENV[$key] = $_SERVER[$key] = $value;
        }
        try {
            return parent::createApplication();
        } finally {
            foreach ($previous as $key => [$value, $env, $server]) {
                putenv($value === false ? $key : $key.'='.$value);
                if ($env === null) { unset($_ENV[$key]); } else { $_ENV[$key] = $env; }
                if ($server === null) { unset($_SERVER[$key]); } else { $_SERVER[$key] = $server; }
            }
        }
    }

    protected function setUp(): void
    {
        parent::setUp();
        config(['logging.default' => 'null']);
        $this->originalPublic = public_path();
        $this->testPublic = sys_get_temp_dir().'/bbf-evidence-delete-'.bin2hex(random_bytes(8));
        File::makeDirectory($this->testPublic, 0755, true);
        $this->app->usePublicPath($this->testPublic);
    }

    protected function tearDown(): void
    {
        $this->app->usePublicPath($this->originalPublic);
        (new \Illuminate\Filesystem\Filesystem)->deleteDirectory($this->testPublic);
        parent::tearDown();
    }

    public function test_png_file_is_removed_before_deletion_sp(): void
    {
        $this->assertFileDeletion('png');
    }

    public function test_pdf_file_is_removed_before_deletion_sp(): void
    {
        $this->assertFileDeletion('pdf');
    }

    private function assertFileDeletion(string $extension): void
    {
        $relative = 'uploads/trainings/evidences/test.'.$extension;
        File::ensureDirectoryExists(dirname(public_path($relative)));
        File::put(public_path($relative), 'isolated deletion fixture');
        $row = $this->row($relative);
        DB::shouldReceive('select')->once()->with('CALL SP_BBF_CAPACITACION_EVIDENCIA_OBTENER(?)', [9])->andReturn([$row]);
        DB::shouldReceive('select')->once()->with('CALL SP_BBF_CAPACITACION_EVIDENCIA_ELIMINAR(?)', [9])
            ->andReturnUsing(function () use ($relative, $row) {
                self::assertFileDoesNotExist(public_path($relative));
                return [(object) ['REGISTROS_ELIMINADOS' => 1]];
            });
        $this->deleteAsAdmin()->assertOk()->assertJsonPath('success', true);
        self::assertFileDoesNotExist(public_path($relative));
    }

    public function test_missing_physical_file_still_deletes_record(): void
    {
        $row = $this->row('uploads/trainings/evidences/missing.pdf');
        DB::shouldReceive('select')->once()->with('CALL SP_BBF_CAPACITACION_EVIDENCIA_OBTENER(?)', [9])->andReturn([$row]);
        DB::shouldReceive('select')->once()->with('CALL SP_BBF_CAPACITACION_EVIDENCIA_ELIMINAR(?)', [9])->andReturn([(object) ['REGISTROS_ELIMINADOS' => 1]]);
        $this->deleteAsAdmin()->assertOk();
    }

    public function test_unknown_evidence_returns_404_without_deleting(): void
    {
        DB::shouldReceive('select')->once()->with('CALL SP_BBF_CAPACITACION_EVIDENCIA_OBTENER(?)', [9])->andReturn([]);
        $this->deleteAsAdmin()->assertNotFound();
    }

    public function test_other_session_is_rejected_before_file_or_record_deletion(): void
    {
        $row = $this->row('other.pdf');
        $row->ID_CAPACITACION_SESION = 5;
        File::put(public_path('other.pdf'), 'must remain');
        DB::shouldReceive('select')->once()->with('CALL SP_BBF_CAPACITACION_EVIDENCIA_OBTENER(?)', [9])->andReturn([$row]);
        $this->deleteAsAdmin()->assertNotFound();
        self::assertFileExists(public_path('other.pdf'));
    }

    public function test_path_outside_public_is_rejected(): void
    {
        DB::shouldReceive('select')->once()->with('CALL SP_BBF_CAPACITACION_EVIDENCIA_OBTENER(?)', [9])->andReturn([$this->row('../outside.pdf')]);
        $this->deleteAsAdmin()->assertUnprocessable();
    }

    public function test_file_delete_failure_does_not_delete_database_record(): void
    {
        File::put(public_path('locked.pdf'), 'must remain');
        DB::shouldReceive('select')->once()->with('CALL SP_BBF_CAPACITACION_EVIDENCIA_OBTENER(?)', [9])->andReturn([$this->row('locked.pdf')]);
        File::partialMock()->shouldReceive('delete')->once()->with(public_path('locked.pdf'))->andReturn(false);
        $this->deleteAsAdmin()->assertUnprocessable();
        self::assertFileExists(public_path('locked.pdf'));
    }

    public function test_zero_deleted_rows_is_not_reported_as_success(): void
    {
        DB::shouldReceive('select')->once()->with('CALL SP_BBF_CAPACITACION_EVIDENCIA_OBTENER(?)', [9])->andReturn([$this->row('missing.pdf')]);
        DB::shouldReceive('select')->once()->with('CALL SP_BBF_CAPACITACION_EVIDENCIA_ELIMINAR(?)', [9])->andReturn([(object) ['REGISTROS_ELIMINADOS' => 0]]);
        $this->deleteAsAdmin()->assertUnprocessable();
    }

    public function test_delete_requires_existing_management_permission(): void
    {
        $token = app(JwtService::class)->encode(['id_usuario' => 99, 'permisos' => ['CAPACITACIONES_VER']])['token'];
        $this->withToken($token)->deleteJson('/api/trainings/sessions/4/evidences/9')->assertForbidden();
    }

    public function test_delete_requires_authentication(): void
    {
        $this->deleteJson('/api/trainings/sessions/4/evidences/9')->assertUnauthorized();
    }

    private function row(string $path): object
    {
        return (object) ['ID_CAPACITACION_EVIDENCIA' => 9, 'ID_CAPACITACION_SESION' => 4, 'ARCHIVO_RUTA' => $path];
    }

    private function deleteAsAdmin()
    {
        $token = app(JwtService::class)->encode(['id_usuario' => 99, 'permisos' => ['CAPACITACIONES_ADMINISTRAR']])['token'];
        return $this->withToken($token)->deleteJson('/api/trainings/sessions/4/evidences/9');
    }
}
