<?php

namespace App\Http\Controllers\Api;

use App\Http\Requests\ChangePasswordRequest;
use App\Http\Requests\LoginRequest;
use App\Http\Requests\RefreshTokenRequest;
use App\Services\AuthService;
use Dedoc\Scramble\Attributes\Group;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

#[Group('Auth', 'Autenticación JWT y administración de sesiones.', weight: 1)]
class AuthController extends ApiController
{
    public function __construct(private readonly AuthService $auth) {}

    /**
     * Iniciar sesión
     *
     * Valida usuario o correo y contraseña. Retorna access token, refresh token, usuario, roles y permisos.
     */
    public function login(LoginRequest $request): JsonResponse
    {
        $data = $this->auth->login((string) $request->string('usuario'), (string) $request->string('password'), $this->context($request));

        return $this->success($data, 'Inicio de sesión exitoso.');
    }

    /**
     * Renovar tokens
     *
     * Valida y rota el refresh token. El token anterior queda revocado.
     */
    public function refresh(RefreshTokenRequest $request): JsonResponse
    {
        return $this->success(
            $this->auth->refresh((string) $request->string('refresh_token'), $this->context($request)),
            'Token renovado exitosamente.',
        );
    }

    /**
     * Cerrar sesión actual
     *
     * Revoca la sesión asociada al access token.
     */
    public function logout(Request $request): JsonResponse
    {
        $this->auth->logout($this->claims($request), $this->context($request));

        return $this->success(null, 'Sesión cerrada exitosamente.');
    }

    /**
     * Obtener usuario autenticado
     *
     * Retorna los datos vigentes del usuario, sus roles y permisos.
     */
    public function me(Request $request): JsonResponse
    {
        return $this->success($this->auth->me($this->actorId($request)));
    }

    /**
     * Cambiar contraseña
     *
     * Verifica la contraseña actual y almacena el hash de la nueva contraseña.
     */
    public function changePassword(ChangePasswordRequest $request): JsonResponse
    {
        $this->auth->changePassword(
            $this->actorId($request),
            (string) $request->string('current_password'),
            (string) $request->string('password'),
            $this->context($request),
        );

        return $this->success(null, 'Contraseña actualizada exitosamente.');
    }
}
