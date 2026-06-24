<?php

namespace App\Http\Controllers\Api;

use App\Http\Requests\AssignRoleRequest;
use App\Http\Requests\StoreUserRequest;
use App\Http\Requests\UpdateUserRequest;
use App\Http\Requests\UpdateUserStatusRequest;
use App\Services\UserService;
use Dedoc\Scramble\Attributes\Group;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

#[Group('Users', 'Administración de usuarios, roles y permisos asignados.', weight: 2)]
class UserController extends ApiController
{
    public function __construct(private readonly UserService $users) {}

    /**
     * Listar usuarios
     *
     * Permite filtrar por estado, tipo de usuario y texto de búsqueda.
     */
    public function index(Request $request): JsonResponse
    {
        return $this->success($this->users->list(
            $request->query('estado'),
            $request->query('tipo_usuario'),
            $request->query('buscar'),
        ));
    }

    /**
     * Obtener usuario
     *
     * Retorna un usuario por su identificador.
     */
    public function show(int $id): JsonResponse
    {
        return $this->success($this->users->find($id));
    }

    /**
     * Crear usuario
     *
     * Crea un usuario con contraseña cifrada mediante el procedimiento almacenado correspondiente.
     */
    public function store(StoreUserRequest $request): JsonResponse
    {
        $user = $this->users->create($request->validated(), $this->actorId($request), $this->context($request));

        return $this->success($user, 'Usuario creado exitosamente.', 201);
    }

    /**
     * Actualizar usuario
     *
     * Actualiza los datos del usuario sin cambiar la contraseña ni los roles.
     */
    public function update(UpdateUserRequest $request, int $id): JsonResponse
    {
        $user = $this->users->update($id, $request->validated(), $this->actorId($request), $this->context($request));

        return $this->success($user, 'Usuario actualizado exitosamente.');
    }

    /**
     * Cambiar estado de usuario
     *
     * Establece el estado ACTIVO, INACTIVO, BLOQUEADO o ELIMINADO.
     */
    public function changeStatus(UpdateUserStatusRequest $request, int $id): JsonResponse
    {
        $user = $this->users->changeStatus($id, (string) $request->string('estado'), $this->actorId($request), $this->context($request));

        return $this->success($user, 'Estado actualizado exitosamente.');
    }

    /**
     * Asignar rol
     *
     * Asigna un rol al usuario y retorna sus roles vigentes.
     */
    public function assignRole(AssignRoleRequest $request, int $id): JsonResponse
    {
        $roles = $this->users->assignRole($id, $request->integer('id_rol'), $this->actorId($request), $this->context($request));

        return $this->success($roles, 'Rol asignado exitosamente.');
    }

    /**
     * Retirar rol
     *
     * Retira un rol del usuario y retorna sus roles vigentes.
     */
    public function removeRole(Request $request, int $id, int $roleId): JsonResponse
    {
        $roles = $this->users->removeRole($id, $roleId, $this->actorId($request), $this->context($request));

        return $this->success($roles, 'Rol retirado exitosamente.');
    }

    /**
     * Listar roles del usuario
     *
     * Retorna los roles activos asignados al usuario.
     */
    public function roles(int $id): JsonResponse
    {
        return $this->success($this->users->roles($id));
    }

    /**
     * Listar permisos del usuario
     *
     * Retorna los permisos efectivos derivados de sus roles.
     */
    public function permissions(int $id): JsonResponse
    {
        return $this->success($this->users->permissions($id));
    }
}
