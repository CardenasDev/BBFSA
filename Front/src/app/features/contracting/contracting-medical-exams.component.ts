import { Component, OnInit, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { finalize } from 'rxjs';
import { CreateMedicalExamRequest, EmployeeMedicalExam, MedicalExamType } from '../../core/models/api.models';
import { AuthService } from '../../core/services/auth.service';
import { CatalogService } from '../../core/services/catalog.service';
import { ContractingService } from '../../core/services/contracting.service';
import { apiErrorMessage } from '../../shared/api-error';
import { environment } from '../../../environments/environment';
import { FeedbackDialogComponent } from '../../shared/feedback-dialog.component';

@Component({
  standalone: true,
  imports: [FormsModule, RouterLink, FeedbackDialogComponent],
  template: `
    <div class="page-heading">
      <div><p class="eyebrow">Contratacion</p><h1>Examenes medicos</h1><p class="muted">Control de examenes de ingreso, periodicos y vencimientos.</p></div>
      <div class="row-actions">
        @if (auth.hasPermission('CONTRATACION_EXAMENES_CREAR')) { <button class="btn primary" type="button" (click)="openCreate()">Registrar examen</button> }
        <a class="btn ghost" routerLink="/admin/contracting">Volver</a>
      </div>
    </div>

    <section class="panel">
      <div class="row-actions" style="margin-bottom:1rem">
        <a class="btn small ghost" [routerLink]="['/admin/contracting/employees', employeeId, 'profile']">Ficha</a>
        <a class="btn small ghost" [routerLink]="['/admin/contracting/employees', employeeId, 'contracts']">Contratos</a>
        <a class="btn small ghost" [routerLink]="['/admin/contracting/employees', employeeId, 'social-security']">Seguridad social</a>
        <a class="btn small secondary" [routerLink]="['/admin/contracting/employees', employeeId, 'medical-exams']">Examenes</a>
        <a class="btn small ghost" [routerLink]="['/admin/contracting/employees', employeeId, 'documents']">Documentos</a>
      </div>

      @if (success()) { <app-feedback-dialog type="success" [message]="success()" (closed)="success.set('')" /> }
      @if (error()) { <app-feedback-dialog type="error" [message]="error()" (closed)="error.set('')" /> }
      @if (examPendingDeletion(); as exam) {
        <app-feedback-dialog type="warning" title="Eliminar examen médico"
          [message]="deleteMessage(exam)" actionLabel="Sí, eliminar" closeLabel="Cancelar"
          (action)="deleteExam()" (closed)="cancelDelete()" />
      }
      @if (medicalExamTypesError()) { <div class="alert error">{{ medicalExamTypesError() }} <button class="btn small ghost" type="button" (click)="loadMedicalExamTypes()" [disabled]="isLoadingMedicalExamTypes()">Reintentar</button></div> }

      <div class="table-wrap">
        <table>
          <thead><tr><th>Tipo</th><th>Fecha examen</th><th>Entidad</th><th>Resultado</th><th>Vencimiento</th><th>Estado</th><th>Archivo</th><th>Observaciones</th><th>Acciones</th></tr></thead>
          <tbody>
            @for (exam of exams(); track exam.id_examen_medico || exam.fecha_examen) {
              <tr>
                <td>{{ displayExamType(exam) }}</td>
                <td>{{ exam.fecha_examen }}</td>
                <td>{{ exam.entidad_realiza || 'Sin dato' }}</td>
                <td>{{ exam.resultado_general || 'Sin resultado' }}</td>
                <td>{{ exam.fecha_vencimiento || 'Sin fecha' }}</td>
                <td><span class="badge" [class.success]="examStatus(exam) === 'Vigente'" [class.danger]="examStatus(exam) === 'Vencido'">{{ examStatus(exam) }}</span></td>
                <td>@if (exam.archivo_url) { <a [href]="backendFileUrl(exam.archivo_url)" target="_blank" rel="noopener">Abrir</a> } @else { Sin archivo }</td>
                <td>{{ exam.observaciones || 'Sin observaciones' }}</td>
                <td class="actions-cell">
                  @if (auth.hasPermission('CONTRATACION_EXAMENES_EDITAR')) { <button class="btn small secondary" type="button" (click)="openEdit(exam)">Editar</button> }
                  @if (auth.hasPermission('CONTRATACION_EXAMENES_ELIMINAR')) { <button class="btn small danger" type="button" (click)="requestDelete(exam)">Eliminar</button> }
                </td>
              </tr>
            } @empty {
              <tr><td colspan="9" class="empty">{{ loading() ? 'Cargando examenes...' : 'No hay registros para mostrar.' }}</td></tr>
            }
          </tbody>
        </table>
      </div>
    </section>

    @if (createOpen()) {
      <button class="drawer-backdrop" type="button" aria-label="Cerrar examen" (click)="closeCreate()"></button>
      <aside class="role-drawer" aria-label="Registrar examen" aria-modal="true">
        <header class="drawer-header">
          <div><p class="eyebrow">Examen medico</p><h2>{{ editingExamId ? 'Editar examen' : 'Registrar examen' }}</h2></div>
          <button class="icon-btn close-btn" type="button" (click)="closeCreate()" aria-label="Cerrar">x</button>
        </header>
        <p class="muted">Registra la informacion del examen medico y su fecha de vencimiento.</p>
        @if (formError()) { <app-feedback-dialog type="error" [message]="formError()" (closed)="formError.set('')" /> }
        <form class="form-grid" (ngSubmit)="saveExam()">
          <label>Tipo de examen
            <select name="id_tipo_examen_medico" [(ngModel)]="form.id_tipo_examen_medico" [disabled]="isLoadingMedicalExamTypes()" required>
              <option [ngValue]="null">{{ isLoadingMedicalExamTypes() ? 'Cargando...' : 'Seleccione tipo de examen' }}</option>
              @for (examType of medicalExamTypes(); track examType.id_tipo_examen_medico) {
                <option [ngValue]="examType.id_tipo_examen_medico">{{ examType.nombre }}</option>
              }
            </select>
          </label>
          <label>Fecha examen<input type="date" name="fecha_examen" [(ngModel)]="form.fecha_examen" required /></label>
          <label>Entidad realiza<input name="entidad_realiza" [(ngModel)]="form.entidad_realiza" maxlength="200" /></label>
          <label>Resultado general<input name="resultado_general" [(ngModel)]="form.resultado_general" maxlength="250" /></label>
          <label>Fecha vencimiento<input type="date" name="fecha_vencimiento" [(ngModel)]="form.fecha_vencimiento" /></label>
          <label class="form-wide">Origen del soporte
            <select name="fileOrigin" [(ngModel)]="fileOrigin" (ngModelChange)="changeFileOrigin()">
              <option value="ARCHIVO">Cargar archivo</option>
              <option value="URL">URL externa</option>
              <option value="NINGUNO">Sin soporte</option>
            </select>
          </label>
          @if (fileOrigin === 'ARCHIVO') {
            <label class="form-wide">Archivo
              <input type="file" name="archivo" accept=".pdf,.jpg,.jpeg,.png,.webp,.doc,.docx" (change)="selectFile($event)" />
              <small class="muted">PDF, imagen o Word. Tamaño máximo: 5 MB.</small>
              @if (editingExamId && !selectedFile) { <small class="muted">Déjalo vacío para conservar el soporte actual.</small> }
            </label>
          } @else if (fileOrigin === 'URL') {
            <label class="form-wide">Archivo URL<input name="archivo_url" [(ngModel)]="form.archivo_url" maxlength="500" placeholder="https://..." /></label>
          }
          <label class="form-wide">Observaciones<textarea rows="3" name="observaciones" [(ngModel)]="form.observaciones"></textarea></label>
          <div class="form-actions form-wide">
            <button class="btn secondary" type="button" (click)="closeCreate()" [disabled]="saving()">Cancelar</button>
            <button class="btn primary" type="submit" [disabled]="saving()">{{ saving() ? 'Guardando...' : (editingExamId ? 'Guardar cambios' : 'Registrar examen') }}</button>
          </div>
        </form>
      </aside>
    }
  `,
})
export class ContractingMedicalExamsComponent implements OnInit {
  readonly auth = inject(AuthService);
  private readonly route = inject(ActivatedRoute);
  private readonly service = inject(ContractingService);
  private readonly catalogs = inject(CatalogService);
  readonly exams = signal<EmployeeMedicalExam[]>([]);
  readonly medicalExamTypes = signal<MedicalExamType[]>([]);
  readonly loading = signal(false);
  readonly isLoadingMedicalExamTypes = signal(false);
  readonly saving = signal(false);
  readonly createOpen = signal(false);
  readonly error = signal('');
  readonly medicalExamTypesError = signal('');
  readonly formError = signal('');
  readonly success = signal('');
  readonly examPendingDeletion = signal<EmployeeMedicalExam | null>(null);
  readonly deletingExamId = signal<number | null>(null);
  employeeId = 0;
  form: CreateMedicalExamRequest = this.emptyForm();
  fileOrigin: 'ARCHIVO' | 'URL' | 'NINGUNO' = 'ARCHIVO';
  selectedFile: File | null = null;
  editingExamId: number | null = null;

  ngOnInit(): void {
    this.employeeId = Number(this.route.snapshot.paramMap.get('employeeId'));
    this.loadMedicalExamTypes();
    this.load();
  }

  loadMedicalExamTypes(): void {
    if (this.isLoadingMedicalExamTypes()) return;
    this.isLoadingMedicalExamTypes.set(true);
    this.medicalExamTypesError.set('');
    this.catalogs.getMedicalExamTypes().pipe(finalize(() => this.isLoadingMedicalExamTypes.set(false))).subscribe({
      next: (examTypes) => this.medicalExamTypes.set(examTypes),
      error: (error) => {
        this.medicalExamTypes.set([]);
        this.medicalExamTypesError.set(apiErrorMessage(error, 'No fue posible cargar los tipos de examen médico.'));
      },
    });
  }

  load(): void {
    this.loading.set(true);
    this.error.set('');
    this.service.getMedicalExams(this.employeeId).pipe(finalize(() => this.loading.set(false))).subscribe({
      next: (exams) => this.exams.set(exams),
      error: (error) => this.error.set(apiErrorMessage(error, 'No fue posible cargar la informacion de contratacion.')),
    });
  }

  openCreate(): void {
    this.editingExamId = null;
    this.form = this.emptyForm();
    this.formError.set('');
    this.success.set('');
    this.fileOrigin = 'ARCHIVO';
    this.selectedFile = null;
    this.createOpen.set(true);
  }

  openEdit(exam: EmployeeMedicalExam): void {
    const examId = this.examId(exam);
    if (!examId) { this.error.set('No fue posible identificar el examen médico.'); return; }
    this.editingExamId = examId;
    this.form = {
      id_tipo_examen_medico: exam.id_tipo_examen_medico ?? null,
      fecha_examen: exam.fecha_examen,
      entidad_realiza: exam.entidad_realiza ?? null,
      resultado_general: exam.resultado_general ?? null,
      fecha_vencimiento: exam.fecha_vencimiento ?? null,
      archivo_url: exam.archivo_url ?? null,
      observaciones: exam.observaciones ?? null,
    };
    this.fileOrigin = exam.archivo_url ? (/^https?:\/\//i.test(exam.archivo_url) ? 'URL' : 'ARCHIVO') : 'NINGUNO';
    this.selectedFile = null;
    this.formError.set('');
    this.success.set('');
    this.createOpen.set(true);
  }

  closeCreate(): void {
    if (this.saving()) return;
    this.createOpen.set(false);
  }

  saveExam(): void {
    const validation = this.validate();
    if (validation) {
      this.formError.set(validation);
      return;
    }
    this.saving.set(true);
    const operation = this.editingExamId
      ? this.service.updateMedicalExam(this.employeeId, this.editingExamId, this.payload())
      : this.service.createMedicalExam(this.employeeId, this.payload());
    operation.pipe(finalize(() => this.saving.set(false))).subscribe({
      next: () => {
        this.success.set(this.editingExamId ? 'Examen médico actualizado correctamente.' : 'Examen médico registrado correctamente.');
        this.editingExamId = null;
        this.createOpen.set(false);
        this.load();
      },
      error: (error) => this.formError.set(apiErrorMessage(error, 'No fue posible guardar el examen médico.')),
    });
  }

  requestDelete(exam: EmployeeMedicalExam): void { this.examPendingDeletion.set(exam); }

  cancelDelete(): void {
    if (this.deletingExamId() === null) this.examPendingDeletion.set(null);
  }

  deleteMessage(exam: EmployeeMedicalExam): string {
    return `¿Deseas eliminar el examen del ${exam.fecha_examen}?\n\nEl registro se ocultará, pero su soporte se conservará para mantener la trazabilidad.`;
  }

  deleteExam(): void {
    const id = this.examId(this.examPendingDeletion());
    if (!id || this.deletingExamId() !== null) return;
    this.deletingExamId.set(id);
    this.service.deleteMedicalExam(this.employeeId, id).pipe(finalize(() => this.deletingExamId.set(null))).subscribe({
      next: () => {
        this.examPendingDeletion.set(null);
        this.success.set('Examen médico eliminado correctamente.');
        this.load();
      },
      error: (error) => {
        this.examPendingDeletion.set(null);
        this.error.set(apiErrorMessage(error, 'No fue posible eliminar el examen médico.'));
      },
    });
  }

  examStatus(exam: EmployeeMedicalExam): string {
    if (this.truthy(exam.vencido)) return 'Vencido';
    if (this.truthy(exam.proximo_vencer)) return 'Proximo a vencer';
    return 'Vigente';
  }

  displayExamType(exam: EmployeeMedicalExam): string {
    if (exam.tipo_examen_medico) return exam.tipo_examen_medico;
    const examType = this.medicalExamTypes().find((item) => item.id_tipo_examen_medico === Number(exam.id_tipo_examen_medico));
    return examType?.nombre ?? (exam.id_tipo_examen_medico ? `ID ${exam.id_tipo_examen_medico}` : 'Sin dato');
  }

  changeFileOrigin(): void {
    this.selectedFile = null;
    this.form.archivo_url = null;
    this.formError.set('');
  }

  selectFile(event: Event): void {
    const input = event.target as HTMLInputElement;
    this.selectedFile = input.files?.[0] ?? null;
    this.formError.set('');
  }

  backendFileUrl(path: string): string {
    if (/^https?:\/\//i.test(path)) return path;
    const baseUrl = environment.backendUrl.replace(/\/$/, '');
    return `${baseUrl}${path.startsWith('/') ? path : `/${path}`}`;
  }

  private validate(): string {
    if (!this.form.id_tipo_examen_medico) return 'El tipo de examen medico es obligatorio.';
    if (!this.form.fecha_examen) return 'La fecha de examen es obligatoria.';
    if (this.form.fecha_vencimiento && this.form.fecha_examen && this.form.fecha_vencimiento < this.form.fecha_examen) return 'La fecha de vencimiento no puede ser menor que la fecha de examen.';
    if (this.fileOrigin === 'ARCHIVO') {
      if (!this.selectedFile && !this.editingExamId) return 'Selecciona el archivo del examen médico.';
      if (this.selectedFile && !/\.(pdf|jpe?g|png|webp|docx?)$/i.test(this.selectedFile.name)) return 'El archivo debe ser PDF, imagen o documento Word.';
      if (this.selectedFile && this.selectedFile.size > 5 * 1024 * 1024) return 'El archivo no debe superar 5 MB.';
    }
    if (this.fileOrigin === 'URL' && !this.form.archivo_url?.trim()) return 'Ingresa la URL externa del examen médico.';
    return '';
  }

  private payload(): CreateMedicalExamRequest | FormData {
    const normalized = { ...this.form, id_tipo_examen_medico: Number(this.form.id_tipo_examen_medico) };
    if (this.fileOrigin !== 'ARCHIVO') {
      if (this.fileOrigin === 'NINGUNO') normalized.archivo_url = null;
      return normalized;
    }

    const formData = new FormData();
    Object.entries(normalized).forEach(([key, value]) => {
      if (value !== null && value !== undefined && value !== '') formData.append(key, String(value));
    });
    if (this.selectedFile) formData.append('archivo', this.selectedFile, this.selectedFile.name);
    return formData;
  }

  private emptyForm(): CreateMedicalExamRequest {
    return { id_tipo_examen_medico: null, fecha_examen: new Date().toISOString().slice(0, 10) };
  }

  private examId(exam: EmployeeMedicalExam | null): number | null {
    const value = Number(exam?.id_examen_medico);
    return Number.isInteger(value) && value > 0 ? value : null;
  }

  private truthy(value: unknown): boolean {
    return value === true || value === 1 || value === '1';
  }
}
