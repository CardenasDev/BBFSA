<?php

namespace App\Http\Controllers\Api;

use App\Http\Requests\CreateEmployeeContractRequest;
use App\Http\Requests\CreateMedicalExamRequest;
use App\Http\Requests\RegisterEmployeeDocumentRequest;
use App\Http\Requests\SaveContractingProfileRequest;
use App\Http\Requests\SaveSocialSecurityRequest;
use App\Services\ContractingService;
use Dedoc\Scramble\Attributes\Group;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

#[Group('Contracting', 'Gestion de contratacion y ficha de ingreso.', weight: 8)]
class ContractingController extends ApiController
{
    public function __construct(private readonly ContractingService $contracting) {}

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
     */
    public function getProfile(int $employeeId): JsonResponse
    {
        return $this->success(
            $this->contracting->getProfile($employeeId),
            'Ficha de contratacion consultada correctamente',
        );
    }

    /**
     * Guardar ficha de ingreso
     *
     * Permiso requerido: CONTRATACION_CREAR o CONTRATACION_EDITAR.
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
    public function listAlerts(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'dias' => ['nullable', 'integer', 'min:0'],
        ]);

        return $this->success(
            $this->contracting->listAlerts(isset($validated['dias']) ? (int) $validated['dias'] : null),
            'Alertas de contratacion consultadas correctamente',
        );
    }
}
