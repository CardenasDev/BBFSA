<?php

namespace App\Http\Controllers\Api;

use App\Http\Requests\CreateEmployeeContractRequest;
use App\Http\Requests\CreateMedicalExamRequest;
use App\Http\Requests\GetContractTemplateByTypeRequest;
use App\Http\Requests\ListContractAlertsRequest;
use App\Http\Requests\ListContractTemplatesRequest;
use App\Http\Requests\RegisterEmployeeDocumentRequest;
use App\Http\Requests\SaveContractingProfileRequest;
use App\Http\Requests\SaveSocialSecurityRequest;
use App\Http\Requests\SignEmployeeContractRequest;
use App\Http\Resources\ContractGenerationDataResource;
use App\Services\ContractingService;
use Dedoc\Scramble\Attributes\Group;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

#[Group('Contracting', 'Gestion de contratacion y ficha de ingreso.', weight: 8)]
class ContractingController extends ApiController
{
    public function __construct(
        private readonly ContractingService $contracting,
    ) {}

    /**
     * Listar empleados de contratacion
     *
     * Permiso requerido: CONTRATACION_VER.
     */
    public function indexEmployees(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'texto_busqueda' => ['nullable', 'string', 'max:150'],
            'id_area' => ['nullable', 'integer'],
            'id_cargo' => ['nullable', 'integer'],
            'estado_empleado' => ['nullable', 'string', 'max:50'],
        ]);

        return $this->success(
            $this->contracting->listEmployees(
                $validated['texto_busqueda'] ?? null,
                isset($validated['id_area']) ? (int) $validated['id_area'] : null,
                isset($validated['id_cargo']) ? (int) $validated['id_cargo'] : null,
                $validated['estado_empleado'] ?? null,
            ),
            'Empleados de contratacion consultados correctamente',
        );
    }

    /**
     * Obtener ficha de ingreso
     *
     * Permiso requerido: CONTRATACION_VER.
     *
     * @response array{success: bool, message: string, data: array{id_empleado: int, estado_ficha: string|null, numero_carpeta: string|null, genero: string|null, fecha_expedicion_documento: string|null, fecha_nacimiento: string|null, lugar_nacimiento: string|null, nacionalidad: string|null, direccion_residencia: string|null, telefono_alterno: string|null, correo_personal: string|null, personas_vivienda: int|null, menores_estudian: int|null}}
     */
    public function getProfile(int $employeeId): JsonResponse
    {
        return $this->success(
            $this->contracting->getProfile($employeeId),
            'Ficha de contratacion consultada correctamente',
        );
    }

    /**
     * Listar plantillas de contrato
     *
     * Permiso requerido: CONTRATACION_VER.
     */
    public function listContractTemplates(ListContractTemplatesRequest $request): JsonResponse
    {
        return $this->success(
            $this->contracting->listContractTemplates($request->validated()),
            'Plantillas de contrato consultadas correctamente',
        );
    }

    /**
     * Obtener plantilla de contrato
     *
     * Permiso requerido: CONTRATACION_VER.
     */
    public function getContractTemplate(int $templateId): JsonResponse
    {
        return $this->success(
            $this->contracting->getContractTemplate($templateId),
            'Plantilla de contrato consultada correctamente',
        );
    }

    /**
     * Obtener plantilla sugerida por tipo de contrato
     *
     * Permiso requerido: CONTRATACION_VER.
     */
    public function getContractTemplateByType(GetContractTemplateByTypeRequest $request): JsonResponse
    {
        $validated = $request->validated();

        return $this->success(
            $this->contracting->getContractTemplateByType((int) $validated['id_tipo_contrato'], $validated['tipo_cargo_contrato'] ?? null),
            'Plantilla de contrato sugerida consultada correctamente',
        );
    }

    /**
     * Guardar ficha de ingreso
     *
     * Permiso requerido: CONTRATACION_CREAR o CONTRATACION_EDITAR.
     *
     * @response array{success: bool, message: string, data: array{id_empleado: int, estado_ficha: string|null, numero_carpeta: string|null, genero: string|null, fecha_expedicion_documento: string|null, fecha_nacimiento: string|null, lugar_nacimiento: string|null, nacionalidad: string|null, direccion_residencia: string|null, telefono_alterno: string|null, correo_personal: string|null, personas_vivienda: int|null, menores_estudian: int|null}}
     */
    public function saveProfile(SaveContractingProfileRequest $request, int $employeeId): JsonResponse
    {
        return $this->success(
            $this->contracting->saveProfile($employeeId, $this->actorId($request), $request->validated(), $this->context($request)),
            'Ficha de contratacion guardada correctamente',
        );
    }

    /**
     * Listar contratos del empleado
     *
     * Permiso requerido: CONTRATACION_HISTORIAL_VER.
     */
    public function listContracts(int $employeeId): JsonResponse
    {
        return $this->success(
            $this->contracting->listContracts($employeeId),
            'Contratos del empleado consultados correctamente',
        );
    }

    /**
     * Crear contrato del empleado
     *
     * Permiso requerido: CONTRATACION_CREAR.
     */
    public function createContract(CreateEmployeeContractRequest $request, int $employeeId): JsonResponse
    {
        return $this->success(
            $this->contracting->createContract($employeeId, $this->actorId($request), $request->validated(), $this->context($request)),
            'Contrato del empleado creado correctamente',
            201,
        );
    }

    /**
     * Obtener datos para generacion de contrato
     *
     * Permiso requerido: CONTRATACION_VER.
     */
    public function getContractGenerationData(int $employeeContractId): JsonResponse
    {
        return $this->success(
            new ContractGenerationDataResource($this->contracting->getContractGenerationData($employeeContractId)),
            'Datos de contrato para generacion consultados correctamente',
        );
    }

    /**
     * Registrar contrato firmado
     *
     * Permiso requerido: CONTRATACION_EDITAR.
     *
     * Acepta multipart/form-data. Para origen ARCHIVO recibe archivo; para origen URL recibe url.
     *
     * @response array{success: bool, message: string, data: array{id_empleado_contrato: int, id_empleado: int, numero_contrato: string, fecha_firma: string, id_empleado_documento: int, nombre_archivo: string, nombre_original: string|null, archivo_url: string|null, archivo_ruta: string|null, estado_documento: string, observaciones: string|null, estado_firma: string}}
     */
    public function signContract(SignEmployeeContractRequest $request, int $employeeContractId): JsonResponse
    {
        return $this->success(
            $this->contracting->signContract($employeeContractId, $this->actorId($request), $request->validated(), $this->context($request)),
            'Contrato firmado registrado correctamente',
        );
    }

    /**
     * Obtener seguridad social
     *
     * Permiso requerido: CONTRATACION_SEGURIDAD_SOCIAL_VER.
     */
    public function getSocialSecurity(int $employeeId): JsonResponse
    {
        return $this->success(
            $this->contracting->getSocialSecurity($employeeId),
            'Seguridad social del empleado consultada correctamente',
        );
    }

    /**
     * Guardar seguridad social
     *
     * Permiso requerido: CONTRATACION_SEGURIDAD_SOCIAL_EDITAR.
     */
    public function saveSocialSecurity(SaveSocialSecurityRequest $request, int $employeeId): JsonResponse
    {
        return $this->success(
            $this->contracting->saveSocialSecurity($employeeId, $this->actorId($request), $request->validated(), $this->context($request)),
            'Seguridad social del empleado guardada correctamente',
        );
    }

    /**
     * Listar examenes medicos
     *
     * Permiso requerido: CONTRATACION_EXAMENES_VER.
     */
    public function listMedicalExams(int $employeeId): JsonResponse
    {
        return $this->success(
            $this->contracting->listMedicalExams($employeeId),
            'Examenes medicos del empleado consultados correctamente',
        );
    }

    /**
     * Crear examen medico
     *
     * Permiso requerido: CONTRATACION_EXAMENES_CREAR.
     */
    public function createMedicalExam(CreateMedicalExamRequest $request, int $employeeId): JsonResponse
    {
        return $this->success(
            $this->contracting->createMedicalExam($employeeId, $this->actorId($request), $request->validated(), $this->context($request)),
            'Examen medico del empleado registrado correctamente',
            201,
        );
    }

    /**
     * Listar documentos laborales
     *
     * Permiso requerido: CONTRATACION_DOCUMENTOS_VER.
     */
    public function listDocuments(int $employeeId): JsonResponse
    {
        return $this->success(
            $this->contracting->listDocuments($employeeId),
            'Documentos laborales del empleado consultados correctamente',
        );
    }

    /**
     * Registrar documento laboral
     *
     * Permiso requerido: CONTRATACION_DOCUMENTOS_SUBIR.
     */
    public function registerDocument(RegisterEmployeeDocumentRequest $request, int $employeeId): JsonResponse
    {
        return $this->success(
            $this->contracting->registerDocument($employeeId, $this->actorId($request), $request->validated(), $this->context($request)),
            'Documento laboral del empleado registrado correctamente',
            201,
        );
    }

    /**
     * Listar alertas de contratacion
     *
     * Permiso requerido: CONTRATACION_ALERTAS_VER.
     */
    public function listAlerts(ListContractAlertsRequest $request): JsonResponse
    {
        $validated = $request->validated();

        return $this->success(
            $this->contracting->listAlerts(isset($validated['dias_antes']) ? (int) $validated['dias_antes'] : null),
            'Alertas de contratacion consultadas correctamente',
        );
    }
}
