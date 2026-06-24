<?php

namespace App\Services;

use App\Repositories\CatalogRepository;

class CatalogService
{
    public function __construct(private readonly CatalogRepository $catalogs) {}

    public function documentTypes(bool $onlyActive = true): array
    {
        return array_map(static fn (array $row): array => [
            'id_tipo_documento' => (int) ($row['id_tipo_documento'] ?? 0),
            'nombre' => (string) ($row['nombre'] ?? ''),
            'activo' => (bool) ($row['activo'] ?? false),
        ], $this->catalogs->documentTypes($onlyActive));
    }

    public function areas(bool $onlyActive = true): array
    {
        return array_map(static fn (array $row): array => [
            'id_area' => (int) ($row['id_area'] ?? 0),
            'nombre' => (string) ($row['nombre'] ?? ''),
            'descripcion' => $row['descripcion'] ?? null,
            'activo' => (bool) ($row['activo'] ?? false),
        ], $this->catalogs->areas($onlyActive));
    }

    public function positions(bool $onlyActive = true): array
    {
        return array_map(static fn (array $row): array => [
            'id_cargo' => (int) ($row['id_cargo'] ?? 0),
            'nombre' => (string) ($row['nombre'] ?? ''),
            'descripcion' => $row['descripcion'] ?? null,
            'activo' => (bool) ($row['activo'] ?? false),
        ], $this->catalogs->positions($onlyActive));
    }

    public function contractTypes(bool $onlyActive = true): array
    {
        return array_map(static fn (array $row): array => [
            'id_tipo_contrato' => (int) ($row['id_tipo_contrato'] ?? 0),
            'nombre' => (string) ($row['nombre'] ?? ''),
            'descripcion' => $row['descripcion'] ?? null,
            'activo' => (bool) ($row['activo'] ?? false),
        ], $this->catalogs->contractTypes($onlyActive));
    }
}
