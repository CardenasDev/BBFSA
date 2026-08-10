import { NgClass } from '@angular/common';
import { Component, OnInit, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { finalize, forkJoin } from 'rxjs';
import { ApplicantDetail, ApplicantDocument, ApplicantDocumentOrigin, ApplicantDocumentStatus, LaborDocumentType, RegisterApplicantDocumentRequest } from '../../core/models/api.models';
import { ApplicantService } from '../../core/services/applicant.service';
import { AuthService } from '../../core/services/auth.service';
import { CatalogService } from '../../core/services/catalog.service';
import { apiErrorMessage } from '../../shared/api-error';
import { environment } from '../../../environments/environment';
import { applicantName, applicantStatusClass, blankToNull, toNullableNumber } from './applicant-utils';

interface ApplicantDocumentForm {
  id_tipo_documento_laboral: number | null;
  origen_documento: ApplicantDocumentOrigin | null;
  nombre_archivo: string;
  archivo_url: string;
  observaciones: string;
}

interface DocumentOriginOption {
  value: ApplicantDocumentOrigin;
  label: string;
}

@Component({
  standalone: true,
  imports: [FormsModule, NgClass, RouterLink],
  templateUrl: './applicant-documents.component.html',
  styleUrl: './applicant-documents.component.scss',
})
export class ApplicantDocumentsComponent implements OnInit {
  readonly auth = inject(AuthService);
  private readonly route = inject(ActivatedRoute);
  private readonly service = inject(ApplicantService);
  private readonly catalogs = inject(CatalogService);
  readonly applicant = signal<ApplicantDetail | null>(null);
  readonly documents = signal<ApplicantDocument[]>([]);
  readonly laborDocumentTypes = signal<LaborDocumentType[]>([]);
  readonly loading = signal(false);
  readonly loadingLaborDocumentTypes = signal(false);
  readonly saving = signal(false);
  readonly createOpen = signal(false);
  readonly editingDocumentId = signal<number | null>(null);
  readonly error = signal('');
  readonly formError = signal('');
  readonly success = signal('');
  readonly documentOrigins: DocumentOriginOption[] = [
    { value: 'PENDIENTE', label: 'Pendiente' },
    { value: 'URL_EXTERNA', label: 'URL externa' },
    { value: 'ARCHIVO_FISICO', label: 'Archivo físico' },
  ];
  readonly acceptDocumentExtensions = '.pdf,.jpg,.jpeg,.png,.webp,.doc,.docx';
  applicantId = 0;
  selectedFile: File | null = null;
  form: ApplicantDocumentForm = this.emptyForm();

  ngOnInit(): void {
    this.applicantId = Number(this.route.snapshot.paramMap.get('applicantId'));
    this.load();
  }

  load(): void {
    this.loading.set(true);
    this.loadingLaborDocumentTypes.set(true);
    this.error.set('');
    forkJoin({
      applicant: this.service.getApplicant(this.applicantId),
      documents: this.service.getDocuments(this.applicantId),
      laborDocumentTypes: this.catalogs.getLaborDocumentTypesForApplicants(),
    }).pipe(finalize(() => {
      this.loading.set(false);
      this.loadingLaborDocumentTypes.set(false);
    })).subscribe({
      next: ({ applicant, documents, laborDocumentTypes }) => {
        this.applicant.set(applicant);
        this.documents.set(documents ?? []);
        this.laborDocumentTypes.set(laborDocumentTypes ?? []);
      },
      error: (error) => this.error.set(apiErrorMessage(error, 'No fue posible cargar los documentos.')),
    });
  }

  openCreate(): void {
    this.resetForm();
    this.success.set('');
    this.createOpen.set(true);
  }

  openEdit(document: ApplicantDocument): void {
    this.resetForm();
    this.success.set('');
    this.editingDocumentId.set(document.id_aspirante_documento);
    this.form = {
      id_tipo_documento_laboral: document.id_tipo_documento_laboral,
      origen_documento: 'ARCHIVO_FISICO',
      nombre_archivo: document.nombre_archivo || document.nombre_original || '',
      archivo_url: '',
      observaciones: document.observaciones || '',
    };
    this.createOpen.set(true);
  }

  closeCreate(): void {
    if (this.saving()) return;
    this.createOpen.set(false);
    this.editingDocumentId.set(null);
  }

  onOriginChange(origin: ApplicantDocumentOrigin | null): void {
    if (origin !== 'URL_EXTERNA') {
      this.form.archivo_url = '';
    }

    if (origin !== 'ARCHIVO_FISICO') {
      this.clearSelectedFile();
    }
  }

  onFileSelected(event: Event): void {
    const input = event.target as HTMLInputElement;
    const file = input.files?.[0] ?? null;

    if (!file) {
      this.clearSelectedFile();
      return;
    }

    const validationError = this.validateSelectedFile(file);
    if (validationError) {
      this.clearSelectedFile();
      input.value = '';
      this.formError.set(validationError);
      return;
    }

    this.selectedFile = file;
    this.formError.set('');
  }

  registerDocument(): void {
    const validation = this.validate();
    if (validation) {
      this.formError.set(validation);
      return;
    }

    this.saving.set(true);
    this.formError.set('');
    const documentId = this.editingDocumentId();
    const request = documentId
      ? this.service.updateDocument(this.applicantId, documentId, this.payload())
      : this.service.registerDocument(this.applicantId, this.payload());
    request.pipe(finalize(() => this.saving.set(false))).subscribe({
      next: () => {
        this.success.set(documentId ? 'Documento actualizado correctamente.' : 'Documento registrado correctamente.');
        this.resetForm();
        this.createOpen.set(false);
        this.editingDocumentId.set(null);
        this.load();
      },
      error: (error) => this.formError.set(apiErrorMessage(error, 'No fue posible registrar el documento.')),
    });
  }

  name(applicant: ApplicantDetail): string {
    return applicantName(applicant);
  }

  initials(applicant: ApplicantDetail): string {
    return this.name(applicant).split(/\s+/).slice(0, 2).map((part) => part[0]).join('').toUpperCase();
  }

  statusClass(status: string): string {
    return applicantStatusClass(status);
  }

  truthy(value: unknown): boolean {
    return value === true || value === 1 || value === '1';
  }

  displayId(value?: number | null): string {
    return value ? `ID ${value}` : 'Sin dato';
  }

  originLabel(origin?: string | null): string {
    if (origin === 'FISICO') return 'Archivo cargado';
    if (origin === 'URL') return 'URL externa';
    if (origin === 'SIN_ARCHIVO') return 'Pendiente';
    return 'Sin origen';
  }

  originBadgeClass(origin?: string | null): string {
    if (origin === 'FISICO') return 'success';
    if (origin === 'URL') return 'info';
    if (origin === 'SIN_ARCHIVO') return 'warning';
    return 'neutral';
  }

  stateBadgeClass(status?: ApplicantDocumentStatus | null): string {
    if (status === 'CARGADO' || status === 'VALIDADO') return 'success';
    if (status === 'RECHAZADO' || status === 'VENCIDO') return 'danger';
    if (status === 'PENDIENTE') return 'warning';
    return 'neutral';
  }

  backendFileUrl(path?: string | null): string {
    if (!path) {
      return '';
    }

    if (/^https?:\/\//i.test(path)) {
      return path;
    }

    const baseUrl = environment.backendUrl.replace(/\/$/, '');
    const normalizedPath = path.startsWith('/') ? path : `/${path}`;

    return `${baseUrl}${normalizedPath}`;
  }

  selectedLaborDocumentType(): LaborDocumentType | null {
    const selectedId = toNullableNumber(this.form.id_tipo_documento_laboral);

    return this.laborDocumentTypes().find((type) => type.id_tipo_documento_laboral === selectedId) ?? null;
  }

  private validate(): string {
    if (!this.form.id_tipo_documento_laboral) return 'Selecciona el tipo de documento.';
    if (!this.form.origen_documento) return 'Selecciona el origen del documento.';

    if (this.form.origen_documento === 'URL_EXTERNA' && !this.form.archivo_url.trim()) {
      return 'Ingresa la URL del documento.';
    }

    if (this.form.origen_documento === 'ARCHIVO_FISICO') {
      if (!this.selectedFile) return 'Selecciona un archivo para cargar.';
      const validation = this.validateSelectedFile(this.selectedFile);
      if (validation) return validation;
    }

    return '';
  }

  private payload(): RegisterApplicantDocumentRequest | FormData {
    const idTipoDocumentoLaboral = toNullableNumber(this.form.id_tipo_documento_laboral) ?? 0;
    const nombreArchivo = blankToNull(this.form.nombre_archivo);
    const observaciones = blankToNull(this.form.observaciones);

    if (this.form.origen_documento === 'ARCHIVO_FISICO') {
      const formData = new FormData();
      formData.append('id_tipo_documento_laboral', String(idTipoDocumentoLaboral));

      if (nombreArchivo) {
        formData.append('nombre_archivo', nombreArchivo);
      }

      if (this.selectedFile) {
        formData.append('archivo', this.selectedFile, this.selectedFile.name);
      }

      formData.append('estado_documento', 'CARGADO');

      if (observaciones) {
        formData.append('observaciones', observaciones);
      }

      return formData;
    }

    const payload: RegisterApplicantDocumentRequest = {
      id_tipo_documento_laboral: idTipoDocumentoLaboral,
      estado_documento: this.form.origen_documento === 'PENDIENTE' ? 'PENDIENTE' : 'CARGADO',
    };

    if (nombreArchivo) {
      payload.nombre_archivo = nombreArchivo;
    }

    if (this.form.origen_documento === 'URL_EXTERNA') {
      payload.archivo_url = this.form.archivo_url.trim();
    }

    if (observaciones) {
      payload.observaciones = observaciones;
    }

    return payload;
  }

  private emptyForm(): ApplicantDocumentForm {
    return { id_tipo_documento_laboral: null, origen_documento: null, nombre_archivo: '', archivo_url: '', observaciones: '' };
  }

  private resetForm(): void {
    this.form = this.emptyForm();
    this.clearSelectedFile();
    this.formError.set('');
    this.editingDocumentId.set(null);
  }

  private clearSelectedFile(): void {
    this.selectedFile = null;
  }

  private validateSelectedFile(file: File): string {
    if (file.size > 5 * 1024 * 1024) {
      return 'El archivo supera el tamaño máximo permitido de 5MB.';
    }

    const extension = file.name.includes('.') ? file.name.split('.').pop()?.toLowerCase() ?? '' : '';
    if (!['pdf', 'jpg', 'jpeg', 'png', 'webp', 'doc', 'docx'].includes(extension)) {
      return 'Tipo de archivo no permitido.';
    }

    return '';
  }
}
