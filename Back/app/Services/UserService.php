<?php

namespace App\Services;

use App\Exceptions\ApiException;
use App\Repositories\AuthRepository;
use App\Repositories\EmployeeRepository;
use App\Repositories\UserRepository;
use Illuminate\Support\Facades\Hash;

class UserService
{
    public function __construct(
        private readonly UserRepository $users,
        private readonly EmployeeRepository $employees,
        private readonly AuthRepository $auth,
        private readonly AuditService $audit,
    ) {}

    public function list(?string $status, ?string $type, ?string $search): array
    {
        return $this->users->list($status, $type, $search);
    }

    public function find(int $userId): array
    {
        return $this->users->find($userId) ?? throw new ApiException('Usuario no encontrado.', 404);
    }

    public function create(array $data, int $actorId, array $context): array
    {
        $data['password_hash'] = Hash::make($data['password']);
        unset($data['password']);

        $hasDocument = trim((string) ($data['numero_documento_empleado'] ?? '')) !== '';
        if ($hasDocument) {
            $data['numero_documento_empleado'] = trim((string) $data['numero_documento_empleado']);
        }

        $this->ensureEmployeeDocumentRule($data, $hasDocument || ! empty($data['id_empleado']));

        if ($hasDocument && $this->users->hasCreateByDocumentProcedure()) {
            $userId = $this->users->createByDocument($data);
        } else {
            $data['id_empleado'] = $hasDocument
                ? $this->employeeIdByDocument((string) $data['numero_documento_empleado'])
                : ($data['id_empleado'] ?? null);
            $userId = $this->users->create($data);
        }

        if ($userId < 1) {
            throw new ApiException('El procedimiento no retorno el usuario creado.', 500);
        }
        $user = $this->find($userId);
        $this->audit->record($actorId, 'USUARIOS', 'CREAR', 'USUARIO', $userId, null, $user, $context);

        return $user;
    }

    public function changeStatus(int $userId, string $status, int $actorId, array $context): array
    {
        $before = $this->find($userId);
        $this->ensureStatusChangeKeepsActiveSuperAdmin($before, $status);

        $this->users->changeStatus($userId, $status);
        $after = $this->find($userId);
        $this->audit->record($actorId, 'USUARIOS', 'CAMBIAR_ESTADO', 'USUARIO', $userId, $before, $after, $context);

        return $after;
    }

    public function assignRole(int $userId, int $roleId, int $actorId, array $context): array
    {
        $this->find($userId);
        $this->users->assignRole($userId, $roleId);
        $this->audit->record($actorId, 'USUARIOS', 'ASIGNAR_ROL', 'USUARIO', $userId, null, ['id_rol' => $roleId], $context);

        return $this->users->roles($userId);
    }

    public function removeRole(int $userId, int $roleId, int $actorId, array $context): array
    {
        $user = $this->find($userId);
        $this->ensureRoleRemovalKeepsActiveSuperAdmin($user, $roleId);

        $this->users->removeRole($userId, $roleId);
        $this->audit->record($actorId, 'USUARIOS', 'QUITAR_ROL', 'USUARIO', $userId, ['id_rol' => $roleId], null, $context);

        return $this->users->roles($userId);
    }

    public function roles(int $userId): array
    {
        $this->find($userId);

        return $this->users->roles($userId);
    }

    public function permissions(int $userId): array
    {
        $this->find($userId);

        return $this->users->permissions($userId);
    }

    public function update(int $userId, array $data, int $actorId, array $context): array
    {
        $before = $this->find($userId);
        $hasDocument = trim((string) ($data['numero_documento_empleado'] ?? '')) !== '';
        $data['id_empleado'] = $hasDocument
            ? $this->employeeIdByDocument(trim((string) $data['numero_documento_empleado']))
            : (array_key_exists('id_empleado', $data) ? $data['id_empleado'] : ($before['id_empleado'] ?? null));
        $data['requiere_cambio_password'] ??= (bool) $before['requiere_cambio_password'];
        $data['correo_verificado'] ??= (bool) $before['correo_verificado'];
        $this->ensureEmployeeDocumentRule($data, ! empty($data['id_empleado']));

        if (strtoupper((string) $data['tipo_autenticacion']) === 'DOMINIO_EMPRESA') {
            if (! $this->auth->validateCorporateDomain((string) $data['correo'])) {
                throw new ApiException(
                    'El correo no pertenece a un dominio corporativo autorizado.',
                    422,
                    ['correo' => ['El dominio no esta autorizado.']]
                );
            }
        }

        $this->users->update($userId, $data, (string) $before['estado']);
        $after = $this->find($userId);
        $this->audit->record($actorId, 'USUARIOS', 'ACTUALIZAR', 'USUARIO', $userId, $before, $after, $context);

        return $after;
    }

    private function ensureEmployeeDocumentRule(array $data, bool $hasEmployee): void
    {
        if (strtoupper((string) ($data['tipo_usuario'] ?? '')) !== 'EMPLEADO' || $hasEmployee) {
            return;
        }

        throw new ApiException(
            'El documento del empleado es obligatorio para usuarios de tipo EMPLEADO.',
            422,
            ['numero_documento_empleado' => ['El documento del empleado es obligatorio para usuarios de tipo EMPLEADO.']]
        );
    }

    private function employeeIdByDocument(string $document): int
    {
        $employee = $this->employees->findByDocument($document);
        if (! $employee || (int) ($employee['id_empleado'] ?? 0) < 1) {
            throw new ApiException(
                'Empleado no encontrado para el documento indicado.',
                422,
                ['numero_documento_empleado' => ['No existe un empleado con ese documento.']]
            );
        }

        return (int) $employee['id_empleado'];
    }

    private function ensureStatusChangeKeepsActiveSuperAdmin(array $user, string $status): void
    {
        if (strtoupper($status) === 'ACTIVO' || strtoupper((string) $user['estado']) !== 'ACTIVO') {
            return;
        }

        if (! $this->userHasRole((int) $user['id_usuario'], 'SUPER_ADMIN')) {
            return;
        }

        if ($this->users->activeSuperAdminCount() <= 1) {
            throw new ApiException(
                'No se puede inactivar o bloquear el unico SUPER_ADMIN activo del sistema.',
                422,
                ['estado' => ['Debe existir al menos un usuario activo con rol SUPER_ADMIN.']]
            );
        }
    }

    private function ensureRoleRemovalKeepsActiveSuperAdmin(array $user, int $roleId): void
    {
        if (strtoupper((string) $this->users->roleName($roleId)) !== 'SUPER_ADMIN') {
            return;
        }

        if (strtoupper((string) $user['estado']) !== 'ACTIVO') {
            return;
        }

        if ($this->users->activeSuperAdminCount() <= 1) {
            throw new ApiException(
                'No se puede retirar el unico rol SUPER_ADMIN activo del sistema.',
                422,
                ['id_rol' => ['Debe existir al menos un usuario activo con rol SUPER_ADMIN.']]
            );
        }
    }

    private function userHasRole(int $userId, string $roleName): bool
    {
        foreach ($this->users->roles($userId) as $role) {
            if (strtoupper((string) $role['nombre']) === strtoupper($roleName)) {
                return true;
            }
        }

        return false;
    }
}
