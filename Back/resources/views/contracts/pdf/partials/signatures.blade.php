<div class="signature-section">
    <div class="signature-block">
        <div class="signature-line"></div>
        <strong>EL EMPLEADOR</strong>
        <span>{{ $employer['razon_social'] }}</span>
        <span>NIT {{ $employer['nit'] }}</span>
    </div>
    <div class="signature-block">
        <div class="signature-line"></div>
        <strong>EL(LA) TRABAJADOR(A)</strong>
        <span>{{ $contract['nombre_completo'] }}</span>
        <span>{{ $contract['tipo_documento'] }} {{ $contract['numero_documento'] }}</span>
    </div>
</div>