<?php

namespace App\Repositories;

class DomainRepository extends StoredProcedureRepository
{
    public function all(bool $onlyActive): array
    {
        return $this->call('SP_BBF_DOMINIOS_LISTAR', [(int) $onlyActive]);
    }

    public function find(int $domainId): ?array
    {
        foreach ($this->all(false) as $domain) {
            if ((int) ($domain['id_dominio'] ?? 0) === $domainId) {
                return $domain;
            }
        }

        return null;
    }

    public function create(string $domain): int
    {
        $row = $this->first('SP_BBF_DOMINIOS_CREAR', [$domain]);

        return (int) ($row['id_dominio'] ?? 0);
    }

    public function changeState(int $domainId, int $active): void
    {
        $this->call('SP_BBF_DOMINIOS_CAMBIAR_ESTADO', [$domainId, $active]);
    }
}
