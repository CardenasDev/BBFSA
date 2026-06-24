<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use RuntimeException;

class BootstrapAdmin extends Command
{
    protected $signature = 'bbf:bootstrap-admin';

    protected $description = 'Crea o asegura el usuario, rol y permisos administrativos iniciales';

    private const LOCAL_DEFAULTS = [
        'email' => 'admin@barroblancofarms.com.co',
        'username' => 'admin',
        'password' => 'abc123*',
    ];

    private const PERMISSIONS = [
        ['DASHBOARD_VER', 'Ver dashboard', 'DASHBOARD'],
        ['USUARIOS_VER', 'Ver usuario', 'USUARIOS'],
        ['USUARIOS_LISTAR', 'Listar usuarios', 'USUARIOS'],
        ['USUARIOS_CREAR', 'Crear usuarios', 'USUARIOS'],
        ['USUARIOS_EDITAR', 'Editar usuarios', 'USUARIOS'],
        ['USUARIOS_INACTIVAR', 'Inactivar usuarios', 'USUARIOS'],
        ['USUARIOS_CAMBIAR_ESTADO', 'Cambiar estado de usuarios', 'USUARIOS'],
        ['USUARIOS_ASIGNAR_ROL', 'Asignar roles a usuarios', 'USUARIOS'],
        ['USUARIOS_QUITAR_ROL', 'Retirar roles de usuarios', 'USUARIOS'],
        ['USUARIOS_VER_ROLES', 'Ver roles de usuarios', 'USUARIOS'],
        ['USUARIOS_VER_PERMISOS', 'Ver permisos de usuarios', 'USUARIOS'],
        ['ROLES_VER', 'Ver rol', 'ROLES'],
        ['ROLES_LISTAR', 'Listar roles', 'ROLES'],
        ['ROLES_CREAR', 'Crear roles', 'ROLES'],
        ['ROLES_EDITAR', 'Editar roles', 'ROLES'],
        ['PERMISOS_VER', 'Ver permisos', 'PERMISOS'],
        ['PERMISOS_LISTAR', 'Listar permisos', 'PERMISOS'],
        ['DOMINIOS_VER', 'Ver dominios autorizados', 'DOMINIOS'],
        ['DOMINIOS_LISTAR', 'Listar dominios autorizados', 'DOMINIOS'],
        ['DOMINIOS_CREAR', 'Crear dominios autorizados', 'DOMINIOS'],
        ['DOMINIOS_EDITAR', 'Editar dominios autorizados', 'DOMINIOS'],
        ['EMPLEADOS_VER', 'Ver empleados', 'EMPLEADOS'],
    ];

    public function handle(): int
    {
        try {
            $credentials = $this->credentials();
            $result = DB::transaction(function () use ($credentials): array {
                $permissionIds = $this->ensurePermissions();
                $roleId = $this->ensureRole();

                foreach ($permissionIds as $permissionId) {
                    DB::select('CALL SP_BBF_ROL_PERMISOS_ASIGNAR(?, ?)', [$roleId, $permissionId]);
                }

                [$userId, $created] = $this->ensureUser($credentials);
                DB::select('CALL SP_BBF_USUARIO_ROLES_ASIGNAR(?, ?)', [$userId, $roleId]);

                return compact('userId', 'roleId', 'created');
            });

            $this->newLine();
            $this->info('Bootstrap administrativo completado.');
            $this->table(['Recurso', 'Valor'], [
                ['Usuario ID', $result['userId']],
                ['Correo', $credentials['email']],
                ['Rol', 'SUPER_ADMIN (ID '.$result['roleId'].')'],
                ['Permisos', count(self::PERMISSIONS)],
                ['Usuario creado', $result['created'] ? 'Sí' : 'No, ya existía'],
            ]);
            if (! $result['created']) {
                $this->comment('La contraseña existente no fue reemplazada.');
            }

            return self::SUCCESS;
        } catch (\Throwable $exception) {
            $this->error('No fue posible completar el bootstrap: '.$exception->getMessage());

            return self::FAILURE;
        }
    }

    private function credentials(): array
    {
        $configured = (array) config('bbf.bootstrap_admin', []);
        $isLocal = app()->environment(['local', 'development', 'testing']);
        $values = [];

        foreach (self::LOCAL_DEFAULTS as $key => $fallback) {
            $value = trim((string) ($configured[$key] ?? ''));
            if ($value === '') {
                if (! $isLocal) {
                    throw new RuntimeException('Debe configurar BBF_ADMIN_'.strtoupper($key).' fuera del ambiente local.');
                }
                $value = $fallback;
                $this->warn('BBF_ADMIN_'.strtoupper($key).' no está configurada; se usará el valor local por defecto.');
            }
            $values[$key] = $value;
        }

        if (! filter_var($values['email'], FILTER_VALIDATE_EMAIL)) {
            throw new RuntimeException('BBF_ADMIN_EMAIL no contiene un correo válido.');
        }

        return $values;
    }

    private function ensurePermissions(): array
    {
        $ids = [];
        foreach (self::PERMISSIONS as [$code, $name, $module]) {
            DB::table('BBF_PERMISOS')->updateOrInsert(
                ['CODIGO' => $code],
                ['NOMBRE' => $name, 'DESCRIPCION' => $name, 'MODULO' => $module, 'ACTIVO' => 1],
            );
            $id = DB::table('BBF_PERMISOS')->where('CODIGO', $code)->value('ID_PERMISO');
            if (! $id) {
                throw new RuntimeException("No se pudo obtener el permiso {$code}.");
            }
            $ids[] = (int) $id;
        }

        return $ids;
    }

    private function ensureRole(): int
    {
        $role = DB::table('BBF_ROLES')->where('NOMBRE', 'SUPER_ADMIN')->first();
        if (! $role) {
            $rows = DB::select('CALL SP_BBF_ROLES_CREAR(?, ?)', [
                'SUPER_ADMIN',
                'Administrador inicial con acceso completo al sistema.',
            ]);
            $roleId = $this->returnedId($rows[0] ?? null, 'ID_ROL');
        } else {
            $roleId = (int) $role->ID_ROL;
        }

        $roleId ??= (int) DB::table('BBF_ROLES')->where('NOMBRE', 'SUPER_ADMIN')->value('ID_ROL');
        if ($roleId < 1) {
            throw new RuntimeException('No se pudo obtener el rol SUPER_ADMIN.');
        }
        DB::select('CALL SP_BBF_ROLES_CAMBIAR_ESTADO(?, ?)', [$roleId, 1]);

        return $roleId;
    }

    private function ensureUser(array $credentials): array
    {
        $byEmail = DB::table('BBF_USUARIOS')->where('CORREO', $credentials['email'])->first();
        $byUsername = DB::table('BBF_USUARIOS')->where('NOMBRE_USUARIO', $credentials['username'])->first();
        if ($byEmail && $byUsername && $byEmail->ID_USUARIO !== $byUsername->ID_USUARIO) {
            throw new RuntimeException('El correo y el nombre de usuario pertenecen a usuarios diferentes.');
        }

        $user = $byEmail ?? $byUsername;
        if ($user) {
            $userId = (int) $user->ID_USUARIO;
            DB::select('CALL SP_BBF_USUARIOS_ACTUALIZAR(?, ?, ?, ?, ?, ?, ?, ?, ?)', [
                $userId, $user->ID_EMPLEADO, $credentials['username'], $credentials['email'],
                'ADMIN', 'LOCAL', (int) $user->REQUIERE_CAMBIO_PASSWORD, 1, 'ACTIVO',
            ]);

            return [$userId, false];
        }

        $rows = DB::select('CALL SP_BBF_USUARIOS_CREAR(?, ?, ?, ?, ?, ?, ?, ?)', [
            null, $credentials['username'], $credentials['email'], Hash::make($credentials['password']),
            'ADMIN', 'LOCAL', 1, 1,
        ]);
        $userId = $this->returnedId($rows[0] ?? null, 'ID_USUARIO');
        $userId ??= (int) DB::table('BBF_USUARIOS')->where('CORREO', $credentials['email'])->value('ID_USUARIO');
        if ($userId < 1) {
            throw new RuntimeException('No se pudo obtener el usuario administrador.');
        }

        return [$userId, true];
    }

    private function returnedId(?object $row, string $field): ?int
    {
        if (! $row) {
            return null;
        }
        $values = array_change_key_case((array) $row, CASE_UPPER);
        $id = (int) ($values[$field] ?? 0);

        return $id > 0 ? $id : null;
    }
}
