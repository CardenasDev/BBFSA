<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Contrato laboral a termino indefinido</title>
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
        .intro, .clause { margin-bottom: 10px; text-align: justify; }
        .section-title { margin: 18px 0 8px; font-size: 12px; font-weight: 700; text-transform: uppercase; color: #102a43; }
        .signature-section { width: 100%; margin-top: 34px; }
        .signature-block { width: 45%; display: inline-block; vertical-align: top; margin-right: 4%; text-align: center; }
        .signature-line { border-top: 1px solid #1f2933; margin: 34px 0 8px; }
        .signature-block span, .signature-block strong { display: block; margin-bottom: 3px; }
        .footer-note { margin-top: 22px; font-size: 9px; color: #52606d; text-align: center; }
    </style>
</head>
<body>
    @include('contracts.pdf.partials.header', ['contract' => $contract, 'employer' => $employer])

    <div class="contract-title">Contrato individual de trabajo a termino indefinido</div>

    <table class="party-table">
        <tr><th>Empleador</th><td>{{ $employer['razon_social'] }}</td><th>NIT</th><td>{{ $employer['nit'] }}</td></tr>
        <tr><th>Trabajador(a)</th><td>{{ $contract['nombre_completo'] }}</td><th>Documento</th><td>{{ $contract['tipo_documento'] }} {{ $contract['numero_documento'] }}</td></tr>
        <tr><th>Cargo</th><td>{{ $contract['cargo'] }}</td><th>Numero contrato</th><td>{{ $contract['numero_contrato'] }}</td></tr>
        <tr><th>Fecha inicio</th><td>{{ $contract['fecha_inicio_texto'] }}</td><th>Lugar labores</th><td>{{ $contract['lugar_labores'] }}</td></tr>
    </table>

    <p class="intro">EL EMPLEADOR contrata a EL(LA) TRABAJADOR(A) mediante contrato a termino indefinido para desempenar el cargo indicado, con plena observancia de las normas laborales colombianas y de las politicas internas de la compania.</p>

    <div class="section-title">Clausulas</div>
    <p class="clause"><strong>Primera. Cargo y funciones.</strong> EL(LA) TRABAJADOR(A) desempenara el cargo de <strong>{{ $contract['cargo'] }}</strong>. Funciones principales: {{ $contract['clausula_funciones'] ?: 'Las asignadas al cargo, al reglamento interno y a las instrucciones del empleador.' }}</p>
    <p class="clause"><strong>Segunda. Duracion.</strong> Este contrato inicia el <strong>{{ $contract['fecha_inicio_texto'] }}</strong> y tendra vigencia indefinida mientras subsistan las causas que le dieron origen.</p>
    <p class="clause"><strong>Tercera. Salario y pago.</strong> EL EMPLEADOR pagara un salario de <strong>{{ $contract['salario_base'] }}</strong> ({{ $contract['salario_texto'] }}), bajo un periodo de pago <strong>{{ $contract['periodo_pago'] }}</strong>. Auxilio de transporte: <strong>{{ $contract['auxilio_transporte_texto'] }}</strong>.</p>
    <p class="clause"><strong>Cuarta. Jornada.</strong> La jornada laboral sera <strong>{{ $contract['jornada_laboral'] ?: 'la que disponga la organizacion conforme a la ley' }}</strong>.</p>
    <p class="clause"><strong>Quinta. Informacion del trabajador.</strong> EL(LA) TRABAJADOR(A) declara como direccion <strong>{{ $contract['direccion_residencia'] }}</strong>, telefono <strong>{{ $contract['telefono'] }}</strong>, correo <strong>{{ $contract['correo_personal'] }}</strong>, lugar de nacimiento <strong>{{ $contract['lugar_nacimiento'] }}</strong> y nacionalidad <strong>{{ $contract['nacionalidad'] }}</strong>.</p>
    <p class="clause"><strong>Sexta. Terminacion.</strong> El presente contrato podra darse por terminado por las causales legales, reglamentarias o disciplinarias aplicables.</p>

    <p class="clause">Se firma en <strong>{{ $contract['ciudad_firma'] }}</strong>, a los <strong>{{ $contract['fecha_firma_texto'] }}</strong>.</p>

    @include('contracts.pdf.partials.signatures', ['contract' => $contract, 'employer' => $employer])
    @include('contracts.pdf.partials.footer', ['contract' => $contract, 'employer' => $employer])
</body>
</html>