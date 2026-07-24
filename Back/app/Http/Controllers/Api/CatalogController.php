<?php

namespace App\Http\Controllers\Api;

use App\Services\CatalogService;
use Dedoc\Scramble\Attributes\Group;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

#[Group('Catalogs', 'Catalogos administrativos del sistema.', weight: 6)]
class CatalogController extends ApiController
{
    private const SOCIAL_SECURITY_TYPES = ['EPS', 'ARL', 'PENSION', 'CESANTIAS', 'CAJA_COMPENSACION'];

    public function __construct(private readonly CatalogService $catalogs) {}

    /**
     * Listar tipos de documento
     *
     * Retorna el catalogo de tipos de documento para formularios de empleados.
     */
    public function documentTypes(Request $request): JsonResponse
    {
        return $this->success(
            $this->catalogs->documentTypes($request->boolean('solo_activos', true)),
            'Tipos de documento consultados correctamente',
        );
    }

    /**
     * Listar areas
     *
     * Retorna el catalogo de areas para formularios de empleados.
     */
    public function areas(Request $request): JsonResponse
    {
        return $this->success(
            $this->catalogs->areas($request->boolean('solo_activos', true)),
            'Areas consultadas correctamente',
        );
    }

    /**
     * Listar cargos
     *
     * Retorna el catalogo de cargos para formularios de empleados.
     */
    public function positions(Request $request): JsonResponse
    {
        return $this->success(
            $this->catalogs->positions($request->boolean('solo_activos', true)),
            'Cargos consultados correctamente',
        );
    }

    /**
     * Listar tipos de contrato
     *
     * Retorna el catalogo de tipos de contrato para formularios de empleados.
     */
    public function contractTypes(Request $request): JsonResponse
    {
        return $this->success(
            $this->catalogs->contractTypes($request->boolean('solo_activos', true)),
            'Tipos de contrato consultados correctamente',
        );
    }

    public function departments(): JsonResponse
    {
        return $this->success($this->catalogs->departments(), 'Departamentos consultados correctamente');
    }

    public function municipalities(int $departmentId): JsonResponse
    {
        abort_if($departmentId < 1, 404);

        return $this->success(
            $this->catalogs->municipalities($departmentId),
            'Municipios consultados correctamente',
        );
    }

    public function socialSecurityEntities(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'type' => ['required', 'string', 'in:'.implode(',', self::SOCIAL_SECURITY_TYPES)],
        ]);

        return $this->success(
            $this->catalogs->socialSecurityEntities($validated['type']),
            'Entidades de seguridad social consultadas correctamente',
        );
    }

    public function medicalExamTypes(): JsonResponse
    {
        return $this->success(
            $this->catalogs->medicalExamTypes(),
            'Tipos de examen medico consultados correctamente',
        );
    }

    /**
     * Listar tipos de documento laboral
     *
     * Retorna el catalogo de documentos laborales filtrable por aplicacion.
     */
    public function laborDocumentTypes(Request $request): JsonResponse
    {
        return $this->success(
            $this->catalogs->laborDocumentTypes(
                $this->optionalBoolean($request, 'active'),
                $this->optionalBoolean($request, 'applies_applicant'),
                $this->optionalBoolean($request, 'applies_contracting'),
                $this->optionalBoolean($request, 'applies_retirement'),
            ),
            'Tipos de documento laboral consultados correctamente',
        );
    }

    private function optionalBoolean(Request $request, string $key): ?bool
    {
        return $request->has($key) ? $request->boolean($key) : null;
    }
}
