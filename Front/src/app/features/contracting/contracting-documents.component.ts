import { Component, OnInit, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { finalize } from 'rxjs';
import { EmployeeLaborDocument, LaborDocumentType, RegisterEmployeeDocumentRequest } from '../../core/models/api.models';
import { AuthService } from '../../core/services/auth.service';
import { CatalogService } from '../../core/services/catalog.service';
import { ContractingService } from '../../core/services/contracting.service';
import { apiErrorMessage } from '../../shared/api-error';
import { FeedbackDialogComponent } from '../../shared/feedback-dialog.component';

const DOCUMENT_STATUSES = ['PENDIENTE', 'CARGADO', 'VALIDADO', 'RECHAZADO', 'VENCIDO'];

@Component({
  standalone: true,
  imports: [FormsModule, RouterLink, FeedbackDialogComponent],
  template: `
    <div class="page-heading">
      <div><p class="eyebrow">Contratacion</p><h1>Documentos laborales</h1><p class="muted">Metadata y vencimientos de documentos del empleado.</p></div>
      <div class="row-actions">
        @if (auth.hasPermission('CONTRATACION_DOCUMENTOS_SUBIR')) { <button class="btn primary" type="button" (click)="openCreate()">Registrar documento</button> }
        <a class="btn ghost" routerLink="/admin/contracting">Volver</a>
      </div>
    </div>

    <section class="panel">
      <div class="row-actions" style="margin-bottom:1rem">
        <a class="btn small ghost" [routerLink]="['/admin/contracting/employees', employeeId, 'profile']">Ficha</a>
        <a class="btn small ghost" [routerLink]="['/admin/contracting/employees', employeeId, 'contracts']">Contratos</a>
        <a class="btn small ghost" [routerLink]="['/admin/contracting/employees', employeeId, 'social-security']">Seguridad social</a>
        <a class="btn small ghost" [routerLink]="['/admin/contracting/employees', employeeId, 'medical-exams']">Examenes</a>
        <a class="btn small secondary" [routerLink]="['/admin/contracting/employees', employeeId, 'documents']">Documentos</a>
      </div>

      @if (success()) { <app-feedback-dialog type="success" [message]="success()" (closed)="success.set('')" /> }
      @if (error()) { <app-feedback-dialog type="error" [message]="error()" (closed)="error.set('')" /> }
      @if (documentPendingDeletion(); as document) {
        <app-feedback-dialog type="warning" title="Eliminar documento"
          [message]="deleteMessage(document)" actionLabel="Sí, eliminar" closeLabel="Cancelar"
          (action)="deleteDocument()" (closed)="cancelDelete()" />
      }

      <div class="table-wrap">
        <table>
          <thead><tr><th>Tipo</th><th>Obligatorio</th><th>Archivo</th><th>Estado</th><th>Carga</th><th>Vencimiento</th><th>Alerta</th><th>Cargado por</th><th>Validado por</th><th>Observaciones</th><th>Acciones</th></tr></thead>
          <tbody>
            @for (document of documents(); track document.id_empleado_documento || document.id_empleado_documento_laboral || document.nombre_archivo) {
              <tr>
                <td>{{ document.tipo_documento_laboral || displayId(document.id_tipo_documento_laboral) }}</td>
                <td>{{ truthy(document.obligatorio) ? 'Si' : 'No' }}</td>
                <td>
                  @if (isPrivateFile(document)) {
                    <button class="btn small ghost" type="button" (click)="openPrivateFile(document)">Abrir {{ document.nombre_archivo || 'archivo' }}</button>
                  } @else if (document.archivo_url) {
                    <a [href]="document.archivo_url" target="_blank" rel="noopener">{{ document.nombre_archivo || 'Abrir' }}</a>
                  } @else { <span>{{ document.nombre_archivo || 'Sin archivo' }}</span> }
                </td>
                <td><span class="badge" [class.success]="document.estado_documento === 'VALIDADO'" [class.danger]="document.estado_documento === 'RECHAZADO' || document.estado_documento === 'VENCIDO'">{{ document.estado_documento || 'Sin estado' }}</span></td>
                <td>{{ document.fecha_carga || 'Sin fecha' }}</td>
                <td>{{ document.fecha_vencimiento || 'Sin fecha' }}</td>
                <td><span class="badge" [class.success]="documentStatus(document) === 'Vigente'" [class.danger]="documentStatus(document) === 'Vencido'">{{ documentStatus(document) }}</span></td>
                <td>{{ document.cargado_por || 'Sin dato' }}</td>
                <td>{{ document.validado_por || 'Sin dato' }}</td>
                <td>{{ document.observaciones || 'Sin observaciones' }}</td>
                <td class="actions-cell">
                  @if (auth.hasPermission('CONTRATACION_DOCUMENTOS_SUBIR')) { <button class="btn small secondary" type="button" (click)="openEdit(document)">Editar</button> }
                  @if (auth.hasPermission('CONTRATACION_DOCUMENTOS_ELIMINAR')) { <button class="btn small danger" type="button" (click)="requestDelete(document)">Eliminar</button> }
                </td>
              </tr>
            } @empty {
              <tr><td colspan="11" class="empty">{{ loading() ? 'Cargando documentos...' : 'No hay registros para mostrar.' }}</td></tr>
            }
          </tbody>
        </table>
      </div>
    </section>

    @if (createOpen()) {
      <button class="drawer-backdrop" type="button" aria-label="Cerrar documento" (click)="closeCreate()"></button>
      <aside class="role-drawer" aria-label="Registrar documento" aria-modal="true">
        <header class="drawer-header">
          <div><p class="eyebrow">Documento laboral</p><h2>{{ editingDocumentId ? 'Editar documento' : 'Registrar documento' }}</h2></div>
          <button class="icon-btn close-btn" type="button" (click)="closeCreate()" aria-label="Cerrar">x</button>
        </header>
        <p class="muted">Registra la informacion del archivo disponible para consulta del empleado.</p>
        @if (formError()) { <app-feedback-dialog type="error" [message]="formError()" (closed)="formError.set('')" /> }
        <form class="form-grid" (ngSubmit)="saveDocument()">
          <label>Tipo documento laboral
            <select name="id_tipo_documento_laboral" [(ngModel)]="form.id_tipo_documento_laboral" required>
              <option [ngValue]="null">{{ loadingDocumentTypes() ? 'Cargando...' : 'Seleccione...' }}</option>
              @for (item of documentTypes(); track item.id_tipo_documento_laboral) {
                <option [ngValue]="item.id_tipo_documento_laboral">{{ item.nombre }}</option>
              }
            </select>
          </label>
          <label>Nombre archivo<input name="nombre_archivo" [(ngModel)]="form.nombre_archivo" required maxlength="255" /></label>
          <label class="form-wide">Origen del documento
            <select name="file_origin" [(ngModel)]="fileOrigin" (ngModelChange)="changeFileOrigin()">
              <option value="ARCHIVO">Cargar archivo físico</option>
              <option value="URL">Usar URL externa</option>
            </select>
          </label>
          @if (fileOrigin === 'ARCHIVO') {
            <label class="form-wide">Archivo
              <input type="file" name="archivo" accept=".pdf,.jpg,.jpeg,.png,.webp,.doc,.docx" (change)="selectFile($event)" />
              <small class="muted">PDF, imagen o documento Word. Máximo 5 MB.</small>
              @if (editingDocumentId && !selectedFile) { <small class="muted">Déjalo vacío para conservar el archivo actual.</small> }
            </label>
          } @else {
            <label class="form-wide">Archivo URL<input type="url" name="archivo_url" [(ngModel)]="form.archivo_url" maxlength="500" placeholder="https://..." /></label>
          }
          <label>Fecha vencimiento<input type="date" name="fecha_vencimiento" [(ngModel)]="form.fecha_vencimiento" /></label>
          <label>Estado
            <select name="estado_documento" [(ngModel)]="form.estado_documento">
              @for (item of statuses; track item) { <option [value]="item">{{ item }}</option> }
            </select>
          </label>
          <label class="form-wide">Observaciones<textarea rows="3" name="observaciones" [(ngModel)]="form.observaciones"></textarea></label>
          <div class="form-actions form-wide">
            <button class="btn secondary" type="button" (click)="closeCreate()" [disabled]="saving()">Cancelar</button>
            <button class="btn primary" type="submit" [disabled]="saving()">{{ saving() ? 'Guardando...' : (editingDocumentId ? 'Guardar cambios' : 'Registrar documento') }}</button>
          </div>
        </form>
      </aside>
    }
  `,
})
export class ContractingDocumentsComponent implements OnInit {
  readonly auth = inject(AuthService);
  private readonly route = inject(ActivatedRoute);
  private readonly service = inject(ContractingService);
  private readonly catalogs = inject(CatalogService);
  readonly documents = signal<EmployeeLaborDocument[]>([]);
  readonly documentTypes = signal<LaborDocumentType[]>([]);
  readonly loadingDocumentTypes = signal(false);
  readonly loading = signal(false);
  readonly saving = signal(false);
  readonly createOpen = signal(false);
  readonly error = signal('');
  readonly formError = signal('');
  readonly success = signal('');
  readonly documentPendingDeletion = signal<EmployeeLaborDocument | null>(null);
  readonly deletingDocumentId = signal<number | null>(null);
  readonly statuses = DOCUMENT_STATUSES;
  employeeId = 0;
  form: RegisterEmployeeDocumentRequest = this.emptyForm();
  fileOrigin: 'ARCHIVO' | 'URL' = 'ARCHIVO';
  selectedFile: File | null = null;
  editingDocumentId: number | null = null;

  ngOnInit(): void {
    this.employeeId = Number(this.route.snapshot.paramMap.get('employeeId'));
    this.load();
    this.loadDocumentTypes();
  }

  load(): void {
    this.loading.set(true);
    this.error.set('');
    this.service.getDocuments(this.employeeId).pipe(finalize(() => this.loading.set(false))).subscribe({
      next: (documents) => this.documents.set(documents),
      error: (error) => this.error.set(apiErrorMessage(error, 'No fue posible cargar la informacion de contratacion.')),
    });
  }

  loadDocumentTypes(): void {
    this.loadingDocumentTypes.set(true);
    this.catalogs.getLaborDocumentTypesForContracting().pipe(finalize(() => this.loadingDocumentTypes.set(false))).subscribe({
      next: (documentTypes) => this.documentTypes.set(documentTypes),
      error: (error) => this.error.set(apiErrorMessage(error, 'No fue posible cargar los tipos de documento laboral.')),
    });
  }

  openCreate(): void {
    this.editingDocumentId = null;
    this.form = this.emptyForm();
    this.formError.set('');
    this.success.set('');
    this.fileOrigin = 'ARCHIVO';
    this.selectedFile = null;
    this.createOpen.set(true);
  }

  openEdit(document: EmployeeLaborDocument): void {
    const documentId = this.documentId(document);
    if (!documentId) {
      this.error.set('No fue posible identificar el documento.');
      return;
    }
    this.editingDocumentId = documentId;
    this.form = {
      id_tipo_documento_laboral: document.id_tipo_documento_laboral ?? null,
      nombre_archivo: document.nombre_archivo ?? '',
      archivo_url: document.archivo_url ?? null,
      mime_type: document.mime_type ?? null,
      peso_bytes: document.peso_bytes ?? null,
      fecha_vencimiento: document.fecha_vencimiento ?? null,
      estado_documento: document.estado_documento ?? 'CARGADO',
      observaciones: document.observaciones ?? null,
    };
    this.fileOrigin = this.isPrivateFile(document) ? 'ARCHIVO' : 'URL';
    this.selectedFile = null;
    this.formError.set('');
    this.success.set('');
    this.createOpen.set(true);
  }

  closeCreate(): void {
    if (this.saving()) return;
    this.createOpen.set(false);
  }

  saveDocument(): void {
    const validation = this.validate();
    if (validation) {
      this.formError.set(validation);
      return;
    }
    this.saving.set(true);
    const operation = this.editingDocumentId
      ? this.service.updateDocument(this.employeeId, this.editingDocumentId, this.payload())
      : this.service.registerDocument(this.employeeId, this.payload());
    operation.pipe(finalize(() => this.saving.set(false))).subscribe({
      next: () => {
        this.success.set(this.editingDocumentId ? 'Documento actualizado correctamente.' : 'Documento registrado correctamente.');
        this.editingDocumentId = null;
        this.createOpen.set(false);
        this.load();
      },
      error: (error) => this.formError.set(apiErrorMessage(error, 'No fue posible guardar el documento.')),
    });
  }

  requestDelete(document: EmployeeLaborDocument): void {
    this.documentPendingDeletion.set(document);
  }

  cancelDelete(): void {
    if (this.deletingDocumentId() === null) this.documentPendingDeletion.set(null);
  }

  deleteMessage(document: EmployeeLaborDocument): string {
    return `¿Deseas eliminar “${document.nombre_archivo || 'este documento'}”?\n\nEl registro se ocultará, pero el archivo físico se conservará para mantener la trazabilidad.`;
  }

  deleteDocument(): void {
    const id = this.documentId(this.documentPendingDeletion());
    if (!id || this.deletingDocumentId() !== null) return;
    this.deletingDocumentId.set(id);
    this.service.deleteDocument(this.employeeId, id).pipe(finalize(() => this.deletingDocumentId.set(null))).subscribe({
      next: () => {
        this.documentPendingDeletion.set(null);
        this.success.set('Documento eliminado correctamente.');
        this.load();
      },
      error: (error) => {
        this.documentPendingDeletion.set(null);
        this.error.set(apiErrorMessage(error, 'No fue posible eliminar el documento.'));
      },
    });
  }

  documentStatus(document: EmployeeLaborDocument): string {
    if (this.truthy(document.vencido)) return 'Vencido';
    if (this.truthy(document.proximo_vencer)) return 'Proximo a vencer';
    return 'Vigente';
  }

  truthy(value: unknown): boolean {
    return value === true || value === 1 || value === '1';
  }

  displayId(value?: number | null): string {
    return value ? `ID ${value}` : 'Sin dato';
  }

  changeFileOrigin(): void {
    this.selectedFile = null;
    this.form.archivo_url = null;
    this.formError.set('');
  }

  selectFile(event: Event): void {
    const input = event.target as HTMLInputElement;
    this.selectedFile = input.files?.[0] ?? null;
    if (this.selectedFile && !this.form.nombre_archivo.trim()) this.form.nombre_archivo = this.selectedFile.name;
    this.formError.set('');
  }

  isPrivateFile(document: EmployeeLaborDocument): boolean {
    return Boolean(document.archivo_url?.startsWith('private://'));
  }

  openPrivateFile(employeeDocument: EmployeeLaborDocument): void {
    const documentId = Number(employeeDocument.id_empleado_documento_laboral ?? employeeDocument.id_empleado_documento);
    if (!documentId) {
      this.error.set('No fue posible identificar el documento.');
      return;
    }
    this.service.downloadDocument(this.employeeId, documentId).subscribe({
      next: (blob) => {
        const url = URL.createObjectURL(blob);
        const link = document.createElement('a');
        link.href = url;
        link.target = '_blank';
        link.rel = 'noopener';
        link.click();
        setTimeout(() => URL.revokeObjectURL(url), 60_000);
      },
      error: (error) => this.error.set(apiErrorMessage(error, 'No fue posible abrir el documento.')),
    });
  }

  private validate(): string {
    if (!this.form.id_tipo_documento_laboral) return 'El tipo de documento laboral es obligatorio.';
    if (!this.form.nombre_archivo?.trim()) return 'El nombre del archivo es obligatorio.';
    if (this.fileOrigin === 'ARCHIVO') {
      if (!this.selectedFile && !this.editingDocumentId) return 'Selecciona el archivo del documento laboral.';
      if (this.selectedFile && !/\.(pdf|jpe?g|png|webp|docx?)$/i.test(this.selectedFile.name)) return 'El archivo debe ser PDF, imagen o documento Word.';
      if (this.selectedFile && this.selectedFile.size > 5 * 1024 * 1024) return 'El archivo no debe superar 5 MB.';
    }
    if (this.fileOrigin === 'URL' && !this.form.archivo_url?.trim()) return 'Ingresa la URL externa del documento.';
    return '';
  }

  private payload(): RegisterEmployeeDocumentRequest | FormData {
    const normalized = { ...this.form, id_tipo_documento_laboral: Number(this.form.id_tipo_documento_laboral) };
    if (this.fileOrigin === 'URL') return normalized;
    normalized.archivo_url = null;

    const formData = new FormData();
    Object.entries(normalized).forEach(([key, value]) => {
      if (value !== null && value !== undefined && value !== '') formData.append(key, String(value));
    });
    if (this.selectedFile) formData.append('archivo', this.selectedFile, this.selectedFile.name);
    return formData;
  }

  private documentId(document: EmployeeLaborDocument | null): number | null {
    const value = Number(document?.id_empleado_documento_laboral ?? document?.id_empleado_documento);
    return Number.isInteger(value) && value > 0 ? value : null;
  }

  private emptyForm(): RegisterEmployeeDocumentRequest {
    return { id_tipo_documento_laboral: null, nombre_archivo: '', archivo_url: null, estado_documento: 'CARGADO' };
  }
}
