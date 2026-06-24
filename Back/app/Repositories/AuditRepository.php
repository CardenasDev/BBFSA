<?php

namespace App\Repositories;

class AuditRepository extends StoredProcedureRepository
{
    public function create(array $event): void
    {
        $this->call('SP_BBF_LOG_AUDITORIA_CREAR', [
            $event['id_usuario'],
            $event['modulo'],
            $event['accion'],
            $event['entidad'],
            $event['entidad_id'],
            $event['datos_anteriores'],
            $event['datos_nuevos'],
            $event['ip_origen'],
            $event['user_agent'],
        ]);
    }
}
