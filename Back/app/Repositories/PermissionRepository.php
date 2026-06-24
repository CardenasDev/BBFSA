<?php

namespace App\Repositories;

class PermissionRepository extends StoredProcedureRepository
{
    public function permissions(bool $onlyActive, ?string $module): array
    {
        return $this->call('SP_BBF_PERMISOS_LISTAR', [(int) $onlyActive, $module]);
    }

    public function rolePermissions(int $roleId): array
    {
        return $this->call('SP_BBF_ROL_OBTENER_PERMISOS', [$roleId]);
    }

    public function assignRolePermission(int $roleId, int $permissionId): void
    {
        $this->call('SP_BBF_ROL_PERMISOS_ASIGNAR', [$roleId, $permissionId]);
    }

    public function removeRolePermission(int $roleId, int $permissionId): void
    {
        $this->call('SP_BBF_ROL_PERMISOS_QUITAR', [$roleId, $permissionId]);
    }
}
