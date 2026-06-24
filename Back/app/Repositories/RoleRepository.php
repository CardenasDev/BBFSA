<?php

namespace App\Repositories;

use Illuminate\Support\Facades\DB;

class RoleRepository extends StoredProcedureRepository
{
    private const CRITICAL_ADMIN_PERMISSIONS = [
        'USUARIOS_CREAR',
        'USUARIOS_EDITAR',
        'USUARIOS_CAMBIAR_ESTADO',
        'USUARIOS_ASIGNAR_ROL',
        'USUARIOS_QUITAR_ROL',
        'ROLES_CREAR',
        'ROLES_EDITAR',
    ];

    public function roles(bool $onlyActive): array
    {
        return $this->call('SP_BBF_ROLES_LISTAR', [(int) $onlyActive]);
    }

    public function find(int $roleId): ?array
    {
        foreach ($this->roles(false) as $role) {
            if ((int) ($role['id_rol'] ?? 0) === $roleId) {
                return $role;
            }
        }

        return null;
    }

    public function create(string $name, ?string $description): int
    {
        $row = $this->first('SP_BBF_ROLES_CREAR', [$name, $description]);

        return (int) ($row['id_rol'] ?? 0);
    }

    public function changeState(int $roleId, int $active): void
    {
        $this->call('SP_BBF_ROLES_CAMBIAR_ESTADO', [$roleId, $active]);
    }

    public function deleteLogical(int $roleId): int
    {
        $row = $this->first('SP_BBF_ROLES_ELIMINAR', [$roleId]);

        return (int) ($row['filas_afectadas'] ?? 0);
    }

    public function permissions(bool $onlyActive, ?string $module): array
    {
        return $this->call('SP_BBF_PERMISOS_LISTAR', [(int) $onlyActive, $module]);
    }

    public function roleHasCriticalAdminPermissions(int $roleId): bool
    {
        return DB::table('BBF_ROL_PERMISOS as rp')
            ->join('BBF_PERMISOS as p', 'p.ID_PERMISO', '=', 'rp.ID_PERMISO')
            ->where('rp.ID_ROL', $roleId)
            ->where('p.ACTIVO', 1)
            ->whereIn('p.CODIGO', self::CRITICAL_ADMIN_PERMISSIONS)
            ->exists();
    }

    public function activeRolesWithCriticalAdminPermissionsExcept(int $roleId): int
    {
        return DB::table('BBF_ROLES as r')
            ->join('BBF_ROL_PERMISOS as rp', 'rp.ID_ROL', '=', 'r.ID_ROL')
            ->join('BBF_PERMISOS as p', 'p.ID_PERMISO', '=', 'rp.ID_PERMISO')
            ->where('r.ID_ROL', '<>', $roleId)
            ->where('r.ACTIVO', 1)
            ->where('r.ELIMINADO', 0)
            ->where('p.ACTIVO', 1)
            ->whereIn('p.CODIGO', self::CRITICAL_ADMIN_PERMISSIONS)
            ->distinct('r.ID_ROL')
            ->count('r.ID_ROL');
    }

    public function activeSuperAdminUsersCount(): int
    {
        return DB::table('BBF_USUARIOS as u')
            ->join('BBF_USUARIO_ROLES as ur', 'ur.ID_USUARIO', '=', 'u.ID_USUARIO')
            ->join('BBF_ROLES as r', 'r.ID_ROL', '=', 'ur.ID_ROL')
            ->where('u.ESTADO', 'ACTIVO')
            ->where('r.NOMBRE', 'SUPER_ADMIN')
            ->where('r.ACTIVO', 1)
            ->where('r.ELIMINADO', 0)
            ->distinct('u.ID_USUARIO')
            ->count('u.ID_USUARIO');
    }
}
