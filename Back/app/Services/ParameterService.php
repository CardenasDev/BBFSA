<?php

namespace App\Services;

use App\Exceptions\ApiException;
use Illuminate\Support\Str;

use App\Repositories\ParametersRepository;

class ParameterService
{
    public function __construct(private readonly ParametersRepository $repo, private readonly AuditService $audit) {}

    public function departments(bool $includeInactive = false): array
    {
        return array_map(static fn(array $r) => ['id_departamento'=>(int)$r['id_departamento'],'codigo_dane'=>(string)$r['codigo_dane'],'nombre'=>(string)$r['nombre'],'activo'=>(bool)$r['activo'],'total_municipios'=>(int)($r['total_municipios']??0),'municipios_activos'=>(int)($r['municipios_activos']??0)], $this->repo->departmentsList($includeInactive));
    }
    public function saveDepartment(array $data, ?int $userId, array $context): array
    {
        $id=$data['id_departamento']??null; $before=$id?collect($this->departments(true))->firstWhere('id_departamento',(int)$id):null;
        $result=$this->repo->saveDepartment($id,$data['codigo_dane'],$data['nombre'],(bool)($data['activo']??true));
        $saved=(int)($result['id_departamento']??$id); $after=collect($this->departments(true))->firstWhere('id_departamento',$saved)??$result;
        $this->audit->record($userId,'PARAMETROS',$id?'ACTUALIZAR':'CREAR','DEPARTAMENTO',$saved,$before,$after,$context); return $after;
    }
    public function municipalities(?int $departmentId, bool $includeInactive = false): array
    {
        return array_map(static fn(array $r) => ['id_municipio'=>(int)$r['id_municipio'],'id_departamento'=>(int)$r['id_departamento'],'codigo_departamento'=>(string)$r['codigo_departamento'],'departamento'=>(string)$r['departamento'],'codigo_dane'=>(string)$r['codigo_dane'],'nombre'=>(string)$r['nombre'],'activo'=>(bool)$r['activo']], $this->repo->municipalitiesList($departmentId,$includeInactive));
    }
    public function saveMunicipality(array $data, ?int $userId, array $context): array
    {
        $id=$data['id_municipio']??null; $before=$id?collect($this->municipalities(null,true))->firstWhere('id_municipio',(int)$id):null;
        $result=$this->repo->saveMunicipality($id,(int)$data['id_departamento'],$data['codigo_dane'],$data['nombre'],(bool)($data['activo']??true));
        $saved=(int)($result['id_municipio']??$id); $after=collect($this->municipalities(null,true))->firstWhere('id_municipio',$saved)??$result;
        $this->audit->record($userId,'PARAMETROS',$id?'ACTUALIZAR':'CREAR','MUNICIPIO',$saved,$before,$after,$context); return $after;
    }

    public function areas(bool $onlyActive = true): array
    {
        return array_map(static fn (array $row): array => [
            'id_area' => (int) ($row['id_area'] ?? 0),
            'nombre' => (string) ($row['nombre'] ?? ''),
            'descripcion' => $row['descripcion'] ?? null,
            'activo' => (bool) ($row['activo'] ?? false),
        ], $this->repo->areasList($onlyActive));
    }

    public function saveArea(array $data, ?int $userId, array $context): array
    {
        $before = null;
        if (! empty($data['id_area'])) {
            $existing = array_filter($this->areas(true), fn($r) => $r['id_area'] === (int) $data['id_area']);
            $before = $existing ? array_values($existing)[0] : null;
        }

        $result = $this->repo->saveArea($data['id_area'] ?? null, $data['nombre'], $data['descripcion'] ?? null, $data['activo'] ?? true);

        $after = null;
        $id = $result['id_area'] ?? null;
        if ($id) {
            $found = array_filter($this->areas(true), fn($r) => $r['id_area'] === (int) $id);
            $after = $found ? array_values($found)[0] : null;
        }

        $action = 'CREAR';
        if (! empty($data['id_area'])) {
            if (is_array($before) && is_array($after)) {
                if (($before['activo'] ?? false) === true && ($after['activo'] ?? false) === false) {
                    $action = 'INACTIVAR';
                } elseif (($before['activo'] ?? false) === false && ($after['activo'] ?? false) === true) {
                    $action = 'ACTIVAR';
                } else {
                    $action = 'ACTUALIZAR';
                }
            } else {
                $action = 'ACTUALIZAR';
            }
        }

        $this->audit->record($userId, 'PARAMETROS', $action, 'AREA', $id ?? null, $before, $after ?? $data, $context);

        return $result;
    }

    public function positions(bool $onlyActive = true): array
    {
        return array_map(static fn (array $row): array => [
            'id_cargo' => (int) ($row['id_cargo'] ?? 0),
            'nombre' => (string) ($row['nombre'] ?? ''),
            'descripcion' => $row['descripcion'] ?? null,
            'activo' => (bool) ($row['activo'] ?? false),
        ], $this->repo->positionsList($onlyActive));
    }

    public function savePosition(array $data, ?int $userId, array $context): array
    {
        $before = null;
        if (! empty($data['id_cargo'])) {
            $existing = array_filter($this->positions(true), fn($r) => $r['id_cargo'] === (int) $data['id_cargo']);
            $before = $existing ? array_values($existing)[0] : null;
        }

        $result = $this->repo->savePosition($data['id_cargo'] ?? null, $data['nombre'], $data['descripcion'] ?? null, $data['activo'] ?? true);

        $after = null;
        $id = $result['id_cargo'] ?? null;
        if ($id) {
            $found = array_filter($this->positions(true), fn($r) => $r['id_cargo'] === (int) $id);
            $after = $found ? array_values($found)[0] : null;
        }

        $action = 'CREAR';
        if (! empty($data['id_cargo'])) {
            if (is_array($before) && is_array($after)) {
                if (($before['activo'] ?? false) === true && ($after['activo'] ?? false) === false) {
                    $action = 'INACTIVAR';
                } elseif (($before['activo'] ?? false) === false && ($after['activo'] ?? false) === true) {
                    $action = 'ACTIVAR';
                } else {
                    $action = 'ACTUALIZAR';
                }
            } else {
                $action = 'ACTUALIZAR';
            }
        }

        $this->audit->record($userId, 'PARAMETROS', $action, 'CARGO', $id ?? null, $before, $after ?? $data, $context);

        return $result;
    }

    public function contractTypes(bool $onlyActive = true): array
    {
        return array_map(static fn (array $row): array => [
            'id_tipo_contrato' => (int) ($row['id_tipo_contrato'] ?? 0),
            'nombre' => (string) ($row['nombre'] ?? ''),
            'descripcion' => $row['descripcion'] ?? null,
            'activo' => (bool) ($row['activo'] ?? false),
        ], $this->repo->contractTypesList($onlyActive));
    }

    public function saveContractType(array $data, ?int $userId, array $context): array
    {
        $before = null;
        if (! empty($data['id_tipo_contrato'])) {
            $existing = array_filter($this->contractTypes(true), fn($r) => $r['id_tipo_contrato'] === (int) $data['id_tipo_contrato']);
            $before = $existing ? array_values($existing)[0] : null;
        }

        $result = $this->repo->saveContractType($data['id_tipo_contrato'] ?? null, $data['nombre'], $data['descripcion'] ?? null, $data['activo'] ?? true);

        $after = null;
        $id = $result['id_tipo_contrato'] ?? null;
        if ($id) {
            $found = array_filter($this->contractTypes(true), fn($r) => $r['id_tipo_contrato'] === (int) $id);
            $after = $found ? array_values($found)[0] : null;
        }

        $action = 'CREAR';
        if (! empty($data['id_tipo_contrato'])) {
            if (is_array($before) && is_array($after)) {
                if (($before['activo'] ?? false) === true && ($after['activo'] ?? false) === false) {
                    $action = 'INACTIVAR';
                } elseif (($before['activo'] ?? false) === false && ($after['activo'] ?? false) === true) {
                    $action = 'ACTIVAR';
                } else {
                    $action = 'ACTUALIZAR';
                }
            } else {
                $action = 'ACTUALIZAR';
            }
        }

        $this->audit->record($userId, 'PARAMETROS', $action, 'TIPO_CONTRATO', $id ?? null, $before, $after ?? $data, $context);

        return $result;
    }

    public function documentTypes(bool $onlyActive = true): array
    {
        return array_map(static fn (array $row): array => [
            'id_tipo_documento' => (int) ($row['id_tipo_documento'] ?? 0),
            'nombre' => (string) ($row['nombre'] ?? ''),
            'activo' => (bool) ($row['activo'] ?? false),
        ], $this->repo->documentTypesList($onlyActive));
    }

    public function saveDocumentType(array $data, ?int $userId, array $context): array
    {
        $before = null;
        if (! empty($data['id_tipo_documento'])) {
            $existing = array_filter($this->documentTypes(true), fn($r) => $r['id_tipo_documento'] === (int) $data['id_tipo_documento']);
            $before = $existing ? array_values($existing)[0] : null;
        }

        $result = $this->repo->saveDocumentType($data['id_tipo_documento'] ?? null, $data['nombre'], $data['activo'] ?? true);

        $after = null;
        $id = $result['id_tipo_documento'] ?? null;
        if ($id) {
            $found = array_filter($this->documentTypes(true), fn($r) => $r['id_tipo_documento'] === (int) $id);
            $after = $found ? array_values($found)[0] : null;
        }

        $action = 'CREAR';
        if (! empty($data['id_tipo_documento'])) {
            if (is_array($before) && is_array($after)) {
                if (($before['activo'] ?? false) === true && ($after['activo'] ?? false) === false) {
                    $action = 'INACTIVAR';
                } elseif (($before['activo'] ?? false) === false && ($after['activo'] ?? false) === true) {
                    $action = 'ACTIVAR';
                } else {
                    $action = 'ACTUALIZAR';
                }
            } else {
                $action = 'ACTUALIZAR';
            }
        }

        $this->audit->record($userId, 'PARAMETROS', $action, 'TIPO_DOCUMENTO', $id ?? null, $before, $after ?? $data, $context);

        return $result;
    }

    public function laborDocuments(bool $onlyActive = true): array
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
        ], $this->repo->laborDocumentsList($onlyActive));
    }

    public function saveLaborDocument(array $data, ?int $userId, array $context): array
    {
        $before = null;
        if (! empty($data['id_tipo_documento_laboral'])) {
            $existing = array_filter($this->laborDocuments(true), fn($r) => $r['id_tipo_documento_laboral'] === (int) $data['id_tipo_documento_laboral']);
            $before = $existing ? array_values($existing)[0] : null;
        }
        $result = $this->repo->saveLaborDocument(
            $data['id_tipo_documento_laboral'] ?? null,
            $data['nombre'],
            $data['descripcion'] ?? null,
            $data['obligatorio'] ?? false,
            $data['requiere_vencimiento'] ?? false,
            $data['aplica_aspirante'] ?? false,
            $data['aplica_contratacion'] ?? false,
            $data['aplica_retiro'] ?? false,
            $data['activo'] ?? true,
        );

        $after = null;
        $id = $result['id_tipo_documento_laboral'] ?? null;
        if ($id) {
            $found = array_filter($this->laborDocuments(true), fn($r) => $r['id_tipo_documento_laboral'] === (int) $id);
            $after = $found ? array_values($found)[0] : null;
        }

        $action = 'CREAR';
        if (! empty($data['id_tipo_documento_laboral'])) {
            if (is_array($before) && is_array($after)) {
                if (($before['activo'] ?? false) === true && ($after['activo'] ?? false) === false) {
                    $action = 'INACTIVAR';
                } elseif (($before['activo'] ?? false) === false && ($after['activo'] ?? false) === true) {
                    $action = 'ACTIVAR';
                } else {
                    $action = 'ACTUALIZAR';
                }
            } else {
                $action = 'ACTUALIZAR';
            }
        }

        $this->audit->record($userId, 'PARAMETROS', $action, 'DOCUMENTO_LABORAL', $id ?? null, $before, $after ?? $data, $context);

        return $result;
    }

    public function socialSecurityEntities(string $type, bool $onlyActive = true): array
    {
        return $this->repo->socialSecurityList($type, $onlyActive);
    }

    public function saveSocialSecurityEntity(array $data, ?int $userId, array $context): array
    {
        $before = null;
        if (! empty($data['id_entidad'])) {
            $existing = array_filter($this->socialSecurityEntities($data['tipo_entidad'], true), fn($r) => (int) ($r['id_entidad'] ?? 0) === (int) $data['id_entidad']);
            $before = $existing ? array_values($existing)[0] : null;
        }

        $result = $this->repo->saveSocialSecurityEntity($data['id_entidad'] ?? null, $data['tipo_entidad'], $data['nombre'], $data['nit'] ?? null, $data['activo'] ?? true);

        $after = null;
        $id = $result['id_entidad'] ?? null;
        if ($id) {
            $found = array_filter($this->socialSecurityEntities($data['tipo_entidad'], true), fn($r) => (int) ($r['id_entidad'] ?? 0) === (int) $id);
            $after = $found ? array_values($found)[0] : null;
        }

        $action = 'CREAR';
        if (! empty($data['id_entidad'])) {
            if (is_array($before) && is_array($after)) {
                if (($before['activo'] ?? false) === true && ($after['activo'] ?? false) === false) {
                    $action = 'INACTIVAR';
                } elseif (($before['activo'] ?? false) === false && ($after['activo'] ?? false) === true) {
                    $action = 'ACTIVAR';
                } else {
                    $action = 'ACTUALIZAR';
                }
            } else {
                $action = 'ACTUALIZAR';
            }
        }

        $this->audit->record($userId, 'PARAMETROS', $action, 'ENTIDAD_SEGURIDAD_SOCIAL', $id ?? null, $before, $after ?? $data, $context);

        return $result;
    }

    public function medicalExamTypes(bool $onlyActive = true): array
    {
        return array_map(static fn (array $row): array => [
            'id_tipo_examen' => (int) ($row['id_tipo_examen'] ?? 0),
            'nombre' => (string) ($row['nombre'] ?? ''),
            'descripcion' => $row['descripcion'] ?? null,
            'activo' => (bool) ($row['activo'] ?? false),
        ], $this->repo->medicalExamTypesList($onlyActive));
    }

    public function saveMedicalExamType(array $data, ?int $userId, array $context): array
    {
        $before = null;
        if (! empty($data['id_tipo_examen'])) {
            $existing = array_filter($this->medicalExamTypes(true), fn($r) => $r['id_tipo_examen'] === (int) $data['id_tipo_examen']);
            $before = $existing ? array_values($existing)[0] : null;
        }

        $result = $this->repo->saveMedicalExamType($data['id_tipo_examen'] ?? null, $data['nombre'], $data['descripcion'] ?? null, $data['activo'] ?? true);

        $after = null;
        $id = $result['id_tipo_examen'] ?? null;
        if ($id) {
            $found = array_filter($this->medicalExamTypes(true), fn($r) => $r['id_tipo_examen'] === (int) $id);
            $after = $found ? array_values($found)[0] : null;
        }

        $action = 'CREAR';
        if (! empty($data['id_tipo_examen'])) {
            if (is_array($before) && is_array($after)) {
                if (($before['activo'] ?? false) === true && ($after['activo'] ?? false) === false) {
                    $action = 'INACTIVAR';
                } elseif (($before['activo'] ?? false) === false && ($after['activo'] ?? false) === true) {
                    $action = 'ACTIVAR';
                } else {
                    $action = 'ACTUALIZAR';
                }
            } else {
                $action = 'ACTUALIZAR';
            }
        }

        $this->audit->record($userId, 'PARAMETROS', $action, 'TIPO_EXAMEN_MEDICO', $id ?? null, $before, $after ?? $data, $context);

        return $result;
    }

    public function dotationArticles(bool $onlyActive = true): array
    {
        return array_map(static fn (array $row): array => [
            'id_dotacion_articulo' => (int) ($row['id_dotacion_articulo'] ?? 0),
            'codigo' => $row['codigo'] ?? null,
            'id_tipo_dotacion' => (int) ($row['id_tipo_dotacion'] ?? 0),
            'nombre' => (string) ($row['articulo'] ?? $row['nombre'] ?? ''),
            'descripcion' => $row['descripcion'] ?? null,
            'genero' => $row['genero'] ?? null,
            'unidad_medida' => $row['unidad_medida'] ?? null,
            'activo' => (bool) ($row['activo'] ?? false),
        ], $this->repo->dotationArticlesList($onlyActive));
    }

    public function saveDotationArticle(array $data, ?int $userId, array $context): array
    {
        $before = null;
        if (! empty($data['id_dotacion_articulo'])) {
            $existing = array_filter($this->dotationArticles(true), fn($r) => $r['id_dotacion_articulo'] === (int) $data['id_dotacion_articulo']);
            $before = $existing ? array_values($existing)[0] : null;
        }

        // El código es una clave técnica: se conserva al editar y se genera al crear.
        // De esta forma nunca depende de que el usuario conozca o diligencie el código interno.
        $codigo = is_array($before)
            ? ($before['codigo'] ?? null)
            : $this->nextDotationArticleCode($data['nombre']);

        $result = $this->repo->saveDotationArticle(
            $data['id_dotacion_articulo'] ?? null,
            $codigo,
            $data['id_tipo_dotacion'],
            $data['nombre'],
            $data['descripcion'] ?? null,
            $data['genero'] ?? 'NO_APLICA',
            $data['unidad_medida'] ?? 'UNIDAD',
            $data['activo'] ?? true,
        );

        $after = null;
        $id = $result['id_dotacion_articulo'] ?? null;
        if ($id) {
            $found = array_filter($this->dotationArticles(true), fn($r) => $r['id_dotacion_articulo'] === (int) $id);
            $after = $found ? array_values($found)[0] : null;
        }

        $action = 'CREAR';
        if (! empty($data['id_dotacion_articulo'])) {
            if (is_array($before) && is_array($after)) {
                if (($before['activo'] ?? false) === true && ($after['activo'] ?? false) === false) {
                    $action = 'INACTIVAR';
                } elseif (($before['activo'] ?? false) === false && ($after['activo'] ?? false) === true) {
                    $action = 'ACTIVAR';
                } else {
                    $action = 'ACTUALIZAR';
                }
            } else {
                $action = 'ACTUALIZAR';
            }
        }

        $this->audit->record($userId, 'PARAMETROS', $action, 'DOTACION_ARTICULO', $id ?? null, $before, $after ?? $data, $context);

        return $result;
    }

    public function noveltyTypes(bool $includeInactive = false): array
    {
        return array_map(static fn (array $row): array => [
            'id_tipo_novedad' => (int) ($row['id_tipo_novedad'] ?? 0),
            'codigo' => (string) ($row['codigo'] ?? ''),
            'nombre' => (string) ($row['nombre'] ?? ''),
            'descripcion' => $row['descripcion'] ?? null,
            'requiere_fecha_fin' => (bool) ($row['requiere_fecha_fin'] ?? false),
            'requiere_soporte' => (bool) ($row['requiere_soporte'] ?? false),
            'es_incapacidad' => (bool) ($row['es_incapacidad'] ?? false),
            'activo' => (bool) ($row['activo'] ?? false),
            'total_novedades' => (int) ($row['total_novedades'] ?? 0),
            'novedades_activas' => (int) ($row['novedades_activas'] ?? 0),
        ], $this->repo->noveltyTypesList($includeInactive));
    }

    public function saveNoveltyType(array $data, ?int $userId, array $context): array
    {
        $id = isset($data['id_tipo_novedad']) ? (int) $data['id_tipo_novedad'] : null;
        $before = null;
        if ($id) {
            $before = collect($this->noveltyTypes(true))->firstWhere('id_tipo_novedad', $id);
        }

        $codigo = $before['codigo'] ?? null;
        if (! $id) {
            $base = Str::upper(Str::slug($data['nombre'], '_'));
            $codigo = $base ?: 'NOVEDAD';
            $existing = array_column($this->noveltyTypes(true), 'codigo');
            $candidate = $codigo;
            $suffix = 2;
            while (in_array($candidate, $existing, true)) {
                $candidate = substr($codigo, 0, 46).'_'.$suffix++;
            }
            $codigo = $candidate;
        }

        $result = $this->repo->saveNoveltyType(
            $id,
            $codigo,
            $data['nombre'],
            $data['descripcion'] ?? null,
            (bool) ($data['requiere_fecha_fin'] ?? false),
            (bool) ($data['requiere_soporte'] ?? false),
            (bool) ($data['es_incapacidad'] ?? false),
            (bool) ($data['activo'] ?? true),
        );

        $savedId = (int) ($result['id_tipo_novedad'] ?? $id ?? 0);
        $after = collect($this->noveltyTypes(true))->firstWhere('id_tipo_novedad', $savedId) ?? $result;
        $action = $id ? 'ACTUALIZAR' : 'CREAR';
        if ($id && $before) {
            if ($before['activo'] && ! $after['activo']) $action = 'INACTIVAR';
            elseif (! $before['activo'] && $after['activo']) $action = 'ACTIVAR';
        }
        $this->audit->record($userId, 'PARAMETROS', $action, 'TIPO_NOVEDAD', $savedId ?: null, $before, $after, $context);

        return $after;
    }

    private function nextDotationArticleCode(string $name): string
    {
        $base = strtoupper((string) Str::of(Str::ascii($name))
            ->replaceMatches('/[^A-Za-z0-9]+/', '_')
            ->trim('_'));
        $base = substr($base !== '' ? $base : 'ARTICULO', 0, 50);

        $usedCodes = array_fill_keys(array_filter(array_map(
            static fn (array $article): string => strtoupper((string) ($article['codigo'] ?? '')),
            $this->dotationArticles(true)
        )), true);

        if (! isset($usedCodes[$base])) {
            return $base;
        }

        for ($suffix = 2; ; $suffix++) {
            $tail = '_'.$suffix;
            $candidate = substr($base, 0, 50 - strlen($tail)).$tail;
            if (! isset($usedCodes[$candidate])) {
                return $candidate;
            }
        }
    }

    public function systemParameters(): array
    {
        return $this->repo->systemParametersList();
    }

    public function saveSystemParameter(array $data, ?int $userId, array $context): array
    {
        $before = null;
        if (! empty($data['id_parametro'])) {
            $existing = array_filter($this->systemParameters(), fn($r) => (int) ($r['id_parametro'] ?? 0) === (int) $data['id_parametro']);
            $before = $existing ? array_values($existing)[0] : null;
        }

        $code = strtoupper(trim((string) $data['codigo']));
        $start = (string) ($data['vigencia_desde'] ?? '');
        $end = (string) ($data['vigencia_hasta'] ?? '9999-12-31');
        $editingId = (int) ($data['id_parametro'] ?? 0);
        foreach (($data['activo'] ?? true) ? $this->systemParameters() : [] as $parameter) {
            if ((int) ($parameter['id_parametro'] ?? 0) === $editingId
                || ! (bool) ($parameter['activo'] ?? false)
                || strtoupper((string) ($parameter['codigo'] ?? '')) !== $code) {
                continue;
            }

            $existingStart = (string) ($parameter['vigencia_desde'] ?? '0000-01-01');
            $existingEnd = (string) ($parameter['vigencia_hasta'] ?? '9999-12-31');
            if ($existingStart <= $end && $existingEnd >= $start) {
                throw new ApiException('Ya existe una vigencia activa para este parámetro que se cruza con las fechas indicadas.', 422);
            }
        }

        $result = $this->repo->saveSystemParameter(
            $data['id_parametro'] ?? null,
            $data['codigo'],
            $data['nombre'],
            $data['grupo'] ?? '',
            $data['descripcion'] ?? null,
            $data['tipo_dato'],
            $data['valor'] ?? null,
            $data['unidad_medida'] ?? null,
            $data['vigencia_desde'] ?? null,
            $data['vigencia_hasta'] ?? null,
            $data['activo'] ?? true,
            $data['editable'] ?? true,
            $userId ?? 0,
        );

        $after = null;
        $id = $result['id_parametro'] ?? null;
        if ($id) {
            $found = array_filter($this->systemParameters(), fn($r) => (int) ($r['id_parametro'] ?? 0) === (int) $id);
            $after = $found ? array_values($found)[0] : null;
        }

        $action = 'CREAR';
        if (! empty($data['id_parametro'])) {
            if (is_array($before) && is_array($after)) {
                if (($before['activo'] ?? false) === true && ($after['activo'] ?? false) === false) {
                    $action = 'INACTIVAR';
                } elseif (($before['activo'] ?? false) === false && ($after['activo'] ?? false) === true) {
                    $action = 'ACTIVAR';
                } else {
                    $action = 'ACTUALIZAR';
                }
            } else {
                $action = 'ACTUALIZAR';
            }
        }

        $this->audit->record($userId, 'PARAMETROS', $action, 'PARAMETRO_SISTEMA', $id ?? null, $before, $after ?? $data, $context);

        return $result;
    }
}
