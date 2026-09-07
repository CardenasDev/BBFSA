<?php

namespace App\Http\Controllers\Api;

use App\Http\Requests\ChangeNoveltyStatusRequest;
use App\Http\Requests\ListNoveltiesRequest;
use App\Http\Requests\ListDisabilityTrackingRequest;
use App\Http\Requests\SaveDisabilityRequest;
use App\Http\Requests\SaveDisabilityTrackingRequest;
use App\Http\Requests\SaveNoveltyRequest;
use App\Http\Requests\StoreNoveltyEvidenceRequest;
use App\Services\NoveltyService;
use Dedoc\Scramble\Attributes\Group;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\StreamedResponse;

#[Group('Novedades e incapacidades', 'Registro y seguimiento de novedades laborales.', weight: 8)]
class NoveltyController extends ApiController
{
 public function __construct(private readonly NoveltyService $service) {}
 /** Catálogo de tipos de novedad. */ public function types(Request $r): JsonResponse { return $this->success($this->service->types($r->boolean('include_inactive')),'Tipos consultados correctamente.'); }
 /** Listado filtrable de novedades. */ public function index(ListNoveltiesRequest $r): JsonResponse { return $this->success($this->service->list($r->validated()),'Novedades consultadas correctamente.'); }
 /** Detalle con soportes e historial. */ public function show(int $id): JsonResponse { return $this->success($this->service->get($id),'Novedad consultada correctamente.'); }
 /** Registrar permiso, llamado o suspensión. */ public function store(SaveNoveltyRequest $r): JsonResponse { return $this->success($this->service->create($r->validated(),$this->actorId($r),$this->context($r)),'Novedad registrada correctamente.',201); }
 /** Registrar incapacidad. */ public function storeDisability(SaveDisabilityRequest $r): JsonResponse { return $this->success($this->service->createDisability($r->validated(),$this->actorId($r),$this->context($r)),'Incapacidad registrada correctamente.',201); }
 /** Actualizar novedad general. */ public function update(SaveNoveltyRequest $r,int $id): JsonResponse { return $this->success($this->service->update($id,$r->validated(),$this->actorId($r),$this->context($r)),'Novedad actualizada correctamente.'); }
 /** Actualizar incapacidad. */ public function updateDisability(SaveDisabilityRequest $r,int $id): JsonResponse { return $this->success($this->service->updateDisability($id,$r->validated(),$this->actorId($r),$this->context($r)),'Incapacidad actualizada correctamente.'); }
 /** Validar, cerrar o anular. */ public function status(ChangeNoveltyStatusRequest $r,int $id): JsonResponse { return $this->success($this->service->changeStatus($id,$r->validated(),$this->actorId($r),$this->context($r)),'Estado actualizado correctamente.'); }
 /** Agregar soporte mediante archivo o URL. */ public function addEvidence(StoreNoveltyEvidenceRequest $r,int $id): JsonResponse { return $this->success($this->service->addEvidence($id,$r->validated()+['file'=>$r->file('file')],$this->actorId($r),$this->context($r)),'Soporte agregado correctamente.',201); }
 /** Consultar seguimiento administrativo y financiero. */ public function disabilityTracking(int $id): JsonResponse { return $this->success($this->service->disabilityTracking($id),'Seguimiento consultado correctamente.'); }
 /** Guardar seguimiento administrativo y financiero. */ public function saveDisabilityTracking(SaveDisabilityTrackingRequest $r,int $id): JsonResponse { return $this->success($this->service->saveDisabilityTracking($id,$r->validated(),$this->actorId($r),$this->context($r)),'Seguimiento guardado correctamente.'); }
 /** Exportar el seguimiento en CSV compatible con Excel. */
 public function exportDisabilityTracking(ListDisabilityTrackingRequest $r): StreamedResponse
 {
     $rows=$this->service->listDisabilityTracking($r->validated());
     return response()->streamDownload(function() use($rows): void {
         $out=fopen('php://output','wb'); fwrite($out,"\xEF\xBB\xBF");
         fputcsv($out,['Documento','Empleado','Fecha inicial','Fecha final','Días incapacidad','Diagnóstico','Entidad responsable','Días pagados empresa','Días por pagar entidad','Número incapacidad','Transcripción','Solicitud de pago','Valor incapacidad','Valor recibido entidad','Valor pagado empresa al trabajador','Valor pagado al trabajador','Valor adeudado entidad','Estado trabajador','Estado seguimiento','Observaciones'],';');
         foreach($rows as $row) fputcsv($out,[$row['numero_documento']??'',$row['apellido_y_nombre_completo']??'',$row['fecha_inicio']??'',$row['fecha_fin']??'',$row['dias_incapacidad']??'',$row['diagnostico']??'',$row['entidad_responsable']??'',$row['dias_pagados_empresa']??0,$row['dias_pagar_entidad']??0,$row['numero_incapacidad']??'',$row['estado_transcripcion']??'',$row['estado_solicitud_pago']??'',$row['valor_incapacidad']??0,$row['valor_recibido_entidad']??0,$row['valor_pagado_empresa_trabajador']??0,$row['valor_pagado_trabajador']??0,$row['valor_adeudado_entidad']??0,$row['estado_trabajador']??'',$row['estado_seguimiento']??'',$row['observaciones']??''],';');
         fclose($out);
     },'seguimiento_incapacidades_'.now()->format('Ymd_His').'.csv',['Content-Type'=>'text/csv; charset=UTF-8']);
 }
}
