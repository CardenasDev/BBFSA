<?php
require __DIR__ . '/vendor/autoload.php';
$app = require __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$user = [
    'id_usuario' => 99,
    'id_sesion' => 1,
    'correo' => 'rrhh@example.com',
    'nombre_usuario' => 'rrhh',
    'tipo_usuario' => 'ADMIN',
    'roles' => [],
    'permisos' => ['CONTRATACION_VER', 'CONTRATACION_HISTORIAL_VER'],
];

echo Tymon\JWTAuth\Facades\JWTAuth::fromUser((object) $user), PHP_EOL;
