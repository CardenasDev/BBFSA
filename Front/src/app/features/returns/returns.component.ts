import { Component, OnInit, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { finalize } from 'rxjs';
import { ReturnFilters, ReturnListItem, ReturnStatus, ReturnType } from '../../core/models/api.models';
import { AuthService } from '../../core/services/auth.service';
import { ReturnService } from '../../core/services/return.service';
import { apiErrorMessage } from '../../shared/api-error';

@Component({
  standalone: true,
  imports: [FormsModule, RouterLink],
  template: `
    <section class="page-header">
      <div><p class="eyebrow">Dotaciones y herramientas</p><h1>Devoluciones</h1><p class="muted">Historial unificado y recepción de elementos devueltos.</p></div>
      @if (auth.hasPermission('DEVOLUCIONES_CREAR')) {
        <a class="btn primary" routerLink="/admin/returns/create">Registrar devolución</a>
      }
    </section>

    <section class="panel">
      <form class="filters" (ngSubmit)="load()">
        <label>Tipo
          <select name="type" [(ngModel)]="filters.type">
            <option value="">Todos</option><option value="DOTACION">Dotación</option><option value="HERRAMIENTA">Herramienta</option>
          </select>
        </label>
        <label>ID empleado<input type="number" min="1" name="employee_id" [(ngModel)]="filters.employee_id" /></label>
        <label>Estado
          <select name="status" [(ngModel)]="filters.status">
            <option value="">Todos</option><option value="REGISTRADA">Registrada</option><option value="CONFIRMADA">Confirmada</option><option value="ANULADA">Anulada</option>
          </select>
        </label>
        <label>Fecha inicial<input type="date" name="date_from" [(ngModel)]="filters.date_from" /></label>
        <label>Fecha final<input type="date" name="date_to" [(ngModel)]="filters.date_to" /></label>
        <div class="filter-actions"><button class="btn secondary" type="submit" [disabled]="loading()">Filtrar</button><button class="btn ghost" type="button" (click)="clearFilters()">Limpiar</button></div>
      </form>
      @if (error()) { <div class="alert error" role="alert">{{ error() }}</div> }
      @if (success()) { <div class="alert success" role="status">{{ success() }}</div> }
      <div class="table-wrap" [attr.aria-busy]="loading()">
        <table>
          <thead><tr><th>ID</th><th>Fecha</th><th>Tipo</th><th>Documento</th><th>Empleado</th><th>Entrega</th><th>Elementos</th><th>Unidades</th><th>Evidencias</th><th>Estado</th><th>Acciones</th></tr></thead>
          <tbody>
            @for (item of returns(); track item.id_devolucion) {
              <tr>
                <td>#{{ item.id_devolucion }}</td><td>{{ item.fecha_devolucion || '—' }}</td><td>{{ typeLabel(item.tipo_devolucion) }}</td>
                <td>{{ item.numero_documento || '—' }}</td><td>{{ employeeName(item) }}</td><td>#{{ item.id_entrega }}</td>
                <td>{{ item.total_elementos ?? '—' }}</td><td>{{ item.total_unidades ?? '—' }}</td><td>{{ item.total_evidencias ?? '—' }}</td>
                <td><span class="badge" [class.success]="item.estado === 'CONFIRMADA'" [class.danger]="item.estado === 'ANULADA'" [class.warning]="item.estado === 'REGISTRADA'">{{ statusLabel(item.estado) }}</span></td>
                <td><div class="row-actions">
                  <a class="btn small ghost" [routerLink]="['/admin/returns', item.id_devolucion]">Ver detalle</a>
                  @if (canConfirm(item)) { <button class="btn small secondary" type="button" [disabled]="actionId() === item.id_devolucion" (click)="confirmReturn(item)">Confirmar</button> }
                  @if (canCancel(item)) { <button class="btn small danger-outline" type="button" [disabled]="actionId() === item.id_devolucion" (click)="cancelReturn(item)">Anular</button> }
                </div></td>
              </tr>
            } @empty {
              <tr><td colspan="11" class="empty">{{ loading() ? 'Cargando devoluciones...' : 'No hay devoluciones para los filtros seleccionados.' }}</td></tr>
            }
          </tbody>
        </table>
      </div>
    </section>
  `,
})
export class ReturnsComponent implements OnInit {
  readonly auth = inject(AuthService);
  private readonly service = inject(ReturnService);
  readonly returns = signal<ReturnListItem[]>([]);
  readonly loading = signal(false);
  readonly actionId = signal<number | null>(null);
  readonly error = signal('');
  readonly success = signal('');
  filters: ReturnFilters = { type: '', employee_id: null, status: '', date_from: '', date_to: '' };

  ngOnInit(): void { this.load(); }

  load(): void {
    this.loading.set(true); this.error.set('');
    this.service.getReturns(this.filters).pipe(finalize(() => this.loading.set(false))).subscribe({
      next: (items) => this.returns.set(items),
      error: (error) => this.error.set(apiErrorMessage(error, 'No fue posible consultar el historial de devoluciones.')),
    });
  }

  clearFilters(): void {
    this.filters = { type: '', employee_id: null, status: '', date_from: '', date_to: '' };
    this.load();
  }

  canConfirm(item: ReturnListItem): boolean {
    return item.estado === 'REGISTRADA' && this.auth.hasPermission('DEVOLUCIONES_CONFIRMAR');
  }

  canCancel(item: ReturnListItem): boolean {
    return item.estado !== 'ANULADA' && this.auth.hasPermission('DEVOLUCIONES_ANULAR');
  }

  confirmReturn(item: ReturnListItem): void {
    if (!this.canConfirm(item) || !window.confirm('¿Confirmas la recepción de esta devolución?\\n\\nUna vez confirmada, la devolución quedará registrada como recibida.')) return;
    this.actionId.set(item.id_devolucion); this.error.set(''); this.success.set('');
    this.service.confirmReturn(item.id_devolucion).pipe(finalize(() => this.actionId.set(null))).subscribe({
      next: () => {
        this.replaceStatus(item.id_devolucion, 'CONFIRMADA');
        this.success.set('Devolución confirmada correctamente.');
      },
      error: (error) => this.error.set(apiErrorMessage(error, 'No fue posible confirmar la devolución.')),
    });
  }

  cancelReturn(item: ReturnListItem): void {
    if (!this.canCancel(item)) return;
    const reason = window.prompt('La devolución será anulada, pero su información y evidencias se conservarán.\\n\\nIndica el motivo de anulación:')?.trim() ?? '';
    if (!reason) { this.error.set('El motivo de anulación es obligatorio.'); return; }
    if (reason.length > 500) { this.error.set('El motivo de anulación no puede superar 500 caracteres.'); return; }
    this.actionId.set(item.id_devolucion); this.error.set(''); this.success.set('');
    this.service.cancelReturn(item.id_devolucion, reason).pipe(finalize(() => this.actionId.set(null))).subscribe({
      next: () => {
        this.replaceStatus(item.id_devolucion, 'ANULADA');
        this.success.set('Devolución anulada correctamente.');
      },
      error: (error) => this.error.set(apiErrorMessage(error, 'No fue posible anular la devolución.')),
    });
  }

  typeLabel(type: ReturnType): string { return type === 'DOTACION' ? 'Dotación' : 'Herramienta'; }
  statusLabel(status: ReturnStatus): string { return ({ REGISTRADA: 'Registrada', CONFIRMADA: 'Confirmada', ANULADA: 'Anulada' })[status]; }
  employeeName(item: ReturnListItem): string { return item.empleado || item.nombre_completo || `Empleado #${item.id_empleado}`; }

  private replaceStatus(id: number, status: ReturnStatus): void {
    this.returns.update((items) => items.map((item) => item.id_devolucion === id ? { ...item, estado: status } : item));
  }
}
