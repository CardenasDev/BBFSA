import { Component, OnInit, inject, signal } from '@angular/core';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { finalize } from 'rxjs';
import { DotationDeliveryDetail } from '../../core/models/api.models';
import { DotationService } from '../../core/services/dotation.service';
import { apiErrorMessage } from '../../shared/api-error';

@Component({
  standalone: true,
  imports: [RouterLink],
  template: `
    <div class="page-heading">
      <div><p class="eyebrow">Dotaciones</p><h1>Detalle entrega #{{ deliveryId }}</h1><p class="muted">Items registrados en la entrega.</p></div>
      <a class="btn ghost" routerLink="/admin/dotations/deliveries">Volver</a>
    </div>

    <section class="panel">
      @if (error()) { <div class="alert error">{{ error() }} <button class="btn small ghost" type="button" (click)="load()" [disabled]="loading()">Reintentar</button></div> }
      <div class="table-wrap">
        <table>
          <thead><tr><th>Tipo dotacion</th><th>Talla</th><th>Cantidad</th><th>Observaciones</th></tr></thead>
          <tbody>
            @for (detail of details(); track detail.id_dotacion_entrega_detalle) {
              <tr>
                <td>{{ detail.tipo_dotacion }}</td>
                <td>{{ detail.talla || 'Sin talla' }}</td>
                <td><strong>{{ detail.cantidad }}</strong></td>
                <td>{{ detail.observaciones || 'Sin observaciones' }}</td>
              </tr>
            } @empty {
              <tr><td colspan="4" class="empty">{{ loading() ? 'Cargando detalle...' : 'No se encontraron detalles para esta entrega.' }}</td></tr>
            }
          </tbody>
        </table>
      </div>
    </section>
  `,
})
export class DotationDeliveryDetailComponent implements OnInit {
  private readonly route = inject(ActivatedRoute);
  private readonly service = inject(DotationService);
  readonly details = signal<DotationDeliveryDetail[]>([]);
  readonly loading = signal(false);
  readonly error = signal('');
  deliveryId = 0;

  ngOnInit(): void {
    this.deliveryId = Number(this.route.snapshot.paramMap.get('deliveryId'));
    this.load();
  }

  load(): void {
    if (!this.deliveryId) {
      this.error.set('Entrega no valida.');
      return;
    }
    this.loading.set(true);
    this.error.set('');
    this.service.getDeliveryDetails(this.deliveryId).pipe(finalize(() => this.loading.set(false))).subscribe({
      next: (details) => this.details.set(details),
      error: (error) => this.error.set(apiErrorMessage(error, 'No fue posible cargar el detalle de la entrega.')),
    });
  }
}
