<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Contrato laboral a termino fijo</title>
    <style>
        @page { margin: 40px 38px 55px; }
        body { font-family: DejaVu Sans, sans-serif; font-size: 11px; color: #1f2933; line-height: 1.45; position: relative; }
        .watermark { position: fixed; top: 42%; left: 12%; font-size: 54px; color: rgba(31, 41, 51, 0.06); transform: rotate(-28deg); z-index: -1; }
        .doc-header, .meta-table, .party-table { width: 100%; border-collapse: collapse; }
        .doc-header td, .meta-table td, .meta-table th, .party-table td, .party-table th { border: 1px solid #7b8794; padding: 6px 8px; vertical-align: top; }
        .brand-cell { width: 34%; }
        .brand-title { font-size: 17px; font-weight: 700; letter-spacing: 0.3px; }
        .brand-subtitle { margin-top: 4px; font-size: 10px; text-transform: uppercase; color: #52606d; }
        .contract-title { text-align: center; margin: 18px 0 10px; font-size: 16px; font-weight: 700; text-transform: uppercase; }
        .intro { margin: 10px 0 14px; text-align: justify; }
        .section-title { margin: 18px 0 8px; font-size: 12px; font-weight: 700; text-transform: uppercase; color: #102a43; }
        .clause { margin-bottom: 10px; text-align: justify; }
        .clause strong { color: #102a43; }
        .signature-section { width: 100%; margin-top: 34px; }
        .signature-block { width: 45%; display: inline-block; vertical-align: top; margin-right: 4%; text-align: center; }
        .signature-line { border-top: 1px solid #1f2933; margin: 34px 0 8px; }
        .signature-block span, .signature-block strong { display: block; margin-bottom: 3px; }
        .footer-note { margin-top: 22px; font-size: 9px; color: #52606d; text-align: center; }
        ul { margin: 6px 0 10px 18px; padding: 0; }
    </style>
</head>
<body>
    @include('contracts.pdf.partials.header', ['contract' => $contract, 'employer' => $employer])

    <div class="contract-title">Contrato individual de trabajo a termino fijo</div>

    <table class="party-table">
        <tr><th>Empleador</th><td>{{ $employer['razon_social'] }}</td><th>NIT</th><td>{{ $employer['nit'] }}</td></tr>
        <tr><th>Domicilio</th><td>{{ $employer['domicilio'] }}</td><th>Correo</th><td>{{ $employer['correo'] }}</td></tr>
        <tr><th>Trabajador(a)</th><td>{{ $contract['nombre_completo'] }}</td><th>Documento</th><td>{{ $contract['tipo_documento'] }} {{ $contract['numero_documento'] }}</td></tr>
        <tr><th>Direccion</th><td>{{ $contract['direccion_residencia'] }}</td><th>Cargo</th><td>{{ $contract['cargo'] }}</td></tr>
        <tr><th>Fecha inicio</th><td>{{ $contract['fecha_inicio_texto'] }}</td><th>Fecha fin</th><td>{{ $contract['fecha_fin_texto'] }}</td></tr>
        <tr><th>Numero contrato</th><td>{{ $contract['numero_contrato'] }}</td><th>Tipo</th><td>{{ $contract['tipo_contrato'] }}</td></tr>
    </table>

    <p class="intro">
        Entre los suscritos a saber, <strong>{{ $employer['razon_social'] }}</strong>, identificado con NIT <strong>{{ $employer['nit'] }}</strong>, quien en adelante se denominara EL EMPLEADOR, y <strong>{{ $contract['nombre_completo'] }}</strong>, identificado con <strong>{{ $contract['tipo_documento'] }} {{ $contract['numero_documento'] }}</strong>, quien en adelante se denominara EL(LA) TRABAJADOR(A), se celebra el presente contrato individual de trabajo a termino fijo.
    </p>

    <div class="section-title">Condiciones generales</div>
    <p class="clause"><strong>Primera. Objeto.</strong> EL(LA) TRABAJADOR(A) prestara sus servicios personales para desempenar el cargo de <strong>{{ $contract['cargo'] }}</strong>, ejecutando las funciones asignadas y aquellas compatibles con su perfil, en el lugar de labores <strong>{{ $contract['lugar_labores'] }}</strong>.</p>
    <p class="clause"><strong>Segunda. Duracion.</strong> El contrato tendra una vigencia inicial de <strong>{{ $contract['termino_inicial_contrato'] ?: 'la pactada entre las partes' }}</strong>, iniciando el <strong>{{ $contract['fecha_inicio_texto'] }}</strong> y finalizando el <strong>{{ $contract['fecha_fin_texto'] ?: 'segun lo determine la necesidad empresarial' }}</strong>.</p>
    <p class="clause"><strong>Tercera. Remuneracion.</strong> EL EMPLEADOR pagara a EL(LA) TRABAJADOR(A) un salario de <strong>{{ $contract['salario_base'] }}</strong> ({{ $contract['salario_texto'] }}), con periodo de pago <strong>{{ $contract['periodo_pago'] }}</strong>. Auxilio de transporte: <strong>{{ $contract['auxilio_transporte_texto'] }}</strong>.</p>
    <p class="clause"><strong>Cuarta. Jornada.</strong> La jornada laboral sera <strong>{{ $contract['jornada_laboral'] ?: 'la legalmente establecida' }}</strong>, sin perjuicio de los ajustes operativos que permita la ley.</p>
    <p class="clause"><strong>Quinta. Funciones.</strong> {{ $contract['clausula_funciones'] ?: 'EL(LA) TRABAJADOR(A) cumplira las funciones inherentes al cargo y las instrucciones impartidas por EL EMPLEADOR.' }}</p>
    <p class="clause"><strong>Sexta. Domicilio y notificaciones.</strong> Para efectos contractuales, EL(LA) TRABAJADOR(A) informa como direccion de residencia <strong>{{ $contract['direccion_residencia'] }}</strong>, correo <strong>{{ $contract['correo_personal'] }}</strong> y telefono <strong>{{ $contract['telefono'] }}</strong>.</p>

    <div class="section-title">Clausulas adicionales</div>
    <ul>
        <li>EL(LA) TRABAJADOR(A) se obliga a cumplir el reglamento interno, politicas corporativas y normas de seguridad y salud en el trabajo.</li>
        <li>Las prestaciones sociales, afiliaciones y aportes se reconoceran conforme a la legislacion colombiana aplicable.</li>
        <li>La renovacion, terminacion o no prorroga del contrato se regira por la normatividad laboral vigente.</li>
    </ul>

    <p class="clause">Se firma en <strong>{{ $contract['ciudad_firma'] }}</strong>, a los <strong>{{ $contract['fecha_firma_texto'] }}</strong>.</p>

    @include('contracts.pdf.partials.signatures', ['contract' => $contract, 'employer' => $employer])
    @include('contracts.pdf.partials.footer', ['contract' => $contract, 'employer' => $employer])
</body>
</html>