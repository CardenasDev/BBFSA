import { HttpErrorResponse } from '@angular/common/http';
import { Component, OnDestroy, OnInit, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { finalize, forkJoin } from 'rxjs';
import { Employee, Tool } from '../../core/models/api.models';
import { EmployeeService } from '../../core/services/employee.service';
import { ToolService } from '../../core/services/tool.service';

interface DetailDraft { key: number; id_herramienta: number | null; cantidad: number; observaciones: string; }
interface EvidencePreview { file: File; url: string; }

const MAX_EVIDENCE_SIZE = 5 * 1024 * 1024;
const EVIDENCE_MIME_TYPES = new Set(['image/jpeg', 'image/png', 'image/webp']);
const EVIDENCE_EXTENSIONS = new Set(['jpg', 'jpeg', 'png', 'webp']);

@Component({
  standalone: true,
  imports: [FormsModule, RouterLink],
  template: `
    <div class="page-heading"><div><p class="eyebrow">Herramientas</p><h1>Registrar entrega</h1><p class="muted">Entrega varias herramientas a un empleado en una sola operación.</p></div><a class="btn ghost" routerLink="/admin/tool-deliveries">Volver</a></div>
    <form class="panel" (ngSubmit)="submit()">
      @if (error()) { <div class="alert error" role="alert">{{ error() }}</div> }
      <div class="form-grid">
        <label>Empleado<select name="id_empleado" [(ngModel)]="employeeId" required><option [ngValue]="null">Selecciona un empleado</option>@for (employee of employees(); track employee.id_empleado) { <option [ngValue]="employee.id_empleado">{{ employeeLabel(employee) }}</option> }</select></label>
        <label>Fecha entrega<input type="date" name="fecha_entrega" [(ngModel)]="deliveryDate" required /></label>
        <label class="form-wide">Observaciones <span class="optional">opcional</span><textarea name="observaciones" [(ngModel)]="observations" maxlength="1000" rows="3"></textarea></label>
      </div>
      <div class="section-title"><div><h2>Herramientas</h2><p class="muted">Agrega al menos una herramienta. No se controlan existencias.</p></div><button class="btn secondary" type="button" (click)="addDetail()">Agregar herramienta</button></div>
      <div class="tool-detail-list">
        @for (detail of details(); track detail.key) {
          <section class="drawer-section tool-detail-row">
            <label>Herramienta<select [name]="'tool_' + detail.key" [ngModel]="detail.id_herramienta" (ngModelChange)="update(detail.key, 'id_herramienta', $event)"><option [ngValue]="null">Selecciona</option>@for (tool of availableTools(detail); track tool.id_herramienta) { <option [ngValue]="tool.id_herramienta">{{ tool.nombre }}</option> }</select></label>
            <label>Cantidad<input type="number" min="1" [name]="'quantity_' + detail.key" [ngModel]="detail.cantidad" (ngModelChange)="update(detail.key, 'cantidad', $event)" /></label>
            <label>Observaciones <span class="optional">opcional</span><input [name]="'notes_' + detail.key" [ngModel]="detail.observaciones" (ngModelChange)="update(detail.key, 'observaciones', $event)" maxlength="1000" /></label>
            <button class="btn small danger-outline" type="button" (click)="removeDetail(detail.key)" [disabled]="details().length === 1">Eliminar fila</button>
          </section>
        }
      </div>
      <section class="drawer-section evidence-section">
        <div class="section-title"><div><h2>Evidencias *</h2><p class="muted">Adjunta una o varias fotografías JPG, PNG o WEBP. Máximo 5 MB por foto.</p></div></div>
        <label>Seleccionar fotografías<input #evidenceInput type="file" multiple accept=".jpg,.jpeg,.png,.webp,image/jpeg,image/png,image/webp" (change)="selectFiles($event)" /></label>
        <div class="evidence-grid">
          @for (preview of evidence(); track preview.url) {
            <article class="evidence-card">
              <img [src]="preview.url" [alt]="'Vista previa de ' + preview.file.name" />
              <div><strong>{{ preview.file.name }}</strong><small>{{ fileSize(preview.file.size) }}</small></div>
              <button class="btn small danger-outline" type="button" (click)="removeFile(preview, evidenceInput)" [attr.aria-label]="'Retirar ' + preview.file.name">Retirar</button>
            </article>
          } @empty { <p class="empty">Debes adjuntar al menos una fotografía.</p> }
        </div>
      </section>
      <div class="form-actions"><a class="btn secondary" routerLink="/admin/tool-deliveries" (click)="resetForm()">Cancelar</a><button class="btn primary" type="submit" [disabled]="saving() || loading()">{{ saving() ? 'Guardando...' : 'Guardar entrega' }}</button></div>
    </form>
  `,
  styles: [`
    .evidence-section{margin-top:1rem}.evidence-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(240px,1fr));gap:.75rem;margin-top:.75rem}
    .evidence-card{display:grid;grid-template-columns:72px minmax(0,1fr) auto;align-items:center;gap:.75rem;border:1px solid var(--line);border-radius:12px;padding:.75rem}
    .evidence-card img{width:72px;height:72px;object-fit:cover;border-radius:8px}.evidence-card strong{display:block;overflow-wrap:anywhere}.evidence-card small{display:block;color:var(--muted);margin-top:.2rem}
  `],
})
export class ToolDeliveryCreateComponent implements OnInit, OnDestroy {
  private readonly toolsService = inject(ToolService);
  private readonly employeesService = inject(EmployeeService);
  private readonly router = inject(Router);
  readonly tools = signal<Tool[]>([]);
  readonly employees = signal<Employee[]>([]);
  readonly details = signal<DetailDraft[]>([{ key: 1, id_herramienta: null, cantidad: 1, observaciones: '' }]);
  readonly evidence = signal<EvidencePreview[]>([]);
  readonly loading = signal(false);
  readonly saving = signal(false);
  readonly error = signal('');
  employeeId: number | null = null;
  deliveryDate = this.localDate();
  observations = '';
  private nextKey = 2;

  ngOnInit(): void {
    this.loading.set(true);
    forkJoin({ tools: this.toolsService.getTools(true), employees: this.employeesService.listEmployees({ estado_empleado: 'ACTIVO' }) })
      .pipe(finalize(() => this.loading.set(false))).subscribe({
        next: ({ tools, employees }) => { this.tools.set(tools); this.employees.set(employees); },
        error: () => this.error.set('No fue posible cargar los datos del formulario.'),
      });
  }
  ngOnDestroy(): void { this.clearEvidence(); }
  addDetail(): void { this.details.update((rows) => [...rows, { key: this.nextKey++, id_herramienta: null, cantidad: 1, observaciones: '' }]); }
  removeDetail(key: number): void { if (this.details().length > 1) this.details.update((rows) => rows.filter((row) => row.key !== key)); }
  update(key: number, field: keyof Omit<DetailDraft, 'key'>, value: unknown): void {
    this.details.update((rows) => rows.map((row) => row.key === key ? { ...row, [field]: field === 'observaciones' ? String(value ?? '') : Number(value) || null } : row));
  }
  availableTools(current: DetailDraft): Tool[] {
    const selected = new Set(this.details().filter((row) => row.key !== current.key).map((row) => row.id_herramienta));
    return this.tools().filter((tool) => !selected.has(tool.id_herramienta));
  }
  selectFiles(event: Event): void {
    const input = event.target as HTMLInputElement;
    this.error.set('');
    for (const file of [...(input.files ?? [])]) {
      const validation = this.validateFile(file);
      if (validation) { this.error.set(validation); continue; }
      const duplicate = this.evidence().some((item) => item.file.name === file.name && item.file.size === file.size && item.file.lastModified === file.lastModified);
      if (!duplicate) this.evidence.update((items) => [...items, { file, url: URL.createObjectURL(file) }]);
    }
    input.value = '';
  }
  removeFile(preview: EvidencePreview, input?: HTMLInputElement): void {
    URL.revokeObjectURL(preview.url);
    this.evidence.update((items) => items.filter((item) => item !== preview));
    if (input) input.value = '';
  }
  fileSize(bytes: number): string {
    return bytes < 1048576 ? `${Math.max(1, Math.round(bytes / 1024))} KB` : `${(bytes / 1048576).toFixed(1)} MB`;
  }
  submit(): void {
    if (this.saving()) return;
    this.error.set('');
    if (!this.employeeId) { this.error.set('Selecciona un empleado.'); return; }
    if (!this.deliveryDate) { this.error.set('Selecciona la fecha de entrega.'); return; }
    const rows = this.details();
    if (rows.some((row) => !row.id_herramienta || !Number.isInteger(Number(row.cantidad)) || Number(row.cantidad) < 1)) { this.error.set('Completa cada herramienta con una cantidad mayor a cero.'); return; }
    if (new Set(rows.map((row) => row.id_herramienta)).size !== rows.length) { this.error.set('No puedes agregar la misma herramienta dos veces.'); return; }
    if (!this.evidence().length) { this.error.set('Debes adjuntar al menos una fotografía de la entrega.'); return; }
    const invalidEvidence = this.evidence().map((item) => this.validateFile(item.file)).find(Boolean);
    if (invalidEvidence) { this.error.set(invalidEvidence); return; }
    this.saving.set(true);
    this.toolsService.createToolDelivery({
      id_empleado: this.employeeId,
      fecha_entrega: this.deliveryDate,
      observaciones: this.observations.trim() || null,
      herramientas: rows.map((row) => ({ id_herramienta: row.id_herramienta!, cantidad: Number(row.cantidad), observaciones: row.observaciones.trim() || null })),
      evidencias: this.evidence().map((item) => item.file),
    }).pipe(finalize(() => this.saving.set(false))).subscribe({
      next: (result) => {
        this.resetForm();
        void this.router.navigate(['/admin/tool-deliveries', result.id_entrega], { state: { message: 'Entrega registrada correctamente.' } });
      },
      error: (error) => this.error.set(toolDeliveryErrorMessage(error)),
    });
  }
  resetForm(): void {
    this.clearEvidence();
    this.employeeId = null;
    this.deliveryDate = this.localDate();
    this.observations = '';
    this.details.set([{ key: this.nextKey++, id_herramienta: null, cantidad: 1, observaciones: '' }]);
    this.error.set('');
  }
  employeeLabel(employee: Employee): string { return `${employee.nombre_completo || `${employee.nombres} ${employee.apellidos}`} — ${employee.numero_documento}`; }
  private localDate(): string { const now = new Date(); now.setMinutes(now.getMinutes() - now.getTimezoneOffset()); return now.toISOString().slice(0, 10); }
  private validateFile(file: File): string {
    if (!(file instanceof File) || !file.name || file.size <= 0) return 'No fue posible leer una de las fotografías. Selecciónala nuevamente.';
    const extension = file.name.split('.').pop()?.toLowerCase() ?? '';
    if (!EVIDENCE_MIME_TYPES.has(file.type.toLowerCase()) || !EVIDENCE_EXTENSIONS.has(extension)) return `${file.name}: usa una fotografía JPG, JPEG, PNG o WEBP válida.`;
    if (file.size > MAX_EVIDENCE_SIZE) return `${file.name}: la fotografía no puede superar 5 MB.`;
    return '';
  }
  private clearEvidence(): void {
    this.evidence().forEach((preview) => URL.revokeObjectURL(preview.url));
    this.evidence.set([]);
  }
}

export function toolDeliveryErrorMessage(error: unknown): string {
  if (error instanceof HttpErrorResponse) {
    const body = error.error as { message?: unknown; errors?: Record<string, unknown> } | null;
    const entries = body?.errors ? Object.entries(body.errors) : [];
    const evidenceEntry = entries.find(([key]) => key.toLowerCase().includes('evidenc'));
    const raw = evidenceEntry?.[1] ?? entries[0]?.[1] ?? body?.message;
    const text = Array.isArray(raw) ? raw[0] : raw;
    if (typeof text === 'string') {
      const normalized = text.toLowerCase();
      if (normalized.includes('required') || normalized.includes('obligator') || normalized.includes('evidenc')) return 'Debes adjuntar al menos una fotografía de la entrega.';
      if (normalized.includes('mime') || normalized.includes('image') || normalized.includes('format')) return 'Una de las fotografías tiene un formato no permitido. Usa JPG, JPEG, PNG o WEBP.';
      if (normalized.includes('max') || normalized.includes('size') || normalized.includes('tama')) return 'Una de las fotografías supera el tamaño máximo permitido de 5 MB.';
      if (text.length <= 240 && !/trace|exception|sql|stack|vendor[\\/]/i.test(text)) return text;
    }
  }
  return 'No fue posible registrar la entrega. Revisa los datos e inténtalo nuevamente.';
}
