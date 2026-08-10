import { Component, OnInit, inject, signal } from '@angular/core';
import { NgClass } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, Router, RouterLink } from '@angular/router';
import { finalize } from 'rxjs';
import { ApplicantDetail, ConvertApplicantToEmployeeRequest, ConvertApplicantToEmployeeResponse } from '../../core/models/api.models';
import { ApplicantService } from '../../core/services/applicant.service';
import { apiErrorMessage } from '../../shared/api-error';
import { applicantName, applicantStatusClass, blankToNull } from './applicant-utils';

@Component({
  standalone: true,
  imports: [FormsModule, NgClass, RouterLink],
  template: `
    <div class="page-heading">
      <div><p class="eyebrow">Aspirantes</p><h1>Convertir a empleado</h1><p class="muted">Crea el empleado. El contrato se asigna posteriormente desde su ficha de contratacion.</p></div>
      <a class="btn ghost" [routerLink]="['/admin/applicants', applicantId]">Volver</a>
    </div>

    @if (error()) { <div class="alert error">{{ error() }} <button class="btn small ghost" type="button" (click)="load()" [disabled]="loading()">Reintentar</button></div> }
    @if (success()) { <div class="alert success">{{ success() }}</div> }

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
        @if (current.id_empleado_generado) {
          <div class="alert success">Este aspirante ya fue convertido. Empleado generado: {{ current.id_empleado_generado }}.</div>
          <a class="btn primary" [routerLink]="['/admin/contracting/employees', current.id_empleado_generado, 'profile']">Ir a ficha de contratacion</a>
        } @else if (current.estado_aspirante !== 'APROBADO_CONTRATACION') {
          <div class="alert error">El aspirante debe estar aprobado para contratacion antes de convertirse en empleado.</div>
        } @else {
          <form class="form-grid" (ngSubmit)="convert()">
            <label>Fecha ingreso<input type="date" name="fecha_ingreso" [(ngModel)]="form.fecha_ingreso" /></label>
            <div class="alert success">El tipo de contrato se seleccionara despues de crear el empleado, desde el modulo de contratacion.</div>
            <label class="form-wide">Observaciones<textarea rows="4" name="observaciones" [(ngModel)]="form.observaciones"></textarea></label>
            @if (formError()) { <div class="alert error form-wide">{{ formError() }}</div> }
            <div class="form-actions form-wide">
              <a class="btn secondary" [routerLink]="['/admin/applicants', applicantId]">Cancelar</a>
              <button class="btn primary" type="submit" [disabled]="saving()">{{ saving() ? 'Convirtiendo...' : 'Convertir a empleado' }}</button>
            </div>
          </form>
        }

        @if (converted(); as result) {
          <div class="drawer-section" style="margin-top:1rem">
            <h3>Empleado generado</h3>
            <p class="muted">ID empleado: <strong>{{ result.id_empleado }}</strong></p>
            @if (result.estado_ficha) { <p class="muted">Ficha de ingreso: <strong>{{ result.estado_ficha }}</strong></p> }
            <a class="btn primary" [routerLink]="['/admin/contracting/employees', result.id_empleado, 'profile']">Continuar a ficha de contratacion</a>
          </div>
        }
      </section>
    } @else {
      <section class="panel empty tall">{{ loading() ? 'Cargando aspirante...' : 'No hay informacion para convertir.' }}</section>
    }
  `,
})
export class ApplicantConvertComponent implements OnInit {
  private readonly route = inject(ActivatedRoute);
  private readonly router = inject(Router);
  private readonly service = inject(ApplicantService);
  readonly applicant = signal<ApplicantDetail | null>(null);
  readonly converted = signal<ConvertApplicantToEmployeeResponse | null>(null);
  readonly loading = signal(false);
  readonly saving = signal(false);
  readonly error = signal('');
  readonly formError = signal('');
  readonly success = signal('');
  applicantId = 0;
  form: ConvertApplicantToEmployeeRequest = {
    fecha_ingreso: new Date().toISOString().slice(0, 10),
    observaciones: 'Conversion a empleado',
  };

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

  convert(): void {
    const current = this.applicant();
    if (!current || current.estado_aspirante !== 'APROBADO_CONTRATACION' || current.id_empleado_generado) {
      this.formError.set('El aspirante debe estar aprobado para contratacion antes de convertirse en empleado.');
      return;
    }
    this.saving.set(true);
    this.formError.set('');
    this.success.set('');
    this.service.convertToEmployee(this.applicantId, this.payload()).pipe(finalize(() => this.saving.set(false))).subscribe({
      next: (result) => {
        this.converted.set(result);
        const message = this.conversionMessage(result);
        this.success.set(message);
        void this.router.navigate(['/admin/contracting/employees', result.id_empleado, 'profile'], {
          state: { successMessage: message },
        });
      },
      error: (error) => this.formError.set(apiErrorMessage(error, 'No fue posible convertir el aspirante en empleado.')),
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

  private payload(): ConvertApplicantToEmployeeRequest {
    return {
      fecha_ingreso: blankToNull(this.form.fecha_ingreso),
      observaciones: blankToNull(this.form.observaciones),
    };
  }

  private conversionMessage(result: ConvertApplicantToEmployeeResponse): string {
    if (!result.estado_ficha) return 'Aspirante convertido en empleado correctamente.';

    return `Aspirante convertido en empleado correctamente. La ficha de ingreso fue creada en estado ${result.estado_ficha}.`;
  }
}
