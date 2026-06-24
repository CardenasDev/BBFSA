import { Component, OnInit, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, Router, RouterLink } from '@angular/router';
import { finalize, forkJoin } from 'rxjs';
import { CreateDotationDeliveryRequest, DotationEmployeeSummary, DotationSize, DotationType } from '../../core/models/api.models';
import { DotationService } from '../../core/services/dotation.service';
import { apiErrorMessage } from '../../shared/api-error';

interface DeliveryDetailDraft {
  clientId: number;
  id_tipo_dotacion: number | null;
  id_talla_dotacion: number | null;
  cantidad: number;
  observaciones: string;
}

@Component({
  standalone: true,
  imports: [FormsModule, RouterLink],
  template: `
    <div class="page-heading">
      <div><p class="eyebrow">Dotaciones</p><h1>Nueva entrega</h1><p class="muted">Registra una entrega real de dotacion.</p></div>
      <a class="btn ghost" routerLink="/admin/dotations/deliveries">Volver</a>
    </div>

    <section class="panel">
      @if (success()) { <div class="alert success">{{ success() }}</div> }
      @if (error()) { <div class="alert error">{{ error() }}</div> }
      @if (catalogError()) { <div class="alert error">{{ catalogError() }} <button class="btn small ghost" type="button" (click)="loadInitialData()" [disabled]="loading()">Reintentar</button></div> }

      <form class="form-grid" (ngSubmit)="submit()">
        <label class="form-wide">Buscar empleado
          <input name="employeeSearch" [(ngModel)]="employeeSearch" placeholder="Documento, nombre, area o cargo" />
        </label>
        <label class="form-wide">Empleado
          <select name="id_empleado" [(ngModel)]="idEmpleado" required>
            <option [ngValue]="null">{{ loading() ? 'Cargando...' : 'Selecciona un empleado' }}</option>
            @for (employee of filteredEmployees(); track employee.id_empleado) {
              <option [ngValue]="employee.id_empleado">{{ employee.numero_documento }} - {{ employee.nombre_completo }}</option>
            }
          </select>
        </label>
        <label>Fecha entrega<input type="date" name="fecha_entrega" [(ngModel)]="fechaEntrega" required /></label>
        <label class="form-wide">Observaciones<textarea rows="3" name="observaciones" [(ngModel)]="observaciones"></textarea></label>

        <div class="form-wide section-title">
          <h2>Detalles</h2>
          <button class="btn secondary" type="button" (click)="addDetail()">Agregar fila</button>
        </div>

        <div class="form-wide table-wrap">
          <table>
            <thead><tr><th>Tipo dotacion</th><th>Talla</th><th>Cantidad</th><th>Observaciones</th><th>Acciones</th></tr></thead>
            <tbody>
              @for (detail of details(); track detail.clientId) {
                <tr>
                  <td>
                    <select [ngModel]="detail.id_tipo_dotacion" [name]="'tipo_' + detail.clientId" (ngModelChange)="updateType(detail.clientId, $event)">
                      <option [ngValue]="null">Selecciona</option>
                      @for (type of types(); track type.id_tipo_dotacion) {
                        <option [ngValue]="type.id_tipo_dotacion">{{ type.nombre }}</option>
                      }
                    </select>
                  </td>
                  <td>
                    <select [ngModel]="detail.id_talla_dotacion" [name]="'talla_' + detail.clientId" (ngModelChange)="updateDetail(detail.clientId, 'id_talla_dotacion', $event)">
                      <option [ngValue]="null">{{ requiresSize(detail.id_tipo_dotacion) ? 'Requerida' : 'Opcional' }}</option>
                      @for (size of sizesByType(detail.id_tipo_dotacion); track size.id_talla_dotacion) {
                        <option [ngValue]="size.id_talla_dotacion">{{ size.talla }}</option>
                      }
                    </select>
                  </td>
                  <td><input type="number" min="1" [ngModel]="detail.cantidad" [name]="'cantidad_' + detail.clientId" (ngModelChange)="updateDetail(detail.clientId, 'cantidad', $event)" /></td>
                  <td><input maxlength="250" [ngModel]="detail.observaciones" [name]="'observaciones_' + detail.clientId" (ngModelChange)="updateDetail(detail.clientId, 'observaciones', $event)" /></td>
                  <td><button class="btn small danger-outline" type="button" (click)="removeDetail(detail.clientId)" [disabled]="details().length === 1">Eliminar</button></td>
                </tr>
              }
            </tbody>
          </table>
        </div>

        <div class="form-actions form-wide">
          <a class="btn ghost" routerLink="/admin/dotations/deliveries">Cancelar</a>
          <button class="btn primary" type="submit" [disabled]="saving()">{{ saving() ? 'Guardando...' : 'Registrar entrega' }}</button>
        </div>
      </form>
    </section>
  `,
})
export class DotationDeliveryCreateComponent implements OnInit {
  private readonly service = inject(DotationService);
  private readonly route = inject(ActivatedRoute);
  private readonly router = inject(Router);
  readonly employees = signal<DotationEmployeeSummary[]>([]);
  readonly types = signal<DotationType[]>([]);
  readonly sizes = signal<DotationSize[]>([]);
  private nextDetailId = 1;
  readonly details = signal<DeliveryDetailDraft[]>([this.newDetail()]);
  readonly loading = signal(false);
  readonly saving = signal(false);
  readonly error = signal('');
  readonly catalogError = signal('');
  readonly success = signal('');
  employeeSearch = '';
  idEmpleado: number | null = null;
  fechaEntrega = new Date().toISOString().slice(0, 10);
  observaciones = '';

  ngOnInit(): void {
    const employeeId = Number(this.route.snapshot.queryParamMap.get('employeeId'));
    this.idEmpleado = Number.isFinite(employeeId) && employeeId > 0 ? employeeId : null;
    this.loadInitialData();
  }

  loadInitialData(): void {
    this.loading.set(true);
    this.catalogError.set('');
    forkJoin({
      employees: this.service.getEmployees(),
      types: this.service.getTypes(true),
      sizes: this.service.getSizes(),
    }).pipe(finalize(() => this.loading.set(false))).subscribe({
      next: ({ employees, types, sizes }) => {
        this.employees.set(employees);
        this.types.set(types);
        this.sizes.set(sizes);
      },
      error: (error) => this.catalogError.set(apiErrorMessage(error, 'No fue posible cargar empleados, tipos o tallas.')),
    });
  }

  filteredEmployees(): DotationEmployeeSummary[] {
    const term = this.employeeSearch.trim().toLowerCase();
    if (!term) return this.employees();
    return this.employees().filter((employee) => [
      employee.numero_documento,
      employee.nombre_completo,
      employee.area ?? '',
      employee.cargo ?? '',
    ].some((value) => value.toLowerCase().includes(term)));
  }

  addDetail(): void {
    this.details.update((details) => [...details, this.newDetail()]);
  }

  removeDetail(clientId: number): void {
    this.details.update((details) => details.length === 1 ? details : details.filter((detail) => detail.clientId !== clientId));
  }

  updateType(clientId: number, typeId: number | null): void {
    this.details.update((details) => details.map((detail) => detail.clientId === clientId ? { ...detail, id_tipo_dotacion: typeId, id_talla_dotacion: null } : detail));
  }

  updateDetail(clientId: number, key: 'id_talla_dotacion' | 'cantidad' | 'observaciones', value: number | string | null): void {
    this.details.update((details) => details.map((detail) => {
      if (detail.clientId !== clientId) return detail;
      if (key === 'cantidad') return { ...detail, cantidad: Number(value) };
      if (key === 'observaciones') return { ...detail, observaciones: String(value ?? '').slice(0, 250) };
      return { ...detail, id_talla_dotacion: value ? Number(value) : null };
    }));
  }

  sizesByType(typeId: number | null): DotationSize[] {
    return typeId ? this.sizes().filter((size) => size.id_tipo_dotacion === typeId) : [];
  }

  requiresSize(typeId: number | null): boolean {
    return Boolean(this.types().find((type) => type.id_tipo_dotacion === typeId)?.requiere_talla);
  }

  submit(): void {
    this.error.set('');
    this.success.set('');
    const validation = this.validate();
    if (validation) {
      this.error.set(validation);
      return;
    }

    const payload: CreateDotationDeliveryRequest = {
      id_empleado: this.idEmpleado!,
      fecha_entrega: this.fechaEntrega,
      observaciones: this.blankToNull(this.observaciones),
      detalles: this.details().map((detail) => ({
        id_tipo_dotacion: detail.id_tipo_dotacion!,
        id_talla_dotacion: detail.id_talla_dotacion,
        cantidad: Number(detail.cantidad),
        observaciones: this.blankToNull(detail.observaciones),
      })),
    };

    this.saving.set(true);
    this.service.createDelivery(payload).pipe(finalize(() => this.saving.set(false))).subscribe({
      next: (result) => {
        this.success.set('Entrega de dotacion registrada correctamente.');
        void this.router.navigate(['/admin/dotations/deliveries', result.id_dotacion_entrega]);
      },
      error: (error) => this.error.set(apiErrorMessage(error, 'No fue posible registrar la entrega de dotacion.')),
    });
  }

  private validate(): string {
    if (!this.idEmpleado) return 'Selecciona un empleado.';
    if (!this.fechaEntrega) return 'Selecciona la fecha de entrega.';
    if (!this.details().length) return 'Agrega al menos un detalle.';
    for (const [index, detail] of this.details().entries()) {
      const row = index + 1;
      if (!detail.id_tipo_dotacion) return `Selecciona el tipo de dotacion en la fila ${row}.`;
      if (!Number.isFinite(Number(detail.cantidad)) || Number(detail.cantidad) < 1) return `La cantidad de la fila ${row} debe ser mayor a cero.`;
      if (this.requiresSize(detail.id_tipo_dotacion) && !detail.id_talla_dotacion) return `Selecciona la talla en la fila ${row}.`;
    }
    return '';
  }

  private newDetail(): DeliveryDetailDraft {
    return { clientId: this.nextDetailId++, id_tipo_dotacion: null, id_talla_dotacion: null, cantidad: 1, observaciones: '' };
  }

  private blankToNull(value: string): string | null {
    const text = value.trim();
    return text ? text : null;
  }
}
