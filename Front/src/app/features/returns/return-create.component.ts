import { Component, OnDestroy, OnInit, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { finalize } from 'rxjs';
import {
  AvailableReturnDelivery,
  AvailableReturnItem,
  CreateReturnDetail,
  Employee,
  ReturnItemCondition,
  ReturnType,
} from '../../core/models/api.models';
import { EmployeeService } from '../../core/services/employee.service';
import { ReturnService } from '../../core/services/return.service';
import { apiErrorMessage } from '../../shared/api-error';

interface ReturnDraft {
  selected: boolean;
  item: AvailableReturnItem;
  cantidad: number;
  estado_elemento: ReturnItemCondition | '';
  observaciones: string;
}

interface EvidencePreview {
  file: File;
  url: string | null;
}

const CONDITIONS: Array<{ value: ReturnItemCondition; label: string }> = [
  { value: 'BUENO', label: 'Bueno' }, { value: 'USADO', label: 'Usado' },
  { value: 'DETERIORADO', label: 'Deteriorado' }, { value: 'DANADO', label: 'Dañado' },
  { value: 'INCOMPLETO', label: 'Incompleto' }, { value: 'NO_FUNCIONAL', label: 'No funcional' },
];

@Component({
  standalone: true,
  imports: [FormsModule, RouterLink],
  template: `
    <section class="page-header"><div><p class="eyebrow">Devoluciones</p><h1>Registrar devolución</h1><p class="muted">Selecciona la entrega original y los elementos que serán recibidos.</p></div><a class="btn ghost" routerLink="/admin/returns">Volver</a></section>
    <section class="panel">
      @if (error()) { <div class="alert error" role="alert">{{ error() }}</div> }
      <form class="form-grid" (ngSubmit)="submit()" novalidate>
        <label>1. Tipo *
          <select name="type" [ngModel]="type" (ngModelChange)="changeType($event)" required>
            <option value="DOTACION">Dotación</option><option value="HERRAMIENTA">Herramienta</option>
          </select>
        </label>
        <label>2. Buscar empleado<input name="employeeSearch" [(ngModel)]="employeeSearch" placeholder="Documento o nombre" /></label>
        <label class="form-wide">Empleado *
          <select name="employee_id" [ngModel]="employeeId" (ngModelChange)="changeEmployee($event)" required>
            <option [ngValue]="null">Selecciona un empleado</option>
            @for (employee of filteredEmployees(); track employee.id_empleado) {
              <option [ngValue]="employee.id_empleado">{{ employee.numero_documento }} - {{ employeeName(employee) }}</option>
            }
          </select>
        </label>

        <div class="form-wide drawer-section">
          <div class="section-title"><div><h2>3. Entrega original</h2><p class="muted">Solo se muestran entregas con saldo disponible.</p></div></div>
          @if (availableLoading()) { <p class="empty" aria-live="polite">Consultando elementos disponibles...</p> }
          @else if (employeeId && !deliveries().length) { <p class="empty">El empleado no tiene elementos disponibles para devolución.</p> }
          @else {
            <div class="return-delivery-grid">
              @for (delivery of deliveries(); track delivery.id_entrega) {
                <button type="button" class="return-delivery-card" [class.selected]="deliveryId === delivery.id_entrega" (click)="selectDelivery(delivery)">
                  <strong>Entrega #{{ delivery.id_entrega }}</strong><span>{{ delivery.fecha_entrega }}</span><small>{{ delivery.items.length }} elemento(s) disponible(s)</small>
                </button>
              }
            </div>
          }
        </div>

        <div class="form-wide drawer-section">
          <div class="section-title"><div><h2>4. Elementos</h2><p class="muted">Selecciona al menos uno; la cantidad puede ser parcial.</p></div></div>
          <div class="table-wrap"><table>
            <thead><tr><th>Seleccionar</th><th>Elemento</th><th>Talla</th><th>Entregada</th><th>Devuelta</th><th>Disponible</th><th>Cantidad *</th><th>Estado *</th><th>Observaciones</th></tr></thead>
            <tbody>
              @for (draft of drafts(); track draft.item.id_detalle) {
                <tr>
                  <td><input type="checkbox" [checked]="draft.selected" (change)="toggleDetail(draft.item.id_detalle, $any($event.target).checked)" [attr.aria-label]="'Seleccionar ' + draft.item.elemento" /></td>
                  <td><strong>{{ draft.item.elemento }}</strong></td><td>{{ draft.item.talla || '—' }}</td>
                  <td>{{ draft.item.cantidad_entregada }}</td><td>{{ draft.item.cantidad_devuelta }}</td><td>{{ draft.item.cantidad_disponible }}</td>
                  <td><input type="number" min="1" [max]="draft.item.cantidad_disponible" [disabled]="!draft.selected" [ngModel]="draft.cantidad" [name]="'quantity_' + draft.item.id_detalle" (ngModelChange)="updateDraft(draft.item.id_detalle, 'cantidad', $event)" /></td>
                  <td><select [disabled]="!draft.selected" [ngModel]="draft.estado_elemento" [name]="'condition_' + draft.item.id_detalle" (ngModelChange)="updateDraft(draft.item.id_detalle, 'estado_elemento', $event)"><option value="">Selecciona</option>@for (condition of conditions; track condition.value) { <option [value]="condition.value">{{ condition.label }}</option> }</select></td>
                  <td><input maxlength="500" [disabled]="!draft.selected" [ngModel]="draft.observaciones" [name]="'detail_notes_' + draft.item.id_detalle" (ngModelChange)="updateDraft(draft.item.id_detalle, 'observaciones', $event)" /></td>
                </tr>
              } @empty { <tr><td colspan="9" class="empty">Selecciona una entrega para ver sus elementos.</td></tr> }
            </tbody>
          </table></div>
        </div>

        <div class="form-wide drawer-section">
          <div class="section-title"><div><h2>5. Información general</h2></div></div>
          <div class="form-grid">
            <label>Fecha de devolución *<input type="date" name="returnDate" [(ngModel)]="returnDate" [max]="today" required /></label>
            <label>Motivo *<input name="reason" [(ngModel)]="reason" maxlength="500" required /></label>
            <label class="form-wide">Observaciones generales<textarea name="observations" rows="3" [(ngModel)]="observations" maxlength="1000"></textarea></label>
          </div>
        </div>

        <div class="form-wide drawer-section">
          <div class="section-title"><div><h2>6. Evidencias *</h2><p class="muted">Máximo 5 MB por archivo. PDF, JPG, PNG, WEBP, DOC o DOCX.</p></div></div>
          @if (type === 'HERRAMIENTA') { <p class="alert warning">Las devoluciones de herramientas requieren al menos una fotografía.</p> }
          <label>Seleccionar archivos<input #evidenceInput type="file" multiple accept=".pdf,.jpg,.jpeg,.png,.webp,.doc,.docx" (change)="selectFiles($event)" /></label>
          <div class="evidence-grid">
            @for (preview of evidence(); track preview.file) {
              <article class="evidence-card">
                @if (preview.url) { <img [src]="preview.url" [alt]="'Vista previa de ' + preview.file.name" /> }
                <div><strong>{{ preview.file.name }}</strong><small>{{ preview.file.type || 'Tipo desconocido' }} · {{ fileSize(preview.file.size) }}</small></div>
                <button class="btn small danger-outline" type="button" (click)="removeFile(preview, evidenceInput)" [attr.aria-label]="'Retirar ' + preview.file.name">Retirar</button>
              </article>
            }
          </div>
        </div>

        <div class="form-actions form-wide"><a class="btn ghost" routerLink="/admin/returns">Cancelar</a><button class="btn primary" type="submit" [disabled]="saving() || availableLoading()">{{ saving() ? 'Registrando devolución...' : 'Registrar devolución' }}</button></div>
      </form>
    </section>
  `,
  styles: [`
    .return-delivery-grid,.evidence-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));gap:.75rem}
    .return-delivery-card{display:grid;gap:.25rem;text-align:left;border:1px solid var(--line);border-radius:12px;background:white;padding:1rem;cursor:pointer}
    .return-delivery-card.selected{border-color:var(--green-700);box-shadow:0 0 0 2px rgba(30,100,75,.15)}
    .return-delivery-card span,.return-delivery-card small,.evidence-card small{color:var(--muted);display:block}
    .evidence-card{display:grid;grid-template-columns:64px 1fr auto;align-items:center;gap:.75rem;border:1px solid var(--line);border-radius:12px;padding:.75rem}
    .evidence-card img{width:64px;height:64px;object-fit:cover;border-radius:8px}
  `],
})
export class ReturnCreateComponent implements OnInit, OnDestroy {
  private readonly service = inject(ReturnService);
  private readonly employeesService = inject(EmployeeService);
  private readonly router = inject(Router);
  readonly employees = signal<Employee[]>([]);
  readonly deliveries = signal<AvailableReturnDelivery[]>([]);
  readonly drafts = signal<ReturnDraft[]>([]);
  readonly evidence = signal<EvidencePreview[]>([]);
  readonly availableLoading = signal(false);
  readonly saving = signal(false);
  readonly error = signal('');
  readonly conditions = CONDITIONS;
  readonly today = new Date().toISOString().slice(0, 10);
  private availableRequest = 0;
  type: ReturnType = 'DOTACION';
  employeeId: number | null = null;
  employeeSearch = '';
  deliveryId: number | null = null;
  returnDate = this.today;
  reason = '';
  observations = '';

  ngOnInit(): void {
    this.employeesService.listEmployees({ estado_empleado: 'ACTIVO' }).subscribe({
      next: (employees) => this.employees.set(employees),
      error: (error) => this.error.set(apiErrorMessage(error, 'No fue posible cargar los empleados.')),
    });
  }

  ngOnDestroy(): void { this.clearEvidence(); }

  filteredEmployees(): Employee[] {
    const term = this.employeeSearch.trim().toLowerCase();
    return term ? this.employees().filter((employee) => [employee.numero_documento, this.employeeName(employee)].some((value) => value.toLowerCase().includes(term))) : this.employees();
  }

  employeeName(employee: Employee): string { return employee.nombre_completo || `${employee.nombres} ${employee.apellidos}`.trim(); }

  changeType(type: ReturnType): void {
    this.type = type;
    this.resetSelection(true);
    if (this.employeeId) this.loadAvailable();
  }

  changeEmployee(employeeId: number | null): void {
    this.employeeId = employeeId ? Number(employeeId) : null;
    this.resetSelection(false);
    if (this.employeeId) this.loadAvailable();
  }

  selectDelivery(delivery: AvailableReturnDelivery): void {
    this.deliveryId = delivery.id_entrega;
    this.drafts.set(delivery.items.map((item) => ({ selected: false, item, cantidad: 1, estado_elemento: '', observaciones: '' })));
    this.error.set('');
  }

  toggleDetail(detailId: number, selected: boolean): void {
    this.drafts.update((drafts) => drafts.map((draft) => draft.item.id_detalle === detailId ? { ...draft, selected } : draft));
  }

  updateDraft(detailId: number, field: 'cantidad' | 'estado_elemento' | 'observaciones', value: unknown): void {
    this.drafts.update((drafts) => drafts.map((draft) => {
      if (draft.item.id_detalle !== detailId) return draft;
      if (field === 'cantidad') return { ...draft, cantidad: Number(value) };
      if (field === 'estado_elemento') return { ...draft, estado_elemento: value as ReturnItemCondition | '' };
      return { ...draft, observaciones: String(value ?? '').slice(0, 500) };
    }));
  }

  selectFiles(event: Event): void {
    const input = event.target as HTMLInputElement;
    const files = [...(input.files ?? [])];
    this.error.set('');
    for (const file of files) {
      const validation = this.validateFile(file);
      if (validation) { this.error.set(validation); continue; }
      const duplicate = this.evidence().some((item) => item.file.name === file.name && item.file.size === file.size);
      if (!duplicate) this.evidence.update((items) => [...items, { file, url: file.type.startsWith('image/') ? URL.createObjectURL(file) : null }]);
    }
    input.value = '';
  }

  removeFile(preview: EvidencePreview, input: HTMLInputElement): void {
    if (preview.url) URL.revokeObjectURL(preview.url);
    this.evidence.update((items) => items.filter((item) => item !== preview));
    input.value = '';
  }

  submit(): void {
    this.error.set('');
    const details = this.selectedDetails();
    const validation = this.validate(details);
    if (validation) { this.error.set(validation); return; }
    this.saving.set(true);
    this.service.createReturn({
      type: this.type,
      employee_id: this.employeeId!,
      delivery_id: this.deliveryId!,
      return_date: this.returnDate,
      reason: this.reason.trim(),
      observations: this.observations.trim() || null,
      details,
      evidence: this.evidence().map((item) => item.file),
    }).pipe(finalize(() => this.saving.set(false))).subscribe({
      next: (result) => {
        this.clearEvidence();
        void this.router.navigate(['/admin/returns', result.id_devolucion], { state: { message: 'Devolución registrada correctamente.' } });
      },
      error: (error) => this.error.set(apiErrorMessage(error, 'No fue posible registrar la devolución.')),
    });
  }

  fileSize(bytes: number): string { return bytes < 1048576 ? `${Math.max(1, Math.round(bytes / 1024))} KB` : `${(bytes / 1048576).toFixed(1)} MB`; }

  private loadAvailable(): void {
    const request = ++this.availableRequest;
    this.availableLoading.set(true); this.error.set('');
    this.service.getAvailableReturns(this.type, this.employeeId!).pipe(finalize(() => {
      if (request === this.availableRequest) this.availableLoading.set(false);
    })).subscribe({
      next: (deliveries) => { if (request === this.availableRequest) this.deliveries.set(deliveries); },
      error: (error) => { if (request === this.availableRequest) this.error.set(apiErrorMessage(error, 'No fue posible consultar los elementos disponibles.')); },
    });
  }

  private resetSelection(clearFiles: boolean): void {
    this.availableRequest++;
    this.deliveries.set([]); this.deliveryId = null; this.drafts.set([]); this.availableLoading.set(false);
    if (clearFiles) this.clearEvidence();
  }

  private selectedDetails(): CreateReturnDetail[] {
    return this.drafts().filter((draft) => draft.selected).map((draft) => ({
      id_detalle: draft.item.id_detalle,
      cantidad: Number(draft.cantidad),
      estado_elemento: draft.estado_elemento as ReturnItemCondition,
      observaciones: draft.observaciones.trim() || null,
    }));
  }

  private validate(details: CreateReturnDetail[]): string {
    if (!this.employeeId) return 'Selecciona un empleado.';
    if (!this.deliveryId) return 'Selecciona la entrega original.';
    if (!details.length) return 'Selecciona al menos un elemento para devolver.';
    if (new Set(details.map((detail) => detail.id_detalle)).size !== details.length) return 'No se permiten detalles duplicados.';
    for (const detail of details) {
      const available = this.drafts().find((draft) => draft.item.id_detalle === detail.id_detalle)?.item.cantidad_disponible ?? 0;
      if (!Number.isInteger(detail.cantidad) || detail.cantidad < 1) return 'Las cantidades deben ser números enteros mayores que cero.';
      if (detail.cantidad > available) return 'La cantidad a devolver no puede superar la cantidad disponible.';
      if (!detail.estado_elemento) return 'Selecciona el estado físico de cada elemento.';
    }
    if (!this.returnDate || this.returnDate > this.today) return 'Selecciona una fecha válida que no sea futura.';
    if (!this.reason.trim()) return 'El motivo es obligatorio.';
    if (this.reason.trim().length > 500) return 'El motivo no puede superar 500 caracteres.';
    if (!this.evidence().length) return 'Debe adjuntar al menos una evidencia.';
    if (this.type === 'HERRAMIENTA' && !this.evidence().some((item) => item.file.type.startsWith('image/'))) return 'Las devoluciones de herramientas requieren al menos una fotografía.';
    return '';
  }

  private validateFile(file: File): string {
    if (file.size > 5 * 1024 * 1024) return `${file.name}: el archivo no puede superar 5 MB.`;
    const extension = file.name.split('.').pop()?.toLowerCase() ?? '';
    if (!['pdf', 'jpg', 'jpeg', 'png', 'webp', 'doc', 'docx'].includes(extension)) return `${file.name}: formato no permitido.`;
    return '';
  }

  private clearEvidence(): void {
    this.evidence().forEach((preview) => { if (preview.url) URL.revokeObjectURL(preview.url); });
    this.evidence.set([]);
  }
}
