<?php

namespace App\Services;

use App\Exceptions\ApiException;
use App\Repositories\RoleRepository;

class RoleService
{
    public function __construct(private readonly RoleRepository $roles) {}

    public function roles(bool $onlyActive): array
    {
        return $this->roles->roles($onlyActive);
    }

    public function find(int $roleId): array
    {
        $role = $this->roles->find($roleId);
        if (! $role) {
            throw new ApiException('Rol no encontrado.', 404);
        }

        return $role;
    }

    public function create(array $data): array
    {
        $roleId = $this->roles->create($data['nombre'], $data['descripcion'] ?? null);
        if ($roleId < 1) {
            throw new ApiException('No fue posible crear el rol.', 500);
        }

        return $this->find($roleId);
    }

    public function changeState(int $roleId, bool $active): array
    {
        $this->find($roleId);
        $this->roles->changeState($roleId, $active ? 1 : 0);

        return $this->find($roleId);
    }

    public function deleteLogical(int $roleId): array
    {
        $role = $this->find($roleId);
        $name = strtoupper((string) ($role['nombre'] ?? ''));

        if ($name === 'SUPER_ADMIN') {
            throw new ApiException('No se puede eliminar el rol SUPER_ADMIN.', 422, [
                'id_rol' => ['El rol SUPER_ADMIN es requerido para administrar el sistema.'],
            ]);
        }

        if ($this->roles->activeSuperAdminUsersCount() < 1) {
            throw new ApiException('No se puede eliminar roles mientras no exista un SUPER_ADMIN activo.', 422, [
                'id_rol' => ['Debe existir al menos un usuario activo con rol SUPER_ADMIN.'],
            ]);
        }

        if ($this->roles->roleHasCriticalAdminPermissions($roleId)
            && $this->roles->activeRolesWithCriticalAdminPermissionsExcept($roleId) < 1) {
            throw new ApiException('No se puede eliminar el unico rol con permisos administrativos criticos.', 422, [
                'id_rol' => ['Debe existir al menos otro rol activo con permisos administrativos criticos.'],
            ]);
        }

        $affected = $this->roles->deleteLogical($roleId);
        if ($affected < 1) {
            throw new ApiException('El rol no existe o ya fue eliminado.', 404);
        }

        return [
            'id_rol' => $roleId,
            'eliminado' => true,
        ];
    }

    public function permissions(bool $onlyActive, ?string $module): array
    {
        return $this->roles->permissions($onlyActive, $module);
    }
}
