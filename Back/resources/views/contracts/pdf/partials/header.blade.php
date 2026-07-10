<div class="watermark">BARRO BLANCO FARMS</div>
<table class="doc-header">
    <tr>
        <td class="brand-cell">
            <div class="brand-title">BARRO BLANCO FARMS S.A.S</div>
            <div class="brand-subtitle">Contrato laboral listo para firma</div>
        </td>
        <td>
            <table class="meta-table">
                <tr>
                    <th>Proceso</th>
                    <td>Gestion Humana</td>
                    <th>Codigo</th>
                    <td>{{ $contract['codigo_formato'] ?: 'N/D' }}</td>
                </tr>
                <tr>
                    <th>Subproceso</th>
                    <td>Contratacion</td>
                    <th>Version</th>
                    <td>{{ $contract['version_formato'] ?: 'N/D' }}</td>
                </tr>
                <tr>
                    <th>Vigente a partir de</th>
                    <td>{{ $contract['fecha_vigencia'] ?: 'N/D' }}</td>
                    <th>Pagina</th>
                    <td>1</td>
                </tr>
            </table>
        </td>
    </tr>
</table>