import { Component, OnInit, inject, signal } from '@angular/core';
import { RouterLink } from '@angular/router';
import { finalize } from 'rxjs';
import { ToolDelivery } from '../../core/models/api.models';
import { ToolService } from '../../core/services/tool.service';
import { apiErrorMessage } from '../../shared/api-error';

@Component({
  standalone: true,
  imports: [RouterLink],
  template: `
    <div class="page-heading">
      <div><p class="eyebrow">Herramientas</p><h1>Mis herramientas</h1><p class="muted">Consulta las herramientas que te han sido entregadas.</p></div>
    </div>
    <section class="panel">
      @if (error()) { <div class="alert error">{{ error() }} <button class="btn small ghost" type="button" (click)="load()" [disabled]="loading()">Reintentar</button></div> }
      <div class="table-wrap"><table>
        <thead><tr><th>Fecha de entrega</th><th>Estado</th><th>Total de herramientas</th><th>Fecha de confirmación</th><th>Observaciones</th><th>Acción</th></tr></thead>
        <tbody>
          @for (delivery of deliveries(); track delivery.id_entrega) {
            <tr>
              <td>{{ delivery.fecha_entrega }}</td>
              <td><span class="badge" [class.success]="isConfirmed(delivery)" [class.warning]="!isConfirmed(delivery)">{{ delivery.estado || 'pendiente' }}</span></td>
              <td><strong>{{ delivery.total_herramientas ?? 0 }}</strong></td>
              <td>{{ delivery.fecha_confirmacion || 'Pendiente' }}</td>
              <td>{{ delivery.observaciones || 'Sin observaciones' }}</td>
              <td><a class="btn small ghost" [routerLink]="['/admin/my-tool-deliveries', delivery.id_entrega]">Ver detalle</a></td>
            </tr>
          } @empty {
            <tr><td colspan="6" class="empty">{{ loading() ? 'Cargando entregas...' : 'No tienes entregas de herramientas registradas.' }}</td></tr>
          }
        </tbody>
      </table></div>
    </section>
  `,
})
export class MyToolDeliveriesComponent implements OnInit {
  private readonly service = inject(ToolService);
  readonly deliveries = signal<ToolDelivery[]>([]);
  readonly loading = signal(false);
  readonly error = signal('');

  ngOnInit(): void { this.load(); }
  load(): void {
    this.loading.set(true); this.error.set('');
    this.service.getMyToolDeliveries().pipe(finalize(() => this.loading.set(false))).subscribe({
      next: (deliveries) => this.deliveries.set(deliveries),
      error: (error) => this.error.set(apiErrorMessage(error, 'No fue posible cargar tus entregas de herramientas.')),
    });
  }
  isConfirmed(delivery: ToolDelivery): boolean {
    return (delivery.estado ?? '').toLowerCase() === 'confirmada' || !!delivery.fecha_confirmacion;
  }
}
