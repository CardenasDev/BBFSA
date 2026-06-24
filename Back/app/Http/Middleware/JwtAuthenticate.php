<?php

namespace App\Http\Middleware;

use App\Exceptions\ApiException;
use App\Services\JwtService;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;
use Throwable;

class JwtAuthenticate
{
    public function __construct(private readonly JwtService $jwt) {}

    public function handle(Request $request, Closure $next): Response
    {
        $token = $request->bearerToken();
        if (! $token) {
            throw new ApiException('Token de acceso requerido.', 401);
        }

        try {
            $claims = $this->jwt->decode($token);
        } catch (Throwable) {
            throw new ApiException('Token de acceso inválido o expirado.', 401);
        }
        if (! isset($claims['id_usuario'])) {
            throw new ApiException('El token no contiene una identidad válida.', 401);
        }

        $request->attributes->set('jwt', $claims);

        return $next($request);
    }
}
