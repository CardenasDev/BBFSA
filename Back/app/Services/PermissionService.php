<?php

namespace App\Services;

use App\Repositories\PermissionRepository;

class PermissionService
{
    public function __construct(private readonly PermissionRepository $permissions) {}

    public function permissions(bool $onlyActive, ?string $module): array
    {
        return $this->permissions->permissions($onlyActive, $module);
    }

    public function rolePermissions(int $roleId): array
    {
        return $this->permissions->rolePermissions($roleId);
    }

    public function assignRolePermission(int $roleId, int $permissionId): void
    {
        $this->permissions->assignRolePermission($roleId, $permissionId);
    }

    public function removeRolePermission(int $roleId, int $permissionId): void
    {
        $this->permissions->removeRolePermission($roleId, $permissionId);
    }
}
