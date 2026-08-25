<?php

namespace App\Services;

use App\Exceptions\ApiException;
use App\Repositories\RetirementRepository;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Str;
use Throwable;

class RetirementService
{
    public function __construct(private readonly RetirementRepository $repo,private readonly AuditService $audit) {}
    public function reasons(bool $inactive=false): array{return $this->repo->reasons($inactive);}
    public function documentTypes():array{return $this->repo->retirementDocumentTypes();}
    public function certificate(int $id):array{$this->get($id);return $this->repo->certificate($id)??throw new ApiException('No fue posible obtener los datos del certificado.',404);}
    public function list(array $f):array{return $this->repo->list($f);}
    public function get(int $id):array{$r=$this->repo->detail($id);if(!$r['retirement'])throw new ApiException('Proceso de retiro no encontrado.',404);foreach($r['documents'] as &$d){$d['archivo_url_publica']=!empty($d['archivo_ruta'])?url($d['archivo_ruta']):($d['archivo_url']??null);}return $r;}
    public function create(array $d,int $u,array $ctx):array{$r=$this->repo->create($d,$u);if(!$r)throw new ApiException('No fue posible iniciar el retiro.',422);$id=(int)$r['id_retiro'];$this->audit->record($u,'RETIROS','RETIRO_CREAR','RETIRO',$id,null,$r,$ctx);return $r;}
    public function activity(int $id,array $d,int $u,array $ctx):array{$before=$this->get($id);$r=$this->repo->activity($id,$d['activity_code'],$d['status'],$d['observations']??null,$u);if(!$r)throw new ApiException('No fue posible actualizar la actividad.',422);$this->audit->record($u,'RETIROS','RETIRO_ACTIVIDAD_ACTUALIZAR','RETIRO',$id,$before['activities'],$r,$ctx);return $r;}
    public function interview(int $id,array $d,int $u,array $ctx):array{$before=$this->get($id)['interview'];$r=$this->repo->interview($id,$d,$u);if(!$r)throw new ApiException('No fue posible guardar la entrevista.',422);$this->audit->record($u,'RETIROS','RETIRO_ENTREVISTA_GUARDAR','RETIRO',$id,$before,$r,$ctx);return $r;}
    public function finalize(int $id,?string $n,int $u,array $ctx):array{$before=$this->get($id)['retirement'];$r=$this->repo->finalize($id,$u,$n);if(!$r)throw new ApiException('No fue posible finalizar el retiro.',422);$this->audit->record($u,'RETIROS','RETIRO_FINALIZAR','RETIRO',$id,$before,$r,$ctx);return $r;}
    public function cancel(int $id,string $reason,int $u,array $ctx):array{$before=$this->get($id)['retirement'];$r=$this->repo->cancel($id,$u,$reason);if(!$r)throw new ApiException('No fue posible cancelar el retiro.',422);$this->audit->record($u,'RETIROS','RETIRO_CANCELAR','RETIRO',$id,$before,$r,$ctx);return $r;}
    public function document(int $id,array $d,?UploadedFile $file,int $u,array $ctx):array
    {
        $detail=$this->get($id);$ret=$detail['retirement'];$path=null;
        if(!$file&&!trim((string)($d['file_url']??'')))throw new ApiException('Adjunta un archivo o registra una URL.',422);
        try{$m=['file_name'=>$d['file_name'],'original_name'=>null,'file_url'=>trim((string)($d['file_url']??''))?:null,'file_path'=>null,'mime_type'=>null,'size_bytes'=>null];if($file){$m=$this->store($file);$path=$m['file_path'];}$r=$this->repo->addDocument($id,(int)$ret['id_empleado'],(int)$d['document_type_id'],$m,$d['period']??null,$d['observations']??null,$u);}catch(Throwable $e){if($path)File::delete(public_path($path));throw $e;}
        $this->audit->record($u,'RETIROS','RETIRO_DOCUMENTO_CARGAR','RETIRO',$id,null,$r,$ctx);return $r;
    }
    private function store(UploadedFile $f):array{if(!$f->isValid())throw new ApiException('Archivo no valido.',422);$allowed=['pdf','png','jpg','jpeg'];$ext=strtolower($f->getClientOriginalExtension());if(!in_array($ext,$allowed,true))throw new ApiException('Solo se permiten PDF, PNG y JPG.',422);$dir='uploads/retirements/'.now()->format('Ym');File::ensureDirectoryExists(public_path($dir),0755,true);$name=Str::uuid().'.'.$ext;$original=$f->getClientOriginalName();$size=$f->getSize();$mime=$f->getMimeType();$f->move(public_path($dir),$name);return['file_name'=>$name,'original_name'=>$original,'file_url'=>null,'file_path'=>"$dir/$name",'mime_type'=>$mime,'size_bytes'=>$size];}
}
