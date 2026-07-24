import { Component, OnInit, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { Observable, catchError, finalize, forkJoin, of } from 'rxjs';
import { EmployeeSocialSecurity, SaveSocialSecurityRequest, SocialSecurityEntity, SocialSecurityType } from '../../core/models/api.models';
import { AuthService } from '../../core/services/auth.service';
import { CatalogService } from '../../core/services/catalog.service';
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
      @if (catalogsError()) { <div class="alert error">{{ catalogsError() }} <button class="btn small ghost" type="button" (click)="loadCatalogs()" [disabled]="isLoadingCatalogs()">Reintentar</button></div> }
      @if (formError()) { <div class="alert error">{{ formError() }}</div> }

      <p class="muted">Actualiza las afiliaciones de seguridad social registradas para el empleado.</p>

      <form class="form-grid" (ngSubmit)="save()">
        <label>EPS<select name="id_eps" [(ngModel)]="form.id_eps" [disabled]="!canEdit() || saving() || isLoadingCatalogs()"><option [ngValue]="null">Seleccione EPS</option>@for (entity of epsEntities(); track entity.id_entidad_seguridad_social) { <option [ngValue]="entity.id_entidad_seguridad_social">{{ entity.nombre }}</option> }</select></label>
        <label>ARL<select name="id_arl" [(ngModel)]="form.id_arl" [disabled]="!canEdit() || saving() || isLoadingCatalogs()"><option [ngValue]="null">Seleccione ARL</option>@for (entity of arlEntities(); track entity.id_entidad_seguridad_social) { <option [ngValue]="entity.id_entidad_seguridad_social">{{ entity.nombre }}</option> }</select></label>
        <label>Fondo de pensión<select name="id_fondo_pension" [(ngModel)]="form.id_fondo_pension" [disabled]="!canEdit() || saving() || isLoadingCatalogs()"><option [ngValue]="null">Seleccione fondo de pensión</option>@for (entity of pensionEntities(); track entity.id_entidad_seguridad_social) { <option [ngValue]="entity.id_entidad_seguridad_social">{{ entity.nombre }}</option> }</select></label>
        <label>Fondo de cesantías<select name="id_fondo_cesantias" [(ngModel)]="form.id_fondo_cesantias" [disabled]="!canEdit() || saving() || isLoadingCatalogs()"><option [ngValue]="null">Seleccione fondo de cesantías</option>@for (entity of cesantiasEntities(); track entity.id_entidad_seguridad_social) { <option [ngValue]="entity.id_entidad_seguridad_social">{{ entity.nombre }}</option> }</select></label>
        <label>Caja de compensación<select name="id_caja_compensacion" [(ngModel)]="form.id_caja_compensacion" [disabled]="!canEdit() || saving() || isLoadingCatalogs()"><option [ngValue]="null">Seleccione caja de compensación</option>@for (entity of cajaCompensacionEntities(); track entity.id_entidad_seguridad_social) { <option [ngValue]="entity.id_entidad_seguridad_social">{{ entity.nombre }}</option> }</select></label>
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
  private readonly catalogs = inject(CatalogService);
  readonly data = signal<EmployeeSocialSecurity | null>(null);
  readonly loading = signal(false);
  readonly saving = signal(false);
  readonly error = signal('');
  readonly formError = signal('');
  readonly catalogsError = signal('');
  readonly success = signal('');
  readonly isLoadingCatalogs = signal(false);
  readonly epsEntities = signal<SocialSecurityEntity[]>([]);
  readonly arlEntities = signal<SocialSecurityEntity[]>([]);
  readonly pensionEntities = signal<SocialSecurityEntity[]>([]);
  readonly cesantiasEntities = signal<SocialSecurityEntity[]>([]);
  readonly cajaCompensacionEntities = signal<SocialSecurityEntity[]>([]);
  employeeId = 0;
  form: SaveSocialSecurityRequest = {};

  ngOnInit(): void {
    this.employeeId = Number(this.route.snapshot.paramMap.get('employeeId'));
    this.loadCatalogs();
    this.load();
  }

  loadCatalogs(): void {
    this.isLoadingCatalogs.set(true);
    this.catalogsError.set('');
    const errors: string[] = [];
    forkJoin({
      eps: this.loadCatalog('EPS', errors),
      arl: this.loadCatalog('ARL', errors),
      pension: this.loadCatalog('PENSION', errors),
      cesantias: this.loadCatalog('CESANTIAS', errors),
      caja: this.loadCatalog('CAJA_COMPENSACION', errors),
    }).pipe(finalize(() => this.isLoadingCatalogs.set(false))).subscribe((entities) => {
      this.epsEntities.set(entities.eps);
      this.arlEntities.set(entities.arl);
      this.pensionEntities.set(entities.pension);
      this.cesantiasEntities.set(entities.cesantias);
      this.cajaCompensacionEntities.set(entities.caja);
      if (errors.length) this.catalogsError.set(errors.join(' '));
    });
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

  private loadCatalog(type: SocialSecurityType, errors: string[]): Observable<SocialSecurityEntity[]> {
    return this.catalogs.getSocialSecurityEntities(type).pipe(catchError((error) => {
      errors.push(apiErrorMessage(error, `No fue posible cargar el catálogo ${type}.`));
      return of([]);
    }));
  }

  private numberOrNull(value: unknown): number | null {
    const numberValue = Number(value);
    return Number.isFinite(numberValue) && value !== '' && value !== null ? numberValue : null;
  }
}
