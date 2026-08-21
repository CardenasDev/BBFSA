<?php

namespace App\Http\Controllers\Api;

use App\Http\Requests\SaveAreaRequest;
use App\Http\Requests\SaveContractTypeRequest;
use App\Http\Requests\SaveDocumentTypeRequest;
use App\Http\Requests\SaveDotationArticleRequest;
use App\Http\Requests\SaveLaborDocumentRequest;
use App\Http\Requests\SaveMedicalExamTypeRequest;
use App\Http\Requests\SaveNoveltyTypeRequest;
use App\Http\Requests\SavePositionRequest;
use App\Http\Requests\SaveSocialSecurityEntityRequest;
use App\Http\Requests\SaveSystemParameterRequest;
use App\Http\Requests\SaveDepartmentRequest;
use App\Http\Requests\SaveMunicipalityRequest;
use App\Services\ParameterService;
use Dedoc\Scramble\Attributes\Group;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use App\Services\DotationService;

#[Group('Parameters', 'Administración centralizada de parámetros del sistema.', weight: 10)]
class ParametersController extends ApiController
{
    public function __construct(private readonly ParameterService $params) {}

    public function departments(Request $request): JsonResponse { return $this->success($this->params->departments($request->boolean('includeInactive'))); }
    public function storeDepartment(SaveDepartmentRequest $request): JsonResponse { return $this->success($this->params->saveDepartment($request->validated(),$this->actorId($request),$this->context($request)),'Departamento guardado correctamente.',201); }
    public function updateDepartment(SaveDepartmentRequest $request,int $id): JsonResponse { $data=$request->validated(); $data['id_departamento']=$id; return $this->success($this->params->saveDepartment($data,$this->actorId($request),$this->context($request)),'Departamento actualizado correctamente.'); }
    public function municipalities(Request $request): JsonResponse { $id=$request->integer('departmentId')?:null; return $this->success($this->params->municipalities($id,$request->boolean('includeInactive'))); }
    public function storeMunicipality(SaveMunicipalityRequest $request): JsonResponse { return $this->success($this->params->saveMunicipality($request->validated(),$this->actorId($request),$this->context($request)),'Municipio guardado correctamente.',201); }
    public function updateMunicipality(SaveMunicipalityRequest $request,int $id): JsonResponse { $data=$request->validated(); $data['id_municipio']=$id; return $this->success($this->params->saveMunicipality($data,$this->actorId($request),$this->context($request)),'Municipio actualizado correctamente.'); }

    /**
     * Listar familias técnicas de artículos (solo datos técnicos)
     *
     * Retorna `id_tipo_dotacion`, `nombre`, `descripcion`, `requiere_talla`.
     */
    public function uniformItemFamilies(Request $request): JsonResponse
    {
        $dotation = app(DotationService::class);

        $rows = $dotation->types($request->boolean('includeInactive', false));

        $mapped = array_map(fn(array $r) => [
            'id_tipo_dotacion' => $r['id_tipo_dotacion'],
            'nombre' => $r['nombre'],
            'descripcion' => $r['descripcion'] ?? null,
            'requiere_talla' => $r['requiere_talla'] ?? false,
        ], $rows);

        return $this->success($mapped);
    }

    public function areas(Request $request): JsonResponse
    {
        return $this->success($this->params->areas($request->boolean('includeInactive', false)));
    }

    /**
     * Guardar área
     *
     * Crea o actualiza un área. Query param: `includeInactive` (boolean) para listar.
     * Permisos: GET -> PARAMETROS_VER, POST/PUT -> PARAMETROS_ADMINISTRAR
     */

    public function storeArea(SaveAreaRequest $request): JsonResponse
    {
        $result = $this->params->saveArea($request->validated(), $this->actorId($request), $this->context($request));

        return $this->success($result, 'Área guardada correctamente.', 201);
    }

    public function updateArea(SaveAreaRequest $request, int $id): JsonResponse
    {
        $data = $request->validated();
        $data['id_area'] = $id;

        $result = $this->params->saveArea($data, $this->actorId($request), $this->context($request));

        return $this->success($result, 'Área actualizada correctamente.');
    }

    /**
     * Listar cargos
     *
     * Retorna los cargos del sistema. Query param: `includeInactive` (boolean).
     */

    public function positions(Request $request): JsonResponse
    {
        return $this->success($this->params->positions($request->boolean('includeInactive', false)));
    }

    /**
     * Guardar cargo
     *
     * Crea o actualiza un cargo.
     */

    public function storePosition(SavePositionRequest $request): JsonResponse
    {
        $result = $this->params->savePosition($request->validated(), $this->actorId($request), $this->context($request));

        return $this->success($result, 'Cargo guardado correctamente.', 201);
    }

    public function updatePosition(SavePositionRequest $request, int $id): JsonResponse
    {
        $data = $request->validated();
        $data['id_cargo'] = $id;

        $result = $this->params->savePosition($data, $this->actorId($request), $this->context($request));

        return $this->success($result, 'Cargo actualizado correctamente.');
    }

    /**
     * Listar tipos de contrato
     *
     * Query param: `includeInactive` (boolean).
     */

    public function contractTypes(Request $request): JsonResponse
    {
        return $this->success($this->params->contractTypes($request->boolean('includeInactive', false)));
    }

    /**
     * Guardar tipo de contrato
     */

    public function storeContractType(SaveContractTypeRequest $request): JsonResponse
    {
        $result = $this->params->saveContractType($request->validated(), $this->actorId($request), $this->context($request));

        return $this->success($result, 'Tipo de contrato guardado correctamente.', 201);
    }

    public function updateContractType(SaveContractTypeRequest $request, int $id): JsonResponse
    {
        $data = $request->validated();
        $data['id_tipo_contrato'] = $id;

        $result = $this->params->saveContractType($data, $this->actorId($request), $this->context($request));

        return $this->success($result, 'Tipo de contrato actualizado correctamente.');
    }

    /**
     * Listar tipos de documento
     *
     * Query param: `includeInactive` (boolean).
     */

    public function documentTypes(Request $request): JsonResponse
    {
        return $this->success($this->params->documentTypes($request->boolean('includeInactive', false)));
    }

    /**
     * Guardar tipo de documento
     */

    public function storeDocumentType(SaveDocumentTypeRequest $request): JsonResponse
    {
        $result = $this->params->saveDocumentType($request->validated(), $this->actorId($request), $this->context($request));

        return $this->success($result, 'Tipo de documento guardado correctamente.', 201);
    }

    public function updateDocumentType(SaveDocumentTypeRequest $request, int $id): JsonResponse
    {
        $data = $request->validated();
        $data['id_tipo_documento'] = $id;

        $result = $this->params->saveDocumentType($data, $this->actorId($request), $this->context($request));

        return $this->success($result, 'Tipo de documento actualizado correctamente.');
    }

    /**
     * Listar documentos laborales
     *
     * Query param: `includeInactive` (boolean).
     */

    public function laborDocumentTypes(Request $request): JsonResponse
    {
        return $this->success($this->params->laborDocuments($request->boolean('includeInactive', false)));
    }

    /**
     * Guardar documento laboral
     */

    public function storeLaborDocument(SaveLaborDocumentRequest $request): JsonResponse
    {
        $result = $this->params->saveLaborDocument($request->validated(), $this->actorId($request), $this->context($request));

        return $this->success($result, 'Documento laboral guardado correctamente.', 201);
    }

    public function updateLaborDocument(SaveLaborDocumentRequest $request, int $id): JsonResponse
    {
        $data = $request->validated();
        $data['id_tipo_documento_laboral'] = $id;

        $result = $this->params->saveLaborDocument($data, $this->actorId($request), $this->context($request));

        return $this->success($result, 'Documento laboral actualizado correctamente.');
    }

    /**
     * Listar entidades de seguridad social
     *
     * Query param: `type` (EPS|ARL|PENSION|CESANTIAS|CAJA_COMPENSACION), `includeInactive` (boolean).
     */

    public function socialSecurityEntities(Request $request): JsonResponse
    {
        $validated = $request->validate(['type' => ['required', 'string']]);

        return $this->success($this->params->socialSecurityEntities($validated['type'], $request->boolean('includeInactive', false)));
    }

    /**
     * Guardar entidad de seguridad social
     */

    public function storeSocialSecurityEntity(SaveSocialSecurityEntityRequest $request): JsonResponse
    {
        $result = $this->params->saveSocialSecurityEntity($request->validated(), $this->actorId($request), $this->context($request));

        return $this->success($result, 'Entidad de seguridad social guardada correctamente.', 201);
    }

    public function updateSocialSecurityEntity(SaveSocialSecurityEntityRequest $request, int $id): JsonResponse
    {
        $data = $request->validated();
        $data['id_entidad'] = $id;

        $result = $this->params->saveSocialSecurityEntity($data, $this->actorId($request), $this->context($request));

        return $this->success($result, 'Entidad de seguridad social actualizada correctamente.');
    }

    /**
     * Listar tipos de examen médico
     */

    public function medicalExamTypes(Request $request): JsonResponse
    {
        return $this->success($this->params->medicalExamTypes($request->boolean('includeInactive', false)));
    }

    /**
     * Guardar tipo de examen médico
     */

    public function storeMedicalExamType(SaveMedicalExamTypeRequest $request): JsonResponse
    {
        $result = $this->params->saveMedicalExamType($request->validated(), $this->actorId($request), $this->context($request));

        return $this->success($result, 'Tipo de examen guardado correctamente.', 201);
    }

    public function updateMedicalExamType(SaveMedicalExamTypeRequest $request, int $id): JsonResponse
    {
        $data = $request->validated();
        $data['id_tipo_examen'] = $id;

        $result = $this->params->saveMedicalExamType($data, $this->actorId($request), $this->context($request));

        return $this->success($result, 'Tipo de examen actualizado correctamente.');
    }

    public function noveltyTypes(Request $request): JsonResponse
    {
        return $this->success($this->params->noveltyTypes($request->boolean('includeInactive', false)));
    }

    public function storeNoveltyType(SaveNoveltyTypeRequest $request): JsonResponse
    {
        $result = $this->params->saveNoveltyType($request->validated(), $this->actorId($request), $this->context($request));
        return $this->success($result, 'Tipo de novedad guardado correctamente.', 201);
    }

    public function updateNoveltyType(SaveNoveltyTypeRequest $request, int $id): JsonResponse
    {
        $data = $request->validated();
        $data['id_tipo_novedad'] = $id;
        $result = $this->params->saveNoveltyType($data, $this->actorId($request), $this->context($request));
        return $this->success($result, 'Tipo de novedad actualizado correctamente.');
    }

    /**
     * Listar artículos de dotación
     *
     * Para información técnica de familias usar `GET /api/dotations/types`.
     */

    public function uniformItems(Request $request): JsonResponse
    {
        return $this->success($this->params->dotationArticles($request->boolean('includeInactive', false)));
    }

    /**
     * Guardar artículo de dotación
     */

    public function storeUniformItem(SaveDotationArticleRequest $request): JsonResponse
    {
        $result = $this->params->saveDotationArticle($request->validated(), $this->actorId($request), $this->context($request));

        return $this->success($result, 'Artículo de dotación guardado correctamente.', 201);
    }

    public function updateUniformItem(SaveDotationArticleRequest $request, int $id): JsonResponse
    {
        $data = $request->validated();
        $data['id_dotacion_articulo'] = $id;

        $result = $this->params->saveDotationArticle($data, $this->actorId($request), $this->context($request));

        return $this->success($result, 'Artículo de dotación actualizado correctamente.');
    }

    /**
     * Listar parámetros del sistema
     */

    public function systemParametersList(): JsonResponse
    {
        return $this->success($this->params->systemParameters());
    }

    /**
     * Guardar parámetro del sistema
     *
     * `P_ID_USUARIO` se establece desde el usuario autenticado (JWT). No aceptar `id_usuario` desde cliente.
     */

    public function storeSystemParameter(SaveSystemParameterRequest $request): JsonResponse
    {
        $result = $this->params->saveSystemParameter($request->validated(), $this->actorId($request), $this->context($request));

        return $this->success($result, 'Parámetro del sistema guardado correctamente.', 201);
    }

    public function updateSystemParameter(SaveSystemParameterRequest $request, int $id): JsonResponse
    {
        $data = $request->validated();
        $data['id_parametro'] = $id;

        $result = $this->params->saveSystemParameter($data, $this->actorId($request), $this->context($request));

        return $this->success($result, 'Parámetro del sistema actualizado correctamente.');
    }
}
