<?php

namespace App\Http\Controllers\Api;

use App\Http\Requests\ChangeApplicantStatusRequest;
use App\Http\Requests\ConvertApplicantToEmployeeRequest;
use App\Http\Requests\CreateApplicantRequest;
use App\Http\Requests\RegisterApplicantDocumentRequest;
use App\Http\Requests\UpdateApplicantRequest;
use App\Services\ApplicantService;
use Dedoc\Scramble\Attributes\Group;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

#[Group('Applicants', 'Gestion de aspirantes para contratacion.', weight: 9)]
class ApplicantController extends ApiController
{
    public function __construct(private readonly ApplicantService $applicants) {}

    /**
     * Listar aspirantes
     *
     * Permiso requerido: ASPIRANTES_VER.
     */
    public function index(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'search' => ['nullable', 'string', 'max:150'],
            'status' => ['nullable', 'string', 'max:50'],
            'area_id' => ['nullable', 'integer'],
            'position_id' => ['nullable', 'integer'],
        ]);

        return $this->success(
            $this->applicants->listApplicants($validated),
            'Aspirantes consultados correctamente',
        );
    }

    /**
     * Obtener aspirante
     *
     * Permiso requerido: ASPIRANTES_VER.
     */
    public function show(int $applicantId): JsonResponse
    {
        return $this->success(
            $this->applicants->getApplicant($applicantId),
            'Aspirante consultado correctamente',
        );
    }

    /**
     * Crear aspirante
     *
     * Permiso requerido: ASPIRANTES_CREAR.
     */
    public function store(CreateApplicantRequest $request): JsonResponse
    {
        return $this->success(
            $this->applicants->createApplicant($request->validated(), $this->actorId($request), $this->context($request)),
            'Aspirante registrado correctamente',
            201,
        );
    }

    /**
     * Actualizar aspirante
     *
     * Permiso requerido: ASPIRANTES_EDITAR.
     */
    public function update(UpdateApplicantRequest $request, int $applicantId): JsonResponse
    {
        return $this->success(
            $this->applicants->updateApplicant($applicantId, $request->validated(), $this->actorId($request), $this->context($request)),
            'Aspirante actualizado correctamente',
        );
    }

    /**
     * Cambiar estado del aspirante
     *
     * Permiso requerido: ASPIRANTES_CAMBIAR_ESTADO.
     */
    public function changeStatus(ChangeApplicantStatusRequest $request, int $applicantId): JsonResponse
    {
        return $this->success(
            $this->applicants->changeStatus($applicantId, $request->validated(), $this->actorId($request), $this->context($request)),
            'Estado del aspirante actualizado correctamente',
        );
    }

    /**
     * Aprobar aspirante para contratacion
     *
     * Permiso requerido: ASPIRANTES_APROBAR_CONTRATACION.
     */
    public function approveForContracting(Request $request, int $applicantId): JsonResponse
    {
        $validated = $request->validate([
            'observaciones' => ['nullable', 'string'],
        ]);

        return $this->success(
            $this->applicants->approveForContracting($applicantId, $validated['observaciones'] ?? null, $this->actorId($request), $this->context($request)),
            'Aspirante aprobado para contratacion correctamente',
        );
    }

    /**
     * Listar documentos del aspirante
     *
     * Permiso requerido: ASPIRANTES_DOCUMENTOS_VER.
     */
    public function documents(int $applicantId): JsonResponse
    {
        return $this->success(
            $this->applicants->listDocuments($applicantId),
            'Documentos del aspirante consultados correctamente',
        );
    }

    /**
     * Registrar documento del aspirante
     *
     * Permiso requerido: ASPIRANTES_DOCUMENTOS_SUBIR.
     *
     * Acepta application/json para documentos con URL externa:
     * {"id_tipo_documento_laboral":1,"nombre_archivo":"Hoja de vida","archivo_url":"https://example.com/hoja-vida.pdf","estado_documento":"CARGADO","observaciones":"Documento externo"}
     *
     * Acepta application/json para documentos pendientes:
     * {"id_tipo_documento_laboral":1,"nombre_archivo":"Hoja de vida","estado_documento":"PENDIENTE","observaciones":"Pendiente de carga"}
     *
     * Acepta multipart/form-data con id_tipo_documento_laboral, nombre_archivo, archivo,
     * estado_documento y observaciones para carga fisica.
     *
     * @response array{success: bool, message: string, data: array{id_aspirante_documento: int, id_aspirante: int, estado_documento: string, nombre_archivo: string, nombre_original: string|null, archivo_url: string|null, archivo_ruta: string|null, mime_type: string|null, peso_bytes: int|null, tipo_origen_archivo: string|null}}
     */
    public function registerDocument(RegisterApplicantDocumentRequest $request, int $applicantId): JsonResponse
    {
        return $this->success(
            $this->applicants->registerDocument($applicantId, $request->validated(), $this->actorId($request), $this->context($request)),
            'Documento del aspirante registrado correctamente',
            201,
        );
    }

    /** Cargar o reemplazar un documento previamente registrado para el aspirante. */
    public function updateDocument(RegisterApplicantDocumentRequest $request, int $applicantId, int $documentId): JsonResponse
    {
        return $this->success(
            $this->applicants->updateDocument($applicantId, $documentId, $request->validated(), $this->actorId($request), $this->context($request)),
            'Documento del aspirante actualizado correctamente',
        );
    }

    /**
     * Listar historial de estados del aspirante
     *
     * Permiso requerido: ASPIRANTES_VER.
     */
    public function statusHistory(int $applicantId): JsonResponse
    {
        return $this->success(
            $this->applicants->listStatusHistory($applicantId),
            'Historial de estados del aspirante consultado correctamente',
        );
    }

    /**
     * Convertir aspirante en empleado
     *
     * Permiso requerido: ASPIRANTES_CONVERTIR_EMPLEADO.
     *
     * @response array{success: bool, message: string, data: array{id_aspirante: int, id_empleado: int, estado_aspirante: string, estado_ficha: string}}
     */
    public function convertToEmployee(ConvertApplicantToEmployeeRequest $request, int $applicantId): JsonResponse
    {
        return $this->success(
            $this->applicants->convertToEmployee($applicantId, $request->validated(), $this->actorId($request), $this->context($request)),
            'Aspirante convertido en empleado correctamente',
        );
    }
}
