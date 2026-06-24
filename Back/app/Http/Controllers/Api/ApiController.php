<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Support\ApiResponse;
use Illuminate\Http\Request;

abstract class ApiController extends Controller
{
    use ApiResponse;

    protected function claims(Request $request): array
    {
        return $request->attributes->get('jwt', []);
    }

    protected function actorId(Request $request): int
    {
        return (int) ($this->claims($request)['id_usuario'] ?? 0);
    }

    protected function context(Request $request): array
    {
        return ['ip' => $request->ip(), 'user_agent' => $request->userAgent()];
    }
}
