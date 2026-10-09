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
        $this->requirePostForSalary($request);
        $data = $request->validate($this->rules(), [
            'id_empleado_contrato.required' => 'Indique el contrato del empleado.',
            'id_empleado_contrato.integer' => 'El contrato debe ser un número entero.',
            'id_empleado_contrato.min' => 'El contrato debe ser mayor que cero.',
            'variante.in' => 'La variante solicitada no está soportada.',
            '*.required' => 'Complete fondo de solidaridad y retención en la fuente.',
            '*.string' => 'El campo debe ser un texto.',
            '*.max' => 'El texto debe tener hasta 200 caracteres.',
            '*.not_regex' => 'El texto no debe contener HTML ni saltos de línea.',
        ]);
        return $this->success($this->service->generationData($employeeId, $formatKey, (int) $data['id_empleado_contrato'], $data['variante'] ?? 'GENERAL', $data),
            'Datos del certificado consultados correctamente.');
    }

    public function download(Request $request, int $employeeId, string $formatKey): Response
    {
        $this->requirePostForSalary($request);
        $data = $request->validate($this->rules(), [
            'id_empleado_contrato.required' => 'Indique el contrato del empleado.',
            'id_empleado_contrato.integer' => 'El contrato debe ser un número entero.',
            'id_empleado_contrato.min' => 'El contrato debe ser mayor que cero.',
            'variante.in' => 'La variante solicitada no está soportada.',
            '*.required' => 'Complete fondo de solidaridad y retención en la fuente.',
            '*.string' => 'El campo debe ser un texto.',
            '*.max' => 'El texto debe tener hasta 200 caracteres.',
            '*.not_regex' => 'El texto no debe contener HTML ni saltos de línea.',
        ]);
        $content = $this->service->generateDocument($employeeId, $formatKey, (int) $data['id_empleado_contrato'], $data['variante'] ?? 'GENERAL', $data);

        return response($content, 200, [
            'Content-Type' => 'application/pdf',
            'Content-Disposition' => 'attachment; filename="BBTH-F-002-CERTIFICADO-LABORAL.pdf"',
            'Cache-Control' => 'no-store, private',
            'Pragma' => 'no-cache',
            'Expires' => '0',
        ]);
    }

    private function rules(): array
    {
        return ['id_empleado_contrato' => ['required', 'integer', 'min:1'],
            'variante' => ['sometimes', 'required', 'string', 'in:GENERAL,SALARIO_AFILIACIONES'],
            'fondo_solidaridad' => ['exclude_unless:variante,SALARIO_AFILIACIONES', 'required', 'string', 'max:200', 'not_regex:/[<>\r\n\x00-\x1F\x7F]/u'],
            'retencion_fuente' => ['exclude_unless:variante,SALARIO_AFILIACIONES', 'required', 'string', 'max:200', 'not_regex:/[<>\r\n\x00-\x1F\x7F]/u']];
    }

    private function requirePostForSalary(Request $request): void
    {
        if ($request->input('variante') === 'SALARIO_AFILIACIONES' && ! $request->isMethod('POST')) {
            throw \Illuminate\Validation\ValidationException::withMessages(['variante' => ['Para esta variante envíe los datos en el cuerpo JSON mediante POST.']]);
        }
    }
}
