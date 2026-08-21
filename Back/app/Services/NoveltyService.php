<?php

namespace App\Services;

use App\Exceptions\ApiException;
use App\Repositories\NoveltyRepository;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Str;
use Throwable;

class NoveltyService
{
    public function __construct(private readonly NoveltyRepository $repository, private readonly AuditService $audit) {}
    public function types(bool $inactive): array { return $this->repository->types($inactive); }
    public function list(array $filters): array { return $this->withEvidenceUrls($this->repository->list($filters)); }
    public function get(int $id): array { $r=$this->repository->get($id); if(!$r['novelty']) throw new ApiException('Novedad no encontrada.',404); $r['evidence']=$this->withEvidenceUrls($r['evidence']); return $r; }
    public function create(array $data,int $user,array $context): array { $r=$this->repository->create($data,$user); return $this->record($r,'NOVEDAD_CREAR',$user,$context); }
    public function createDisability(array $data,int $user,array $context): array { $r=$this->repository->createDisability($data,$user); return $this->record($r,'INCAPACIDAD_CREAR',$user,$context); }
    public function update(int $id,array $data,int $user,array $context): array { $before=$this->get($id)['novelty']; $r=$this->repository->update($id,$data,$user); if(!$r) throw new ApiException('No fue posible actualizar la novedad.',422); $this->audit->record($user,'NOVEDADES','NOVEDAD_ACTUALIZAR','NOVEDAD',$id,$before,$r,$context); return $r; }
    public function updateDisability(int $id,array $data,int $user,array $context): array { $before=$this->get($id)['novelty']; $r=$this->repository->updateDisability($id,$data,$user); if(!$r) throw new ApiException('No fue posible actualizar la incapacidad.',422); $this->audit->record($user,'NOVEDADES','INCAPACIDAD_ACTUALIZAR','NOVEDAD',$id,$before,$r,$context); return $r; }
    public function changeStatus(int $id,array $data,int $user,array $context): array { $before=$this->get($id)['novelty']; $r=$this->repository->changeStatus($id,$data['status'],$data['observation']??null,$user); if(!$r) throw new ApiException('No fue posible cambiar el estado.',422); $this->audit->record($user,'NOVEDADES','NOVEDAD_CAMBIAR_ESTADO','NOVEDAD',$id,$before,$r,$context); return $r; }
    public function evidence(int $id): array { $this->get($id); return $this->withEvidenceUrls($this->repository->evidence($id)); }
    public function history(int $id): array { $this->get($id); return $this->repository->history($id); }

    public function addEvidence(int $id,array $data,int $user,array $context): array
    {
        $this->get($id); $path=null; $payload=$data;
        try {
            if(($data['file']??null) instanceof UploadedFile) { $meta=$this->store($data['file']); $path=$meta['file_path']; $payload=[...$payload,...$meta,'file_url'=>null]; }
            else { $payload += ['original_name'=>null,'file_path'=>null,'mime_type'=>null,'size_bytes'=>null]; }
            $r=$this->repository->addEvidence($id,$payload,$user);
            if(!$r) throw new ApiException('No fue posible registrar el soporte.',422);
        } catch(Throwable $e) { if($path) File::delete(public_path($path)); throw $e; }
        $this->audit->record($user,'NOVEDADES','NOVEDAD_SOPORTE_AGREGAR','NOVEDAD',$id,null,$r,$context); return $r;
    }
    private function record(?array $r,string $action,int $user,array $context): array { if(!$r) throw new ApiException('No fue posible registrar la novedad.',422); $id=(int)($r['id_novedad']??0); $this->audit->record($user,'NOVEDADES',$action,'NOVEDAD',$id,null,$r,$context); return $r; }
    private function store(UploadedFile $f): array { if(!$f->isValid()) throw new ApiException('El archivo no es válido.',422); $ext=strtolower($f->getClientOriginalExtension()); $mime=strtolower((string)$f->getMimeType()); if(!in_array($ext,config('novelties.allowed_extensions'),true)||!in_array($mime,config("novelties.extension_mime_types.$ext",[]),true)) throw new ApiException('El tipo real del archivo no coincide con su extensión o no está permitido.',422); $dir='uploads/novelties/'.now()->format('Ym'); File::ensureDirectoryExists(public_path($dir),0755,true); $name=Str::uuid().'.'.$ext; $original=$f->getClientOriginalName(); $size=$f->getSize(); $f->move(public_path($dir),$name); return ['original_name'=>$original,'file_path'=>"$dir/$name",'mime_type'=>$mime,'size_bytes'=>$size]; }
    private function withEvidenceUrls(array $rows): array { return array_map(function($r){ if(!empty($r['archivo_ruta'])) $r['archivo_url_publica']=url($r['archivo_ruta']); else $r['archivo_url_publica']=$r['archivo_url']??null; return $r; },$rows); }
}
