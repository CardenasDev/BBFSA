import { Component, OnInit, inject, signal } from '@angular/core';
import { NgClass } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, Router, RouterLink } from '@angular/router';
import { finalize } from 'rxjs';
import { ApplicantDetail, ApplicantStatus } from '../../core/models/api.models';
import { ApplicantService } from '../../core/services/applicant.service';
import { AuthService } from '../../core/services/auth.service';
import { apiErrorMessage } from '../../shared/api-error';
import {
  MANUAL_APPLICANT_STATUSES,
  applicantName,
  applicantStatusClass,
  blankToNull,
  canApproveApplicant,
  canConvertApplicant,
} from './applicant-utils';

@Component({
  standalone: true,
  imports: [FormsModule, NgClass, RouterLink],
  template: `
    <div class="page-heading">
      <div><p class="eyebrow">Aspirantes</p><h1>Detalle del aspirante</h1><p class="muted">Consulta y acciones del proceso inicial.</p></div>
      <div class="row-actions">
        <a class="btn ghost" routerLink="/admin/applicants">Volver</a>
        @if (applicant(); as current) {
          @if (auth.hasPermission('ASPIRANTES_EDITAR')) { <a class="btn secondary" [routerLink]="['/admin/applicants', current.id_aspirante, 'edit']">Editar</a> }
        }
      </div>
    </div>

    @if (success()) { <div class="alert success">{{ success() }}</div> }
    @if (error()) { <div class="alert error">{{ error() }} <button class="btn small ghost" type="button" (click)="load()" [disabled]="loading()">Reintentar</button></div> }

    @if (applicant(); as current) {
      <section class="panel profile-summary">
        <div class="avatar large">{{ initials(current) }}</div>
        <div>
          <h2>{{ name(current) }}</h2>
          <p class="muted">Documento {{ current.numero_documento }} - {{ current.area_aspira || 'Sin area' }} - {{ current.cargo_aspira || 'Sin cargo' }}</p>
        </div>
        <span class="badge" [ngClass]="statusClass(current.estado_aspirante)">{{ current.estado_aspirante }}</span>
      </section>

      <section class="panel">
        <div class="row-actions" style="margin-bottom:1rem">
          @if (auth.hasPermission('ASPIRANTES_DOCUMENTOS_VER')) { <a class="btn small ghost" [routerLink]="['/admin/applicants', current.id_aspirante, 'documents']">Documentos</a> }
          @if (auth.hasPermission('ASPIRANTES_VER')) { <a class="btn small ghost" [routerLink]="['/admin/applicants', current.id_aspirante, 'history']">Historial</a> }
          @if (auth.hasPermission('ASPIRANTES_CAMBIAR_ESTADO')) { <button class="btn small tertiary" type="button" (click)="openStatus()">Cambiar estado</button> }
          @if (auth.hasPermission('ASPIRANTES_APROBAR_CONTRATACION') && canApprove(current)) { <button class="btn small secondary" type="button" (click)="openApprove()">Aprobar contratacion</button> }
          @if (auth.hasPermission('ASPIRANTES_CONVERTIR_EMPLEADO') && canConvert(current)) { <button class="btn small primary" type="button" (click)="convert(current)" [disabled]="converting()">{{ converting() ? 'Convirtiendo...' : 'Convertir a empleado' }}</button> }
          @if (current.id_empleado_generado) { <a class="btn small ghost" [routerLink]="['/admin/contracting/employees', current.id_empleado_generado, 'profile']">Ir a contratacion</a> }
        </div>

        <div class="detail-grid">
          <section class="drawer-section">
            <h3>Datos basicos</h3>
            <dl>
              <dt>Tipo documento</dt><dd>{{ current.tipo_documento || displayId(current.id_tipo_documento) }}</dd>
              <dt>Documento</dt><dd>{{ current.numero_documento }}</dd>
              <dt>Nombres</dt><dd>{{ current.nombres }}</dd>
              <dt>Apellidos</dt><dd>{{ current.apellidos }}</dd>
              <dt>Correo</dt><dd>{{ current.correo || 'Sin correo' }}</dd>
              <dt>Telefono</dt><dd>{{ current.telefono || 'Sin telefono' }}</dd>
            </dl>
          </section>
          <section class="drawer-section">
            <h3>Datos personales</h3>
            <dl>
              <dt>Fecha nacimiento</dt><dd>{{ current.fecha_nacimiento || 'Sin fecha' }}</dd>
              <dt>Lugar nacimiento</dt><dd>{{ current.lugar_nacimiento || 'Sin dato' }}</dd>
              <dt>Departamento nacimiento</dt><dd>{{ current.departamento_nacimiento || 'Sin dato' }}</dd>
              <dt>Nacionalidad</dt><dd>{{ current.nacionalidad || 'Sin dato' }}</dd>
              <dt>Estado civil</dt><dd>{{ current.estado_civil || 'Sin dato' }}</dd>
              <dt>Nivel educativo</dt><dd>{{ current.nivel_educativo || 'Sin dato' }}</dd>
              <dt>Personas a cargo</dt><dd>{{ current.personas_a_cargo ?? 'Sin dato' }}</dd>
              <dt>Numero hijos</dt><dd>{{ current.numero_hijos ?? 'Sin dato' }}</dd>
            </dl>
          </section>
          <section class="drawer-section">
            <h3>Residencia</h3>
            <dl>
              <dt>Direccion</dt><dd>{{ current.direccion || 'Sin direccion' }}</dd>
              <dt>Ciudad residencia</dt><dd>{{ current.ciudad_residencia || 'Sin dato' }}</dd>
              <dt>Departamento residencia</dt><dd>{{ current.departamento_residencia || 'Sin dato' }}</dd>
            </dl>
          </section>
          <section class="drawer-section">
            <h3>Perfil aspirado</h3>
            <dl>
              <dt>Area aspirada</dt><dd>{{ current.area_aspira || displayId(current.id_area_aspira) }}</dd>
              <dt>Cargo aspirado</dt><dd>{{ current.cargo_aspira || displayId(current.id_cargo_aspira) }}</dd>
              <dt>ID empleado generado</dt><dd>{{ current.id_empleado_generado || 'No convertido' }}</dd>
            </dl>
          </section>
        </div>
        <section class="drawer-section">
          <h3>Observaciones</h3>
          <p class="muted">{{ current.observaciones || 'Sin observaciones.' }}</p>
        </section>
      </section>
    } @else {
      <section class="panel empty tall">{{ loading() ? 'Cargando aspirante...' : 'No hay informacion para mostrar.' }}</section>
    }

    @if (statusOpen() && applicant(); as current) {
      <button class="drawer-backdrop" type="button" aria-label="Cerrar cambio de estado" (click)="closeStatus()"></button>
      <aside class="role-drawer" aria-label="Cambiar estado" aria-modal="true">
        <header class="drawer-header"><div><p class="eyebrow">Estado</p><h2>Cambiar estado</h2></div><button class="icon-btn close-btn" type="button" (click)="closeStatus()">x</button></header>
        @if (statusError()) { <div class="alert error">{{ statusError() }}</div> }
        <form class="narrow-form" (ngSubmit)="saveStatus()">
          <label>Nuevo estado
            <select name="estado_aspirante" [(ngModel)]="statusForm.estado_aspirante">
              @for (item of manualStatuses; track item) { <option [value]="item">{{ item }}</option> }
            </select>
          </label>
          <label>Observaciones<textarea rows="4" name="observaciones" [(ngModel)]="statusForm.observaciones"></textarea></label>
          <div class="form-actions">
            <button class="btn secondary" type="button" (click)="closeStatus()" [disabled]="savingStatus()">Cancelar</button>
            <button class="btn primary" type="submit" [disabled]="savingStatus()">{{ savingStatus() ? 'Guardando...' : 'Actualizar estado' }}</button>
          </div>
        </form>
      </aside>
    }

    @if (approveOpen() && applicant(); as current) {
      <button class="drawer-backdrop" type="button" aria-label="Cerrar aprobacion" (click)="closeApprove()"></button>
      <aside class="role-drawer" aria-label="Aprobar aspirante" aria-modal="true">
        <header class="drawer-header"><div><p class="eyebrow">Aprobacion</p><h2>Aprobar para contratacion</h2></div><button class="icon-btn close-btn" type="button" (click)="closeApprove()">x</button></header>
        <p><strong>Deseas aprobar este aspirante para iniciar el proceso de contratacion?</strong></p>
        <p class="muted">{{ name(current) }} - {{ current.numero_documento }}</p>
        @if (approveError()) { <div class="alert error">{{ approveError() }}</div> }
        <form class="narrow-form" (ngSubmit)="approve()">
          <label>Observaciones<textarea rows="4" name="approve_observaciones" [(ngModel)]="approveObservations"></textarea></label>
          <div class="form-actions">
            <button class="btn secondary" type="button" (click)="closeApprove()" [disabled]="approving()">Cancelar</button>
            <button class="btn primary" type="submit" [disabled]="approving()">{{ approving() ? 'Aprobando...' : 'Aprobar' }}</button>
          </div>
        </form>
      </aside>
    }
  `,
})
export class ApplicantDetailComponent implements OnInit {
  readonly auth = inject(AuthService);
  private readonly route = inject(ActivatedRoute);
  private readonly router = inject(Router);
  private readonly service = inject(ApplicantService);
  readonly applicant = signal<ApplicantDetail | null>(null);
  readonly loading = signal(false);
  readonly error = signal('');
  readonly success = signal('');
  readonly statusOpen = signal(false);
  readonly approveOpen = signal(false);
  readonly savingStatus = signal(false);
  readonly approving = signal(false);
  readonly converting = signal(false);
  readonly statusError = signal('');
  readonly approveError = signal('');
  readonly manualStatuses = MANUAL_APPLICANT_STATUSES;
  applicantId = 0;
  approveObservations = 'Aprobado por RRHH para iniciar contratacion';
  statusForm: { estado_aspirante: ApplicantStatus; observaciones: string | null } = { estado_aspirante: 'EN_REVISION', observaciones: null };

  ngOnInit(): void {
    this.applicantId = Number(this.route.snapshot.paramMap.get('applicantId'));
    this.load();
  }

  load(): void {
    this.loading.set(true);
    this.error.set('');
    this.service.getApplicant(this.applicantId).pipe(finalize(() => this.loading.set(false))).subscribe({
      next: (applicant) => this.applicant.set(applicant),
      error: (error) => this.error.set(apiErrorMessage(error, 'No fue posible cargar el aspirante.')),
    });
  }

  openStatus(): void {
    const current = this.applicant();
    if (!current) return;
    this.statusError.set('');
    this.statusForm = { estado_aspirante: current.estado_aspirante === 'CONVERTIDO_EMPLEADO' ? 'EN_REVISION' : current.estado_aspirante, observaciones: null };
    this.statusOpen.set(true);
  }

  closeStatus(): void {
    if (this.savingStatus()) return;
    this.statusOpen.set(false);
  }

  saveStatus(): void {
    this.savingStatus.set(true);
    this.statusError.set('');
    this.success.set('');
    this.service.changeStatus(this.applicantId, {
      estado_aspirante: this.statusForm.estado_aspirante,
      observaciones: blankToNull(this.statusForm.observaciones),
    }).pipe(finalize(() => this.savingStatus.set(false))).subscribe({
      next: () => {
        this.success.set('Estado del aspirante actualizado correctamente.');
        this.closeStatus();
        this.load();
      },
      error: (error) => this.statusError.set(apiErrorMessage(error, 'No fue posible cambiar el estado.')),
    });
  }

  openApprove(): void {
    this.approveError.set('');
    this.approveObservations = 'Aprobado por RRHH para iniciar contratacion';
    this.approveOpen.set(true);
  }

  closeApprove(): void {
    if (this.approving()) return;
    this.approveOpen.set(false);
  }

  approve(): void {
    this.approving.set(true);
    this.approveError.set('');
    this.success.set('');
    this.service.approveForContracting(this.applicantId, blankToNull(this.approveObservations) ?? undefined)
      .pipe(finalize(() => this.approving.set(false))).subscribe({
        next: () => {
          this.success.set('Aspirante aprobado para contratacion correctamente.');
          this.closeApprove();
          this.load();
        },
        error: (error) => this.approveError.set(apiErrorMessage(error, 'No fue posible aprobar para contratacion.')),
      });
  }

  convert(current: ApplicantDetail): void {
    if (!confirm(`Se creara el empleado para ${this.name(current)}. El contrato y la fecha de ingreso se asignaran posteriormente. ¿Deseas continuar?`)) return;

    this.converting.set(true);
    this.error.set('');
    this.success.set('');
    this.service.convertToEmployee(this.applicantId, {
      observaciones: 'Empleado generado desde aspirante; pendiente de asignacion contractual.',
    }).pipe(finalize(() => this.converting.set(false))).subscribe({
      next: (result) => {
        void this.router.navigate(['/admin/contracting/employees', result.id_empleado, 'profile'], {
          state: { successMessage: 'Aspirante convertido en empleado. Ahora puedes asignar su contrato y fecha de ingreso.' },
        });
      },
      error: (error) => this.error.set(apiErrorMessage(error, 'No fue posible convertir el aspirante en empleado.')),
    });
  }

  name(applicant: ApplicantDetail): string {
    return applicantName(applicant);
  }

  initials(applicant: ApplicantDetail): string {
    return this.name(applicant).split(/\s+/).slice(0, 2).map((part) => part[0]).join('').toUpperCase();
  }

  statusClass(status: ApplicantStatus): string {
    return applicantStatusClass(status);
  }

  canApprove(applicant: ApplicantDetail): boolean {
    return canApproveApplicant(applicant);
  }

  canConvert(applicant: ApplicantDetail): boolean {
    return canConvertApplicant(applicant);
  }

  displayId(value?: number | null): string {
    return value ? `ID ${value}` : 'Sin dato';
  }
}
