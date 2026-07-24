import { HttpErrorResponse } from '@angular/common/http';
import { Component, OnInit, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { finalize } from 'rxjs';
import { DotationDelivery } from '../../core/models/api.models';
import { AuthService } from '../../core/services/auth.service';
import { DotationService, resolveDotationEvidenceUrl } from '../../core/services/dotation.service';
import { apiErrorMessage } from '../../shared/api-error';

@Component({
  standalone: true,
  imports: [FormsModule, RouterLink],
  template: `
    <div class="page-heading">
      <div><p class="eyebrow">Dotaciones</p><h1>Entregas</h1><p class="muted">Consulta general de entregas registradas y confirmacion de recibido.</p></div>
      <a class="btn primary" routerLink="/admin/dotations/deliveries/create">Nueva entrega</a>
    </div>

    <section class="panel">
      <form class="filters" (ngSubmit)="load()">
        <label>ID empleado<input type="number" min="1" name="id_empleado" [(ngModel)]="idEmpleado" placeholder="Opcional" /></label>
        <label>Fecha inicio<input type="date" name="fecha_inicio" [(ngModel)]="fechaInicio" /></label>
        <label>Fecha fin<input type="date" name="fecha_fin" [(ngModel)]="fechaFin" /></label>
        <button class="btn secondary" type="submit" [disabled]="loading()">Filtrar</button>
      </form>

      @if (error()) { <div class="alert error">{{ error() }} <button class="btn small ghost" type="button" (click)="load()" [disabled]="loading()">Reintentar</button></div> }
      @if (success()) { <div class="alert success" role="status">{{ success() }}</div> }
      <div class="table-wrap">
        <table>
          <thead><tr><th>ID</th><th>Fecha entrega</th><th>Tipo / combinacion</th><th>Documento</th><th>Nombre empleado</th><th>Estado</th><th>Fecha confirmacion</th><th>Confirmado por</th><th>Registrado por</th><th>Observaciones</th><th>Acciones</th></tr></thead>
          <tbody>
            @for (delivery of deliveries(); track delivery.id_dotacion_entrega) {
              <tr>
                <td><strong>#{{ delivery.id_dotacion_entrega }}</strong></td>
                <td>{{ delivery.fecha_entrega }}</td>
                <td><span class="badge">{{ delivery.tipo_entrega === 'EXTRAORDINARIA' ? 'Extraordinaria' : 'Ordinaria' }}</span><br><span class="muted">{{ combinationLabel(delivery) }}</span></td>
                <td>{{ delivery.numero_documento }}</td>
                <td>{{ delivery.nombre_completo }}</td>
                <td><span class="badge" [class.success]="delivery.estado === 'ENTREGADA'" [class.danger]="delivery.estado === 'ANULADA'">{{ delivery.estado }}</span></td>
                <td>{{ delivery.fecha_confirmacion || 'Pendiente' }}</td>
                <td>{{ delivery.confirmado_por || (delivery.id_confirmado_por ? 'ID ' + delivery.id_confirmado_por : 'Pendiente') }}</td>
                <td>{{ delivery.registrado_por || ('ID ' + delivery.id_registrado_por) }}</td>
                <td>{{ delivery.observaciones || 'Sin observaciones' }}</td>
                <td>
                  <div class="row-actions">
                    <a class="btn small ghost" [routerLink]="['/admin/dotations/deliveries', delivery.id_dotacion_entrega]">Ver detalle</a>
                    @if (evidenceUrl(delivery); as url) {
                      <a class="btn small secondary" [href]="url" target="_blank" rel="noopener noreferrer">Ver evidencia</a>
                    }
                    @if (canDeleteDelivery(delivery)) {
                      <button class="btn small danger-outline" type="button" (click)="openDeleteDelivery(delivery)" [disabled]="deleting()">Eliminar</button>
                    }
                  </div>
                </td>
              </tr>
            } @empty {
              <tr><td colspan="11" class="empty">{{ loading() ? 'Cargando entregas...' : 'No se encontraron entregas.' }}</td></tr>
            }
          </tbody>
        </table>
      </div>
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
          <p class="muted">Empleado: {{ delivery.nombre_completo }} - Fecha de entrega: {{ delivery.fecha_entrega }}</p>
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
export class DotationDeliveriesComponent implements OnInit {
  private readonly auth = inject(AuthService);
  private readonly service = inject(DotationService);
  readonly deliveries = signal<DotationDelivery[]>([]);
  readonly loading = signal(false);
  readonly deleting = signal(false);
  readonly error = signal('');
  readonly deleteError = signal('');
  readonly success = signal('');
  readonly selectedDeleteDelivery = signal<DotationDelivery | null>(null);
  idEmpleado: number | null = null;
  fechaInicio = '';
  fechaFin = '';
  deleteReason = '';

  ngOnInit(): void {
    this.load();
  }

  load(): void {
    this.loading.set(true);
    this.error.set('');
    this.service.getDeliveries({
      id_empleado: this.toNullableNumber(this.idEmpleado),
      fecha_inicio: this.blankToNull(this.fechaInicio),
      fecha_fin: this.blankToNull(this.fechaFin),
    }).pipe(finalize(() => this.loading.set(false))).subscribe({
      next: (deliveries) => this.deliveries.set(deliveries),
      error: (error) => this.error.set(apiErrorMessage(error, 'No fue posible cargar las entregas de dotacion.')),
    });
  }

  canDeleteDelivery(delivery: DotationDelivery): boolean {
    return this.auth.hasPermission('DOTACIONES_ENTREGAS_ELIMINAR')
      && delivery.estado === 'REGISTRADA'
      && !delivery.fecha_confirmacion;
  }

  combinationLabel(delivery: DotationDelivery): string {
    return delivery.codigo_combinacion
      ? `${delivery.codigo_combinacion} - ${delivery.nombre_combinacion ?? ''}`.trim()
      : '—';
  }

  evidenceUrl(delivery: DotationDelivery): string | null {
    return resolveDotationEvidenceUrl(delivery.evidencia_url_publica);
  }

  openDeleteDelivery(delivery: DotationDelivery): void {
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

  private toNullableNumber(value: unknown): number | null {
    const numberValue = Number(value);
    return Number.isFinite(numberValue) && numberValue > 0 ? numberValue : null;
  }

  private blankToNull(value: string): string | null {
    const text = value.trim();
    return text ? text : null;
  }

  private blankToUndefined(value: string): string | undefined {
    const text = value.trim();
    return text ? text : undefined;
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
}
