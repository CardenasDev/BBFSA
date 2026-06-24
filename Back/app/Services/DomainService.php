<?php

namespace App\Services;

use App\Exceptions\ApiException;
use App\Repositories\DomainRepository;

class DomainService
{
    public function __construct(private readonly DomainRepository $domains) {}

    public function listDomains(bool $onlyActive): array
    {
        return $this->domains->all($onlyActive);
    }

    public function create(array $data): array
    {
        $domain = $this->normalizeDomain($data['dominio']);

        if ($this->domainExists($domain)) {
            throw new ApiException('El dominio autorizado ya existe.', 422, ['dominio' => ['El dominio autorizado ya existe.']]);
        }

        $domainId = $this->domains->create($domain);

        if ($domainId < 1) {
            throw new ApiException('No fue posible crear el dominio autorizado.', 500);
        }

        return $this->find($domainId);
    }

    public function changeState(int $domainId, bool $active): array
    {
        $this->find($domainId);
        $this->domains->changeState($domainId, $active ? 1 : 0);

        return $this->find($domainId);
    }

    public function find(int $domainId): array
    {
        $domain = $this->domains->find($domainId);

        if (! $domain) {
            throw new ApiException('Dominio autorizado no encontrado.', 404);
        }

        return $domain;
    }

    private function normalizeDomain(string $domain): string
    {
        $normalized = mb_strtolower(trim($domain));

        return ltrim($normalized, '@');
    }

    private function domainExists(string $domain): bool
    {
        foreach ($this->domains->all(false) as $existing) {
            if (mb_strtolower((string) ($existing['dominio'] ?? '')) === $domain) {
                return true;
            }
        }

        return false;
    }
}
