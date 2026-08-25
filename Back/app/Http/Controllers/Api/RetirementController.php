<?php

namespace App\Http\Controllers\Api;

use App\Services\RetirementService;
use Dedoc\Scramble\Attributes\Group;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

#[Group('Retiros laborales','Proceso integral de finalizacion laboral.',weight:7)]
class RetirementController extends ApiController
{
 public function __construct(private readonly RetirementService $service){}
 public function reasons(Request $r):JsonResponse{return $this->success($this->service->reasons($r->boolean('include_inactive')));}
 public function documentTypes():JsonResponse{return $this->success($this->service->documentTypes());}
 public function index(Request $r):JsonResponse{$d=$r->validate(['employee_id'=>'nullable|integer|min:1','status'=>'nullable|in:BORRADOR,EN_PROCESO,COMPLETADO,CANCELADO','date_from'=>'nullable|date','date_to'=>'nullable|date|after_or_equal:date_from']);return $this->success($this->service->list($d));}
 public function show(int $id):JsonResponse{return $this->success($this->service->get($id));}
 public function certificate(int $id):JsonResponse{return $this->success($this->service->certificate($id));}
 public function store(Request $r):JsonResponse{$d=$r->validate(['employee_id'=>'required|integer|min:1','employee_contract_id'=>'nullable|integer|min:1','retirement_reason_id'=>'required|integer|min:1','process_start_date'=>'required|date','retirement_date'=>'required|date|after_or_equal:process_start_date','reason_detail'=>'nullable|string|max:1000','observations'=>'nullable|string|max:3000']);return $this->success($this->service->create($d,$this->actorId($r),$this->context($r)),'Proceso de retiro iniciado.',201);}
 public function activity(Request $r,int $id):JsonResponse{$d=$r->validate(['activity_code'=>'required|string|max:60','status'=>'required|in:PENDIENTE,EN_PROCESO,COMPLETADA,NO_APLICA','observations'=>'nullable|string|max:1000']);return $this->success($this->service->activity($id,$d,$this->actorId($r),$this->context($r)),'Actividad actualizada.');}
 public function interview(Request $r,int $id):JsonResponse{$d=$r->validate(['interview_date'=>'required|date','stated_reason'=>'nullable|string','positive_aspects'=>'nullable|string','improvement_aspects'=>'nullable|string','work_environment'=>'nullable|string','leadership_relationship'=>'nullable|string','compensation_benefits'=>'nullable|string','would_recommend_company'=>'nullable|boolean','eligible_for_rehire'=>'nullable|boolean','conclusions'=>'nullable|string']);return $this->success($this->service->interview($id,$d,$this->actorId($r),$this->context($r)),'Entrevista guardada.');}
 public function document(Request $r,int $id):JsonResponse{$d=$r->validate(['document_type_id'=>'required|integer|min:1','file_name'=>'required|string|max:255','period'=>'nullable|date_format:Y-m','file_url'=>'nullable|url|max:500','file'=>'nullable|file|max:10240|mimes:pdf,png,jpg,jpeg','observations'=>'nullable|string|max:2000']);return $this->success($this->service->document($id,$d,$r->file('file'),$this->actorId($r),$this->context($r)),'Documento cargado.',201);}
 public function finalize(Request $r,int $id):JsonResponse{$d=$r->validate(['observations'=>'nullable|string|max:3000']);return $this->success($this->service->finalize($id,$d['observations']??null,$this->actorId($r),$this->context($r)),'Retiro finalizado.');}
 public function cancel(Request $r,int $id):JsonResponse{$d=$r->validate(['reason'=>'required|string|max:500']);return $this->success($this->service->cancel($id,$d['reason'],$this->actorId($r),$this->context($r)),'Retiro cancelado.');}
}
