<?php

namespace App\Repositories;

class AuthRepository extends StoredProcedureRepository
{
    public function findForLogin(string $login): ?array
    {
        return $this->first('SP_BBF_LOGIN_OBTENER_USUARIO', [$this->normalizeLogin($login)]);
    }

    public function markFailed(int $userId): void
    {
        $this->call('SP_BBF_LOGIN_MARCAR_FALLIDO', [$userId]);
    }

    public function markSuccessful(int $userId): void
    {
        $this->call('SP_BBF_LOGIN_MARCAR_EXITOSO', [$userId]);
    }

    public function validateCorporateDomain(string $email): bool
    {
        return (bool) ($this->first('SP_BBF_DOMINIOS_VALIDAR', [$this->normalizeEmail($email)])['es_valido'] ?? false);
    }

    private function normalizeEmail(string $email): string
    {
        return mb_strtolower(trim($email));
    }

    private function normalizeLogin(string $login): string
    {
        return mb_strtolower(trim($login));
    }

    public function createSession(int $userId, string $tokenHash, ?string $ip, ?string $userAgent, string $expiresAt): int
    {
        $row = $this->first('SP_BBF_USUARIO_SESIONES_CREAR', [$userId, $tokenHash, $ip, $userAgent, $expiresAt]);

        return (int) ($row['id_sesion'] ?? 0);
    }

    public function findSession(string $tokenHash): ?array
    {
        return $this->first('SP_BBF_USUARIO_SESIONES_OBTENER_POR_TOKEN', [$tokenHash]);
    }

    public function revokeSession(int $sessionId): void
    {
        $this->call('SP_BBF_USUARIO_SESIONES_REVOCAR', [$sessionId]);
    }

}
