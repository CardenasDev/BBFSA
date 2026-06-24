import { Component, OnInit, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { finalize } from 'rxjs';
import { CreateMedicalExamRequest, EmployeeMedicalExam } from '../../core/models/api.models';
import { AuthService } from '../../core/services/auth.service';
import { ContractingService } from '../../core/services/contracting.service';
import { apiErrorMessage } from '../../shared/api-error';

@Component({
  standalone: true,
  imports: [FormsModule, RouterLink],
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

      @if (success()) { <div class="alert success">{{ success() }}</div> }
      @if (error()) { <div class="alert error">{{ error() }} <button class="btn small ghost" type="button" (click)="load()" [disabled]="loading()">Reintentar</button></div> }

      <div class="table-wrap">
        <table>
          <thead><tr><th>Tipo</th><th>Fecha examen</th><th>Entidad</th><th>Resultado</th><th>Vencimiento</th><th>Estado</th><th>Archivo</th><th>Observaciones</th></tr></thead>
          <tbody>
            @for (exam of exams(); track exam.id_examen_medico || exam.fecha_examen) {
              <tr>
                <td>{{ exam.tipo_examen_medico || displayId(exam.id_tipo_examen_medico) }}</td>
                <td>{{ exam.fecha_examen }}</td>
                <td>{{ exam.entidad_realiza || 'Sin dato' }}</td>
                <td>{{ exam.resultado_general || 'Sin resultado' }}</td>
                <td>{{ exam.fecha_vencimiento || 'Sin fecha' }}</td>
                <td><span class="badge" [class.success]="examStatus(exam) === 'Vigente'" [class.danger]="examStatus(exam) === 'Vencido'">{{ examStatus(exam) }}</span></td>
                <td>@if (exam.archivo_url) { <a [href]="exam.archivo_url" target="_blank" rel="noopener">Abrir</a> } @else { Sin archivo }</td>
                <td>{{ exam.observaciones || 'Sin observaciones' }}</td>
              </tr>
            } @empty {
              <tr><td colspan="8" class="empty">{{ loading() ? 'Cargando examenes...' : 'No hay registros para mostrar.' }}</td></tr>
            }
          </tbody>
        </table>
      </div>
    </section>

    @if (createOpen()) {
      <button class="drawer-backdrop" type="button" aria-label="Cerrar examen" (click)="closeCreate()"></button>
      <aside class="role-drawer" aria-label="Registrar examen" aria-modal="true">
        <header class="drawer-header">
          <div><p class="eyebrow">Examen medico</p><h2>Registrar examen</h2></div>
          <button class="icon-btn close-btn" type="button" (click)="closeCreate()" aria-label="Cerrar">x</button>
        </header>
        <p class="muted">Registra la informacion del examen medico y su fecha de vencimiento.</p>
        @if (formError()) { <div class="alert error">{{ formError() }}</div> }
        <form class="form-grid" (ngSubmit)="createExam()">
          <label>ID tipo examen<input type="number" min="1" name="id_tipo_examen_medico" [(ngModel)]="form.id_tipo_examen_medico" required /></label>
          <label>Fecha examen<input type="date" name="fecha_examen" [(ngModel)]="form.fecha_examen" required /></label>
          <label>Entidad realiza<input name="entidad_realiza" [(ngModel)]="form.entidad_realiza" maxlength="200" /></label>
          <label>Resultado general<input name="resultado_general" [(ngModel)]="form.resultado_general" maxlength="250" /></label>
          <label>Fecha vencimiento<input type="date" name="fecha_vencimiento" [(ngModel)]="form.fecha_vencimiento" /></label>
          <label class="form-wide">Archivo URL<input name="archivo_url" [(ngModel)]="form.archivo_url" maxlength="500" /></label>
          <label class="form-wide">Observaciones<textarea rows="3" name="observaciones" [(ngModel)]="form.observaciones"></textarea></label>
          <div class="form-actions form-wide">
            <button class="btn secondary" type="button" (click)="closeCreate()" [disabled]="saving()">Cancelar</button>
            <button class="btn primary" type="submit" [disabled]="saving()">{{ saving() ? 'Guardando...' : 'Registrar examen' }}</button>
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
  readonly exams = signal<EmployeeMedicalExam[]>([]);
  readonly loading = signal(false);
  readonly saving = signal(false);
  readonly createOpen = signal(false);
  readonly error = signal('');
  readonly formError = signal('');
  readonly success = signal('');
  employeeId = 0;
  form: CreateMedicalExamRequest = this.emptyForm();

  ngOnInit(): void {
    this.employeeId = Number(this.route.snapshot.paramMap.get('employeeId'));
    this.load();
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
    this.form = this.emptyForm();
    this.formError.set('');
    this.success.set('');
    this.createOpen.set(true);
  }

  closeCreate(): void {
    if (this.saving()) return;
    this.createOpen.set(false);
  }

  createExam(): void {
    const validation = this.validate();
    if (validation) {
      this.formError.set(validation);
      return;
    }
    this.saving.set(true);
    this.service.createMedicalExam(this.employeeId, this.normalize()).pipe(finalize(() => this.saving.set(false))).subscribe({
      next: () => {
        this.success.set('Examen medico registrado correctamente.');
        this.createOpen.set(false);
        this.load();
      },
      error: (error) => this.formError.set(apiErrorMessage(error, 'No fue posible registrar el examen medico.')),
    });
  }

  examStatus(exam: EmployeeMedicalExam): string {
    if (this.truthy(exam.vencido)) return 'Vencido';
    if (this.truthy(exam.proximo_vencer)) return 'Proximo a vencer';
    return 'Vigente';
  }

  displayId(value?: number | null): string {
    return value ? `ID ${value}` : 'Sin dato';
  }

  private validate(): string {
    if (!this.form.id_tipo_examen_medico) return 'El tipo de examen medico es obligatorio.';
    if (!this.form.fecha_examen) return 'La fecha de examen es obligatoria.';
    if (this.form.fecha_vencimiento && this.form.fecha_examen && this.form.fecha_vencimiento < this.form.fecha_examen) return 'La fecha de vencimiento no puede ser menor que la fecha de examen.';
    return '';
  }

  private normalize(): CreateMedicalExamRequest {
    return { ...this.form, id_tipo_examen_medico: Number(this.form.id_tipo_examen_medico) };
  }

  private emptyForm(): CreateMedicalExamRequest {
    return { id_tipo_examen_medico: null, fecha_examen: new Date().toISOString().slice(0, 10) };
  }

  private truthy(value: unknown): boolean {
    return value === true || value === 1 || value === '1';
  }
}
