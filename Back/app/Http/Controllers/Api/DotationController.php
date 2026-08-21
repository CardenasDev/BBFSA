<?php

namespace App\Http\Controllers\Api;

use App\Http\Requests\ConfirmDotationDeliveryRequest;
use App\Http\Requests\CreateDotationDeliveryRequest;
use App\Http\Requests\DeleteDotationDeliveryRequest;
use App\Http\Requests\ExportDotationQuotationRequest;
use App\Http\Requests\ListDotationDeliveriesRequest;
use App\Http\Requests\ListDotationEmployeesRequest;
use App\Http\Requests\SaveEmployeeDotationArticleSizeRequest;
use App\Http\Requests\PrepareDotationDeliveryRequest;
use App\Http\Requests\SaveMyDotationSizeRequest;
use App\Http\Requests\UpdateDotationEvidenceRequest;
use App\Services\DotationService;
use Dedoc\Scramble\Attributes\Group;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\BinaryFileResponse;

#[Group('Dotations', 'Gestion de tallas y entregas de dotacion.', weight: 7)]
class DotationController extends ApiController
{
    public function __construct(private readonly DotationService $dotations) {}

    /**
     * Listar tipos de dotacion
     *
     * Retorna el catalogo de tipos de dotacion disponibles.
     */
    public function types(Request $request): JsonResponse
    {
        return $this->success(
            $this->dotations->types($request->boolean('solo_activos', true)),
            'Tipos de dotación consultados correctamente',
        );
    }

    /**
     * Listar tallas de dotacion
     *
     * Retorna tallas de dotacion, opcionalmente filtradas por tipo.
     */
    public function sizes(Request $request): JsonResponse
    {
        return $this->success(
            $this->dotations->sizes($request->integer('id_tipo_dotacion') ?: null, $request->boolean('solo_activos', true)),
            'Tallas de dotación consultadas correctamente',
        );
    }

    /**
     * Listar artículos de dotación
     *
     * Retorna el catálogo de artículos específicos. Puede filtrarse por familia y género.
     *
     * @response array{success: bool, message: string, data: list<array{id_dotacion_articulo: int, codigo: string, articulo: string, descripcion: string|null, genero: string, unidad_medida: string, id_tipo_dotacion: int, tipo_dotacion: string, requiere_talla: bool, activo: bool}>}
     */
    public function articles(Request $request): JsonResponse
    {
        $request->validate([
            'id_tipo_dotacion' => ['nullable', 'integer', 'min:1'],
            'genero' => ['nullable', 'string', 'in:HOMBRE,MUJER,UNISEX,NO_APLICA'],
            'incluir_inactivos' => ['nullable', 'boolean'],
        ]);

        return $this->success(
            $this->dotations->articles(
                $request->integer('id_tipo_dotacion') ?: null,
                $request->input('genero'),
                $request->boolean('incluir_inactivos'),
            ),
            'Artículos de dotación consultados correctamente',
        );
    }

    /**
     * Listar combinaciones de dotacion
     *
     * Retorna las combinaciones activas configuradas para entregas ordinarias.
     */
    public function combinations(): JsonResponse
    {
        return $this->success(
            $this->dotations->combinations(),
            'Combinaciones de dotacion consultadas correctamente',
        );
    }

    /**
     * Consultar detalle de combinacion de dotacion
     *
     * Retorna las prendas activas que conforman una combinacion activa.
     */
    public function combinationDetails(int $combinationId): JsonResponse
    {
        return $this->success(
            $this->dotations->combinationDetails($combinationId),
            'Detalle de combinacion de dotacion consultado correctamente',
        );
    }

    /**
     * Consultar mis tallas
     *
     * Retorna las tallas de dotacion asociadas al usuario autenticado.
     */
    public function mySizes(Request $request): JsonResponse
    {
        return $this->success(
            $this->dotations->mySizes($this->actorId($request)),
            'Mis tallas consultadas correctamente',
        );
    }

    /**
     * Consultar mis entregas
     *
     * Retorna las entregas de dotacion asociadas al usuario autenticado.
     *
     * @response array{success: bool, message: string, data: list<array{id_dotacion_entrega: int, id_empleado: int, numero_documento: string, nombre_completo: string, fecha_entrega: string, fecha_confirmacion: string|null, estado: string, observaciones: string|null, observacion_confirmacion: string|null, firma_url: string|null, id_registrado_por: int|null, registrado_por: string|null, id_confirmado_por: int|null, confirmado_por: string|null, created_at: string|null, updated_at: string|null}>}
     */
    public function myDeliveries(Request $request): JsonResponse
    {
        return $this->success(
            $this->dotations->myDeliveries($this->actorId($request)),
            'Mis entregas de dotaciÃ³n consultadas correctamente',
        );
    }

    /**
     * Guardar mi talla
     *
     * Guarda una talla de dotacion para el empleado asociado al usuario autenticado.
     */
    public function saveMySize(SaveMyDotationSizeRequest $request): JsonResponse
    {
        return $this->success(
            $this->dotations->saveMySize($this->actorId($request), $request->validated(), $this->context($request)),
            'Talla de dotación guardada correctamente',
        );
    }

    /**
     * Listar empleados con tallas
     *
     * Retorna empleados con resumen de tallas de dotacion.
     */
    public function employees(ListDotationEmployeesRequest $request): JsonResponse
    {
        return $this->success(
            $this->dotations->employees(
                $request->validated('texto_busqueda'),
                $request->integer('id_area') ?: null,
                $request->integer('id_cargo') ?: null,
            ),
            'Empleados con tallas consultados correctamente',
        );
    }

    /**
     * Exportar cotizacion de dotacion
     *
     * Descarga las tallas actuales y la ultima entrega confirmada por prenda.
     */
    public function exportQuotation(ExportDotationQuotationRequest $request): BinaryFileResponse
    {
        $export = $this->dotations->exportQuotation(
            $request->validated('id_area'),
            $request->validated('id_cargo'),
            $request->validated('id_empleado'),
        );

        return response()->download($export['path'], $export['filename'], [
            'Content-Type' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        ])->deleteFileAfterSend(true);
    }

    public function exportPurchaseQuotation(ExportDotationQuotationRequest $request): BinaryFileResponse
    {
        $export = $this->dotations->exportPurchaseQuotation(
            $request->validated('id_area'),
            $request->validated('id_cargo'),
            $request->validated('id_empleado'),
        );

        return response()->download($export['path'], $export['filename'], [
            'Content-Type' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        ])->deleteFileAfterSend(true);
    }

    /**
     * Consultar tallas de empleado
     *
     * Retorna las tallas de dotacion de un empleado.
     */
    public function employeeSizes(int $employeeId): JsonResponse
    {
        return $this->success(
            $this->dotations->employeeSizes($employeeId),
            'Tallas del empleado consultadas correctamente',
        );
    }

    public function employeeArticleSizes(int $employeeId): JsonResponse
    {
        return $this->success(
            $this->dotations->employeeArticleSizes($employeeId),
            'Tallas por articulo del empleado consultadas correctamente',
        );
    }

    public function saveEmployeeArticleSize(SaveEmployeeDotationArticleSizeRequest $request, int $employeeId, int $articleId): JsonResponse
    {
        return $this->success(
            $this->dotations->saveEmployeeArticleSize(
                $employeeId,
                $articleId,
                $request->integer('id_talla_dotacion'),
                $request->validated('observaciones'),
                $this->actorId($request),
                $this->context($request),
            ),
            'Talla del articulo guardada correctamente',
        );
    }

    /**
     * Consultar historial de dotaciones de empleado
     *
     * Retorna todos los items entregados a un empleado agrupables por entrega.
     *
     * @response array{success: bool, message: string, data: list<array{id_dotacion_entrega: int, id_empleado: int, numero_documento: string, nombre_completo: string, area: string|null, cargo: string|null, fecha_entrega: string, fecha_confirmacion: string|null, estado: string, id_dotacion_entrega_detalle: int, id_dotacion_articulo: int|null, codigo_articulo: string|null, articulo: string, genero: string|null, unidad_medida: string|null, id_tipo_dotacion: int, tipo_dotacion: string, id_talla_dotacion: int|null, talla: string|null, cantidad: int}>}
     */
    public function employeeHistory(int $employeeId): JsonResponse
    {
        return $this->success(
            $this->dotations->employeeHistory($employeeId),
            'Historial de dotaciones del empleado consultado correctamente',
        );
    }

    /**
     * Registrar entrega de dotacion
     *
     * Crea una entrega ordinaria o extraordinaria por artículos específicos. La combinación es opcional para entregas ordinarias.
     * Acepta multipart/form-data con origen_evidencia ARCHIVO o URL.
     */
    public function createDelivery(CreateDotationDeliveryRequest $request): JsonResponse
    {
        return $this->success(
            $this->dotations->createDelivery($request->validated(), $this->actorId($request), $this->context($request)),
            'Entrega de dotación registrada correctamente',
            201,
        );
    }

    /**
     * Listar entregas de dotacion
     *
     * Retorna entregas de dotacion filtradas por empleado o fechas.
     *
     * @response array{success: bool, message: string, data: list<array{id_dotacion_entrega: int, id_empleado: int, numero_documento: string, nombre_completo: string, fecha_entrega: string, fecha_confirmacion: string|null, estado: string, observaciones: string|null, observacion_confirmacion: string|null, firma_url: string|null, id_registrado_por: int|null, registrado_por: string|null, id_confirmado_por: int|null, confirmado_por: string|null, created_at: string|null, updated_at: string|null}>}
     */
    public function deliveries(ListDotationDeliveriesRequest $request): JsonResponse
    {
        return $this->success(
            $this->dotations->deliveries(
                $request->integer('id_empleado') ?: null,
                $request->validated('fecha_inicio'),
                $request->validated('fecha_fin'),
            ),
            'Entregas de dotación consultadas correctamente',
        );
    }

    public function prepareDelivery(PrepareDotationDeliveryRequest $request, int $deliveryId): JsonResponse
    {
        return $this->success(
            $this->dotations->prepareDelivery($deliveryId, $request->validated(), $this->actorId($request), $this->context($request)),
            'Entrega preparada correctamente',
        );
    }

    /**
     * Consultar detalle de entrega
     *
     * Retorna los items registrados en una entrega de dotacion.
     *
     * @response array{success: bool, message: string, data: list<array{id_dotacion_entrega_detalle: int, id_dotacion_entrega: int, id_dotacion_articulo: int|null, codigo_articulo: string|null, articulo: string, genero: string|null, unidad_medida: string|null, id_tipo_dotacion: int, tipo_dotacion: string, requiere_talla: bool, id_talla_dotacion: int|null, talla: string|null, cantidad: int}>}
     */
    public function deliveryDetails(int $deliveryId): JsonResponse
    {
        return $this->success(
            $this->dotations->deliveryDetails($deliveryId),
            'Detalle de entrega consultado correctamente',
        );
    }

    /** Reemplazar la evidencia de una entrega mediante archivo o URL. */
    public function replaceDeliveryEvidence(UpdateDotationEvidenceRequest $request, int $deliveryId): JsonResponse
    {
        return $this->success(
            $this->dotations->replaceDeliveryEvidence($deliveryId, $request->validated(), $this->actorId($request), $this->context($request)),
            'Evidencia de la entrega reemplazada correctamente',
        );
    }

    /** Eliminar la evidencia actual sin eliminar la entrega. */
    public function deleteDeliveryEvidence(Request $request, int $deliveryId): JsonResponse
    {
        return $this->success(
            $this->dotations->deleteDeliveryEvidence($deliveryId, $this->actorId($request), $this->context($request)),
            'Evidencia de la entrega eliminada correctamente',
        );
    }

    /**
     * Eliminar entrega de dotacion
     *
     * Elimina logicamente una entrega no confirmada y sus detalles.
     * Permiso requerido: DOTACIONES_ENTREGAS_ELIMINAR.
     *
     * @response array{success: bool, message: string, data: array{id_dotacion_entrega: int, eliminado: bool, estado: string, fecha_eliminacion: string|null}}
     */
    public function deleteDelivery(DeleteDotationDeliveryRequest $request, int $deliveryId): JsonResponse
    {
        return $this->success(
            $this->dotations->deleteDelivery($deliveryId, $this->actorId($request), $request->validated('motivo_eliminacion')),
            'Entrega de dotaciÃ³n eliminada correctamente',
        );
    }

    /**
     * Confirmar recibido
     *
     * Confirma que el empleado autenticado recibio una entrega de dotacion.
     *
     * @response array{success: bool, message: string, data: array{id_dotacion_entrega: int, id_empleado: int, fecha_entrega: string, fecha_confirmacion: string|null, estado: string, observaciones: string|null, observacion_confirmacion: string|null, firma_url: string|null, id_confirmado_por: int|null}}
     */
    public function confirmDeliveryReceived(ConfirmDotationDeliveryRequest $request, int $deliveryId): JsonResponse
    {
        return $this->success(
            $this->dotations->confirmDeliveryReceived($this->actorId($request), $deliveryId, $request->validated(), $this->context($request)),
            'Entrega de dotaciÃ³n confirmada correctamente',
        );
    }

    /**
     * Confirmar entrega presencial por RRHH
     *
     * Permite al personal autorizado confirmar la entrega en presencia del empleado.
     * Permiso requerido: DOTACIONES_ENTREGAS_CREAR.
     *
     * @response array{success: bool, message: string, data: array{id_dotacion_entrega: int, id_empleado: int, fecha_entrega: string, fecha_confirmacion: string|null, estado: string, observaciones: string|null, observacion_confirmacion: string|null, firma_url: string|null, id_confirmado_por: int|null}}
     */
    public function confirmDeliveryByHr(ConfirmDotationDeliveryRequest $request, int $deliveryId): JsonResponse
    {
        return $this->success(
            $this->dotations->confirmDeliveryByHr($this->actorId($request), $deliveryId, $request->validated(), $this->context($request)),
            'Entrega de dotacion confirmada presencialmente',
        );
    }
}
