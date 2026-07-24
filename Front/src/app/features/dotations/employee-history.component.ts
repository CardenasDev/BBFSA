import { HttpErrorResponse } from '@angular/common/http';
import { Component, OnInit, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { finalize } from 'rxjs';
import { EmployeeDotationHistory } from '../../core/models/api.models';
import { AuthService } from '../../core/services/auth.service';
import { DotationService } from '../../core/services/dotation.service';
import { apiErrorMessage } from '../../shared/api-error';

interface DeliveryHistoryGroup {
  id_dotacion_entrega: number;
  fecha_entrega: string;
  tipo_entrega: EmployeeDotationHistory['tipo_entrega'];
  codigo_combinacion?: string | null;
  nombre_combinacion?: string | null;
  fecha_confirmacion?: string | null;
  estado: string;
  registrado_por?: string | null;
  id_registrado_por?: number | null;
  confirmado_por?: string | null;
  id_confirmado_por?: number | null;
  observaciones_entrega?: string | null;
  observacion_confirmacion?: string | null;
  items: EmployeeDotationHistory[];
}

@Component({
  standalone: true,
  imports: [FormsModule, RouterLink],
  template: `
    <div class="page-heading">
      <div><p class="eyebrow">Dotaciones</p><h1>Historial de dotaciones</h1><p class="muted">Todo lo entregado al empleado, agrupado por entrega.</p></div>
      <div class="row-actions">
        @if (canCreateDelivery()) { <a class="btn primary" [routerLink]="['/admin/dotations/deliveries/create']" [queryParams]="{ employeeId: employeeId }">Nueva entrega</a> }
        <a class="btn ghost" routerLink="/admin/dotations/employees">Volver</a>
      </div>
    </div>

    @if (error()) { <div class="alert error" role="alert">{{ error() }} <button class="btn small ghost" type="button" (click)="load()" [disabled]="loading()">Reintentar</button></div> }
    @if (success()) { <div class="alert success" role="status">{{ success() }}</div> }

    @if (history().length) {
      <section class="panel profile-summary">
        <div class="avatar large">{{ initials() }}</div>
        <div>
          <h2>{{ employeeName() }}</h2>
          <p class="muted">Documento {{ employeeDocument() }} - {{ employeeArea() }} - {{ employeePosition() }}</p>
        </div>
        <span class="badge" [class.success]="pendingConfirmations() === 0" [class.danger]="pendingConfirmations() > 0">{{ pendingConfirmations() }} pendientes</span>
      </section>

      <section class="stats-grid">
        <article class="stat-card"><span>Total entregas</span><strong>{{ totalDeliveries() }}</strong><small>Entregas unicas registradas</small></article>
        <article class="stat-card"><span>Total items entregados</span><strong>{{ totalItemsDelivered() }}</strong><small>Suma de cantidades en detalles</small></article>
        <article class="stat-card"><span>Ultima entrega</span><strong>{{ lastDeliveryDate() }}</strong><small>Fecha mas reciente registrada</small></article>
      </section>
    }

    <section class="panel">
      @for (group of deliveryGroups(); track group.id_dotacion_entrega) {
        <article class="drawer-section">
          <div class="section-title">
            <div>
              <h3>Entrega #{{ group.id_dotacion_entrega }}</h3>
              <p class="muted">Fecha entrega: {{ group.fecha_entrega }}</p>
            </div>
            <div class="row-actions">
              @if (canDeleteDelivery(group)) {
                <button class="btn small danger-outline" type="button" (click)="openDeleteDelivery(group)" [disabled]="deleting()">Eliminar entrega</button>
              }
              <span class="badge" [class.success]="group.estado === 'ENTREGADA'" [class.danger]="group.estado === 'ANULADA'">{{ statusLabel(group.estado) }}</span>
            </div>
          </div>

          <dl>
            <dt>Tipo de entrega</dt><dd>{{ group.tipo_entrega === 'EXTRAORDINARIA' ? 'Extraordinaria' : 'Ordinaria' }}</dd>
            <dt>Combinacion</dt><dd>{{ combinationLabel(group) }}</dd>
            <dt>Fecha confirmacion</dt><dd>{{ group.fecha_confirmacion || 'Pendiente' }}</dd>
            <dt>Confirmado por</dt><dd>{{ group.confirmado_por || (group.id_confirmado_por ? 'ID ' + group.id_confirmado_por : 'Pendiente') }}</dd>
            <dt>Registrado por</dt><dd>{{ group.registrado_por || (group.id_registrado_por ? 'ID ' + group.id_registrado_por : 'Sin dato') }}</dd>
            <dt>Observacion entrega</dt><dd>{{ group.observaciones_entrega || 'Sin observaciones' }}</dd>
            <dt>Observacion confirmacion</dt><dd>{{ group.observacion_confirmacion || 'Sin observacion' }}</dd>
          </dl>

          <div class="table-wrap">
            <table>
              <thead><tr><th>Tipo dotacion</th><th>Talla</th><th>Cantidad</th><th>Observaciones detalle</th></tr></thead>
              <tbody>
                @for (item of group.items; track item.id_dotacion_entrega_detalle) {
                  <tr>
                    <td>{{ item.tipo_dotacion }}</td>
                    <td>{{ item.talla || 'Sin talla' }}</td>
                    <td><strong>{{ item.cantidad }}</strong></td>
                    <td>{{ item.observaciones_detalle || 'Sin observaciones' }}</td>
                  </tr>
                }
              </tbody>
            </table>
          </div>
        </article>
      } @empty {
        <div class="empty tall">{{ loading() ? 'Cargando historial...' : 'Este empleado aún no tiene dotaciones registradas.' }}</div>
      }
    </section>

    @if (selectedDeleteDelivery(); as delivery) {
      <button class="drawer-backdrop" type="button" aria-label="Cerrar eliminacion" (click)="closeDeleteDelivery()"></button>
      <aside class="role-drawer" aria-label="Eliminar entrega" aria-modal="true">
        <header class="drawer-header">
          <div><p class="eyebrow">Eliminacion logica</p><h2>Entrega #{{ delivery.id_dotacion_entrega }}</h2></div>
          <button class="icon-btn close-btn" type="button" (click)="closeDeleteDelivery()" aria-label="Cerrar">x</button>
        </header>

        <section class="drawer-section">
          <h3>Seguro que deseas eliminar esta entrega de dotacion?</h3>
          <p class="muted">Esta accion ocultara la entrega del historial normal, pero no borrara el registro fisico de la base de datos.</p>
          <p class="muted">Fecha de entrega: {{ delivery.fecha_entrega }}</p>
        </section>

        @if (deleteError()) { <div class="alert error" role="alert">{{ deleteError() }}</div> }

        <label>Motivo de eliminacion <span class="optional">opcional</span>
          <textarea rows="5" maxlength="500" name="motivo_eliminacion" [(ngModel)]="deleteReason" [disabled]="deleting()" placeholder="Registro creado por error."></textarea>
        </label>
        <p class="muted">{{ deleteReason.length }}/500 caracteres</p>

        <div class="form-actions">
          <button class="btn secondary" type="button" (click)="closeDeleteDelivery()" [disabled]="deleting()">Cancelar</button>
          <button class="btn danger-outline" type="button" (click)="confirmDeleteDelivery()" [disabled]="deleting()">{{ deleting() ? 'Eliminando...' : 'Eliminar' }}</button>
        </div>
      </aside>
    }
  `,
})
export class EmployeeDotationHistoryComponent implements OnInit {
  private readonly route = inject(ActivatedRoute);
  private readonly auth = inject(AuthService);
  private readonly service = inject(DotationService);
  readonly history = signal<EmployeeDotationHistory[]>([]);
  readonly loading = signal(false);
  readonly deleting = signal(false);
  readonly error = signal('');
  readonly deleteError = signal('');
  readonly success = signal('');
  readonly selectedDeleteDelivery = signal<DeliveryHistoryGroup | null>(null);
  deleteReason = '';
  employeeId = 0;

  ngOnInit(): void {
    this.employeeId = Number(this.route.snapshot.paramMap.get('employeeId'));
    this.load();
  }

  load(): void {
    if (!Number.isFinite(this.employeeId) || this.employeeId < 1) {
      this.error.set('Empleado no valido.');
      return;
    }

    this.loading.set(true);
    this.error.set('');
    this.service.getEmployeeHistory(this.employeeId).pipe(finalize(() => this.loading.set(false))).subscribe({
      next: (history) => this.history.set(history),
      error: (error) => this.error.set(apiErrorMessage(error, 'No fue posible cargar el historial de dotaciones del empleado.')),
    });
  }

  deliveryGroups(): DeliveryHistoryGroup[] {
    const groups = new Map<number, DeliveryHistoryGroup>();
    this.history().forEach((item) => {
      const group = groups.get(item.id_dotacion_entrega) ?? {
        id_dotacion_entrega: item.id_dotacion_entrega,
        fecha_entrega: item.fecha_entrega,
        tipo_entrega: item.tipo_entrega,
        codigo_combinacion: item.codigo_combinacion,
        nombre_combinacion: item.nombre_combinacion,
        fecha_confirmacion: item.fecha_confirmacion,
        estado: item.estado,
        registrado_por: item.registrado_por,
        id_registrado_por: item.id_registrado_por,
        confirmado_por: item.confirmado_por,
        id_confirmado_por: item.id_confirmado_por,
        observaciones_entrega: item.observaciones_entrega,
        observacion_confirmacion: item.observacion_confirmacion,
        items: [],
      };
      group.items.push(item);
      groups.set(item.id_dotacion_entrega, group);
    });
    return Array.from(groups.values());
  }

  totalDeliveries(): number {
    return this.deliveryGroups().length;
  }

  combinationLabel(delivery: DeliveryHistoryGroup): string {
    return delivery.codigo_combinacion
      ? `${delivery.codigo_combinacion} - ${delivery.nombre_combinacion ?? ''}`.trim()
      : '—';
  }

  totalItemsDelivered(): number {
    return this.history().reduce((total, item) => total + Number(item.cantidad || 0), 0);
  }

  pendingConfirmations(): number {
    return this.deliveryGroups().filter((group) => !group.fecha_confirmacion && group.estado === 'REGISTRADA').length;
  }

  lastDeliveryDate(): string {
    return this.deliveryGroups().reduce<string | null>((latest, group) => !latest || group.fecha_entrega > latest ? group.fecha_entrega : latest, null) ?? 'Sin entregas';
  }

  statusLabel(status: string): string {
    if (status === 'REGISTRADA') return 'Pendiente de confirmacion';
    if (status === 'ENTREGADA') return 'Confirmada';
    if (status === 'ANULADA') return 'Anulada';
    return status;
  }

  canCreateDelivery(): boolean {
    return this.auth.hasPermission('DOTACIONES_ENTREGAS_CREAR');
  }

  canDeleteDelivery(delivery: DeliveryHistoryGroup): boolean {
    return this.auth.hasPermission('DOTACIONES_ENTREGAS_ELIMINAR')
      && delivery.estado === 'REGISTRADA'
      && !delivery.fecha_confirmacion;
  }

  openDeleteDelivery(delivery: DeliveryHistoryGroup): void {
    this.selectedDeleteDelivery.set(delivery);
    this.deleteReason = '';
    this.deleteError.set('');
    this.success.set('');
  }

  closeDeleteDelivery(): void {
    if (this.deleting()) return;
    this.selectedDeleteDelivery.set(null);
    this.deleteReason = '';
    this.deleteError.set('');
  }

  confirmDeleteDelivery(): void {
    const delivery = this.selectedDeleteDelivery();
    if (!delivery) return;

    if (!this.canDeleteDelivery(delivery)) {
      this.deleteError.set('Esta entrega no se puede eliminar.');
      return;
    }

    this.deleting.set(true);
    this.deleteError.set('');
    this.service.deleteDelivery(delivery.id_dotacion_entrega, this.blankToUndefined(this.deleteReason))
      .pipe(finalize(() => this.deleting.set(false)))
      .subscribe({
        next: () => {
          this.success.set('Entrega eliminada correctamente.');
          this.selectedDeleteDelivery.set(null);
          this.deleteReason = '';
          this.load();
        },
        error: (error) => this.deleteError.set(this.deleteDeliveryErrorMessage(error)),
      });
  }

  employeeName(): string {
    return this.firstRow()?.nombre_completo ?? `Empleado #${this.employeeId}`;
  }

  employeeDocument(): string {
    return this.firstRow()?.numero_documento ?? 'Sin dato';
  }

  employeeArea(): string {
    return this.firstRow()?.area ?? 'Sin area';
  }

  employeePosition(): string {
    return this.firstRow()?.cargo ?? 'Sin cargo';
  }

  initials(): string {
    return this.employeeName().split(/\s+/).slice(0, 2).map((part) => part[0]).join('').toUpperCase();
  }

  private firstRow(): EmployeeDotationHistory | undefined {
    return this.history()[0];
  }

  private deleteDeliveryErrorMessage(error: unknown): string {
    if (error instanceof HttpErrorResponse && error.status === 403) {
      return 'No tienes permiso para eliminar entregas de dotacion.';
    }

    const message = error instanceof HttpErrorResponse
      ? String((error.error as { message?: string } | null)?.message ?? '').toLowerCase()
      : '';

    if (message.includes('confirm') || message.includes('entregada')) {
      return 'No se puede eliminar una entrega ya confirmada.';
    }

    if (message.includes('no existe') || message.includes('eliminad')) {
      return 'La entrega no existe o ya fue eliminada.';
    }

    return 'No fue posible eliminar la entrega.';
  }

  private blankToUndefined(value: string): string | undefined {
    const text = value.trim();
    return text ? text : undefined;
  }
}
