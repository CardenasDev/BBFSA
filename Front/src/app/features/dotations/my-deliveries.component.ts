import { HttpErrorResponse } from '@angular/common/http';
import { Component, OnInit, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { finalize } from 'rxjs';
import { DotationDeliveryDetail, MyDotationDelivery } from '../../core/models/api.models';
import { AuthService } from '../../core/services/auth.service';
import { DotationService } from '../../core/services/dotation.service';
import { apiErrorMessage } from '../../shared/api-error';

@Component({
  standalone: true,
  imports: [FormsModule],
  template: `
    <div class="page-heading">
      <div><p class="eyebrow">Dotaciones</p><h1>Mis dotaciones</h1><p class="muted">Consulta las dotaciones que te han entregado y confirma recibido.</p></div>
    </div>

    <section class="panel">
      @if (success()) { <div class="alert success" role="status">{{ success() }}</div> }
      @if (error()) { <div class="alert error" role="alert">{{ error() }} <button class="btn small ghost" type="button" (click)="load()" [disabled]="loading()">Reintentar</button></div> }

      @for (delivery of deliveries(); track delivery.id_dotacion_entrega) {
        <article class="drawer-section">
          <div class="section-title">
            <div>
              <h3>Entrega #{{ delivery.id_dotacion_entrega }}</h3>
              <p class="muted">Fecha entrega: {{ delivery.fecha_entrega }} - Registrado por: {{ delivery.registrado_por || (delivery.id_registrado_por ? 'ID ' + delivery.id_registrado_por : 'Sin dato') }}</p>
            </div>
            <span class="badge" [class.success]="delivery.estado === 'ENTREGADA'" [class.danger]="delivery.estado === 'ANULADA'">{{ statusLabel(delivery.estado) }}</span>
          </div>

          <dl>
            <dt>Tipo de entrega</dt><dd>{{ delivery.tipo_entrega === 'EXTRAORDINARIA' ? 'Extraordinaria' : 'Ordinaria' }}</dd>
            <dt>Combinacion</dt><dd>{{ combinationLabel(delivery) }}</dd>
            <dt>Observaciones entrega</dt><dd>{{ delivery.observaciones || 'Sin observaciones' }}</dd>
            <dt>Fecha confirmacion</dt><dd>{{ delivery.fecha_confirmacion || 'Pendiente' }}</dd>
            <dt>Observacion confirmacion</dt><dd>{{ delivery.observacion_confirmacion || 'Sin observacion' }}</dd>
          </dl>

          <div class="row-actions">
            <button class="btn small ghost" type="button" (click)="toggleDetails(delivery)" [disabled]="detailsLoadingId() === delivery.id_dotacion_entrega">
              {{ isExpanded(delivery.id_dotacion_entrega) ? 'Ocultar detalle' : detailsLoadingId() === delivery.id_dotacion_entrega ? 'Cargando...' : 'Ver detalle' }}
            </button>
            @if (canConfirm(delivery)) {
              <button class="btn small primary" type="button" (click)="openConfirm(delivery)">Confirmar recibido</button>
            }
          </div>

          @if (detailErrors()[delivery.id_dotacion_entrega]) {
            <div class="alert error">{{ detailErrors()[delivery.id_dotacion_entrega] }}</div>
          }

          @if (isExpanded(delivery.id_dotacion_entrega)) {
            <div class="table-wrap">
              <table>
                <thead><tr><th>Tipo dotacion</th><th>Talla</th><th>Cantidad</th><th>Observaciones detalle</th></tr></thead>
                <tbody>
                  @for (detail of deliveryDetails(delivery.id_dotacion_entrega); track detail.id_dotacion_entrega_detalle) {
                    <tr>
                      <td>{{ detail.tipo_dotacion }}</td>
                      <td>{{ detail.talla || 'Sin talla' }}</td>
                      <td><strong>{{ detail.cantidad }}</strong></td>
                      <td>{{ detail.observaciones || 'Sin observaciones' }}</td>
                    </tr>
                  } @empty {
                    <tr><td colspan="4" class="empty">{{ detailsLoadingId() === delivery.id_dotacion_entrega ? 'Cargando detalle...' : 'No hay items registrados para esta entrega.' }}</td></tr>
                  }
                </tbody>
              </table>
            </div>
          }
        </article>
      } @empty {
        <div class="empty tall">{{ loading() ? 'Cargando dotaciones...' : 'No tienes entregas de dotacion registradas.' }}</div>
      }
    </section>

    @if (selectedDelivery(); as delivery) {
      <button class="drawer-backdrop" type="button" aria-label="Cerrar confirmacion" (click)="closeConfirm()"></button>
      <aside class="role-drawer" aria-label="Confirmar recibido" aria-modal="true">
        <header class="drawer-header">
          <div><p class="eyebrow">Confirmacion</p><h2>Entrega #{{ delivery.id_dotacion_entrega }}</h2></div>
          <button class="icon-btn close-btn" type="button" (click)="closeConfirm()" aria-label="Cerrar">x</button>
        </header>

        <section class="drawer-section">
          <h3>Confirma que recibiste los elementos listados en esta entrega.</h3>
          <p class="muted">Fecha de entrega: {{ delivery.fecha_entrega }}</p>
          <p class="muted">Observaciones: {{ delivery.observaciones || 'Sin observaciones' }}</p>
        </section>

        @if (confirmError()) { <div class="alert error" role="alert">{{ confirmError() }}</div> }

        <label>Observacion de confirmacion
          <textarea rows="5" maxlength="500" name="observacion_confirmacion" [(ngModel)]="confirmationObservation" [disabled]="confirming()" placeholder="Recibido completo y en buen estado."></textarea>
        </label>
        <p class="muted">{{ confirmationObservation.length }}/500 caracteres</p>

        <div class="form-actions">
          <button class="btn secondary" type="button" (click)="closeConfirm()" [disabled]="confirming()">Cancelar</button>
          <button class="btn primary" type="button" (click)="confirmReceived()" [disabled]="confirming()">{{ confirming() ? 'Confirmando...' : 'Confirmar recibido' }}</button>
        </div>
      </aside>
    }
  `,
})
export class MyDotationDeliveriesComponent implements OnInit {
  readonly auth = inject(AuthService);
  private readonly service = inject(DotationService);
  readonly deliveries = signal<MyDotationDelivery[]>([]);
  readonly loading = signal(false);
  readonly confirming = signal(false);
  readonly detailsLoadingId = signal<number | null>(null);
  readonly error = signal('');
  readonly confirmError = signal('');
  readonly success = signal('');
  readonly selectedDelivery = signal<MyDotationDelivery | null>(null);
  readonly expandedDeliveries = signal<Record<number, boolean>>({});
  readonly detailsByDelivery = signal<Record<number, DotationDeliveryDetail[]>>({});
  readonly detailErrors = signal<Record<number, string>>({});
  confirmationObservation = '';

  ngOnInit(): void {
    this.load();
  }

  canConfirm(delivery: MyDotationDelivery): boolean {
    return delivery.estado === 'REGISTRADA' && this.auth.hasPermission('DOTACIONES_MIS_ENTREGAS_CONFIRMAR');
  }

  statusLabel(status: string): string {
    if (status === 'REGISTRADA') return 'Pendiente de confirmacion';
    if (status === 'ENTREGADA') return 'Confirmada';
    if (status === 'ANULADA') return 'Anulada';
    return status;
  }

  combinationLabel(delivery: MyDotationDelivery): string {
    return delivery.codigo_combinacion
      ? `${delivery.codigo_combinacion} - ${delivery.nombre_combinacion ?? ''}`.trim()
      : '—';
  }

  load(): void {
    this.loading.set(true);
    this.error.set('');
    this.service.getMyDeliveries().pipe(finalize(() => this.loading.set(false))).subscribe({
      next: (deliveries) => {
        this.deliveries.set(deliveries);
        this.expandedDeliveries.set({});
        this.detailsByDelivery.set({});
        this.detailErrors.set({});
      },
      error: (error) => this.error.set(apiErrorMessage(error, 'No fue posible cargar tus entregas de dotacion.')),
    });
  }

  toggleDetails(delivery: MyDotationDelivery): void {
    const deliveryId = delivery.id_dotacion_entrega;
    if (this.isExpanded(deliveryId)) {
      this.expandedDeliveries.update((current) => ({ ...current, [deliveryId]: false }));
      return;
    }

    this.expandedDeliveries.update((current) => ({ ...current, [deliveryId]: true }));
    if (this.detailsByDelivery()[deliveryId]) {
      return;
    }

    this.detailsLoadingId.set(deliveryId);
    this.detailErrors.update((current) => ({ ...current, [deliveryId]: '' }));
    this.service.getDeliveryDetails(deliveryId).pipe(finalize(() => this.detailsLoadingId.set(null))).subscribe({
      next: (details) => this.detailsByDelivery.update((current) => ({ ...current, [deliveryId]: details })),
      error: (error) => this.detailErrors.update((current) => ({
        ...current,
        [deliveryId]: apiErrorMessage(error, 'No fue posible cargar el detalle de esta entrega.'),
      })),
    });
  }

  isExpanded(deliveryId: number): boolean {
    return Boolean(this.expandedDeliveries()[deliveryId]);
  }

  deliveryDetails(deliveryId: number): DotationDeliveryDetail[] {
    return this.detailsByDelivery()[deliveryId] ?? [];
  }

  openConfirm(delivery: MyDotationDelivery): void {
    this.selectedDelivery.set(delivery);
    this.confirmationObservation = delivery.observacion_confirmacion ?? '';
    this.confirmError.set('');
    this.success.set('');
  }

  closeConfirm(): void {
    if (this.confirming()) return;
    this.selectedDelivery.set(null);
    this.confirmationObservation = '';
    this.confirmError.set('');
  }

  confirmReceived(): void {
    const delivery = this.selectedDelivery();
    if (!delivery) return;
    if (!this.auth.hasPermission('DOTACIONES_MIS_ENTREGAS_CONFIRMAR')) {
      this.confirmError.set('No tienes permisos para confirmar entregas.');
      return;
    }

    this.confirming.set(true);
    this.confirmError.set('');
    this.service.confirmDeliveryReceived(delivery.id_dotacion_entrega, {
      observacion_confirmacion: this.blankToNull(this.confirmationObservation),
      firma_url: null,
    }).pipe(finalize(() => this.confirming.set(false))).subscribe({
      next: (confirmed) => {
        this.success.set('Entrega confirmada correctamente.');
        this.selectedDelivery.set(null);
        this.confirmationObservation = '';
        this.deliveries.update((deliveries) => deliveries.map((item) => item.id_dotacion_entrega === delivery.id_dotacion_entrega ? {
          ...item,
          estado: confirmed.estado,
          fecha_confirmacion: confirmed.fecha_confirmacion,
          observacion_confirmacion: confirmed.observacion_confirmacion,
          firma_url: confirmed.firma_url,
          id_confirmado_por: confirmed.id_confirmado_por,
        } : item));
      },
      error: (error) => this.confirmError.set(this.confirmErrorMessage(error)),
    });
  }

  private confirmErrorMessage(error: unknown): string {
    if (error instanceof HttpErrorResponse && error.status === 403) {
      return 'No tienes permisos para confirmar entregas.';
    }
    return apiErrorMessage(error, 'No fue posible confirmar la entrega.');
  }

  private blankToNull(value: string): string | null {
    const text = value.trim();
    return text ? text : null;
  }
}
