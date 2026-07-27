import { Component, OnInit, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { finalize, forkJoin } from 'rxjs';
import { Employee, Tool } from '../../core/models/api.models';
import { EmployeeService } from '../../core/services/employee.service';
import { ToolService } from '../../core/services/tool.service';
import { apiErrorMessage } from '../../shared/api-error';

interface DetailDraft { key: number; id_herramienta: number | null; cantidad: number; observaciones: string; }

@Component({
  standalone: true,
  imports: [FormsModule, RouterLink],
  template: `
    <div class="page-heading"><div><p class="eyebrow">Herramientas</p><h1>Registrar entrega</h1><p class="muted">Entrega varias herramientas a un empleado en una sola operación.</p></div><a class="btn ghost" routerLink="/admin/tool-deliveries">Volver</a></div>
    <form class="panel" (ngSubmit)="submit()">
      @if (error()) { <div class="alert error">{{ error() }}</div> }
      <div class="form-grid">
        <label>Empleado<select name="id_empleado" [(ngModel)]="employeeId" required><option [ngValue]="null">Selecciona un empleado</option>@for (employee of employees(); track employee.id_empleado) { <option [ngValue]="employee.id_empleado">{{ employeeLabel(employee) }}</option> }</select></label>
        <label>Fecha entrega<input type="date" name="fecha_entrega" [(ngModel)]="deliveryDate" required /></label>
        <label class="form-wide">Observaciones <span class="optional">opcional</span><textarea name="observaciones" [(ngModel)]="observations" maxlength="1000" rows="3"></textarea></label>
      </div>
      <div class="section-title"><div><h2>Herramientas</h2><p class="muted">Agrega al menos una herramienta. No se controlan existencias.</p></div><button class="btn secondary" type="button" (click)="addDetail()">Agregar herramienta</button></div>
      <div class="tool-detail-list">
        @for (detail of details(); track detail.key; let index = $index) {
          <section class="drawer-section tool-detail-row">
            <label>Herramienta<select [name]="'tool_' + detail.key" [ngModel]="detail.id_herramienta" (ngModelChange)="update(detail.key, 'id_herramienta', $event)"><option [ngValue]="null">Selecciona</option>@for (tool of availableTools(detail); track tool.id_herramienta) { <option [ngValue]="tool.id_herramienta">{{ tool.nombre }}</option> }</select></label>
            <label>Cantidad<input type="number" min="1" [name]="'quantity_' + detail.key" [ngModel]="detail.cantidad" (ngModelChange)="update(detail.key, 'cantidad', $event)" /></label>
            <label>Observaciones <span class="optional">opcional</span><input [name]="'notes_' + detail.key" [ngModel]="detail.observaciones" (ngModelChange)="update(detail.key, 'observaciones', $event)" maxlength="1000" /></label>
            <button class="btn small danger-outline" type="button" (click)="removeDetail(detail.key)" [disabled]="details().length === 1">Eliminar fila</button>
          </section>
        }
      </div>
      <div class="form-actions"><a class="btn secondary" routerLink="/admin/tool-deliveries">Cancelar</a><button class="btn primary" type="submit" [disabled]="saving() || loading()">{{ saving() ? 'Guardando...' : 'Guardar entrega' }}</button></div>
    </form>
  `,
})
export class ToolDeliveryCreateComponent implements OnInit {
  private readonly toolsService = inject(ToolService);
  private readonly employeesService = inject(EmployeeService);
  private readonly router = inject(Router);
  readonly tools = signal<Tool[]>([]);
  readonly employees = signal<Employee[]>([]);
  readonly details = signal<DetailDraft[]>([{ key: 1, id_herramienta: null, cantidad: 1, observaciones: '' }]);
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
        error: (error) => this.error.set(apiErrorMessage(error, 'No fue posible cargar los datos del formulario.')),
      });
  }
  addDetail(): void { this.details.update((rows) => [...rows, { key: this.nextKey++, id_herramienta: null, cantidad: 1, observaciones: '' }]); }
  removeDetail(key: number): void { if (this.details().length > 1) this.details.update((rows) => rows.filter((row) => row.key !== key)); }
  update(key: number, field: keyof Omit<DetailDraft, 'key'>, value: unknown): void {
    this.details.update((rows) => rows.map((row) => row.key === key ? { ...row, [field]: field === 'observaciones' ? String(value ?? '') : Number(value) || null } : row));
  }
  availableTools(current: DetailDraft): Tool[] {
    const selected = new Set(this.details().filter((row) => row.key !== current.key).map((row) => row.id_herramienta));
    return this.tools().filter((tool) => !selected.has(tool.id_herramienta));
  }
  submit(): void {
    this.error.set('');
    if (!this.employeeId) { this.error.set('Selecciona un empleado.'); return; }
    if (!this.deliveryDate) { this.error.set('Selecciona la fecha de entrega.'); return; }
    const rows = this.details();
    if (rows.some((row) => !row.id_herramienta || !Number.isInteger(Number(row.cantidad)) || Number(row.cantidad) < 1)) { this.error.set('Completa cada herramienta con una cantidad mayor a cero.'); return; }
    if (new Set(rows.map((row) => row.id_herramienta)).size !== rows.length) { this.error.set('No puedes agregar la misma herramienta dos veces.'); return; }
    this.saving.set(true);
    this.toolsService.createToolDelivery({
      id_empleado: this.employeeId, fecha_entrega: this.deliveryDate, observaciones: this.observations.trim() || null,
      herramientas: rows.map((row) => ({ id_herramienta: row.id_herramienta!, cantidad: Number(row.cantidad), observaciones: row.observaciones.trim() || null })),
    }).pipe(finalize(() => this.saving.set(false))).subscribe({
      next: (result) => void this.router.navigate(['/admin/tool-deliveries', result.id_entrega], { state: { message: 'Entrega registrada correctamente.' } }),
      error: (error) => this.error.set(apiErrorMessage(error, 'No fue posible completar la operación.')),
    });
  }
  employeeLabel(employee: Employee): string { return `${employee.nombre_completo || `${employee.nombres} ${employee.apellidos}`} — ${employee.numero_documento}`; }
  private localDate(): string { const now = new Date(); now.setMinutes(now.getMinutes() - now.getTimezoneOffset()); return now.toISOString().slice(0, 10); }
}
