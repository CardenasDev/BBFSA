import { HttpErrorResponse } from '@angular/common/http';
import { Component, OnInit, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { finalize } from 'rxjs';
import { DotationDelivery, DotationEvidenceOrigin } from '../../core/models/api.models';
import { AuthService } from '../../core/services/auth.service';
import { DotationService, resolveDotationEvidenceUrl } from '../../core/services/dotation.service';
import { apiErrorMessage } from '../../shared/api-error';
import { CameraFilePickerComponent } from '../../shared/camera-file-picker.component';

@Component({
  standalone: true,
  imports: [FormsModule, RouterLink, CameraFilePickerComponent],
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
                <td><span class="badge" [class.success]="delivery.estado === 'ENTREGADA'" [class.danger]="delivery.estado === 'ANULADA'">{{ statusLabel(delivery.estado) }}</span></td>
                <td>{{ delivery.estado === 'POR_COMPRAR' ? 'No aplica' : (delivery.fecha_confirmacion || 'Pendiente') }}</td>
                <td>{{ delivery.estado === 'POR_COMPRAR' ? 'No aplica' : (delivery.confirmado_por || (delivery.id_confirmado_por ? 'ID ' + delivery.id_confirmado_por : 'Pendiente')) }}</td>
                <td>{{ delivery.registrado_por || ('ID ' + delivery.id_registrado_por) }}</td>
                <td>{{ delivery.observaciones || 'Sin observaciones' }}</td>
                <td>
                  <div class="row-actions">
                    <a class="btn small ghost" [routerLink]="['/admin/dotations/deliveries', delivery.id_dotacion_entrega]">Ver detalle</a>
                    @if (evidenceUrl(delivery); as url) {
                      <a class="btn small secondary" [href]="url" target="_blank" rel="noopener noreferrer">Ver evidencia</a>
                    }
                    @if (canManageEvidence(delivery)) {
                      <button class="btn small secondary" type="button" (click)="openEvidence(delivery)">{{ evidenceUrl(delivery) ? 'Modificar evidencia' : 'Agregar evidencia' }}</button>
                    }
                    @if (canPrepareDelivery(delivery)) {
                      <button class="btn small primary" type="button" (click)="openPrepareDelivery(delivery)" [disabled]="preparing()">Preparar entrega</button>
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

    @if (selectedPrepareDelivery(); as delivery) {
      <button class="drawer-backdrop" type="button" aria-label="Cerrar preparación" (click)="closePrepareDelivery()"></button>
      <aside class="role-drawer" aria-label="Preparar entrega" aria-modal="true">
        <header class="drawer-header">
          <div><p class="eyebrow">Compra completada</p><h2>Preparar entrega #{{ delivery.id_dotacion_entrega }}</h2></div>
          <button class="icon-btn close-btn" type="button" (click)="closePrepareDelivery()" aria-label="Cerrar">x</button>
        </header>
        <p class="muted">Registra la fecha real y la evidencia. La misma solicitud pasará a lista para entregar.</p>
        @if (prepareError()) { <div class="alert error" role="alert">{{ prepareError() }}</div> }
        <label>Fecha de entrega *<input type="date" name="prepare_fecha" [(ngModel)]="prepareDate" [disabled]="preparing()" /></label>
        <label>Origen de evidencia *
          <select name="prepare_origin" [(ngModel)]="prepareOrigin" (ngModelChange)="clearPrepareEvidence()" [disabled]="preparing()">
            <option value="ARCHIVO">Archivo</option><option value="URL">URL externa</option>
          </select>
        </label>
        @if (prepareOrigin === 'ARCHIVO') {
          <app-camera-file-picker accept=".pdf,.jpg,.jpeg,.png,.webp,.doc,.docx" galleryLabel="Seleccionar evidencia" (filesSelected)="setPrepareFiles($event)" />
          @if (prepareFile) { <p><strong>{{ prepareFile.name }}</strong></p> }
        } @else {
          <label>URL de evidencia *<input type="url" name="prepare_url" [(ngModel)]="prepareUrl" maxlength="500" placeholder="https://..." /></label>
        }
        <div class="form-actions">
          <button class="btn secondary" type="button" (click)="closePrepareDelivery()" [disabled]="preparing()">Cancelar</button>
          <button class="btn primary" type="button" (click)="confirmPrepareDelivery()" [disabled]="preparing()">{{ preparing() ? 'Preparando...' : 'Preparar entrega' }}</button>
        </div>
      </aside>
    }

    @if (selectedEvidenceDelivery(); as delivery) {
      <button class="drawer-backdrop" type="button" aria-label="Cerrar evidencia" (click)="closeEvidence()"></button>
      <aside class="role-drawer" aria-label="Gestionar evidencia" aria-modal="true">
        <header class="drawer-header"><div><p class="eyebrow">Evidencia de dotación</p><h2>Entrega #{{ delivery.id_dotacion_entrega }}</h2></div><button class="icon-btn close-btn" type="button" (click)="closeEvidence()">x</button></header>
        <p class="muted">Puedes reemplazar la evidencia actual por un archivo o una URL externa.</p>
        @if (evidenceUrl(delivery); as currentUrl) { <p><a class="btn small ghost" [href]="currentUrl" target="_blank" rel="noopener noreferrer">Ver evidencia actual</a></p> }
        @if (evidenceManageError()) { <div class="alert error">{{ evidenceManageError() }}</div> }
        <label>Origen de la nueva evidencia *<select [(ngModel)]="evidenceOrigin" name="evidence_origin" (ngModelChange)="clearEvidenceInput()" [disabled]="evidenceSaving()"><option value="ARCHIVO">Archivo</option><option value="URL">URL externa</option></select></label>
        @if (evidenceOrigin === 'ARCHIVO') {
          <app-camera-file-picker accept=".pdf,.jpg,.jpeg,.png,.webp,.doc,.docx" galleryLabel="Seleccionar evidencia" (filesSelected)="setEvidenceFiles($event)" />
          @if (evidenceFile) { <p><strong>{{ evidenceFile.name }}</strong></p> }
        } @else {
          <label>URL de evidencia *<input type="url" [(ngModel)]="evidenceExternalUrl" name="evidence_external_url" maxlength="500" placeholder="https://..." [disabled]="evidenceSaving()" /></label>
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
export class DotationDeliveriesComponent implements OnInit {
  private readonly auth = inject(AuthService);
  private readonly service = inject(DotationService);
  readonly deliveries = signal<DotationDelivery[]>([]);
  readonly loading = signal(false);
  readonly deleting = signal(false);
  readonly preparing = signal(false);
  readonly error = signal('');
  readonly deleteError = signal('');
  readonly success = signal('');
  readonly selectedDeleteDelivery = signal<DotationDelivery | null>(null);
  readonly selectedPrepareDelivery = signal<DotationDelivery | null>(null);
  readonly prepareError = signal('');
  readonly selectedEvidenceDelivery = signal<DotationDelivery | null>(null);
  readonly evidenceManageError = signal('');
  readonly evidenceSaving = signal(false);
  idEmpleado: number | null = null;
  fechaInicio = '';
  fechaFin = '';
  deleteReason = '';
  prepareDate = new Date().toISOString().slice(0, 10);
  prepareOrigin: DotationEvidenceOrigin = 'ARCHIVO';
  prepareFile: File | null = null;
  prepareUrl = '';
  evidenceOrigin: DotationEvidenceOrigin = 'ARCHIVO';
  evidenceFile: File | null = null;
  evidenceExternalUrl = '';

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

  canPrepareDelivery(delivery: DotationDelivery): boolean {
    return this.auth.hasPermission('DOTACIONES_ENTREGAS_CREAR') && delivery.estado === 'POR_COMPRAR';
  }

  canManageEvidence(delivery: DotationDelivery): boolean {
    return this.auth.hasPermission('DOTACIONES_ENTREGAS_CREAR') && delivery.estado !== 'POR_COMPRAR' && delivery.estado !== 'ANULADA';
  }

  openEvidence(delivery: DotationDelivery): void {
    this.selectedEvidenceDelivery.set(delivery); this.evidenceOrigin='ARCHIVO'; this.evidenceFile=null; this.evidenceExternalUrl=''; this.evidenceManageError.set('');
  }
  closeEvidence(): void { if(this.evidenceSaving()) return; this.selectedEvidenceDelivery.set(null); this.clearEvidenceInput(); }
  clearEvidenceInput(): void { this.evidenceFile=null; this.evidenceExternalUrl=''; this.evidenceManageError.set(''); }
  setEvidenceFiles(files: File[]): void { this.evidenceFile=files[0] ?? null; this.evidenceManageError.set(''); }
  replaceEvidence(): void {
    const delivery=this.selectedEvidenceDelivery(); if(!delivery) return;
    if(this.evidenceOrigin==='ARCHIVO' && !this.evidenceFile){this.evidenceManageError.set('Selecciona el archivo de evidencia.');return;}
    if(this.evidenceOrigin==='URL' && !/^https?:\/\/\S+$/i.test(this.evidenceExternalUrl.trim())){this.evidenceManageError.set('Ingresa una URL válida.');return;}
    this.evidenceSaving.set(true); this.evidenceManageError.set('');
    this.service.replaceDeliveryEvidence(delivery.id_dotacion_entrega,{origen_evidencia:this.evidenceOrigin,evidencia_nombre_archivo:'Evidencia entrega',evidencia_archivo:this.evidenceOrigin==='ARCHIVO'?this.evidenceFile:null,evidencia_url:this.evidenceOrigin==='URL'?this.evidenceExternalUrl.trim():null}).pipe(finalize(()=>this.evidenceSaving.set(false))).subscribe({next:()=>{this.selectedEvidenceDelivery.set(null);this.success.set('Evidencia reemplazada correctamente.');this.load();},error:e=>this.evidenceManageError.set(apiErrorMessage(e,'No fue posible reemplazar la evidencia.'))});
  }
  removeEvidence(): void {
    const delivery=this.selectedEvidenceDelivery(); if(!delivery || !confirm('¿Deseas eliminar la evidencia actual? La entrega se conservará.')) return;
    this.evidenceSaving.set(true); this.evidenceManageError.set('');
    this.service.deleteDeliveryEvidence(delivery.id_dotacion_entrega).pipe(finalize(()=>this.evidenceSaving.set(false))).subscribe({next:()=>{this.selectedEvidenceDelivery.set(null);this.success.set('Evidencia eliminada correctamente.');this.load();},error:e=>this.evidenceManageError.set(apiErrorMessage(e,'No fue posible eliminar la evidencia.'))});
  }

  statusLabel(status: string): string {
    if (status === 'POR_COMPRAR') return 'Por comprar';
    if (status === 'REGISTRADA') return 'Lista para entregar';
    if (status === 'ENTREGADA') return 'Entregada';
    if (status === 'ANULADA') return 'Anulada';
    return status;
  }

  openPrepareDelivery(delivery: DotationDelivery): void {
    this.selectedPrepareDelivery.set(delivery);
    this.prepareDate = new Date().toISOString().slice(0, 10);
    this.prepareOrigin = 'ARCHIVO';
    this.prepareFile = null;
    this.prepareUrl = '';
    this.prepareError.set('');
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
      this.prepareError.set('Selecciona la fecha de entrega.');
      return;
    }
    if (this.prepareOrigin === 'ARCHIVO' && !this.prepareFile) {
      this.prepareError.set('Selecciona el archivo de evidencia.');
      return;
    }
    if (this.prepareOrigin === 'URL' && !/^https?:\/\/\S+$/i.test(this.prepareUrl.trim())) {
      this.prepareError.set('Ingresa una URL de evidencia válida.');
      return;
    }
    this.preparing.set(true);
    this.prepareError.set('');
    this.service.prepareDelivery(delivery.id_dotacion_entrega, {
      fecha_entrega: this.prepareDate,
      origen_evidencia: this.prepareOrigin,
      evidencia_archivo: this.prepareOrigin === 'ARCHIVO' ? this.prepareFile : null,
      evidencia_url: this.prepareOrigin === 'URL' ? this.prepareUrl.trim() : null,
    }).pipe(finalize(() => this.preparing.set(false))).subscribe({
      next: () => {
        this.success.set('La solicitud quedó lista para entregar.');
        this.closePrepareDelivery();
        this.load();
      },
      error: (error) => this.prepareError.set(apiErrorMessage(error, 'No fue posible preparar la entrega.')),
    });
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
