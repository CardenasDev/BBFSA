<?php

namespace App\Http\Controllers\Api;

use App\Http\Requests\AssignRolePermissionRequest;
use App\Http\Requests\StoreRoleRequest;
use App\Http\Requests\UpdateRoleStateRequest;
use App\Services\PermissionService;
use App\Services\RoleService;
use Dedoc\Scramble\Attributes\Group;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class RoleController extends ApiController
{
    public function __construct(
        private readonly RoleService $roles,
        private readonly PermissionService $permissions,
    ) {}

    /**
     * Listar roles
     *
     * Retorna el catálogo de roles, opcionalmente solo los activos.
     */
    #[Group('Roles', 'Catálogo de roles del sistema.', weight: 3)]
    public function roles(Request $request): JsonResponse
    {
        return $this->success($this->roles->roles($request->boolean('solo_activos', true)));
    }

    /**
     * Crear rol
     *
     * Crea un nuevo rol en el sistema.
     */
    #[Group('Roles', 'Catálogo de roles del sistema.', weight: 3)]
    public function store(StoreRoleRequest $request): JsonResponse
    {
        return $this->success($this->roles->create($request->validated()), 'Rol creado exitosamente.', 201);
    }

    /**
     * Cambiar estado del rol
     *
     * Activa o inactiva un rol existente.
     */
    #[Group('Roles', 'Catálogo de roles del sistema.', weight: 3)]
    public function changeState(UpdateRoleStateRequest $request, int $id): JsonResponse
    {
        return $this->success($this->roles->changeState($id, $request->boolean('activo')), 'Estado actualizado exitosamente.');
    }

    /**
     * Eliminar rol
     *
     * Elimina logicamente un rol sin borrar permisos ni asignaciones historicas.
     */
    #[Group('Roles', 'CatÃ¡logo de roles del sistema.', weight: 3)]
    public function destroy(int $id): JsonResponse
    {
        return $this->success($this->roles->deleteLogical($id), 'Rol eliminado exitosamente.');
    }

    /**
     * Listar permisos asignados al rol
     *
     * Retorna los permisos que tiene asignado un rol.
     */
    #[Group('Roles', 'Catálogo de roles del sistema.', weight: 3)]
    public function rolePermissions(int $id): JsonResponse
    {
        return $this->success($this->permissions->rolePermissions($id));
    }

    /**
     * Asignar permiso al rol
     *
     * Asigna un permiso existente a un rol.
     */
    #[Group('Roles', 'Catálogo de roles del sistema.', weight: 3)]
    public function assignPermission(AssignRolePermissionRequest $request, int $id): JsonResponse
    {
        $this->permissions->assignRolePermission($id, $request->integer('id_permiso'));

        return $this->success($this->permissions->rolePermissions($id), 'Permiso asignado exitosamente.');
    }

    /**
     * Retirar permiso del rol
     *
     * Elimina un permiso asignado de un rol.
     */
    #[Group('Roles', 'Catálogo de roles del sistema.', weight: 3)]
    public function removePermission(int $id, int $permissionId): JsonResponse
    {
        $this->permissions->removeRolePermission($id, $permissionId);

        return $this->success($this->permissions->rolePermissions($id), 'Permiso retirado exitosamente.');
    }

    /**
     * Listar permisos
     *
     * Retorna el catálogo de permisos y permite filtrar por módulo.
     */
    #[Group('Permissions', 'Catálogo de permisos del sistema.', weight: 4)]
    public function permissions(Request $request): JsonResponse
    {
        return $this->success($this->permissions->permissions(
            $request->boolean('solo_activos', true),
            $request->query('modulo'),
        ));
    }
}
