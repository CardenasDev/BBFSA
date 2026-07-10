<?php

namespace App\Repositories;

class CatalogRepository extends StoredProcedureRepository
{
    public function documentTypes(bool $onlyActive): array
    {
        return $this->call('SP_BBF_TIPOS_DOCUMENTO_LISTAR', [(int) $onlyActive]);
    }

    public function areas(bool $onlyActive): array
    {
        return $this->call('SP_BBF_AREAS_LISTAR', [(int) $onlyActive]);
    }

    public function positions(bool $onlyActive): array
    {
        return $this->call('SP_BBF_CARGOS_LISTAR', [(int) $onlyActive]);
    }

    public function contractTypes(bool $onlyActive): array
    {
        return $this->call('SP_BBF_TIPOS_CONTRATO_LISTAR', [(int) $onlyActive]);
    }

    public function listLaborDocumentTypes(?bool $active, ?bool $appliesApplicant, ?bool $appliesContracting, ?bool $appliesRetirement): array
    {
        return $this->call('SP_BBF_TIPOS_DOCUMENTO_LABORAL_LISTAR', [
            $this->nullableBool($active),
            $this->nullableBool($appliesApplicant),
            $this->nullableBool($appliesContracting),
            $this->nullableBool($appliesRetirement),
        ]);
    }

    private function nullableBool(?bool $value): ?int
    {
        return $value === null ? null : (int) $value;
    }
}
