import { HttpErrorResponse } from '@angular/common/http';
import { Component, OnInit, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { finalize } from 'rxjs';
import { DotationEvidenceOrigin, EmployeeDotationHistory } from '../../core/models/api.models';
import { AuthService } from '../../core/services/auth.service';
import { DotationService, resolveDotationEvidenceUrl } from '../../core/services/dotation.service';
import { apiErrorMessage } from '../../shared/api-error';
import { CameraFilePickerComponent } from '../../shared/camera-file-picker.component';

interface DeliveryHistoryGroup {
  id_dotacion_entrega: number;
  fecha_entrega: string;
  tipo_entrega: EmployeeDotationHistory['tipo_entrega'];
  codigo_combinacion?: string | null;
  nombre_combinacion?: string | null;
  evidencia_nombre_archivo?: string | null;
  evidencia_nombre_original?: string | null;
  evidencia_url_publica?: string | null;
  evidencia_fecha_carga?: string | null;
  fecha_confirmacion?: string | null;
  estado: EmployeeDotationHistory['estado'];
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
  imports: [FormsModule, RouterLink, CameraFilePickerComponent],
  template: `
    <div class="page-heading">
      <div>
        <p class="eyebrow">Dotaciones</p>
        <h1>Historial de dotaciones</h1>
        <p class="muted">Todo lo entregado al empleado, agrupado por entrega.</p>
      </div>
      <div class="row-actions">
        @if (canCreateDelivery()) {
          <a
            class="btn primary"
            [routerLink]="['/admin/dotations/deliveries/create']"
            [queryParams]="{ employeeId: employeeId }"
            >Nueva entrega</a
          >
        }
        <a class="btn ghost" routerLink="/admin/dotations/employees">Volver</a>
      </div>
    </div>

    @if (error()) {
      <div class="alert error" role="alert">
        {{ error() }}
        <button class="btn small ghost" type="button" (click)="load()" [disabled]="loading()">
          Reintentar
        </button>
      </div>
    }
    @if (success()) {
      <div class="alert success" role="status">{{ success() }}</div>
    }

    @if (history().length) {
      <section class="panel profile-summary">
        <div class="avatar large">{{ initials() }}</div>
        <div>
          <h2>{{ employeeName() }}</h2>
          <p class="muted">
            Documento {{ employeeDocument() }} - {{ employeeArea() }} - {{ employeePosition() }}
          </p>
        </div>
        <span
          class="badge"
          [class.success]="pendingConfirmations() === 0"
          [class.danger]="pendingConfirmations() > 0"
          >{{ pendingConfirmations() }} pendientes</span
        >
      </section>

      <section class="stats-grid">
        <article class="stat-card">
          <span>Total entregas</span><strong>{{ totalDeliveries() }}</strong
          ><small>Entregas unicas registradas</small>
        </article>
        <article class="stat-card">
          <span>Total items entregados</span><strong>{{ totalItemsDelivered() }}</strong
          ><small>Suma de cantidades en detalles</small>
        </article>
        <article class="stat-card">
          <span>Ultima entrega</span><strong>{{ lastDeliveryDate() }}</strong
          ><small>Fecha mas reciente registrada</small>
        </article>
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
              @if (canManageEvidence(group)) {
                <button class="btn small secondary" type="button" (click)="openEvidence(group)">
                  {{ evidenceUrl(group) ? 'Modificar evidencia' : 'Agregar evidencia' }}
                </button>
              }
              @if (canPrepareDelivery(group)) {
                <button
                  class="btn small primary"
                  type="button"
                  (click)="openPrepareDelivery(group)"
                  [disabled]="preparing()"
                >
                  Confirmar compra
                </button>
              }
              @if (canDeleteDelivery(group)) {
                <button
                  class="btn small danger-outline"
                  type="button"
                  (click)="openDeleteDelivery(group)"
                  [disabled]="deleting()"
                >
                  Eliminar entrega
                </button>
              }
              @if (canConfirmDeliveryByHr(group)) {
                <button
                  class="btn small primary"
                  type="button"
                  (click)="confirmDeliveryByHr(group)"
                  [disabled]="confirmingDelivery()"
                >
                  {{ confirmingDelivery() ? 'Confirmando...' : 'Confirmar entrega' }}
                </button>
              }
              <span
                class="badge"
                [class.success]="group.estado === 'ENTREGADA'"
                [class.danger]="group.estado === 'ANULADA'"
                >{{ statusLabel(group.estado) }}</span
              >
            </div>
          </div>

          <dl>
            <dt>Tipo de entrega</dt>
            <dd>{{ group.tipo_entrega === 'EXTRAORDINARIA' ? 'Extraordinaria' : 'Ordinaria' }}</dd>
            <dt>Combinacion</dt>
            <dd>{{ combinationLabel(group) }}</dd>
            <dt>Fecha confirmacion</dt>
            <dd>
              {{
                group.estado === 'POR_COMPRAR'
                  ? 'No aplica'
                  : group.fecha_confirmacion || 'Pendiente'
              }}
            </dd>
            <dt>Confirmado por</dt>
            <dd>
              {{
                group.estado === 'POR_COMPRAR'
                  ? 'No aplica'
                  : group.confirmado_por ||
                    (group.id_confirmado_por ? 'ID ' + group.id_confirmado_por : 'Pendiente')
              }}
            </dd>
            <dt>Registrado por</dt>
            <dd>
              {{
                group.registrado_por ||
                  (group.id_registrado_por ? 'ID ' + group.id_registrado_por : 'Sin dato')
              }}
            </dd>
            <dt>Observacion entrega</dt>
            <dd>{{ group.observaciones_entrega || 'Sin observaciones' }}</dd>
            <dt>Observacion confirmacion</dt>
            <dd>{{ group.observacion_confirmacion || 'Sin observacion' }}</dd>
            <dt>Evidencia</dt>
            <dd>
              @if (evidenceUrl(group); as url) {
                <a [href]="url" target="_blank" rel="noopener noreferrer"
                  >Ver
                  {{
                    group.evidencia_nombre_original || group.evidencia_nombre_archivo || 'evidencia'
                  }}</a
                >
                <span class="muted"> {{ group.evidencia_fecha_carga || '' }}</span>
              } @else {
                —
              }
            </dd>
          </dl>

          <div class="table-wrap">
            <table>
              <thead>
                <tr>
                  <th>Articulo</th>
                  <th>Familia</th>
                  <th>Genero / unidad</th>
                  <th>Talla</th>
                  <th>Cantidad</th>
                  <th>Observaciones detalle</th>
                </tr>
              </thead>
              <tbody>
                @for (item of group.items; track item.id_dotacion_entrega_detalle) {
                  <tr>
                    <td>
                      <strong>{{ item.articulo || item.tipo_dotacion }}</strong>
                    </td>
                    <td>{{ item.tipo_dotacion }}</td>
                    <td>{{ item.genero || '—' }} / {{ item.unidad_medida || '—' }}</td>
                    <td>{{ item.talla || 'Sin talla' }}</td>
                    <td>
                      <strong>{{ item.cantidad }}</strong>
                    </td>
                    <td>{{ item.observaciones_detalle || 'Sin observaciones' }}</td>
                  </tr>
                }
              </tbody>
            </table>
          </div>
        </article>
      } @empty {
        <div class="empty tall">
          {{
            loading()
              ? 'Cargando historial...'
              : 'Este empleado aún no tiene dotaciones registradas.'
          }}
        </div>
      }
    </section>

    @if (selectedDeleteDelivery(); as delivery) {
      <button
        class="drawer-backdrop"
        type="button"
        aria-label="Cerrar eliminacion"
        (click)="closeDeleteDelivery()"
      ></button>
      <aside class="role-drawer" aria-label="Eliminar entrega" aria-modal="true">
        <header class="drawer-header">
          <div>
            <p class="eyebrow">Eliminacion logica</p>
            <h2>Entrega #{{ delivery.id_dotacion_entrega }}</h2>
          </div>
          <button
            class="icon-btn close-btn"
            type="button"
            (click)="closeDeleteDelivery()"
            aria-label="Cerrar"
          >
            x
          </button>
        </header>

        <section class="drawer-section">
          <h3>Seguro que deseas eliminar esta entrega de dotacion?</h3>
          <p class="muted">
            Esta accion ocultara la entrega del historial normal, pero no borrara el registro fisico
            de la base de datos.
          </p>
          <p class="muted">Fecha de entrega: {{ delivery.fecha_entrega }}</p>
        </section>

        @if (deleteError()) {
          <div class="alert error" role="alert">{{ deleteError() }}</div>
        }

        <label
          >Motivo de eliminacion <span class="optional">opcional</span>
          <textarea
            rows="5"
            maxlength="500"
            name="motivo_eliminacion"
            [(ngModel)]="deleteReason"
            [disabled]="deleting()"
            placeholder="Registro creado por error."
          ></textarea>
        </label>
        <p class="muted">{{ deleteReason.length }}/500 caracteres</p>

        <div class="form-actions">
          <button
            class="btn secondary"
            type="button"
            (click)="closeDeleteDelivery()"
            [disabled]="deleting()"
          >
            Cancelar
          </button>
          <button
            class="btn danger-outline"
            type="button"
            (click)="confirmDeleteDelivery()"
            [disabled]="deleting()"
          >
            {{ deleting() ? 'Eliminando...' : 'Eliminar' }}
          </button>
        </div>
      </aside>
    }

    @if (selectedPrepareDelivery(); as delivery) {
      <button
        class="drawer-backdrop"
        type="button"
        aria-label="Cerrar confirmacion de compra"
        (click)="closePrepareDelivery()"
      ></button>
      <aside class="role-drawer" aria-label="Confirmar compra y preparar entrega" aria-modal="true">
        <header class="drawer-header">
          <div>
            <p class="eyebrow">Compra completada</p>
            <h2>Entrega #{{ delivery.id_dotacion_entrega }}</h2>
          </div>
          <button
            class="icon-btn close-btn"
            type="button"
            (click)="closePrepareDelivery()"
            aria-label="Cerrar"
          >
            x
          </button>
        </header>

        <p class="muted">
          Registra la fecha real y la evidencia de la compra. La solicitud pasara a lista para
          entregar; el empleado confirmara el recibido posteriormente.
        </p>

        @if (prepareError()) {
          <div class="alert error" role="alert">{{ prepareError() }}</div>
        }

        <label
          >Fecha real de entrega *
          <input
            type="date"
            name="prepare_fecha"
            [(ngModel)]="prepareDate"
            [disabled]="preparing()"
          />
        </label>

        <label
          >Origen de evidencia *
          <select
            name="prepare_origin"
            [(ngModel)]="prepareOrigin"
            (ngModelChange)="clearPrepareEvidence()"
            [disabled]="preparing()"
          >
            <option value="ARCHIVO">Archivo</option>
            <option value="URL">URL externa</option>
          </select>
        </label>

        @if (prepareOrigin === 'ARCHIVO') {
          <app-camera-file-picker
            accept=".pdf,.jpg,.jpeg,.png,.webp,.doc,.docx"
            galleryLabel="Seleccionar evidencia"
            (filesSelected)="setPrepareFiles($event)"
          />
          @if (prepareFile) {
            <p>
              <strong>{{ prepareFile.name }}</strong>
            </p>
          }
        } @else {
          <label
            >URL de evidencia *
            <input
              type="url"
              name="prepare_url"
              [(ngModel)]="prepareUrl"
              maxlength="500"
              placeholder="https://..."
            />
          </label>
        }

        <div class="form-actions">
          <button
            class="btn secondary"
            type="button"
            (click)="closePrepareDelivery()"
            [disabled]="preparing()"
          >
            Cancelar
          </button>
          <button
            class="btn primary"
            type="button"
            (click)="confirmPrepareDelivery()"
            [disabled]="preparing()"
          >
            {{ preparing() ? 'Confirmando...' : 'Confirmar compra' }}
          </button>
        </div>
      </aside>
    }

    @if (selectedEvidenceDelivery(); as delivery) {
      <button class="drawer-backdrop" type="button" aria-label="Cerrar evidencia" (click)="closeEvidence()"></button>
      <aside class="role-drawer" aria-label="Gestionar evidencia" aria-modal="true">
        <header class="drawer-header">
          <div><p class="eyebrow">Evidencia de dotación</p><h2>Entrega #{{ delivery.id_dotacion_entrega }}</h2></div>
          <button class="icon-btn close-btn" type="button" (click)="closeEvidence()" aria-label="Cerrar">x</button>
        </header>
        <p class="muted">La entrega está {{ statusLabel(delivery.estado).toLowerCase() }}. Puedes reemplazar o eliminar únicamente su evidencia.</p>
        @if (evidenceUrl(delivery); as currentUrl) {
          <p><a class="btn small ghost" [href]="currentUrl" target="_blank" rel="noopener noreferrer">Ver evidencia actual</a></p>
        }
        @if (evidenceManageError()) { <div class="alert error" role="alert">{{ evidenceManageError() }}</div> }
        <label>Origen de la nueva evidencia *
          <select [(ngModel)]="evidenceOrigin" name="history_evidence_origin" (ngModelChange)="clearEvidenceInput()" [disabled]="evidenceSaving()">
            <option value="ARCHIVO">Archivo</option><option value="URL">URL externa</option>
          </select>
        </label>
        @if (evidenceOrigin === 'ARCHIVO') {
          <app-camera-file-picker accept=".pdf,.jpg,.jpeg,.png,.webp,.doc,.docx" galleryLabel="Seleccionar evidencia" (filesSelected)="setEvidenceFiles($event)" />
          @if (evidenceFile) { <p><strong>{{ evidenceFile.name }}</strong></p> }
        } @else {
          <label>URL de evidencia *<input type="url" [(ngModel)]="evidenceExternalUrl" name="history_evidence_url" maxlength="500" placeholder="https://..." [disabled]="evidenceSaving()" /></label>
        }
        <div class="form-actions">
          @if (evidenceUrl(delivery)) { <button class="btn danger-outline" type="button" (click)="removeEvidence()" [disabled]="evidenceSaving()">Eliminar evidencia</button> }
          <button class="btn secondary" type="button" (click)="closeEvidence()" [disabled]="evidenceSaving()">Cancelar</button>
          <button class="btn primary" type="button" (click)="replaceEvidence()" [disabled]="evidenceSaving()">{{ evidenceSaving() ? 'Guardando...' : 'Reemplazar evidencia' }}</button>
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
  readonly preparing = signal(false);
  readonly confirmingDelivery = signal(false);
  readonly error = signal('');
  readonly deleteError = signal('');
  readonly success = signal('');
  readonly selectedDeleteDelivery = signal<DeliveryHistoryGroup | null>(null);
  readonly selectedPrepareDelivery = signal<DeliveryHistoryGroup | null>(null);
  readonly prepareError = signal('');
  readonly selectedEvidenceDelivery = signal<DeliveryHistoryGroup | null>(null);
  readonly evidenceManageError = signal('');
  readonly evidenceSaving = signal(false);
  deleteReason = '';
  prepareDate = new Date().toISOString().slice(0, 10);
  prepareOrigin: DotationEvidenceOrigin = 'ARCHIVO';
  prepareFile: File | null = null;
  prepareUrl = '';
  evidenceOrigin: DotationEvidenceOrigin = 'ARCHIVO';
  evidenceFile: File | null = null;
  evidenceExternalUrl = '';
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
    this.service
      .getEmployeeHistory(this.employeeId)
      .pipe(finalize(() => this.loading.set(false)))
      .subscribe({
        next: (history) => this.history.set(history),
        error: (error) =>
          this.error.set(
            apiErrorMessage(
              error,
              'No fue posible cargar el historial de dotaciones del empleado.',
            ),
          ),
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
        evidencia_nombre_archivo: item.evidencia_nombre_archivo,
        evidencia_nombre_original: item.evidencia_nombre_original,
        evidencia_url_publica: item.evidencia_url_publica,
        evidencia_fecha_carga: item.evidencia_fecha_carga,
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
    return this.deliveryGroups().filter((group) => group.estado === 'ENTREGADA').length;
  }

  combinationLabel(delivery: DeliveryHistoryGroup): string {
    return delivery.codigo_combinacion
      ? `${delivery.codigo_combinacion} - ${delivery.nombre_combinacion ?? ''}`.trim()
      : '—';
  }

  evidenceUrl(delivery: DeliveryHistoryGroup): string | null {
    return resolveDotationEvidenceUrl(delivery.evidencia_url_publica);
  }

  totalItemsDelivered(): number {
    return this.history()
      .filter((item) => item.estado === 'ENTREGADA')
      .reduce((total, item) => total + Number(item.cantidad || 0), 0);
  }

  pendingConfirmations(): number {
    return this.deliveryGroups().filter(
      (group) => !group.fecha_confirmacion && group.estado === 'REGISTRADA',
    ).length;
  }

  lastDeliveryDate(): string {
    return (
      this.deliveryGroups()
        .filter((group) => group.estado === 'ENTREGADA')
        .reduce<string | null>(
          (latest, group) =>
            !latest || group.fecha_entrega > latest ? group.fecha_entrega : latest,
          null,
        ) ?? 'Sin entregas'
    );
  }

  statusLabel(status: string): string {
    if (status === 'POR_COMPRAR') return 'Por comprar';
    if (status === 'REGISTRADA') return 'Pendiente de confirmacion';
    if (status === 'ENTREGADA') return 'Confirmada';
    if (status === 'ANULADA') return 'Anulada';
    return status;
  }

  canCreateDelivery(): boolean {
    return this.auth.hasPermission('DOTACIONES_ENTREGAS_CREAR');
  }

  canPrepareDelivery(delivery: DeliveryHistoryGroup): boolean {
    return (
      this.auth.hasPermission('DOTACIONES_ENTREGAS_CREAR') && delivery.estado === 'POR_COMPRAR'
    );
  }

  canConfirmDeliveryByHr(delivery: DeliveryHistoryGroup): boolean {
    return this.auth.hasPermission('DOTACIONES_ENTREGAS_CREAR') && delivery.estado === 'REGISTRADA';
  }

  canManageEvidence(delivery: DeliveryHistoryGroup): boolean {
    return this.auth.hasPermission('DOTACIONES_ENTREGAS_CREAR')
      && delivery.estado !== 'POR_COMPRAR'
      && delivery.estado !== 'ANULADA';
  }

  openEvidence(delivery: DeliveryHistoryGroup): void {
    this.selectedEvidenceDelivery.set(delivery);
    this.evidenceOrigin = 'ARCHIVO';
    this.evidenceFile = null;
    this.evidenceExternalUrl = '';
    this.evidenceManageError.set('');
  }

  closeEvidence(): void {
    if (this.evidenceSaving()) return;
    this.selectedEvidenceDelivery.set(null);
    this.clearEvidenceInput();
  }

  clearEvidenceInput(): void {
    this.evidenceFile = null;
    this.evidenceExternalUrl = '';
    this.evidenceManageError.set('');
  }

  setEvidenceFiles(files: File[]): void {
    this.evidenceFile = files[0] ?? null;
    this.evidenceManageError.set('');
  }

  replaceEvidence(): void {
    const delivery = this.selectedEvidenceDelivery();
    if (!delivery) return;
    if (this.evidenceOrigin === 'ARCHIVO' && !this.evidenceFile) {
      this.evidenceManageError.set('Selecciona el archivo de evidencia.'); return;
    }
    if (this.evidenceOrigin === 'URL' && !/^https?:\/\/\S+$/i.test(this.evidenceExternalUrl.trim())) {
      this.evidenceManageError.set('Ingresa una URL válida.'); return;
    }
    this.evidenceSaving.set(true);
    this.evidenceManageError.set('');
    this.service.replaceDeliveryEvidence(delivery.id_dotacion_entrega, {
      origen_evidencia: this.evidenceOrigin,
      evidencia_nombre_archivo: 'Evidencia entrega',
      evidencia_archivo: this.evidenceOrigin === 'ARCHIVO' ? this.evidenceFile : null,
      evidencia_url: this.evidenceOrigin === 'URL' ? this.evidenceExternalUrl.trim() : null,
    }).pipe(finalize(() => this.evidenceSaving.set(false))).subscribe({
      next: () => { this.selectedEvidenceDelivery.set(null); this.success.set('Evidencia reemplazada correctamente.'); this.load(); },
      error: (error) => this.evidenceManageError.set(apiErrorMessage(error, 'No fue posible reemplazar la evidencia.')),
    });
  }

  removeEvidence(): void {
    const delivery = this.selectedEvidenceDelivery();
    if (!delivery || !window.confirm('¿Deseas eliminar la evidencia actual? La entrega confirmada se conservará.')) return;
    this.evidenceSaving.set(true);
    this.evidenceManageError.set('');
    this.service.deleteDeliveryEvidence(delivery.id_dotacion_entrega).pipe(finalize(() => this.evidenceSaving.set(false))).subscribe({
      next: () => { this.selectedEvidenceDelivery.set(null); this.success.set('Evidencia eliminada correctamente.'); this.load(); },
      error: (error) => this.evidenceManageError.set(apiErrorMessage(error, 'No fue posible eliminar la evidencia.')),
    });
  }

  confirmDeliveryByHr(delivery: DeliveryHistoryGroup): void {
    if (!this.canConfirmDeliveryByHr(delivery)) return;
    if (!window.confirm('¿Confirmas que la dotación fue entregada presencialmente al empleado?'))
      return;

    this.confirmingDelivery.set(true);
    this.error.set('');
    this.success.set('');
    this.service
      .confirmDeliveryByHr(delivery.id_dotacion_entrega, {
        observacion_confirmacion: 'Entrega presencial confirmada por Recursos Humanos.',
      })
      .pipe(finalize(() => this.confirmingDelivery.set(false)))
      .subscribe({
        next: () => {
          this.success.set('Entrega presencial confirmada correctamente.');
          this.load();
        },
        error: (error) =>
          this.error.set(apiErrorMessage(error, 'No fue posible confirmar la entrega presencial.')),
      });
  }

  openPrepareDelivery(delivery: DeliveryHistoryGroup): void {
    this.selectedPrepareDelivery.set(delivery);
    this.prepareDate = new Date().toISOString().slice(0, 10);
    this.prepareOrigin = 'ARCHIVO';
    this.prepareFile = null;
    this.prepareUrl = '';
    this.prepareError.set('');
    this.success.set('');
  }

  closePrepareDelivery(): void {
    if (this.preparing()) return;
    this.selectedPrepareDelivery.set(null);
    this.prepareFile = null;
    this.prepareUrl = '';
    this.prepareError.set('');
  }

  clearPrepareEvidence(): void {
    this.prepareFile = null;
    this.prepareUrl = '';
    this.prepareError.set('');
  }

  setPrepareFiles(files: File[]): void {
    this.prepareFile = files[0] ?? null;
    this.prepareError.set('');
  }

  confirmPrepareDelivery(): void {
    const delivery = this.selectedPrepareDelivery();
    if (!delivery || !this.prepareDate) {
      this.prepareError.set('Selecciona la fecha real de entrega.');
      return;
    }
    if (this.prepareOrigin === 'ARCHIVO' && !this.prepareFile) {
      this.prepareError.set('Selecciona el archivo de evidencia.');
      return;
    }
    if (this.prepareOrigin === 'URL' && !/^https?:\/\/\S+$/i.test(this.prepareUrl.trim())) {
      this.prepareError.set('Ingresa una URL de evidencia valida.');
      return;
    }

    this.preparing.set(true);
    this.prepareError.set('');
    this.service
      .prepareDelivery(delivery.id_dotacion_entrega, {
        fecha_entrega: this.prepareDate,
        origen_evidencia: this.prepareOrigin,
        evidencia_archivo: this.prepareOrigin === 'ARCHIVO' ? this.prepareFile : null,
        evidencia_url: this.prepareOrigin === 'URL' ? this.prepareUrl.trim() : null,
      })
      .pipe(finalize(() => this.preparing.set(false)))
      .subscribe({
        next: () => {
          this.success.set('Compra confirmada. La dotacion quedo lista para entregar.');
          this.selectedPrepareDelivery.set(null);
          this.prepareFile = null;
          this.prepareUrl = '';
          this.load();
        },
        error: (error) =>
          this.prepareError.set(apiErrorMessage(error, 'No fue posible confirmar la compra.')),
      });
  }

  canDeleteDelivery(delivery: DeliveryHistoryGroup): boolean {
    return (
      this.auth.hasPermission('DOTACIONES_ENTREGAS_ELIMINAR') &&
      delivery.estado === 'REGISTRADA' &&
      !delivery.fecha_confirmacion
    );
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
    this.service
      .deleteDelivery(delivery.id_dotacion_entrega, this.blankToUndefined(this.deleteReason))
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
    return this.employeeName()
      .split(/\s+/)
      .slice(0, 2)
      .map((part) => part[0])
      .join('')
      .toUpperCase();
  }

  private firstRow(): EmployeeDotationHistory | undefined {
    return this.history()[0];
  }

  private deleteDeliveryErrorMessage(error: unknown): string {
    if (error instanceof HttpErrorResponse && error.status === 403) {
      return 'No tienes permiso para eliminar entregas de dotacion.';
    }

    const message =
      error instanceof HttpErrorResponse
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
