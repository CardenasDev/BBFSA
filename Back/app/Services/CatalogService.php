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

    public function departments(): array
    {
        $departments = array_map(static fn (array $row): array => [
            'id_departamento' => (int) ($row['id_departamento'] ?? 0),
            'codigo_dane' => (string) ($row['codigo_dane'] ?? ''),
            'nombre' => (string) ($row['nombre'] ?? ''),
        ], array_filter(
            $this->catalogs->departments(),
            static fn (array $row): bool => ! array_key_exists('activo', $row) || (bool) $row['activo'],
        ));

        usort($departments, static fn (array $left, array $right): int => strcasecmp($left['nombre'], $right['nombre']));

        return $departments;
    }

    public function municipalities(int $departmentId): array
    {
        $municipalities = array_map(static fn (array $row): array => [
            'id_municipio' => (int) ($row['id_municipio'] ?? 0),
            'id_departamento' => (int) ($row['id_departamento'] ?? 0),
            'codigo_dane' => (string) ($row['codigo_dane'] ?? ''),
            'nombre' => (string) ($row['nombre'] ?? ''),
        ], array_filter(
            $this->catalogs->municipalities($departmentId),
            static fn (array $row): bool => (int) ($row['id_departamento'] ?? 0) === $departmentId
                && (! array_key_exists('activo', $row) || (bool) $row['activo']),
        ));

        usort($municipalities, static fn (array $left, array $right): int => strcasecmp($left['nombre'], $right['nombre']));

        return $municipalities;
    }

    public function socialSecurityEntities(string $type): array
    {
        return $this->catalogs->socialSecurityEntities($type);
    }

    public function medicalExamTypes(): array
    {
        return $this->catalogs->medicalExamTypes();
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
