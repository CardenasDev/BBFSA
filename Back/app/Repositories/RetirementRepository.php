<?php

namespace App\Repositories;

use Illuminate\Support\Facades\DB;
use PDO;

class RetirementRepository extends StoredProcedureRepository
{
    public function reasons(bool $inactive=false): array { return $this->call('SP_BBF_RETIROS_MOTIVOS_LISTAR',[$inactive?1:0]); }
    public function list(array $f): array { return $this->call('SP_BBF_RETIROS_LISTAR',[$f['employee_id']??null,$f['status']??null,$f['date_from']??null,$f['date_to']??null]); }
    public function create(array $d,int $user): ?array { return $this->first('SP_BBF_RETIROS_CREAR',[$d['employee_id'],$d['employee_contract_id']??null,$d['retirement_reason_id'],$d['process_start_date'],$d['retirement_date'],$d['reason_detail']??null,$d['observations']??null,$user]); }
    public function activity(int $id,string $code,string $status,?string $notes,int $user): ?array { return $this->first('SP_BBF_RETIROS_ACTIVIDAD_ACTUALIZAR',[$id,$code,$status,$notes,$user]); }
    public function interview(int $id,array $d,int $user): ?array { return $this->first('SP_BBF_RETIROS_ENTREVISTA_GUARDAR',[$id,$d['interview_date'],$user,$d['stated_reason']??null,$d['positive_aspects']??null,$d['improvement_aspects']??null,$d['work_environment']??null,$d['leadership_relationship']??null,$d['compensation_benefits']??null,$d['would_recommend_company']??null,$d['eligible_for_rehire']??null,$d['conclusions']??null]); }
    public function finalize(int $id,int $user,?string $notes): ?array { return $this->first('SP_BBF_RETIROS_FINALIZAR',[$id,$user,$notes]); }
    public function cancel(int $id,int $user,string $reason): ?array { return $this->first('SP_BBF_RETIROS_CANCELAR',[$id,$user,$reason]); }
    public function detail(int $id): array
    {
        $s=DB::connection()->getPdo()->prepare('CALL SP_BBF_RETIROS_OBTENER(?)'); $s->execute([$id]); $sets=[];
        try { do { if($s->columnCount()>0) $sets[]=array_map(fn($r)=>array_change_key_case($r,CASE_LOWER),$s->fetchAll(PDO::FETCH_ASSOC)); } while($s->nextRowset()); } finally { $s->closeCursor(); }
        return ['retirement'=>$sets[0][0]??null,'activities'=>$sets[1]??[],'documents'=>$sets[2]??[],'interview'=>$sets[3][0]??null];
    }
    public function retirementDocumentTypes(): array { return array_map(fn($r)=>array_change_key_case((array)$r,CASE_LOWER),DB::select('SELECT ID_TIPO_DOCUMENTO_LABORAL,NOMBRE,DESCRIPCION,OBLIGATORIO FROM bbf_tipos_documento_laboral WHERE APLICA_RETIRO=1 AND ACTIVO=1 ORDER BY NOMBRE')); }
    public function certificate(int $id): ?array
    {
        $r=DB::selectOne("SELECT R.ID_RETIRO,R.FECHA_RETIRO,E.NUMERO_DOCUMENTO,CONCAT_WS(' ',E.NOMBRES,E.APELLIDOS) EMPLEADO,E.FECHA_INGRESO,C.FECHA_INICIO,C.FECHA_FIN,C.SALARIO_BASE,C.NUMERO_CONTRATO,A.NOMBRE AREA,CA.NOMBRE CARGO,M.NOMBRE MOTIVO_RETIRO FROM bbf_retiros_empleado R JOIN bbf_empleados E ON E.ID_EMPLEADO=R.ID_EMPLEADO JOIN bbf_motivos_retiro M ON M.ID_MOTIVO_RETIRO=R.ID_MOTIVO_RETIRO LEFT JOIN bbf_empleado_contratos C ON C.ID_EMPLEADO_CONTRATO=R.ID_EMPLEADO_CONTRATO LEFT JOIN bbf_areas A ON A.ID_AREA=COALESCE(C.ID_AREA,E.ID_AREA) LEFT JOIN bbf_cargos CA ON CA.ID_CARGO=COALESCE(C.ID_CARGO,E.ID_CARGO) WHERE R.ID_RETIRO=?",[$id]);
        return $r?array_change_key_case((array)$r,CASE_LOWER):null;
    }
    public function addDocument(int $id,int $employeeId,int $typeId,array $m,?string $period,?string $notes,int $user): array
    {
        $newId=DB::table('bbf_empleado_documentos')->insertGetId(['ID_EMPLEADO'=>$employeeId,'ID_RETIRO'=>$id,'ID_TIPO_DOCUMENTO_LABORAL'=>$typeId,'NOMBRE_ARCHIVO'=>$m['file_name'],'NOMBRE_ORIGINAL'=>$m['original_name'],'ARCHIVO_URL'=>$m['file_url']??null,'ARCHIVO_RUTA'=>$m['file_path']??null,'MIME_TYPE'=>$m['mime_type']??null,'PESO_BYTES'=>$m['size_bytes']??null,'PERIODO_DOCUMENTO'=>$period,'ESTADO_DOCUMENTO'=>'CARGADO','OBSERVACIONES'=>$notes,'ID_CARGADO_POR'=>$user]);
        return array_change_key_case((array)DB::table('bbf_empleado_documentos')->where('ID_EMPLEADO_DOCUMENTO',$newId)->first(),CASE_LOWER);
    }
}
