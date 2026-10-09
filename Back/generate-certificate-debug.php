<?php
require __DIR__.'/vendor/autoload.php';
$app = require __DIR__.'/bootstrap/app.php';
$renderer = new App\Services\CertificateRenderer;
$data = [
    'empleado' => ['nombre_completo' => 'Ana Pérez', 'tipo_documento' => 'Cédula', 'numero_documento' => '123', 'fecha_ingreso' => '2020-02-03', 'lugar_expedicion_documento' => 'Bogotá'],
    'contrato' => ['cargo' => 'Analista'],
    'funciones' => ['Desarrollar software'],
    'empresa' => ['razon_social' => 'Empresa de prueba', 'ciudad' => 'Bogotá'],
    'formato' => ['codigo_formato' => 'BBTH-F-002'],
    'firmantes' => [['nombre' => 'Firmante de prueba', 'cargo' => 'RRHH', 'telefono' => '123']],
    'fecha_expedicion' => '2026-10-06',
];
file_put_contents(__DIR__.'/storage/certificate-debug.pdf', $renderer->render($data));
