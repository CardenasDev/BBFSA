import { Component, inject, signal } from '@angular/core';
import { finalize } from 'rxjs';
import { apiErrorMessage } from '../../shared/api-error';
import { blobErrorMessage, downloadBlob, downloadFilename } from '../../shared/file-download';
import { AuthService } from '../../core/services/auth.service';
import { BulkLoadError, BulkLoadService, BulkLoadValidation } from '../../core/services/bulk-load.service';

@Component({
  standalone: true,
  template: `
    <section class="page-header">
      <div><span class="eyebrow">Carga masiva</span><h1>Empleados</h1><p>Acepta la plantilla oficial y la base ampliada del cliente con tallas por artículo.</p></div>
      <button type="button" class="btn secondary" (click)="downloadTemplate()" [disabled]="downloading()">{{ downloading() ? 'Descargando…' : 'Descargar plantilla XLSX' }}</button>
    </section>

    @if (message()) { <div class="alert success" role="status">{{ message() }}</div> }
    @if (error()) { <div class="alert error" role="alert">{{ error() }}</div> }

    <section class="card flow">
      <div class="steps" aria-label="Progreso"><span class="active">1. Archivo</span><span [class.active]="validation()">2. Validación</span><span [class.active]="message()">3. Importación</span></div>
      <div class="drop-zone" [class.dragging]="dragging()" (dragover)="onDragOver($event)" (dragleave)="dragging.set(false)" (drop)="onDrop($event)">
        <input #picker type="file" accept=".xlsx,application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" (change)="onFileInput($event)" hidden>
        <strong>Arrastra aquí el archivo XLSX</strong><span>Plantilla oficial de 51 columnas o base cliente de 72 columnas</span><span>o</span>
        <button type="button" class="btn ghost" (click)="picker.click()" [disabled]="busy()">Seleccionar archivo</button>
      </div>
      @if (file()) {
        <div class="selected-file"><div><strong>{{ file()!.name }}</strong><small>{{ fileSize() }}</small></div><button type="button" class="btn small ghost" (click)="clear()" [disabled]="busy()">Quitar</button></div>
        <div class="actions"><button type="button" class="btn primary" (click)="validate()" [disabled]="busy()">{{ validating() ? 'Validando…' : 'Validar archivo' }}</button></div>
      }
    </section>

    @if (validation(); as result) {
      <section class="summary" aria-label="Resumen de validación">
        <article class="card metric"><small>Total</small><strong>{{ result.total }}</strong></article>
        <article class="card metric valid"><small>Válidas</small><strong>{{ result.valid }}</strong></article>
        <article class="card metric invalid"><small>Inválidas</small><strong>{{ result.invalid }}</strong></article>
        <article class="card metric"><small>Advertencias</small><strong>{{ result.warnings.length }}</strong></article>
        <article class="card metric sizes"><small>Tallas por artículo</small><strong>{{ result.article_sizes }}</strong><span>{{ formatLabel(result.format) }}</span></article>
      </section>
      @if (result.errors.length) {
        <section class="card">
          <div class="section-heading"><div><h2>Errores encontrados</h2><p>Corrige la plantilla y vuelve a validarla.</p></div>
            <div class="actions"><button class="btn small ghost" type="button" (click)="copyReport()">Copiar informe</button><button class="btn small secondary" type="button" (click)="downloadReport()">Descargar CSV</button></div>
          </div>
          <div class="table-wrap"><table><thead><tr><th>Fila</th><th>Campo</th><th>Detalle</th></tr></thead><tbody>
            @for (item of result.errors; track $index) { <tr><td>{{ item.row }}</td><td><code>{{ item.field }}</code></td><td>{{ item.message }}</td></tr> }
          </tbody></table></div>
        </section>
      } @else {
        <section class="card ready"><div><h2>Archivo listo para importar</h2><p>El servidor volverá a validar los {{ result.valid }} empleados y {{ result.article_sizes }} tallas específicas antes de escribir.</p></div>
          <button type="button" class="btn primary" (click)="import()" [disabled]="busy() || !canImport">{{ importing() ? 'Importando…' : 'Importar ' + result.valid + ' empleados' }}</button>
          @if (!canImport) { <p class="permission-note">Tu usuario puede validar, pero requiere EMPLEADOS_CREAR para importar.</p> }
        </section>
      }
      @if (result.warnings.length) {
        <section class="card warnings">
          <div class="section-heading"><div><h2>Advertencias informativas</h2><p>Revisa las conversiones seguras y los datos históricos que el sistema no almacenará.</p></div></div>
          <div class="table-wrap"><table><thead><tr><th>Tipo</th><th>Fila</th><th>Campo</th><th>Detalle</th></tr></thead><tbody>
            @for (item of result.warnings; track $index) {
              <tr [class.conversion-warning]="isDocumentConversionWarning(item)">
                <td><span class="warning-kind">{{ warningKind(item) }}</span></td><td>{{ item.row }}</td><td><code>{{ item.field }}</code></td><td>{{ item.message }}</td>
              </tr>
            }
          </tbody></table></div>
        </section>
      }
    }
  `,
  styles: [`
    .flow{padding:1.25rem;margin-bottom:1rem}.steps{display:flex;gap:.5rem;flex-wrap:wrap;margin-bottom:1rem}.steps span{padding:.4rem .75rem;border-radius:999px;background:#e2e8f0;color:#64748b}.steps .active{background:#dbeafe;color:#1d4ed8;font-weight:700}
    .drop-zone{display:flex;min-height:180px;flex-direction:column;align-items:center;justify-content:center;gap:.5rem;border:2px dashed #94a3b8;border-radius:14px;background:#f8fafc;text-align:center;padding:1rem}.drop-zone.dragging{border-color:#2563eb;background:#eff6ff}
    .selected-file{display:flex;align-items:center;justify-content:space-between;gap:1rem;margin-top:1rem;padding:.8rem;border-radius:10px;background:#f1f5f9}.selected-file div{display:flex;flex-direction:column;min-width:0}.selected-file strong{overflow:hidden;text-overflow:ellipsis}.selected-file small{color:#64748b}
    .flow>.actions{display:flex;justify-content:flex-end;margin-top:1rem}.summary{display:grid;grid-template-columns:repeat(5,minmax(120px,1fr));gap:1rem;margin-bottom:1rem}.metric{padding:1rem}.metric small,.metric span{display:block;color:#64748b}.metric span{font-size:.75rem}.metric strong{font-size:2rem}.metric.valid strong{color:#15803d}.metric.invalid strong{color:#b91c1c}.metric.sizes strong{color:#0369a1}
    .section-heading,.ready{display:flex;align-items:center;justify-content:space-between;gap:1rem}.section-heading{margin-bottom:1rem}.section-heading h2,.ready h2{margin:0}.section-heading p,.ready p{margin:.25rem 0;color:#64748b}.actions{display:flex;gap:.5rem;flex-wrap:wrap}.ready{padding:1.25rem;border-left:4px solid #16a34a}.warnings{margin-top:1rem;border-left:4px solid #d97706}.warnings tr.conversion-warning{background:#eff6ff}.warning-kind{display:inline-block;padding:.2rem .5rem;border-radius:999px;background:#fef3c7;color:#92400e;font-size:.75rem;font-weight:700;white-space:nowrap}.conversion-warning .warning-kind{background:#dbeafe;color:#1d4ed8}.permission-note{flex-basis:100%}
    @media(max-width:700px){.summary{grid-template-columns:repeat(2,1fr)}.section-heading,.ready{align-items:stretch;flex-direction:column}.section-heading .actions,.ready .btn{width:100%}.page-header .btn{width:100%}}
  `],
})
export class EmployeeBulkLoadComponent {
  private readonly service = inject(BulkLoadService);
  private readonly auth = inject(AuthService);
  readonly file = signal<File | null>(null);
  readonly validation = signal<BulkLoadValidation | null>(null);
  readonly error = signal('');
  readonly message = signal('');
  readonly downloading = signal(false);
  readonly validating = signal(false);
  readonly importing = signal(false);
  readonly dragging = signal(false);
  readonly canImport = this.auth.hasPermission('EMPLEADOS_CREAR');

  busy(): boolean { return this.downloading() || this.validating() || this.importing(); }
  fileSize(): string { return `${((this.file()?.size ?? 0) / 1024).toFixed(1)} KB`; }

  downloadTemplate(): void {
    if (this.downloading()) return;
    this.error.set(''); this.downloading.set(true);
    this.service.downloadEmployeeTemplate().pipe(finalize(() => this.downloading.set(false))).subscribe({
      next: (response) => downloadBlob(response.body!, downloadFilename(response.headers.get('content-disposition'), 'plantilla_carga_masiva_empleados.xlsx')),
      error: async (err) => this.error.set(await blobErrorMessage(err, 'No fue posible descargar la plantilla.')),
    });
  }

  onFileInput(event: Event): void { this.select((event.target as HTMLInputElement).files?.[0] ?? null); }
  onDragOver(event: DragEvent): void { event.preventDefault(); this.dragging.set(true); }
  onDrop(event: DragEvent): void { event.preventDefault(); this.dragging.set(false); this.select(event.dataTransfer?.files?.[0] ?? null); }

  validate(): void {
    const file = this.file(); if (!file || this.validating()) return;
    this.error.set(''); this.message.set(''); this.validating.set(true); this.validation.set(null);
    this.service.validateEmployees(file).pipe(finalize(() => this.validating.set(false))).subscribe({
      next: (result) => this.validation.set(result),
      error: (err) => this.error.set(apiErrorMessage(err, 'No fue posible validar el archivo.')),
    });
  }

  import(): void {
    const file = this.file(); const result = this.validation();
    if (!file || !result || result.invalid || this.importing() || !this.canImport) return;
    if (!window.confirm(`Se crearán ${result.valid} empleados. ¿Deseas continuar?`)) return;
    this.error.set(''); this.importing.set(true);
    this.service.importEmployees(file).pipe(finalize(() => this.importing.set(false))).subscribe({
      next: (response) => { this.clear(); this.message.set(`Carga completada: ${response.created} empleados creados.`); },
      error: (err) => { this.validation.set(null); this.error.set(apiErrorMessage(err, 'La importación falló. No se creó ningún registro. Vuelve a validar el archivo.')); },
    });
  }

  clear(): void { this.file.set(null); this.validation.set(null); this.error.set(''); }
  copyReport(): void { void navigator.clipboard.writeText(this.reportText()).then(() => this.message.set('Informe copiado al portapapeles.')); }
  downloadReport(): void { downloadBlob(new Blob(['\uFEFF' + this.reportText(';')], { type: 'text/csv;charset=utf-8' }), 'errores_carga_empleados.csv'); }
  isDocumentConversionWarning(item: BulkLoadError): boolean {
    return item.field === 'numero_documento' && item.message.includes('llegó como número');
  }
  warningKind(item: BulkLoadError): string {
    return this.isDocumentConversionWarning(item) ? 'Conversión segura' : 'Dato informativo';
  }
  formatLabel(format: BulkLoadValidation['format']): string {
    return format === 'CLIENTE_72' ? 'Base cliente · 72 columnas' : 'Plantilla oficial · 51 columnas';
  }

  private select(file: File | null): void {
    this.clear(); this.message.set('');
    if (!file || !file.name.toLowerCase().endsWith('.xlsx')) { this.error.set('Selecciona un archivo con extensión .xlsx.'); return; }
    this.file.set(file);
  }

  private reportText(separator = '\t'): string {
    const escape = (value: string | number) => `"${String(value).replaceAll('"', '""')}"`;
    const result = this.validation();
    return [['Tipo', 'Fila', 'Campo', 'Detalle'],
      ...(result?.errors ?? []).map((item: BulkLoadError) => ['ERROR', item.row, item.field, item.message]),
      ...(result?.warnings ?? []).map((item: BulkLoadError) => ['ADVERTENCIA', item.row, item.field, item.message])]
      .map((row) => row.map(escape).join(separator)).join('\r\n');
  }
}
