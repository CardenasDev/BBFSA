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

    public function laborDocumentTypes(?bool $active, ?bool $appliesApplicant, ?bool $appliesContracting, ?bool $appliesRetirement): array
    {
        return array_map(static fn (array $row): array => [
            'id_tipo_documento_laboral' => (int) ($row['id_tipo_documento_laboral'] ?? 0),
            'nombre' => (string) ($row['nombre'] ?? ''),
            'descripcion' => $row['descripcion'] ?? null,
            'obligatorio' => (bool) ($row['obligatorio'] ?? false),
            'requiere_vencimiento' => (bool) ($row['requiere_vencimiento'] ?? false),
            'aplica_aspirante' => (bool) ($row['aplica_aspirante'] ?? false),
            'aplica_contratacion' => (bool) ($row['aplica_contratacion'] ?? false),
            'aplica_retiro' => (bool) ($row['aplica_retiro'] ?? false),
            'activo' => (bool) ($row['activo'] ?? false),
        ], $this->catalogs->listLaborDocumentTypes($active, $appliesApplicant, $appliesContracting, $appliesRetirement));
    }
}
