import { Component, OnInit, inject, signal } from '@angular/core';
import { ActivatedRoute, Router, RouterLink } from '@angular/router';
import { finalize } from 'rxjs';
import { ToolDelivery } from '../../core/models/api.models';
import { AuthService } from '../../core/services/auth.service';
import { ToolService } from '../../core/services/tool.service';
import { apiErrorMessage } from '../../shared/api-error';

@Component({
  standalone: true,
  imports: [RouterLink],
  template: `
    <div class="page-heading">
      <div><p class="eyebrow">Herramientas</p><h1>Entrega #{{ deliveryId }}</h1><p class="muted">Cabecera y herramientas registradas en la entrega.</p></div>
      <a class="btn ghost" routerLink="/admin/tool-deliveries">Volver</a>
    </div>
    <section class="panel">
      @if (error()) { <div class="alert error">{{ error() }}</div> }
      @if (success()) { <div class="alert success">{{ success() }}</div> }
      @if (delivery(); as item) {
        <dl>
          <dt>Empleado</dt><dd>{{ employeeName(item) }}</dd><dt>Documento</dt><dd>{{ item.numero_documento || 'Sin dato' }}</dd>
          <dt>Fecha entrega</dt><dd>{{ item.fecha_entrega }}</dd><dt>Estado</dt><dd><span class="badge" [class.success]="isConfirmed(item)">{{ item.estado }}</span></dd>
          <dt>Observaciones</dt><dd>{{ item.observaciones || 'Sin observaciones' }}</dd><dt>Fecha confirmación</dt><dd>{{ item.fecha_confirmacion || 'Pendiente' }}</dd>
        </dl>
        @if (!isConfirmed(item) && auth.hasPermission('HERRAMIENTAS_CONFIRMAR')) {
          <div class="form-actions"><button class="btn primary" type="button" (click)="confirmReception()" [disabled]="confirming()">{{ confirming() ? 'Confirmando...' : 'Confirmar recibido' }}</button></div>
        }
        <div class="section-title"><div><h2>Detalle de herramientas</h2><p class="muted">Elementos incluidos en esta entrega.</p></div></div>
        <div class="table-wrap"><table>
          <thead><tr><th>Herramienta</th><th>Cantidad</th><th>Observaciones</th></tr></thead>
          <tbody>
            @for (detail of item.herramientas ?? []; track detail.id_detalle ?? detail.id_herramienta) {
              <tr><td><strong>{{ detail.herramienta || ('Herramienta ' + detail.id_herramienta) }}</strong></td><td>{{ detail.cantidad }}</td><td>{{ detail.observaciones || 'Sin observaciones' }}</td></tr>
            } @empty { <tr><td colspan="3" class="empty">No se encontraron herramientas en la entrega.</td></tr> }
          </tbody>
        </table></div>
      } @else if (loading()) { <div class="empty tall">Cargando entrega...</div> }
    </section>
  `,
})
export class ToolDeliveryDetailComponent implements OnInit {
  readonly auth = inject(AuthService);
  private readonly route = inject(ActivatedRoute);
  private readonly router = inject(Router);
  private readonly service = inject(ToolService);
  readonly delivery = signal<ToolDelivery | null>(null);
  readonly loading = signal(false);
  readonly confirming = signal(false);
  readonly error = signal('');
  readonly success = signal('');
  deliveryId = 0;

  ngOnInit(): void {
    this.deliveryId = Number(this.route.snapshot.paramMap.get('id'));
    this.success.set(String(this.router.getCurrentNavigation()?.extras.state?.['message'] ?? history.state?.message ?? ''));
    this.load();
  }
  load(): void {
    if (!this.deliveryId) { this.error.set('Entrega no válida.'); return; }
    this.loading.set(true); this.error.set('');
    this.service.getToolDelivery(this.deliveryId).pipe(finalize(() => this.loading.set(false))).subscribe({
      next: (delivery) => this.delivery.set(delivery),
      error: (error) => this.error.set(apiErrorMessage(error, 'No fue posible cargar la entrega.')),
    });
  }
  confirmReception(): void {
    if (!confirm('¿Confirmas que las herramientas fueron recibidas?')) return;
    this.confirming.set(true); this.error.set('');
    this.service.confirmToolDelivery(this.deliveryId).pipe(finalize(() => this.confirming.set(false))).subscribe({
      next: () => { this.success.set('Recepción confirmada correctamente.'); this.load(); },
      error: (error) => this.error.set(apiErrorMessage(error, 'No fue posible completar la operación.')),
    });
  }
  isConfirmed(delivery: ToolDelivery): boolean { return (delivery.estado ?? '').toLowerCase() === 'confirmada' || !!delivery.fecha_confirmacion; }
  employeeName(delivery: ToolDelivery): string { return delivery.empleado || `${delivery.nombres ?? ''} ${delivery.apellidos ?? ''}`.trim() || `Empleado ${delivery.id_empleado}`; }
}
