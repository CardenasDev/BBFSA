<?php

namespace App\Http\Controllers\Api;

use App\Services\CertificateService;
use App\Services\CesantiasTerminationService;
use App\Services\CesantiasWithdrawalService;
use App\Services\ResignationAcceptanceService;
use App\Services\RetirementCertificateService;
use App\Services\RetirementChecklistService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class CertificateController extends ApiController
{
    public function __construct(
        private CertificateService $service,
        private RetirementCertificateService $retirementService,
        private RetirementChecklistService $checklistService,
        private ResignationAcceptanceService $acceptanceService,
        private CesantiasWithdrawalService $cesantiasService,
        private CesantiasTerminationService $cesantiasTerminationService,
    ) {}

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
            'variante' => ['sometimes', 'required', 'string', 'in:GENERAL,SALARIO_AFILIACIONES,HISTORIAL_CONTRACTUAL'],
            'fecha_inicio_labores' => ['exclude_unless:variante,HISTORIAL_CONTRACTUAL', 'required', 'date_format:Y-m-d'],
            'fondo_solidaridad' => ['exclude_unless:variante,SALARIO_AFILIACIONES', 'required', 'string', 'max:200', 'not_regex:/[<>\r\n\x00-\x1F\x7F]/u'],
            'retencion_fuente' => ['exclude_unless:variante,SALARIO_AFILIACIONES', 'required', 'string', 'max:200', 'not_regex:/[<>\r\n\x00-\x1F\x7F]/u']];
    }

    private function requirePostForSalary(Request $request): void
    {
        if ($request->input('variante') === 'SALARIO_AFILIACIONES' && ! $request->isMethod('POST')) {
            throw \Illuminate\Validation\ValidationException::withMessages(['variante' => ['Para esta variante envíe los datos en el cuerpo JSON mediante POST.']]);
        }
    }

    public function retirementAvailable(int $employeeId): JsonResponse
    {
        return $this->success($this->retirementService->available($employeeId), 'Certificados de retiro disponibles consultados correctamente.');
    }

    public function retirementGenerationData(Request $request, int $employeeId): JsonResponse
    {
        $data = $request->validate($this->retirementRules(), [
            'id_retiro.required' => 'Indique el retiro del empleado.',
            'id_retiro.integer' => 'El retiro debe ser un número entero.',
            'id_retiro.min' => 'El retiro debe ser mayor que cero.',
            '*.required' => 'Complete fondo de solidaridad, retención en la fuente y auxilio de transporte.',
            '*.string' => 'El campo debe ser un texto.',
            '*.max' => 'El texto debe tener hasta 200 caracteres.',
            '*.not_regex' => 'El texto no debe contener HTML ni saltos de línea.',
        ]);
        return $this->success($this->retirementService->generationData($employeeId, (int) $data['id_retiro'], $data),
            'Datos del certificado de retiro consultados correctamente.');
    }

    public function retirementDownload(Request $request, int $employeeId): Response
    {
        $data = $request->validate($this->retirementRules(), [
            'id_retiro.required' => 'Indique el retiro del empleado.',
            'id_retiro.integer' => 'El retiro debe ser un número entero.',
            'id_retiro.min' => 'El retiro debe ser mayor que cero.',
            '*.required' => 'Complete fondo de solidaridad, retención en la fuente y auxilio de transporte.',
            '*.string' => 'El campo debe ser un texto.',
            '*.max' => 'El texto debe tener hasta 200 caracteres.',
            '*.not_regex' => 'El texto no debe contener HTML ni saltos de línea.',
        ]);
        $content = $this->retirementService->generateDocument($employeeId, (int) $data['id_retiro'], $data);

        return response($content, 200, [
            'Content-Type' => 'application/pdf',
            'Content-Disposition' => 'attachment; filename="BBTH-F-003-CERTIFICADO-LABORAL-RETIRO.pdf"',
            'Cache-Control' => 'no-store, private',
            'Pragma' => 'no-cache',
            'Expires' => '0',
        ]);
    }

    private function retirementRules(): array
    {
        return [
            'id_retiro' => ['required', 'integer', 'min:1'],
            'fondo_solidaridad' => ['required', 'string', 'max:200', 'not_regex:/[<>\r\n\x00-\x1F\x7F]/u'],
            'retencion_fuente' => ['required', 'string', 'max:200', 'not_regex:/[<>\r\n\x00-\x1F\x7F]/u'],
            'auxilio_transporte' => ['required', 'string', 'max:200', 'not_regex:/[<>\r\n\x00-\x1F\x7F]/u'],
        ];
    }

    public function checklistAvailable(int $employeeId): JsonResponse
    {
        return $this->success($this->checklistService->available($employeeId), 'Documentos de paz y salvo consultados correctamente.');
    }

    public function checklistGenerationData(Request $request, int $employeeId): JsonResponse
    {
        $data = $request->validate(['id_retiro' => ['required', 'integer', 'min:1']], [
            'id_retiro.required' => 'Indique el retiro del empleado.',
            'id_retiro.integer' => 'El retiro debe ser un número entero.',
            'id_retiro.min' => 'El retiro debe ser mayor que cero.',
        ]);
        return $this->success($this->checklistService->generationData($employeeId, (int) $data['id_retiro']),
            'Datos del checklist de retiro consultados correctamente.');
    }

    public function checklistDownload(Request $request, int $employeeId): Response
    {
        $data = $request->validate(['id_retiro' => ['required', 'integer', 'min:1']], [
            'id_retiro.required' => 'Indique el retiro del empleado.',
            'id_retiro.integer' => 'El retiro debe ser un número entero.',
            'id_retiro.min' => 'El retiro debe ser mayor que cero.',
        ]);
        $content = $this->checklistService->generateDocument($employeeId, (int) $data['id_retiro']);

        return response($content, 200, [
            'Content-Type' => 'application/pdf',
            'Content-Disposition' => 'attachment; filename="BBTH-F-004-PAZ-Y-SALVO-ENTREGA-RETIRO.pdf"',
            'Cache-Control' => 'no-store, private',
            'Pragma' => 'no-cache',
            'Expires' => '0',
        ]);
    }

    public function acceptanceAvailable(int $employeeId): JsonResponse
    {
        return $this->success($this->acceptanceService->available($employeeId), 'Cartas de aceptación de renuncia consultadas correctamente.');
    }

    public function acceptanceGenerationData(Request $request, int $employeeId): JsonResponse
    {
        $data = $request->validate($this->acceptanceRules(), [
            'id_retiro.required' => 'Indique el retiro del empleado.',
            'id_retiro.integer' => 'El retiro debe ser un número entero.',
            'id_retiro.min' => 'El retiro debe ser mayor que cero.',
            'fecha_presentacion_renuncia.required' => 'Indique la fecha de presentación de la renuncia.',
            'fecha_presentacion_renuncia.date_format' => 'La fecha de presentación debe tener formato YYYY-MM-DD.',
        ]);
        return $this->success($this->acceptanceService->generationData($employeeId, (int) $data['id_retiro'], $data),
            'Datos de la carta de aceptación consultados correctamente.');
    }

    public function acceptanceDownload(Request $request, int $employeeId): Response
    {
        $data = $request->validate($this->acceptanceRules(), [
            'id_retiro.required' => 'Indique el retiro del empleado.',
            'id_retiro.integer' => 'El retiro debe ser un número entero.',
            'id_retiro.min' => 'El retiro debe ser mayor que cero.',
            'fecha_presentacion_renuncia.required' => 'Indique la fecha de presentación de la renuncia.',
            'fecha_presentacion_renuncia.date_format' => 'La fecha de presentación debe tener formato YYYY-MM-DD.',
        ]);
        $content = $this->acceptanceService->generateDocument($employeeId, (int) $data['id_retiro'], $data);

        return response($content, 200, [
            'Content-Type' => 'application/pdf',
            'Content-Disposition' => 'attachment; filename="BBTH-F-005-CARTA-ACEPTACION-RENUNCIA.pdf"',
            'Cache-Control' => 'no-store, private',
            'Pragma' => 'no-cache',
            'Expires' => '0',
        ]);
    }

    private function acceptanceRules(): array
    {
        return [
            'id_retiro' => ['required', 'integer', 'min:1'],
            'fecha_presentacion_renuncia' => ['required', 'date_format:Y-m-d'],
        ];
    }

    public function cesantiasAvailable(int $employeeId): JsonResponse
    {
        return $this->success($this->cesantiasService->available($employeeId), 'Cartas de retiro de cesantías consultadas correctamente.');
    }

    public function cesantiasGenerationData(Request $request, int $employeeId): JsonResponse
    {
        $data = $request->validate($this->cesantiasRules(), [
            'modalidad.required' => 'Indique la modalidad del retiro.',
            'modalidad.in' => 'La modalidad debe ser TOTAL o PARCIAL.',
            'concepto_retiro.required' => 'Indique el concepto del retiro.',
            'concepto_retiro.string' => 'El concepto debe ser un texto.',
            'concepto_retiro.max' => 'El concepto debe tener hasta 200 caracteres.',
            'concepto_retiro.not_regex' => 'El concepto no debe contener HTML ni saltos de línea.',
            'monto_retiro.required' => 'Indique el monto a retirar.',
            'monto_retiro.regex' => 'El monto debe ser un valor decimal mayor que cero, con hasta dos decimales.',
        ]);
        return $this->success($this->cesantiasService->generationData($employeeId, $data),
            'Datos de la carta de retiro de cesantías consultados correctamente.');
    }

    public function cesantiasDownload(Request $request, int $employeeId): Response
    {
        $data = $request->validate($this->cesantiasRules(), [
            'modalidad.required' => 'Indique la modalidad del retiro.',
            'modalidad.in' => 'La modalidad debe ser TOTAL o PARCIAL.',
            'concepto_retiro.required' => 'Indique el concepto del retiro.',
            'concepto_retiro.string' => 'El concepto debe ser un texto.',
            'concepto_retiro.max' => 'El concepto debe tener hasta 200 caracteres.',
            'concepto_retiro.not_regex' => 'El concepto no debe contener HTML ni saltos de línea.',
            'monto_retiro.required' => 'Indique el monto a retirar.',
            'monto_retiro.regex' => 'El monto debe ser un valor decimal mayor que cero, con hasta dos decimales.',
        ]);
        $content = $this->cesantiasService->generateDocument($employeeId, $data);

        return response($content, 200, [
            'Content-Type' => 'application/pdf',
            'Content-Disposition' => 'attachment; filename="BBTH-F-011-CARTA-RETIRO-CESANTIAS-VIVIENDA.pdf"',
            'Cache-Control' => 'no-store, private',
            'Pragma' => 'no-cache',
            'Expires' => '0',
        ]);
    }

    private function cesantiasRules(): array
    {
        return [
            'modalidad' => ['required', 'string', 'in:TOTAL,PARCIAL'],
            'concepto_retiro' => ['required', 'string', 'max:200', 'not_regex:/[<>\r\n\x00-\x1F\x7F]/u'],
            'monto_retiro' => ['required', 'regex:/^\d{1,10}(\.\d{1,2})?$/'],
        ];
    }

    public function cesantiasTerminationAvailable(int $employeeId): JsonResponse
    {
        return $this->success($this->cesantiasTerminationService->available($employeeId), 'Cartas de retiro de cesantías por finalización consultadas correctamente.');
    }

    public function cesantiasTerminationGenerationData(Request $request, int $employeeId): JsonResponse
    {
        $data = $request->validate($this->cesantiasTerminationRules(), [
            'fecha_desde.required' => 'Indique la fecha inicial del periodo.',
            'fecha_desde.date_format' => 'La fecha inicial debe tener formato YYYY-MM-DD.',
            'fecha_hasta.required' => 'Indique la fecha final del periodo.',
            'fecha_hasta.date_format' => 'La fecha final debe tener formato YYYY-MM-DD.',
            'nit_empresa.required' => 'Indique el NIT de la empresa.',
            'nit_empresa.regex' => 'El NIT debe tener formato de dígitos y dígito de verificación.',
            'correo_contacto.required' => 'Indique el correo de contacto.',
            'correo_contacto.email' => 'El correo de contacto debe ser válido.',
            'telefono_contacto.required' => 'Indique el teléfono de contacto.',
            'telefono_contacto.regex' => 'El teléfono debe tener entre 6 y 30 caracteres válidos.',
        ]);
        return $this->success($this->cesantiasTerminationService->generationData($employeeId, $data),
            'Datos de la carta de retiro de cesantías por finalización consultados correctamente.');
    }

    public function cesantiasTerminationDownload(Request $request, int $employeeId): Response
    {
        $data = $request->validate($this->cesantiasTerminationRules(), [
            'fecha_desde.required' => 'Indique la fecha inicial del periodo.',
            'fecha_desde.date_format' => 'La fecha inicial debe tener formato YYYY-MM-DD.',
            'fecha_hasta.required' => 'Indique la fecha final del periodo.',
            'fecha_hasta.date_format' => 'La fecha final debe tener formato YYYY-MM-DD.',
            'nit_empresa.required' => 'Indique el NIT de la empresa.',
            'nit_empresa.regex' => 'El NIT debe tener formato de dígitos y dígito de verificación.',
            'correo_contacto.required' => 'Indique el correo de contacto.',
            'correo_contacto.email' => 'El correo de contacto debe ser válido.',
            'telefono_contacto.required' => 'Indique el teléfono de contacto.',
            'telefono_contacto.regex' => 'El teléfono debe tener entre 6 y 30 caracteres válidos.',
        ]);
        $content = $this->cesantiasTerminationService->generateDocument($employeeId, $data);

        return response($content, 200, [
            'Content-Type' => 'application/pdf',
            'Content-Disposition' => 'attachment; filename="BBTH-F-012-CARTA-RETIRO-CESANTIAS-FIN-CONTRATO.pdf"',
            'Cache-Control' => 'no-store, private',
            'Pragma' => 'no-cache',
            'Expires' => '0',
        ]);
    }

    private function cesantiasTerminationRules(): array
    {
        return [
            'fecha_desde' => ['required', 'date_format:Y-m-d'],
            'fecha_hasta' => ['required', 'date_format:Y-m-d'],
            'nit_empresa' => ['required', 'string', 'max:20', 'regex:/^\d{5,12}-\d$/'],
            'correo_contacto' => ['required', 'email:rfc', 'max:150'],
            'telefono_contacto' => ['required', 'string', 'max:30', 'regex:/^[\d\s\-+]{6,30}$/'],
        ];
    }
}
