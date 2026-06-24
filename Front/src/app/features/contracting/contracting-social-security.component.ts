import { Component, OnInit, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { finalize } from 'rxjs';
import { EmployeeSocialSecurity, SaveSocialSecurityRequest } from '../../core/models/api.models';
import { AuthService } from '../../core/services/auth.service';
import { ContractingService } from '../../core/services/contracting.service';
import { apiErrorMessage } from '../../shared/api-error';

@Component({
  standalone: true,
  imports: [FormsModule, RouterLink],
  template: `
    <div class="page-heading">
      <div><p class="eyebrow">Contratacion</p><h1>Seguridad social</h1><p class="muted">Afiliaciones del empleado.</p></div>
      <a class="btn ghost" routerLink="/admin/contracting">Volver</a>
    </div>

    <section class="panel">
      <div class="row-actions" style="margin-bottom:1rem">
        <a class="btn small ghost" [routerLink]="['/admin/contracting/employees', employeeId, 'profile']">Ficha</a>
        <a class="btn small ghost" [routerLink]="['/admin/contracting/employees', employeeId, 'contracts']">Contratos</a>
        <a class="btn small secondary" [routerLink]="['/admin/contracting/employees', employeeId, 'social-security']">Seguridad social</a>
        <a class="btn small ghost" [routerLink]="['/admin/contracting/employees', employeeId, 'medical-exams']">Examenes</a>
        <a class="btn small ghost" [routerLink]="['/admin/contracting/employees', employeeId, 'documents']">Documentos</a>
      </div>

      @if (success()) { <div class="alert success">{{ success() }}</div> }
      @if (error()) { <div class="alert error">{{ error() }} <button class="btn small ghost" type="button" (click)="load()" [disabled]="loading()">Reintentar</button></div> }
      @if (formError()) { <div class="alert error">{{ formError() }}</div> }

      <p class="muted">Actualiza las afiliaciones de seguridad social registradas para el empleado.</p>

      <form class="form-grid" (ngSubmit)="save()">
        <label>ID EPS<input type="number" min="1" name="id_eps" [(ngModel)]="form.id_eps" [disabled]="!canEdit() || saving()" /><small class="muted">{{ data()?.eps || '' }}</small></label>
        <label>ID ARL<input type="number" min="1" name="id_arl" [(ngModel)]="form.id_arl" [disabled]="!canEdit() || saving()" /><small class="muted">{{ data()?.arl || '' }}</small></label>
        <label>ID fondo pension<input type="number" min="1" name="id_fondo_pension" [(ngModel)]="form.id_fondo_pension" [disabled]="!canEdit() || saving()" /><small class="muted">{{ data()?.fondo_pension || '' }}</small></label>
        <label>ID fondo cesantias<input type="number" min="1" name="id_fondo_cesantias" [(ngModel)]="form.id_fondo_cesantias" [disabled]="!canEdit() || saving()" /><small class="muted">{{ data()?.fondo_cesantias || '' }}</small></label>
        <label>ID caja compensacion<input type="number" min="1" name="id_caja_compensacion" [(ngModel)]="form.id_caja_compensacion" [disabled]="!canEdit() || saving()" /><small class="muted">{{ data()?.caja_compensacion || '' }}</small></label>
        <label>Fecha afiliacion EPS<input type="date" name="fecha_afiliacion_eps" [(ngModel)]="form.fecha_afiliacion_eps" [disabled]="!canEdit() || saving()" /></label>
        <label>Fecha afiliacion ARL<input type="date" name="fecha_afiliacion_arl" [(ngModel)]="form.fecha_afiliacion_arl" [disabled]="!canEdit() || saving()" /></label>
        <label>Fecha afiliacion pension<input type="date" name="fecha_afiliacion_pension" [(ngModel)]="form.fecha_afiliacion_pension" [disabled]="!canEdit() || saving()" /></label>
        <label>Fecha afiliacion cesantias<input type="date" name="fecha_afiliacion_cesantias" [(ngModel)]="form.fecha_afiliacion_cesantias" [disabled]="!canEdit() || saving()" /></label>
        <label>Fecha afiliacion caja<input type="date" name="fecha_afiliacion_caja" [(ngModel)]="form.fecha_afiliacion_caja" [disabled]="!canEdit() || saving()" /></label>
        <label class="form-wide">Observaciones<textarea rows="3" name="observaciones" [(ngModel)]="form.observaciones" [disabled]="!canEdit() || saving()"></textarea></label>
        @if (canEdit()) {
          <div class="form-actions form-wide"><button class="btn primary" type="submit" [disabled]="saving()">{{ saving() ? 'Guardando...' : 'Guardar seguridad social' }}</button></div>
        }
      </form>
    </section>
  `,
})
export class ContractingSocialSecurityComponent implements OnInit {
  readonly auth = inject(AuthService);
  private readonly route = inject(ActivatedRoute);
  private readonly service = inject(ContractingService);
  readonly data = signal<EmployeeSocialSecurity | null>(null);
  readonly loading = signal(false);
  readonly saving = signal(false);
  readonly error = signal('');
  readonly formError = signal('');
  readonly success = signal('');
  employeeId = 0;
  form: SaveSocialSecurityRequest = {};

  ngOnInit(): void {
    this.employeeId = Number(this.route.snapshot.paramMap.get('employeeId'));
    this.load();
  }

  load(): void {
    this.loading.set(true);
    this.error.set('');
    this.service.getSocialSecurity(this.employeeId).pipe(finalize(() => this.loading.set(false))).subscribe({
      next: (data) => {
        this.data.set(data);
        this.form = { ...(data ?? {}) };
      },
      error: (error) => this.error.set(apiErrorMessage(error, 'No fue posible cargar la informacion de contratacion.')),
    });
  }

  save(): void {
    this.formError.set('');
    this.success.set('');
    this.saving.set(true);
    this.service.saveSocialSecurity(this.employeeId, this.normalize()).pipe(finalize(() => this.saving.set(false))).subscribe({
      next: () => {
        this.success.set('Seguridad social guardada correctamente.');
        this.load();
      },
      error: (error) => this.formError.set(apiErrorMessage(error, 'No fue posible guardar la seguridad social.')),
    });
  }

  canEdit(): boolean {
    return this.auth.hasPermission('CONTRATACION_SEGURIDAD_SOCIAL_EDITAR');
  }

  private normalize(): SaveSocialSecurityRequest {
    return {
      ...this.form,
      id_eps: this.numberOrNull(this.form.id_eps),
      id_arl: this.numberOrNull(this.form.id_arl),
      id_fondo_pension: this.numberOrNull(this.form.id_fondo_pension),
      id_fondo_cesantias: this.numberOrNull(this.form.id_fondo_cesantias),
      id_caja_compensacion: this.numberOrNull(this.form.id_caja_compensacion),
    };
  }

  private numberOrNull(value: unknown): number | null {
    const numberValue = Number(value);
    return Number.isFinite(numberValue) && value !== '' && value !== null ? numberValue : null;
  }
}
