<?php

namespace App\Repositories;

class CertificateRepository extends StoredProcedureRepository
{
    public function listFormats(string $date): array
    {
        return $this->call('SP_BBF_DOCUMENTO_FORMATOS_LISTAR', ['EMPLEADO', $date]);
    }

    public function getFormat(string $key, string $date, string $variant = 'GENERAL'): ?array
    {
        return $this->first('SP_BBF_DOCUMENTO_FORMATO_OBTENER', [$key, $variant, $date]);
    }
}
