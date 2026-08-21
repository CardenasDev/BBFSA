<?php

namespace App\Repositories;

class ParametersRepository extends StoredProcedureRepository
{
    public function departmentsList(bool $includeInactive): array { return $this->call('SP_BBF_PARAM_DEPARTAMENTOS_LISTAR', [(int) $includeInactive]); }
    public function saveDepartment(?int $id, string $code, string $name, bool $active): array { return $this->first('SP_BBF_PARAM_DEPARTAMENTO_GUARDAR', [$id, $code, $name, (int) $active]); }
    public function municipalitiesList(?int $departmentId, bool $includeInactive): array { return $this->call('SP_BBF_PARAM_MUNICIPIOS_LISTAR', [$departmentId, (int) $includeInactive]); }
    public function saveMunicipality(?int $id, int $departmentId, string $code, string $name, bool $active): array { return $this->first('SP_BBF_PARAM_MUNICIPIO_GUARDAR', [$id, $departmentId, $code, $name, (int) $active]); }

    public function areasList(bool $includeInactive): array
    {
        return $this->call('SP_BBF_PARAM_AREAS_LISTAR', [(int) $includeInactive]);
    }

    public function saveArea(?int $id, string $nombre, ?string $descripcion, bool $activo): array
    {
        return $this->first('SP_BBF_PARAM_AREAS_GUARDAR', [$id ?: null, $nombre, $descripcion, (int) $activo]);
    }

    public function positionsList(bool $includeInactive): array
    {
        return $this->call('SP_BBF_PARAM_CARGOS_LISTAR', [(int) $includeInactive]);
    }

    public function savePosition(?int $id, string $nombre, ?string $descripcion, bool $activo): array
    {
        return $this->first('SP_BBF_PARAM_CARGOS_GUARDAR', [$id ?: null, $nombre, $descripcion, (int) $activo]);
    }

    public function contractTypesList(bool $includeInactive): array
    {
        return $this->call('SP_BBF_PARAM_TIPOS_CONTRATO_LISTAR', [(int) $includeInactive]);
    }

    public function saveContractType(?int $id, string $nombre, ?string $descripcion, bool $activo): array
    {
        return $this->first('SP_BBF_PARAM_TIPOS_CONTRATO_GUARDAR', [$id ?: null, $nombre, $descripcion, (int) $activo]);
    }

    public function documentTypesList(bool $includeInactive): array
    {
        return $this->call('SP_BBF_PARAM_TIPOS_DOCUMENTO_LISTAR', [(int) $includeInactive]);
    }

    public function saveDocumentType(?int $id, string $nombre, bool $activo): array
    {
        return $this->first('SP_BBF_PARAM_TIPOS_DOCUMENTO_GUARDAR', [$id ?: null, $nombre, (int) $activo]);
    }

    public function laborDocumentsList(bool $includeInactive): array
    {
        return $this->call('SP_BBF_PARAM_DOCUMENTOS_LABORALES_LISTAR', [(int) $includeInactive]);
    }

    public function saveLaborDocument(?int $id, string $nombre, ?string $descripcion, bool $obligatorio, bool $requiereVencimiento, bool $aplicaAspirante, bool $aplicaContratacion, bool $aplicaRetiro, bool $activo): array
    {
        return $this->first('SP_BBF_PARAM_DOCUMENTO_LABORAL_GUARDAR', [
            $id ?: null,
            $nombre,
            $descripcion,
            (int) $obligatorio,
            (int) $requiereVencimiento,
            (int) $aplicaAspirante,
            (int) $aplicaContratacion,
            (int) $aplicaRetiro,
            (int) $activo,
        ]);
    }

    public function socialSecurityList(string $type, bool $includeInactive): array
    {
        return $this->call('SP_BBF_PARAM_SEGURIDAD_SOCIAL_LISTAR', [$type, (int) $includeInactive]);
    }

    public function saveSocialSecurityEntity(?int $id, string $type, string $nombre, ?string $nit, bool $activo): array
    {
        return $this->first('SP_BBF_PARAM_SEGURIDAD_SOCIAL_GUARDAR', [$id ?: null, $type, $nombre, $nit, (int) $activo]);
    }

    public function medicalExamTypesList(bool $includeInactive): array
    {
        return $this->call('SP_BBF_PARAM_TIPOS_EXAMEN_LISTAR', [(int) $includeInactive]);
    }

    public function saveMedicalExamType(?int $id, string $nombre, ?string $descripcion, bool $activo): array
    {
        return $this->first('SP_BBF_PARAM_TIPO_EXAMEN_GUARDAR', [$id ?: null, $nombre, $descripcion, (int) $activo]);
    }

    public function noveltyTypesList(bool $includeInactive): array
    {
        return $this->call('SP_BBF_PARAM_TIPOS_NOVEDAD_LISTAR', [(int) $includeInactive]);
    }

    public function saveNoveltyType(?int $id, ?string $codigo, string $nombre, ?string $descripcion, bool $requiereFechaFin, bool $requiereSoporte, bool $esIncapacidad, bool $activo): array
    {
        return $this->first('SP_BBF_PARAM_TIPO_NOVEDAD_GUARDAR', [
            $id ?: null, $codigo, $nombre, $descripcion,
            (int) $requiereFechaFin, (int) $requiereSoporte,
            (int) $esIncapacidad, (int) $activo,
        ]);
    }

    public function dotationArticlesList(bool $includeInactive): array
    {
        return $this->call('SP_BBF_PARAM_DOTACION_ARTICULOS_LISTAR', [(int) $includeInactive]);
    }

    public function saveDotationArticle(?int $id, ?string $codigo, int $idTipoDotacion, string $nombre, ?string $descripcion, string $genero, string $unidadMedida, bool $activo): array
    {
        return $this->first('SP_BBF_PARAM_DOTACION_ARTICULO_GUARDAR', [
            $id ?: null,
            $codigo,
            $idTipoDotacion,
            $nombre,
            $descripcion,
            $genero,
            $unidadMedida,
            (int) $activo,
        ]);
    }

    public function systemParametersList(): array
    {
        return $this->call('SP_BBF_PARAMETROS_LISTAR');
    }

    public function saveSystemParameter($id, string $codigo, string $nombre, string $grupo, ?string $descripcion, string $tipoDato, $valor, ?string $unidadMedida, ?string $vigenciaDesde, ?string $vigenciaHasta, bool $activo, bool $editable, int $idUsuario): array
    {
        return $this->first('SP_BBF_PARAM_SISTEMA_GUARDAR', [
            $id ?: null,
            $codigo,
            $nombre,
            $grupo,
            $descripcion,
            $tipoDato,
            $valor,
            $unidadMedida,
            $vigenciaDesde,
            $vigenciaHasta,
            (int) $activo,
            (int) $editable,
            $idUsuario,
        ]);
    }
}
