import { Component, OnInit, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { finalize } from 'rxjs';
import { ContractingProfile, SaveContractingProfileRequest } from '../../core/models/api.models';
import { AuthService } from '../../core/services/auth.service';
import { ContractingService } from '../../core/services/contracting.service';
import { apiErrorMessage } from '../../shared/api-error';

const CIVIL_STATES = ['SOLTERO', 'CASADO', 'UNION_LIBRE', 'SEPARADO', 'DIVORCIADO', 'VIUDO', 'OTRO'];
const EDUCATION_LEVELS = ['PRIMARIA', 'BACHILLER', 'TECNICO', 'TECNOLOGO', 'PROFESIONAL', 'POSGRADO', 'NINGUNO', 'OTRO'];

type EmergencyContactForm = NonNullable<SaveContractingProfileRequest['contacto_emergencia']>;

interface ContractingProfileForm extends SaveContractingProfileRequest {
  fecha_nacimiento: string | null;
  nacionalidad: string | null;
  contacto_emergencia: EmergencyContactForm;
}

@Component({
  standalone: true,
  imports: [FormsModule, RouterLink],
  template: `
    <div class="page-heading">
      <div><p class="eyebrow">Contratacion</p><h1>Ficha de ingreso</h1><p class="muted">Datos personales y contacto de emergencia del empleado.</p></div>
      <a class="btn ghost" routerLink="/admin/contracting">Volver a contratacion</a>
    </div>

    <section class="panel profile-summary">
      <div class="avatar large">{{ initials() }}</div>
      <div>
        <h2>{{ profile()?.nombre_completo || 'Empleado #' + employeeId }}</h2>
        <p class="muted">Documento {{ profile()?.numero_documento || 'Sin dato' }} - {{ profile()?.area || 'Sin area' }} - {{ profile()?.cargo || 'Sin cargo' }}</p>
      </div>
      <span class="badge" [class.success]="profile()?.estado_ficha === 'COMPLETA'" [class.danger]="profile()?.estado_ficha !== 'COMPLETA'">{{ profile()?.estado_ficha || 'Sin ficha' }}</span>
    </section>

    <section class="panel">
      <div class="row-actions" style="margin-bottom:1rem">
        <a class="btn small secondary" [routerLink]="['/admin/contracting/employees', employeeId, 'profile']">Ficha</a>
        <a class="btn small ghost" [routerLink]="['/admin/contracting/employees', employeeId, 'contracts']">Contratos</a>
        <a class="btn small ghost" [routerLink]="['/admin/contracting/employees', employeeId, 'social-security']">Seguridad social</a>
        <a class="btn small ghost" [routerLink]="['/admin/contracting/employees', employeeId, 'medical-exams']">Examenes</a>
        <a class="btn small ghost" [routerLink]="['/admin/contracting/employees', employeeId, 'documents']">Documentos</a>
      </div>

      @if (success()) { <div class="alert success">{{ success() }}</div> }
      @if (error()) { <div class="alert error">{{ error() }} <button class="btn small ghost" type="button" (click)="load()" [disabled]="loading()">Reintentar</button></div> }
      @if (formError()) { <div class="alert error">{{ formError() }}</div> }
      @if (profile()?.id_aspirante_origen) { <p class="muted">Informacion precargada desde el registro del aspirante.</p> }

      <form class="form-grid" (ngSubmit)="save()">
        <label>Fecha nacimiento<input type="date" name="fecha_nacimiento" [(ngModel)]="form.fecha_nacimiento" disabled /></label>
        <label>Lugar nacimiento<input name="lugar_nacimiento" [(ngModel)]="form.lugar_nacimiento" [disabled]="!canEdit() || saving()" maxlength="150" /></label>
        <label>Nacionalidad<input type="text" name="nacionalidad" [(ngModel)]="form.nacionalidad" disabled maxlength="100" /></label>
        <label>Departamento nacimiento<input name="departamento_nacimiento" [(ngModel)]="form.departamento_nacimiento" [disabled]="!canEdit() || saving()" maxlength="150" /></label>
        <label>Ciudad residencia<input name="ciudad_residencia" [(ngModel)]="form.ciudad_residencia" [disabled]="!canEdit() || saving()" maxlength="150" /></label>
        <label>Departamento residencia<input name="departamento_residencia" [(ngModel)]="form.departamento_residencia" [disabled]="!canEdit() || saving()" maxlength="150" /></label>
        <label class="form-wide">Direccion residencia<input name="direccion_residencia" [(ngModel)]="form.direccion_residencia" [disabled]="!canEdit() || saving()" maxlength="250" /></label>
        <label>Telefono alterno<input name="telefono_alterno" [(ngModel)]="form.telefono_alterno" [disabled]="!canEdit() || saving()" maxlength="50" /></label>
        <label>Correo personal<input type="email" name="correo_personal" [(ngModel)]="form.correo_personal" [disabled]="!canEdit() || saving()" maxlength="150" /></label>
        <label>Estado civil
          <select name="estado_civil" [(ngModel)]="form.estado_civil" [disabled]="!canEdit() || saving()">
            <option [ngValue]="null">Seleccione...</option>
            @for (item of civilStates; track item) { <option [value]="item">{{ item }}</option> }
          </select>
        </label>
        <label>Nivel educativo
          <select name="nivel_educativo" [(ngModel)]="form.nivel_educativo" [disabled]="!canEdit() || saving()">
            <option [ngValue]="null">Seleccione...</option>
            @for (item of educationLevels; track item) { <option [value]="item">{{ item }}</option> }
          </select>
        </label>
        <label>Personas a cargo<input type="number" min="0" name="personas_a_cargo" [(ngModel)]="form.personas_a_cargo" [disabled]="!canEdit() || saving()" /></label>
        <label>Numero hijos<input type="number" min="0" name="numero_hijos" [(ngModel)]="form.numero_hijos" [disabled]="!canEdit() || saving()" /></label>
        <label class="form-wide">Observaciones<textarea rows="3" name="observaciones" [(ngModel)]="form.observaciones" [disabled]="!canEdit() || saving()"></textarea></label>

        <div class="form-wide section-title"><h2>Contacto de emergencia</h2></div>
        <label>Nombre completo<input name="contacto_nombre" [(ngModel)]="form.contacto_emergencia.nombre_completo" [disabled]="!canEdit() || saving()" maxlength="200" /></label>
        <label>Parentesco<input name="contacto_parentesco" [(ngModel)]="form.contacto_emergencia.parentesco" [disabled]="!canEdit() || saving()" maxlength="100" /></label>
        <label>Telefono<input name="contacto_telefono" [(ngModel)]="form.contacto_emergencia.telefono" [disabled]="!canEdit() || saving()" maxlength="50" /></label>
        <label>Telefono alterno<input name="contacto_telefono_alterno" [(ngModel)]="form.contacto_emergencia.telefono_alterno" [disabled]="!canEdit() || saving()" maxlength="50" /></label>
        <label class="form-wide">Direccion<input name="contacto_direccion" [(ngModel)]="form.contacto_emergencia.direccion" [disabled]="!canEdit() || saving()" maxlength="250" /></label>
        <label class="form-wide">Observaciones contacto<textarea rows="3" name="contacto_observaciones" [(ngModel)]="form.contacto_emergencia.observaciones" [disabled]="!canEdit() || saving()" maxlength="500"></textarea></label>

        @if (canEdit()) {
          <div class="form-actions form-wide">
            <button class="btn primary" type="submit" [disabled]="saving() || loading()">{{ saving() ? 'Guardando...' : 'Guardar ficha' }}</button>
          </div>
        }
        <p class="muted form-wide">Completa los campos pendientes de la ficha de ingreso.</p>
      </form>
    </section>
  `,
})
export class ContractingProfileComponent implements OnInit {
  readonly auth = inject(AuthService);
  private readonly route = inject(ActivatedRoute);
  private readonly service = inject(ContractingService);
  readonly profile = signal<ContractingProfile | null>(null);
  readonly loading = signal(false);
  readonly saving = signal(false);
  readonly error = signal('');
  readonly formError = signal('');
  readonly success = signal('');
  readonly civilStates = CIVIL_STATES;
  readonly educationLevels = EDUCATION_LEVELS;
  employeeId = 0;
  form: ContractingProfileForm = this.emptyForm();

  ngOnInit(): void {
    this.employeeId = Number(this.route.snapshot.paramMap.get('employeeId'));
    const successMessage = history.state?.successMessage;
    if (typeof successMessage === 'string') this.success.set(successMessage);
    this.load();
  }

  load(): void {
    this.loading.set(true);
    this.error.set('');
    this.service.getProfile(this.employeeId).pipe(finalize(() => this.loading.set(false))).subscribe({
      next: (profile) => {
        this.profile.set(profile);
        this.form = this.formFromProfile(profile);
      },
      error: (error) => this.error.set(apiErrorMessage(error, 'No fue posible cargar la informacion de contratacion.')),
    });
  }

  save(): void {
    this.formError.set('');
    this.success.set('');
    const validation = this.validate();
    if (validation) {
      this.formError.set(validation);
      return;
    }
    this.saving.set(true);
    this.service.saveProfile(this.employeeId, this.payload()).pipe(finalize(() => this.saving.set(false))).subscribe({
      next: () => {
        this.success.set('Ficha guardada correctamente.');
        this.load();
      },
      error: (error) => this.formError.set(apiErrorMessage(error, 'No fue posible guardar la ficha de contratacion.')),
    });
  }

  canEdit(): boolean {
    return this.auth.hasAnyPermission(['CONTRATACION_CREAR', 'CONTRATACION_EDITAR']);
  }

  initials(): string {
    return (this.profile()?.nombre_completo ?? `E ${this.employeeId}`).split(/\s+/).slice(0, 2).map((part) => part[0]).join('').toUpperCase();
  }

  private validate(): string {
    if (this.form.fecha_nacimiento && !this.isValidDate(this.form.fecha_nacimiento)) return 'La fecha de nacimiento no es valida.';
    if ((this.form.nacionalidad?.length ?? 0) > 100) return 'La nacionalidad debe tener maximo 100 caracteres.';
    if (this.form.correo_personal && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(this.form.correo_personal)) return 'El correo personal no es valido.';
    if (Number(this.form.personas_a_cargo ?? 0) < 0) return 'Personas a cargo debe ser mayor o igual a cero.';
    if (Number(this.form.numero_hijos ?? 0) < 0) return 'Numero de hijos debe ser mayor o igual a cero.';
    const contact = this.form.contacto_emergencia ?? {};
    if ((contact.nombre_completo || contact.parentesco || contact.direccion) && !contact.telefono) return 'Si diligencias contacto de emergencia, el telefono es recomendado.';
    return '';
  }

  private payload(): SaveContractingProfileRequest {
    const { fecha_nacimiento: _fechaNacimiento, nacionalidad: _nacionalidad, ...rest } = this.form;
    return {
      ...rest,
      personas_a_cargo: this.nullableNumber(this.form.personas_a_cargo),
      numero_hijos: this.nullableNumber(this.form.numero_hijos),
      contacto_emergencia: { ...(this.form.contacto_emergencia ?? {}) },
    };
  }

  private formFromProfile(profile: ContractingProfile | null): ContractingProfileForm {
    return {
      lugar_nacimiento: profile?.lugar_nacimiento ?? null,
      fecha_nacimiento: profile?.fecha_nacimiento ?? null,
      nacionalidad: profile?.nacionalidad ?? null,
      departamento_nacimiento: profile?.departamento_nacimiento ?? null,
      ciudad_residencia: profile?.ciudad_residencia ?? null,
      departamento_residencia: profile?.departamento_residencia ?? null,
      direccion_residencia: profile?.direccion_residencia ?? null,
      telefono_alterno: profile?.telefono_alterno ?? null,
      correo_personal: profile?.correo_personal ?? null,
      estado_civil: profile?.estado_civil ?? null,
      nivel_educativo: profile?.nivel_educativo ?? null,
      personas_a_cargo: profile?.personas_a_cargo ?? null,
      numero_hijos: profile?.numero_hijos ?? null,
      observaciones: profile?.observaciones ?? null,
      contacto_emergencia: {
        nombre_completo: profile?.contacto_nombre_completo ?? null,
        parentesco: profile?.contacto_parentesco ?? null,
        telefono: profile?.contacto_telefono ?? null,
        telefono_alterno: profile?.contacto_telefono_alterno ?? null,
        direccion: profile?.contacto_direccion ?? null,
        observaciones: profile?.contacto_observaciones ?? null,
      },
    };
  }

  private emptyForm(): ContractingProfileForm {
    return this.formFromProfile(null);
  }

  private nullableNumber(value: unknown): number | null {
    if (value === '' || value == null) return null;
    const numberValue = Number(value);
    return Number.isFinite(numberValue) ? numberValue : null;
  }

  private isValidDate(value: string): boolean {
    return /^\d{4}-\d{2}-\d{2}$/.test(value) && !Number.isNaN(Date.parse(`${value}T00:00:00`));
  }
}
