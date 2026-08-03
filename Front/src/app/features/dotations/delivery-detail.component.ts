import { Component, OnInit, inject, signal } from '@angular/core';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { finalize } from 'rxjs';
import { DotationDeliveryDetail } from '../../core/models/api.models';
import { DotationService, resolveDotationEvidenceUrl } from '../../core/services/dotation.service';
import { apiErrorMessage } from '../../shared/api-error';

@Component({
  standalone: true,
  imports: [RouterLink],
  template: `
    <div class="page-heading">
      <div>
        <p class="eyebrow">Dotaciones</p>
        <h1>Detalle entrega #{{ deliveryId }}</h1>
        <p class="muted">Items registrados en la entrega.</p>
      </div>
      <a class="btn ghost" routerLink="/admin/dotations/deliveries">Volver</a>
    </div>

    <section class="panel">
      @if (error()) {
        <div class="alert error">
          {{ error() }}
          <button class="btn small ghost" type="button" (click)="load()" [disabled]="loading()">
            Reintentar
          </button>
        </div>
      }
      @if (header(); as delivery) {
        <dl>
          <dt>Tipo de entrega</dt>
          <dd>{{ delivery.tipo_entrega === 'EXTRAORDINARIA' ? 'Extraordinaria' : 'Ordinaria' }}</dd>
          <dt>Combinacion</dt>
          <dd>{{ combinationLabel(delivery) }}</dd>
          <dt>Fecha</dt>
          <dd>{{ delivery.fecha_entrega || 'Sin dato' }}</dd>
          <dt>Estado</dt>
          <dd>{{ delivery.estado || 'Sin dato' }}</dd>
          <dt>Observaciones</dt>
          <dd>{{ delivery.observaciones_entrega || 'Sin observaciones' }}</dd>
          <dt>Fecha confirmacion</dt>
          <dd>{{ delivery.fecha_confirmacion || 'Pendiente' }}</dd>
        </dl>
        <section class="drawer-section">
          <div class="section-title">
            <div>
              <h2>Evidencia de entrega</h2>
              <p class="muted">Evidencia registrada por quien realizó la entrega.</p>
            </div>
          </div>
          @if (evidenceUrl(delivery); as url) {
            <dl>
              <dt>Nombre</dt>
              <dd>
                {{
                  delivery.evidencia_nombre_original ||
                    delivery.evidencia_nombre_archivo ||
                    'Evidencia entrega'
                }}
              </dd>
              <dt>Fecha carga</dt>
              <dd>{{ delivery.evidencia_fecha_carga || 'Sin dato' }}</dd>
              <dt>Tamaño</dt>
              <dd>{{ evidenceSize(delivery.evidencia_peso_bytes) }}</dd>
            </dl>
            <a class="btn secondary" [href]="url" target="_blank" rel="noopener noreferrer"
              >Ver evidencia</a
            >
          } @else {
            <p class="muted">Esta entrega histórica no tiene evidencia registrada.</p>
          }
        </section>
      }
      <div class="table-wrap">
        <table>
          <thead>
            <tr>
              <th>Articulo</th>
              <th>Familia</th>
              <th>Genero / unidad</th>
              <th>Talla</th>
              <th>Cantidad</th>
              <th>Observaciones</th>
            </tr>
          </thead>
          <tbody>
            @for (detail of details(); track detail.id_dotacion_entrega_detalle) {
              <tr>
                <td>
                  <strong>{{ detail.articulo || detail.tipo_dotacion }}</strong>
                </td>
                <td>{{ detail.tipo_dotacion }}</td>
                <td>{{ detail.genero || '—' }} / {{ detail.unidad_medida || '—' }}</td>
                <td>{{ detail.talla || 'Sin talla' }}</td>
                <td>
                  <strong>{{ detail.cantidad }}</strong>
                </td>
                <td>{{ detail.observaciones || 'Sin observaciones' }}</td>
              </tr>
            } @empty {
              <tr>
                <td colspan="6" class="empty">
                  {{
                    loading()
                      ? 'Cargando detalle...'
                      : 'No se encontraron detalles para esta entrega.'
                  }}
                </td>
              </tr>
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
    this.service
      .getDeliveryDetails(this.deliveryId)
      .pipe(finalize(() => this.loading.set(false)))
      .subscribe({
        next: (details) => this.details.set(details),
        error: (error) =>
          this.error.set(apiErrorMessage(error, 'No fue posible cargar el detalle de la entrega.')),
      });
  }

  header(): DotationDeliveryDetail | undefined {
    return this.details()[0];
  }

  combinationLabel(delivery: DotationDeliveryDetail): string {
    return delivery.codigo_combinacion
      ? `${delivery.codigo_combinacion} - ${delivery.nombre_combinacion ?? ''}`.trim()
      : 'No aplica';
  }

  evidenceSize(bytes?: number | null): string {
    if (!bytes) return 'No aplica';
    return bytes < 1024 * 1024
      ? `${Math.max(1, Math.round(bytes / 1024))} KB`
      : `${(bytes / 1024 / 1024).toFixed(1)} MB`;
  }

  evidenceUrl(delivery: DotationDeliveryDetail): string | null {
    return resolveDotationEvidenceUrl(delivery.evidencia_url_publica);
  }
}
