<?php

namespace App\Services;

use Illuminate\Support\Carbon;
use RuntimeException;

class JwtService
{
    public function encode(array $claims): array
    {
        $now = Carbon::now()->timestamp;
        $expiresAt = Carbon::now()->addMinutes(config('jwt.ttl_minutes'))->timestamp;
        $payload = array_merge($claims, [
            'iss' => config('jwt.issuer'),
            'iat' => $now,
            'nbf' => $now,
            'exp' => $expiresAt,
            'jti' => bin2hex(random_bytes(16)),
        ]);

        return [
            'token' => $this->sign($payload),
            'expires_in' => $expiresAt - $now,
        ];
    }

    public function decode(string $token): array
    {
        $parts = explode('.', $token);
        if (count($parts) !== 3) {
            throw new RuntimeException('JWT mal formado.');
        }
        [$header64, $payload64, $signature64] = $parts;
        $expected = $this->base64UrlEncode(hash_hmac('sha256', "{$header64}.{$payload64}", $this->secret(), true));
        if (! hash_equals($expected, $signature64)) {
            throw new RuntimeException('Firma JWT inválida.');
        }

        $header = $this->decodePart($header64);
        $payload = $this->decodePart($payload64);
        $now = Carbon::now()->timestamp;
        if (($header['alg'] ?? null) !== 'HS256' || ($header['typ'] ?? null) !== 'JWT') {
            throw new RuntimeException('Algoritmo JWT no permitido.');
        }
        if (($payload['iss'] ?? null) !== config('jwt.issuer')
            || (int) ($payload['nbf'] ?? PHP_INT_MAX) > $now
            || (int) ($payload['exp'] ?? 0) <= $now) {
            throw new RuntimeException('JWT inválido o expirado.');
        }

        return $payload;
    }

    private function sign(array $payload): string
    {
        $header64 = $this->base64UrlEncode(json_encode(['typ' => 'JWT', 'alg' => 'HS256'], JSON_THROW_ON_ERROR));
        $payload64 = $this->base64UrlEncode(json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_THROW_ON_ERROR));
        $signature64 = $this->base64UrlEncode(hash_hmac('sha256', "{$header64}.{$payload64}", $this->secret(), true));

        return "{$header64}.{$payload64}.{$signature64}";
    }

    private function decodePart(string $part): array
    {
        $decoded = base64_decode(strtr($part, '-_', '+/'), true);
        if ($decoded === false) {
            throw new RuntimeException('Segmento JWT inválido.');
        }

        return json_decode($decoded, true, 512, JSON_THROW_ON_ERROR);
    }

    private function base64UrlEncode(string $value): string
    {
        return rtrim(strtr(base64_encode($value), '+/', '-_'), '=');
    }

    private function secret(): string
    {
        $secret = (string) config('jwt.secret');
        if (strlen($secret) < 32) {
            throw new RuntimeException('JWT_SECRET debe contener al menos 32 caracteres.');
        }

        return $secret;
    }
}
