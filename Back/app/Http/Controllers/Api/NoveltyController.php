<?php

namespace App\Http\Controllers\Api;

use App\Http\Requests\ChangeNoveltyStatusRequest;
use App\Http\Requests\ListNoveltiesRequest;
use App\Http\Requests\SaveDisabilityRequest;
use App\Http\Requests\SaveNoveltyRequest;
use App\Http\Requests\StoreNoveltyEvidenceRequest;
use App\Services\NoveltyService;
use Dedoc\Scramble\Attributes\Group;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

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
 /** Listar soportes. */ public function evidence(int $id): JsonResponse { return $this->success($this->service->evidence($id),'Soportes consultados correctamente.'); }
 /** Consultar trazabilidad. */ public function history(int $id): JsonResponse { return $this->success($this->service->history($id),'Historial consultado correctamente.'); }
}
