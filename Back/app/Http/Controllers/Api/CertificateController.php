<?php

namespace App\Http\Controllers\Api;

use App\Services\CertificateService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class CertificateController extends ApiController
{
    public function __construct(private CertificateService $service) {}

    public function index(int $employeeId): JsonResponse
    {
        return $this->success($this->service->available($employeeId), 'Certificados disponibles consultados correctamente.');
    }

    public function generationData(Request $request, int $employeeId, string $formatKey): JsonResponse
    {
        $data = $request->validate(['id_empleado_contrato' => ['required', 'integer', 'min:1']], [
            'id_empleado_contrato.required' => 'Indique el contrato del empleado.',
            'id_empleado_contrato.integer' => 'El contrato debe ser un número entero.',
            'id_empleado_contrato.min' => 'El contrato debe ser mayor que cero.',
        ]);
        return $this->success($this->service->generationData($employeeId, $formatKey, (int) $data['id_empleado_contrato']),
            'Datos del certificado consultados correctamente.');
    }

    public function download(Request $request, int $employeeId, string $formatKey): Response
    {
        $data = $request->validate(['id_empleado_contrato' => ['required', 'integer', 'min:1']], [
            'id_empleado_contrato.required' => 'Indique el contrato del empleado.',
            'id_empleado_contrato.integer' => 'El contrato debe ser un número entero.',
            'id_empleado_contrato.min' => 'El contrato debe ser mayor que cero.',
        ]);
        $content = $this->service->generateDocument($employeeId, $formatKey, (int) $data['id_empleado_contrato']);

        return response($content, 200, [
            'Content-Type' => 'application/pdf',
            'Content-Disposition' => 'attachment; filename="BBTH-F-002-CERTIFICADO-LABORAL.pdf"',
            'Cache-Control' => 'no-store, private',
            'Pragma' => 'no-cache',
            'Expires' => '0',
        ]);
    }
}
