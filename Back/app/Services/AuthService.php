<?php

namespace App\Services;

use App\Exceptions\ApiException;
use App\Repositories\AuthRepository;
use App\Repositories\UserRepository;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Hash;

class AuthService
{
    public function __construct(
        private readonly AuthRepository $auth,
        private readonly UserRepository $users,
        private readonly JwtService $jwt,
        private readonly AuditService $audit,
    ) {}

    public function login(string $login, string $password, array $context): array
    {
        $user = $this->auth->findForLogin($login);
        if (! $user) {
            $this->audit->record(null, 'AUTENTICACION', 'LOGIN_FALLIDO', 'USUARIO', null, null, ['usuario' => $login, 'motivo' => 'NO_EXISTE'], $context);
            throw new ApiException('Credenciales incorrectas.', 401);
        }

        $userId = (int) $user['id_usuario'];
        $status = strtoupper((string) $user['estado']);
        if ($status === 'INACTIVO') {
            $this->auditFailure($userId, 'INACTIVO', $context);
            throw new ApiException('El usuario está inactivo.', 403);
        }
        if ($status === 'BLOQUEADO') {
            $this->auditFailure($userId, 'BLOQUEADO', $context);
            throw new ApiException('El usuario está bloqueado.', 403);
        }
        if ($status === 'ELIMINADO') {
            $this->auditFailure($userId, 'ELIMINADO', $context);
            throw new ApiException('El usuario fue eliminado.', 403);
        }
        if (strtoupper((string) $user['tipo_autenticacion']) === 'DOMINIO_EMPRESA'
            && ! $this->auth->validateCorporateDomain((string) $user['correo'])) {
            $this->auditFailure($userId, 'DOMINIO_NO_AUTORIZADO', $context);
            throw new ApiException('El correo no pertenece a un dominio corporativo autorizado.', 403);
        }
        if (! Hash::check($password, (string) $user['password_hash'])) {
            $this->auth->markFailed($userId);
            $this->auditFailure($userId, 'PASSWORD_INCORRECTO', $context);
            throw new ApiException('Credenciales incorrectas.', 401);
        }

        $this->auth->markSuccessful($userId);
        $roles = $this->users->roles($userId);
        $permissions = $this->users->permissions($userId);
        $tokens = $this->issueTokens($user, $roles, $permissions, $context);
        $this->audit->record($userId, 'AUTENTICACION', 'LOGIN_EXITOSO', 'USUARIO', $userId, null, ['correo' => $user['correo']], $context);

        return array_merge($tokens, [
            'usuario' => $this->publicUser($user),
            'roles' => $roles,
            'permisos' => $permissions,
            'requiere_cambio_password' => (bool) $user['requiere_cambio_password'],
        ]);
    }

    public function refresh(string $refreshToken, array $context): array
    {
        $session = $this->auth->findSession(hash('sha256', $refreshToken));
        if (! $session || ! (bool) $session['activo'] || $session['fecha_revocacion'] !== null
            || Carbon::parse($session['fecha_expiracion'])->isPast()) {
            throw new ApiException('Refresh token inválido o expirado.', 401);
        }
        if (strtoupper((string) $session['estado']) !== 'ACTIVO') {
            throw new ApiException('El usuario no está activo.', 403);
        }

        $userId = (int) $session['id_usuario'];
        $user = $this->users->find($userId);
        if (! $user) {
            throw new ApiException('Usuario no encontrado.', 404);
        }
        $roles = $this->users->roles($userId);
        $permissions = $this->users->permissions($userId);

        // Rotar impide reutilizar un refresh token que haya sido interceptado.
        $this->auth->revokeSession((int) $session['id_sesion']);

        return $this->issueTokens($user, $roles, $permissions, $context);
    }

    public function logout(array $claims, array $context): void
    {
        $sessionId = (int) ($claims['id_sesion'] ?? 0);
        if ($sessionId < 1) {
            throw new ApiException('El token no identifica una sesión.', 400);
        }
        $this->auth->revokeSession($sessionId);
        $userId = (int) $claims['id_usuario'];
        $this->audit->record($userId, 'AUTENTICACION', 'LOGOUT', 'USUARIO_SESION', $sessionId, null, null, $context);
    }

    public function logoutAll(int $userId, array $context): void
    {
        $this->auth->revokeAllSessions($userId);
        $this->audit->record($userId, 'AUTENTICACION', 'LOGOUT_TODAS', 'USUARIO', $userId, null, null, $context);
    }

    public function me(int $userId): array
    {
        $user = $this->users->find($userId);
        if (! $user) {
            throw new ApiException('Usuario no encontrado.', 404);
        }

        return [
            'usuario' => $this->publicUser($user),
            'roles' => $this->users->roles($userId),
            'permisos' => $this->users->permissions($userId),
        ];
    }

    public function changePassword(int $userId, string $currentPassword, string $newPassword, array $context): void
    {
        $user = $this->users->find($userId);
        $credentials = $user ? $this->auth->findForLogin((string) $user['correo']) : null;
        if (! $credentials || ! Hash::check($currentPassword, (string) $credentials['password_hash'])) {
            throw new ApiException('La contraseña actual es incorrecta.', 422, ['current_password' => ['La contraseña actual es incorrecta.']]);
        }
        if (Hash::check($newPassword, (string) $credentials['password_hash'])) {
            throw new ApiException('La nueva contraseña debe ser diferente.', 422, ['password' => ['La nueva contraseña debe ser diferente.']]);
        }

        $this->users->changePassword($userId, Hash::make($newPassword));
        $this->audit->record($userId, 'AUTENTICACION', 'CAMBIO_PASSWORD', 'USUARIO', $userId, null, null, $context);
    }

    private function issueTokens(array $user, array $roles, array $permissions, array $context): array
    {
        $refreshToken = bin2hex(random_bytes(32));
        $expiresAt = Carbon::now()->addDays(config('jwt.refresh_ttl_days'));
        $sessionId = $this->auth->createSession(
            (int) $user['id_usuario'],
            hash('sha256', $refreshToken),
            $context['ip'] ?? null,
            isset($context['user_agent']) ? mb_substr($context['user_agent'], 0, 500) : null,
            $expiresAt->format('Y-m-d H:i:s'),
        );
        $access = $this->jwt->encode([
            'id_usuario' => (int) $user['id_usuario'],
            'id_sesion' => $sessionId,
            'correo' => $user['correo'],
            'nombre_usuario' => $user['nombre_usuario'],
            'tipo_usuario' => $user['tipo_usuario'],
            'roles' => array_values(array_column($roles, 'nombre')),
            'permisos' => array_values(array_column($permissions, 'codigo')),
        ]);

        return [
            'access_token' => $access['token'],
            'refresh_token' => $refreshToken,
            'expires_in' => $access['expires_in'],
        ];
    }

    private function publicUser(array $user): array
    {
        unset($user['password_hash']);

        return $user;
    }

    private function auditFailure(int $userId, string $reason, array $context): void
    {
        $this->audit->record($userId, 'AUTENTICACION', 'LOGIN_FALLIDO', 'USUARIO', $userId, null, ['motivo' => $reason], $context);
    }
}
