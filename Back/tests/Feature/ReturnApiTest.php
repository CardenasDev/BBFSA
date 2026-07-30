<?php

namespace Tests\Feature;

use App\Repositories\ReturnRepository;
use App\Services\AuditService;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\File;
use Mockery;
use RuntimeException;
use Tests\TestCase;

class ReturnApiTest extends TestCase
{
    private function jwt(array $permissions): string
    {
        return app('App\Services\JwtService')->encode([
            'id_usuario' => 99,
            'id_sesion' => 1,
            'correo' => 'admin@example.com',
            'permisos' => $permissions,
        ])['token'];
    }

    public function test_available_groups_positive_balances_by_delivery(): void
    {
        $repository = Mockery::mock(ReturnRepository::class);
        $repository->shouldReceive('available')->once()->with('DOTACION', 8)->andReturn([
            ['tipo_devolucion' => 'DOTACION', 'id_entrega' => 10, 'id_detalle' => 1, 'id_empleado' => 8, 'fecha_entrega' => '2026-07-01', 'elemento' => 'Camisa', 'talla' => 'M', 'cantidad_disponible' => 2],
            ['tipo_devolucion' => 'DOTACION', 'id_entrega' => 10, 'id_detalle' => 2, 'id_empleado' => 8, 'fecha_entrega' => '2026-07-01', 'elemento' => 'Pantalón', 'talla' => '32', 'cantidad_disponible' => 0],
        ]);
        $this->app->instance(ReturnRepository::class, $repository);

        $this->withToken($this->jwt(['DEVOLUCIONES_CREAR']))
            ->getJson('/api/returns/available?type=dotacion&employee_id=8')
            ->assertOk()
            ->assertJsonPath('data.0.id_entrega', 10)
            ->assertJsonCount(1, 'data.0.items');
    }

    public function test_store_rejects_missing_evidence_and_duplicate_detail(): void
    {
        $payload = [
            'type' => 'DOTACION',
            'employee_id' => 8,
            'delivery_id' => 10,
            'return_date' => '2026-07-20',
            'reason' => 'Cambio',
            'details' => json_encode([
                ['id_detalle' => 1, 'cantidad' => 1, 'estado_elemento' => 'BUENO'],
                ['id_detalle' => 1, 'cantidad' => 1, 'estado_elemento' => 'USADO'],
            ]),
        ];

        $this->withToken($this->jwt(['DEVOLUCIONES_CREAR']))
            ->postJson('/api/returns', $payload)
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['evidence', 'details.0.id_detalle']);
    }

    public function test_tool_return_rejects_document_without_photo(): void
    {
        $repository = Mockery::mock(ReturnRepository::class);
        $repository->shouldNotReceive('create');
        $this->app->instance(ReturnRepository::class, $repository);

        $this->withToken($this->jwt(['DEVOLUCIONES_CREAR']))
            ->post('/api/returns', [
                'type' => 'HERRAMIENTA',
                'employee_id' => 8,
                'delivery_id' => 10,
                'return_date' => '2026-07-20',
                'reason' => 'Fin de uso',
                'details' => json_encode([
                    ['id_detalle' => 1, 'cantidad' => 1, 'estado_elemento' => 'BUENO'],
                ]),
                'evidence' => [UploadedFile::fake()->createWithContent('acta.pdf', "%PDF-1.4\n")],
            ], ['Authorization' => 'Bearer '.$this->jwt(['DEVOLUCIONES_CREAR'])])
            ->assertUnprocessable()
            ->assertJsonPath('message', 'Las devoluciones de herramientas requieren al menos una fotografía válida.');
    }

    public function test_tool_return_accepts_real_photo_and_keeps_it_after_success(): void
    {
        $storedPath = null;
        $repository = Mockery::mock(ReturnRepository::class);
        $repository->shouldReceive('create')->once()->withArgs(function (array $data, int $actor, array $details, array $evidence) use (&$storedPath): bool {
            $storedPath = $evidence[0]['archivo_ruta'];

            return $data['type'] === 'HERRAMIENTA'
                && $actor === 99
                && $evidence[0]['tipo_evidencia'] === 'FOTO'
                && $evidence[0]['mime_type'] === 'image/png';
        })->andReturn(['id_devolucion' => 44, 'estado' => 'REGISTRADA']);
        $this->app->instance(ReturnRepository::class, $repository);
        $audit = Mockery::mock(AuditService::class);
        $audit->shouldReceive('record')->once();
        $this->app->instance(AuditService::class, $audit);

        try {
            $this->withToken($this->jwt(['DEVOLUCIONES_CREAR']))
                ->post('/api/returns', $this->validPayload([
                    'evidence' => [$this->png('herramienta.png')],
                ]), ['Authorization' => 'Bearer '.$this->jwt(['DEVOLUCIONES_CREAR'])])
                ->assertCreated()
                ->assertJsonPath('data.id_devolucion', 44);

            $this->assertNotNull($storedPath);
            $this->assertFileExists(public_path($storedPath));
        } finally {
            if ($storedPath) {
                File::delete(public_path($storedPath));
            }
        }
    }

    public function test_store_deletes_new_files_when_procedure_fails(): void
    {
        $storedPath = null;
        $repository = Mockery::mock(ReturnRepository::class);
        $repository->shouldReceive('create')->once()->withArgs(function (array $data, int $actor, array $details, array $evidence) use (&$storedPath): bool {
            $storedPath = $evidence[0]['archivo_ruta'];

            return true;
        })->andThrow(new RuntimeException('Fallo simulado del SP'));
        $this->app->instance(ReturnRepository::class, $repository);

        $this->withToken($this->jwt(['DEVOLUCIONES_CREAR']))
            ->post('/api/returns', $this->validPayload([
                'evidence' => [$this->png('herramienta.png')],
            ]), ['Authorization' => 'Bearer '.$this->jwt(['DEVOLUCIONES_CREAR'])])
            ->assertInternalServerError();

        $this->assertNotNull($storedPath);
        $this->assertFileDoesNotExist(public_path($storedPath));
    }

    public function test_routes_enforce_operation_permission(): void
    {
        $this->withToken($this->jwt(['DEVOLUCIONES_VER']))
            ->getJson('/api/returns/available?type=DOTACION&employee_id=8')
            ->assertForbidden();
    }

    private function validPayload(array $overrides = []): array
    {
        return array_replace([
            'type' => 'HERRAMIENTA',
            'employee_id' => 8,
            'delivery_id' => 10,
            'return_date' => '2026-07-20',
            'reason' => 'Fin de uso',
            'details' => json_encode([
                ['id_detalle' => 1, 'cantidad' => 1, 'estado_elemento' => 'BUENO'],
            ]),
        ], $overrides);
    }

    private function png(string $name): UploadedFile
    {
        return UploadedFile::fake()->createWithContent($name, base64_decode(
            'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
        ));
    }
}
