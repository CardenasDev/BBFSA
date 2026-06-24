<?php

namespace App\Repositories;

use Illuminate\Support\Facades\DB;

class UserRepository extends StoredProcedureRepository
{
    public function list(?string $status, ?string $type, ?string $search): array
    {
        return $this->call('SP_BBF_USUARIOS_LISTAR', [$status, $type, $search]);
    }

    public function find(int $userId): ?array
    {
        return $this->first('SP_BBF_USUARIOS_OBTENER_POR_ID', [$userId]);
    }

    public function create(array $data): int
    {
        $row = $this->first('SP_BBF_USUARIOS_CREAR', [
            $data['id_empleado'] ?? null,
            $data['nombre_usuario'],
            $data['correo'],
            $data['password_hash'],
            $data['tipo_usuario'],
            $data['tipo_autenticacion'],
            (int) $data['requiere_cambio_password'],
            (int) $data['correo_verificado'],
        ]);

        return (int) ($row['id_usuario'] ?? 0);
    }

    public function createByDocument(array $data): int
    {
        $row = $this->first('SP_BBF_USUARIOS_CREAR_POR_DOCUMENTO', [
            $data['numero_documento_empleado'],
            $data['nombre_usuario'],
            $data['correo'],
            $data['password_hash'],
            $data['tipo_usuario'],
            $data['tipo_autenticacion'],
            (int) $data['requiere_cambio_password'],
            (int) $data['correo_verificado'],
        ]);

        return (int) ($row['id_usuario'] ?? 0);
    }

    public function hasCreateByDocumentProcedure(): bool
    {
        $row = DB::selectOne(
            'SELECT ROUTINE_NAME FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_SCHEMA = DATABASE() AND ROUTINE_NAME = ? LIMIT 1',
            ['SP_BBF_USUARIOS_CREAR_POR_DOCUMENTO'],
        );

        return $row !== null;
    }

    public function changeStatus(int $userId, string $status): void
    {
        $this->call('SP_BBF_USUARIOS_CAMBIAR_ESTADO', [$userId, $status]);
    }

    public function changePassword(int $userId, string $hash, bool $saveHistory = true): void
    {
        $this->call('SP_BBF_USUARIOS_CAMBIAR_PASSWORD', [$userId, $hash, (int) $saveHistory]);
    }

    public function roles(int $userId): array
    {
        return $this->call('SP_BBF_USUARIO_OBTENER_ROLES', [$userId]);
    }

    public function permissions(int $userId): array
    {
        return $this->call('SP_BBF_USUARIO_OBTENER_PERMISOS', [$userId]);
    }

    public function assignRole(int $userId, int $roleId): void
    {
        $this->call('SP_BBF_USUARIO_ROLES_ASIGNAR', [$userId, $roleId]);
    }

    public function removeRole(int $userId, int $roleId): void
    {
        $this->call('SP_BBF_USUARIO_ROLES_QUITAR', [$userId, $roleId]);
    }

    public function update(int $userId, array $data, string $status): void
    {
        $this->call('SP_BBF_USUARIOS_ACTUALIZAR', [
            $userId,
            $data['id_empleado'] ?? null,
            $data['nombre_usuario'],
            $data['correo'],
            $data['tipo_usuario'],
            $data['tipo_autenticacion'],
            (int) $data['requiere_cambio_password'],
            (int) $data['correo_verificado'],
            $status,
        ]);
    }

    public function activeSuperAdminCount(): int
    {
        return (int) DB::table('BBF_USUARIOS as u')
            ->join('BBF_USUARIO_ROLES as ur', 'ur.ID_USUARIO', '=', 'u.ID_USUARIO')
            ->join('BBF_ROLES as r', 'r.ID_ROL', '=', 'ur.ID_ROL')
            ->where('u.ESTADO', 'ACTIVO')
            ->where('r.NOMBRE', 'SUPER_ADMIN')
            ->where('r.ACTIVO', 1)
            ->distinct('u.ID_USUARIO')
            ->count('u.ID_USUARIO');
    }

    public function roleName(int $roleId): ?string
    {
        $name = DB::table('BBF_ROLES')->where('ID_ROL', $roleId)->value('NOMBRE');

        return is_string($name) ? $name : null;
    }
}
