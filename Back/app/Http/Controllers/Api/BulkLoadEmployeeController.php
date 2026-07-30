<?php

namespace App\Http\Controllers\Api;

use App\Http\Requests\BulkLoadEmployeeFileRequest;
use App\Services\BulkLoadEmployeeService;
use Illuminate\Http\JsonResponse;
use Symfony\Component\HttpFoundation\BinaryFileResponse;

class BulkLoadEmployeeController extends ApiController
{
    public function __construct(private readonly BulkLoadEmployeeService $service) {}

    /**
     * Descargar plantilla oficial de carga masiva de empleados.
     */
    public function template(): BinaryFileResponse
    {
        $template = $this->service->template();

        return response()->download($template['path'], $template['filename'], [
            'Content-Type' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            'Cache-Control' => 'no-store, private',
        ])->deleteFileAfterSend(true);
    }

    /**
     * Validar un XLSX de empleados sin realizar escrituras.
     */
    public function validateFile(BulkLoadEmployeeFileRequest $request): JsonResponse
    {
        $result = $this->service->validate($request->file('file'));

        return $this->success($this->service->publicResult($result), 'Archivo validado.');
    }

    /**
     * Revalidar e importar atómicamente un XLSX de empleados.
     */
    public function import(BulkLoadEmployeeFileRequest $request): JsonResponse
    {
        $result = $this->service->import(
            $request->file('file'),
            $this->actorId($request),
            $this->context($request),
        );

        return $this->success($result, 'Carga masiva completada.', 201);
    }
}
