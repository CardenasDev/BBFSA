import { Component, OnInit, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { finalize } from 'rxjs';
import { ToolDelivery } from '../../core/models/api.models';
import { AuthService } from '../../core/services/auth.service';
import { ToolService } from '../../core/services/tool.service';
import { apiErrorMessage } from '../../shared/api-error';

@Component({
  standalone: true,
  imports: [FormsModule, RouterLink],
  template: `
    <div class="page-heading">
      <div><p class="eyebrow">Herramientas</p><h1>Entregas</h1><p class="muted">Consulta las entregas registradas a empleados.</p></div>
      @if (auth.hasPermission('HERRAMIENTAS_ENTREGAR')) { <a class="btn primary" routerLink="/admin/tool-deliveries/create">Registrar entrega</a> }
    </div>
    <section class="panel">
      <form class="filters" (ngSubmit)="load()">
        <label>ID empleado<input type="number" min="1" name="id_empleado" [(ngModel)]="employeeId" placeholder="Opcional" /></label>
        <label>Estado<select name="estado" [(ngModel)]="status"><option value="">Todos</option><option value="pendiente">Pendiente</option><option value="confirmada">Confirmada</option></select></label>
        <button class="btn secondary" type="submit" [disabled]="loading()">Filtrar</button>
      </form>
      @if (error()) { <div class="alert error">{{ error() }}</div> }
      @if (success()) { <div class="alert success">{{ success() }}</div> }
      <div class="table-wrap"><table>
        <thead><tr><th>ID</th><th>Empleado</th><th>Documento</th><th>Fecha</th><th>Estado</th><th>Confirmación</th><th>Observaciones</th><th>Acciones</th></tr></thead>
        <tbody>
          @for (delivery of deliveries(); track delivery.id_entrega) {
            <tr><td><strong>#{{ delivery.id_entrega }}</strong></td><td>{{ employeeName(delivery) }}</td><td>{{ delivery.numero_documento || '—' }}</td><td>{{ delivery.fecha_entrega }}</td>
              <td><span class="badge" [class.success]="normalizedStatus(delivery) === 'confirmada'">{{ delivery.estado || 'pendiente' }}</span></td>
              <td>{{ delivery.fecha_confirmacion || 'Pendiente' }}</td><td>{{ delivery.observaciones || 'Sin observaciones' }}</td>
              <td><div class="row-actions"><a class="btn small ghost" [routerLink]="['/admin/tool-deliveries', delivery.id_entrega]">Ver detalle</a>
                @if (canDelete(delivery)) { <button class="btn small danger-outline" type="button" (click)="remove(delivery)" [disabled]="deleting()">Eliminar</button> }
              </div></td>
            </tr>
          } @empty { <tr><td colspan="8" class="empty">{{ loading() ? 'Cargando entregas...' : 'No se encontraron entregas.' }}</td></tr> }
        </tbody>
      </table></div>
    </section>
  `,
})
export class ToolDeliveriesComponent implements OnInit {
  readonly auth = inject(AuthService);
  private readonly service = inject(ToolService);
  readonly deliveries = signal<ToolDelivery[]>([]);
  readonly loading = signal(false);
  readonly deleting = signal(false);
  readonly error = signal('');
  readonly success = signal('');
  employeeId: number | null = null;
  status: '' | 'pendiente' | 'confirmada' = '';

  ngOnInit(): void { this.load(); }
  load(): void {
    this.loading.set(true); this.error.set('');
    this.service.getToolDeliveries({
      id_empleado: Number(this.employeeId) > 0 ? Number(this.employeeId) : null,
      estado: this.status || null,
    }).pipe(finalize(() => this.loading.set(false))).subscribe({
      next: (deliveries) => this.deliveries.set(deliveries),
      error: (error) => this.error.set(apiErrorMessage(error, 'No fue posible cargar las entregas.')),
    });
  }
  remove(delivery: ToolDelivery): void {
    if (!confirm('¿Deseas eliminar esta entrega?')) return;
    this.deleting.set(true); this.error.set('');
    this.service.deleteToolDelivery(delivery.id_entrega).pipe(finalize(() => this.deleting.set(false))).subscribe({
      next: () => { this.success.set('Entrega eliminada correctamente.'); this.load(); },
      error: (error) => this.error.set(apiErrorMessage(error, 'No fue posible completar la operación.')),
    });
  }
  canDelete(delivery: ToolDelivery): boolean { return this.auth.hasPermission('HERRAMIENTAS_ELIMINAR') && this.normalizedStatus(delivery) === 'pendiente'; }
  normalizedStatus(delivery: ToolDelivery): string { return (delivery.estado ?? 'pendiente').toLowerCase(); }
  employeeName(delivery: ToolDelivery): string { return delivery.empleado || `${delivery.nombres ?? ''} ${delivery.apellidos ?? ''}`.trim() || `Empleado ${delivery.id_empleado}`; }
}
