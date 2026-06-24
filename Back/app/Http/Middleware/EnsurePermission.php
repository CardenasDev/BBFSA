<?php

namespace App\Http\Middleware;

use App\Exceptions\ApiException;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsurePermission
{
    public function handle(Request $request, Closure $next, string ...$required): Response
    {
        $permissions = $request->attributes->get('jwt')['permisos'] ?? [];
        if (! array_intersect($required, $permissions)) {
            throw new ApiException('No tiene el permiso requerido para esta operación.', 403);
        }

        return $next($request);
    }
}
