<?php

use App\Console\Commands\BootstrapAdmin;
use App\Exceptions\ApiException;
use App\Http\Middleware\EnsurePermission;
use App\Http\Middleware\JwtAuthenticate;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Auth\AuthenticationException;
use Illuminate\Database\QueryException;
use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;
use Symfony\Component\HttpKernel\Exception\HttpExceptionInterface;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withCommands([BootstrapAdmin::class])
    ->withMiddleware(function (Middleware $middleware): void {
        $middleware->alias([
            'auth.jwt' => JwtAuthenticate::class,
            'permission' => EnsurePermission::class,
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        $exceptions->shouldRenderJsonWhen(fn (Request $request): bool => $request->is('api/*') || $request->expectsJson());

        $error = fn (string $message, array $errors, int $status) => response()->json([
            'success' => false,
            'message' => $message,
            'errors' => (object) $errors,
        ], $status);

        $exceptions->render(function (ValidationException $e, Request $request) use ($error) {
            return ($request->is('api/*') || $request->expectsJson()) ? $error('Los datos enviados no son válidos.', $e->errors(), 422) : null;
        });
        $exceptions->render(function (ApiException $e, Request $request) use ($error) {
            return ($request->is('api/*') || $request->expectsJson()) ? $error($e->getMessage(), $e->errors, $e->status) : null;
        });
        $exceptions->render(function (AuthenticationException $e, Request $request) use ($error) {
            return ($request->is('api/*') || $request->expectsJson()) ? $error('No autenticado.', [], 401) : null;
        });
        $exceptions->render(function (AuthorizationException $e, Request $request) use ($error) {
            return ($request->is('api/*') || $request->expectsJson()) ? $error('No tiene permiso para realizar esta acción.', [], 403) : null;
        });
        $exceptions->render(function (NotFoundHttpException $e, Request $request) use ($error) {
            return ($request->is('api/*') || $request->expectsJson()) ? $error('Recurso no encontrado.', [], 404) : null;
        });
        $exceptions->render(function (QueryException $e, Request $request) use ($error) {
            report($e);

            if (in_array($e->errorInfo[0] ?? null, ['45000', '23000'], true)) {
                return ($request->is('api/*') || $request->expectsJson())
                    ? $error((string) ($e->errorInfo[2] ?? 'La operación viola una regla de negocio.'), [], 422)
                    : null;
            }

            return ($request->is('api/*') || $request->expectsJson()) ? $error('No fue posible completar la operación en la base de datos.', [], 500) : null;
        });
        $exceptions->render(function (HttpExceptionInterface $e, Request $request) use ($error) {
            $message = $e->getStatusCode() === 405 ? 'Método no permitido.' : 'Error en la solicitud.';

            return ($request->is('api/*') || $request->expectsJson()) ? $error($message, [], $e->getStatusCode()) : null;
        });
        $exceptions->render(function (Throwable $e, Request $request) use ($error) {
            report($e);

            return ($request->is('api/*') || $request->expectsJson()) ? $error('Ocurrió un error interno.', [], 500) : null;
        });
    })->create();
