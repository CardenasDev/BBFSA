import { Component, OnInit, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { finalize } from 'rxjs';
import { ContractingProfile, Department, Municipality, SaveContractingProfileRequest } from '../../core/models/api.models';
import { AuthService } from '../../core/services/auth.service';
import { ContractingService } from '../../core/services/contracting.service';
import { CatalogService } from '../../core/services/catalog.service';
import { apiErrorMessage } from '../../shared/api-error';

const CIVIL_STATES = ['SOLTERO', 'CASADO', 'UNION_LIBRE', 'SEPARADO', 'DIVORCIADO', 'VIUDO', 'OTRO'];
const EDUCATION_LEVELS = ['PRIMARIA', 'BACHILLER', 'TECNICO', 'TECNOLOGO', 'PROFESIONAL', 'POSGRADO', 'NINGUNO', 'OTRO'];
const GENDERS = [
  { value: 'MASCULINO', label: 'Masculino' },
  { value: 'FEMENINO', label: 'Femenino' },
];

export function contractingStudyStatus(value: boolean | number | string | null | undefined): boolean | null {
  if (value === true || value === 1 || value === '1') return true;
  if (value === false || value === 0 || value === '0') return false;
  return null;
}

export function contractingNullableInteger(value: unknown): number | null {
  if (value === '' || value == null) return null;
  const numberValue = Number(value);
  return Number.isInteger(numberValue) ? numberValue : null;
}

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
        <label>Numero de carpeta<input type="text" name="numero_carpeta" [(ngModel)]="form.numero_carpeta" [disabled]="!canEdit() || saving()" maxlength="50" /></label>
        <label>Genero
          <select name="genero" [(ngModel)]="form.genero" [disabled]="!canEdit() || saving()">
            <option [ngValue]="null">Seleccione...</option>
            @for (item of genders; track item.value) { <option [value]="item.value">{{ item.label }}</option> }
          </select>
        </label>
        <label>Fecha expedicion documento<input type="date" name="fecha_expedicion_documento" [(ngModel)]="form.fecha_expedicion_documento" [disabled]="!canEdit() || saving()" /></label>
        <label>Fecha nacimiento<input type="date" name="fecha_nacimiento" [(ngModel)]="form.fecha_nacimiento" disabled /></label>
        <label>Departamento nacimiento
          <select name="id_departamento_nacimiento" [(ngModel)]="form.id_departamento_nacimiento" (ngModelChange)="onBirthDepartmentChange($event)" [disabled]="!canEdit() || saving() || isLoadingDepartments()">
            <option [ngValue]="null">Seleccione departamento</option>
            @for (department of departments(); track department.id_departamento) { <option [ngValue]="department.id_departamento">{{ department.nombre }}</option> }
          </select>
          @if (!form.id_departamento_nacimiento && profile()?.departamento_nacimiento) { <small class="muted">Valor registrado anteriormente: {{ profile()?.departamento_nacimiento }}</small> }
        </label>
        <label>Lugar/Ciudad nacimiento
          <select name="id_municipio_nacimiento" [(ngModel)]="form.id_municipio_nacimiento" [disabled]="!canEdit() || saving() || !form.id_departamento_nacimiento || isLoadingBirthMunicipalities()">
            <option [ngValue]="null">Seleccione municipio</option>
            @for (municipality of birthMunicipalities(); track municipality.id_municipio) { <option [ngValue]="municipality.id_municipio">{{ municipality.nombre }}</option> }
          </select>
          @if (!form.id_municipio_nacimiento && profile()?.lugar_nacimiento) { <small class="muted">Valor registrado anteriormente: {{ profile()?.lugar_nacimiento }}</small> }
        </label>
        <label>Nacionalidad<input type="text" name="nacionalidad" [(ngModel)]="form.nacionalidad" disabled maxlength="100" /></label>
        <label>Departamento residencia
          <select name="id_departamento_residencia" [(ngModel)]="form.id_departamento_residencia" (ngModelChange)="onResidenceDepartmentChange($event)" [disabled]="!canEdit() || saving() || isLoadingDepartments()">
            <option [ngValue]="null">Seleccione departamento</option>
            @for (department of departments(); track department.id_departamento) { <option [ngValue]="department.id_departamento">{{ department.nombre }}</option> }
          </select>
          @if (!form.id_departamento_residencia && profile()?.departamento_residencia) { <small class="muted">Valor registrado anteriormente: {{ profile()?.departamento_residencia }}</small> }
        </label>
        <label>Ciudad residencia
          <select name="id_municipio_residencia" [(ngModel)]="form.id_municipio_residencia" [disabled]="!canEdit() || saving() || !form.id_departamento_residencia || isLoadingResidenceMunicipalities()">
            <option [ngValue]="null">Seleccione municipio</option>
            @for (municipality of residenceMunicipalities(); track municipality.id_municipio) { <option [ngValue]="municipality.id_municipio">{{ municipality.nombre }}</option> }
          </select>
          @if (!form.id_municipio_residencia && profile()?.ciudad_residencia) { <small class="muted">Valor registrado anteriormente: {{ profile()?.ciudad_residencia }}</small> }
        </label>
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
        <label>Personas en la vivienda<input type="number" min="0" step="1" name="personas_vivienda" [(ngModel)]="form.personas_vivienda" [disabled]="!canEdit() || saving()" /></label>
        <label>¿Los menores de edad estudian?
          <select name="menores_estudian" [(ngModel)]="form.menores_estudian" [disabled]="!canEdit() || saving()">
            <option [ngValue]="undefined">Seleccione...</option>
            <option [ngValue]="true">Si</option>
            <option [ngValue]="false">No</option>
            <option [ngValue]="null">No aplica / No informado</option>
          </select>
        </label>
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
  private readonly catalogs = inject(CatalogService);
  readonly profile = signal<ContractingProfile | null>(null);
  readonly loading = signal(false);
  readonly saving = signal(false);
  readonly error = signal('');
  readonly formError = signal('');
  readonly success = signal('');
  readonly departments = signal<Department[]>([]);
  readonly birthMunicipalities = signal<Municipality[]>([]);
  readonly residenceMunicipalities = signal<Municipality[]>([]);
  readonly isLoadingDepartments = signal(false);
  readonly isLoadingBirthMunicipalities = signal(false);
  readonly isLoadingResidenceMunicipalities = signal(false);
  readonly civilStates = CIVIL_STATES;
  readonly educationLevels = EDUCATION_LEVELS;
  readonly genders = GENDERS;
  employeeId = 0;
  form: ContractingProfileForm = this.emptyForm();
  private birthMunicipalityRequest = 0;
  private residenceMunicipalityRequest = 0;

  ngOnInit(): void {
    this.employeeId = Number(this.route.snapshot.paramMap.get('employeeId'));
    const successMessage = history.state?.successMessage;
    if (typeof successMessage === 'string') this.success.set(successMessage);
    this.loadDepartments();
    this.load();
  }

  loadDepartments(): void {
    this.isLoadingDepartments.set(true);
    this.catalogs.getDepartments().pipe(finalize(() => this.isLoadingDepartments.set(false))).subscribe({
      next: (departments) => this.departments.set(departments),
      error: (error) => {
        this.departments.set([]);
        this.formError.set(apiErrorMessage(error, 'No fue posible cargar los departamentos.'));
      },
    });
  }

  load(): void {
    this.loading.set(true);
    this.error.set('');
    this.service.getProfile(this.employeeId).pipe(finalize(() => this.loading.set(false))).subscribe({
      next: (profile) => {
        this.profile.set(profile);
        this.form = this.formFromProfile(profile);
        this.loadBirthMunicipalities(this.form.id_departamento_nacimiento ?? null, this.form.id_municipio_nacimiento ?? null);
        this.loadResidenceMunicipalities(this.form.id_departamento_residencia ?? null, this.form.id_municipio_residencia ?? null);
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
    if ((this.form.numero_carpeta?.length ?? 0) > 50) return 'El numero de carpeta debe tener maximo 50 caracteres.';
    if (this.form.fecha_expedicion_documento && !this.isValidDate(this.form.fecha_expedicion_documento)) return 'La fecha de expedicion del documento no es valida.';
    if (this.form.fecha_nacimiento && !this.isValidDate(this.form.fecha_nacimiento)) return 'La fecha de nacimiento no es valida.';
    if ((this.form.nacionalidad?.length ?? 0) > 100) return 'La nacionalidad debe tener maximo 100 caracteres.';
    if (this.form.correo_personal && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(this.form.correo_personal)) return 'El correo personal no es valido.';
    if (Number(this.form.personas_a_cargo ?? 0) < 0) return 'Personas a cargo debe ser mayor o igual a cero.';
    if (Number(this.form.numero_hijos ?? 0) < 0) return 'Numero de hijos debe ser mayor o igual a cero.';
    if (this.form.personas_vivienda != null && (!Number.isInteger(Number(this.form.personas_vivienda)) || Number(this.form.personas_vivienda) < 0)) {
      return 'Personas en la vivienda debe ser un numero entero mayor o igual a cero.';
    }
    const contact = this.form.contacto_emergencia ?? {};
    if ((contact.nombre_completo || contact.parentesco || contact.direccion) && !contact.telefono) return 'Si diligencias contacto de emergencia, el telefono es recomendado.';
    return '';
  }

  private payload(): SaveContractingProfileRequest {
    const { fecha_nacimiento: _fechaNacimiento, nacionalidad: _nacionalidad, ...rest } = this.form;
    return {
      ...rest,
      numero_carpeta: this.blankToNull(this.form.numero_carpeta),
      genero: this.blankToNull(this.form.genero),
      fecha_expedicion_documento: this.blankToNull(this.form.fecha_expedicion_documento),
      id_departamento_nacimiento: this.nullableNumber(this.form.id_departamento_nacimiento),
      id_municipio_nacimiento: this.nullableNumber(this.form.id_municipio_nacimiento),
      id_departamento_residencia: this.nullableNumber(this.form.id_departamento_residencia),
      id_municipio_residencia: this.nullableNumber(this.form.id_municipio_residencia),
      personas_a_cargo: this.nullableNumber(this.form.personas_a_cargo),
      numero_hijos: this.nullableNumber(this.form.numero_hijos),
      personas_vivienda: contractingNullableInteger(this.form.personas_vivienda),
      menores_estudian: contractingStudyStatus(this.form.menores_estudian),
      contacto_emergencia: { ...(this.form.contacto_emergencia ?? {}) },
    };
  }

  private formFromProfile(profile: ContractingProfile | null): ContractingProfileForm {
    return {
      numero_carpeta: profile?.numero_carpeta ?? null,
      genero: profile?.genero ?? null,
      fecha_expedicion_documento: profile?.fecha_expedicion_documento ?? null,
      id_departamento_nacimiento: profile?.id_departamento_nacimiento ?? null,
      id_municipio_nacimiento: profile?.id_municipio_nacimiento ?? null,
      fecha_nacimiento: profile?.fecha_nacimiento ?? null,
      nacionalidad: profile?.nacionalidad ?? null,
      id_departamento_residencia: profile?.id_departamento_residencia ?? null,
      id_municipio_residencia: profile?.id_municipio_residencia ?? null,
      direccion_residencia: profile?.direccion_residencia ?? null,
      telefono_alterno: profile?.telefono_alterno ?? null,
      correo_personal: profile?.correo_personal ?? null,
      estado_civil: profile?.estado_civil ?? null,
      nivel_educativo: profile?.nivel_educativo ?? null,
      personas_a_cargo: profile?.personas_a_cargo ?? null,
      numero_hijos: profile?.numero_hijos ?? null,
      personas_vivienda: profile?.personas_vivienda ?? null,
      menores_estudian: contractingStudyStatus(profile?.menores_estudian),
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

  private loadBirthMunicipalities(departmentId: number | null, selectedMunicipalityId: number | null): void {
    const request = ++this.birthMunicipalityRequest;
    this.birthMunicipalities.set([]);
    if (!departmentId) {
      this.isLoadingBirthMunicipalities.set(false);
      return;
    }
    this.isLoadingBirthMunicipalities.set(true);
    this.catalogs.getMunicipalitiesByDepartment(departmentId).pipe(finalize(() => {
      if (request === this.birthMunicipalityRequest) this.isLoadingBirthMunicipalities.set(false);
    })).subscribe({
      next: (municipalities) => {
        if (request !== this.birthMunicipalityRequest) return;
        this.birthMunicipalities.set(municipalities);
        this.form.id_municipio_nacimiento = selectedMunicipalityId;
      },
      error: (error) => {
        if (request !== this.birthMunicipalityRequest) return;
        this.birthMunicipalities.set([]);
        this.formError.set(apiErrorMessage(error, 'No fue posible cargar los municipios de nacimiento.'));
      },
    });
  }

  private loadResidenceMunicipalities(departmentId: number | null, selectedMunicipalityId: number | null): void {
    const request = ++this.residenceMunicipalityRequest;
    this.residenceMunicipalities.set([]);
    if (!departmentId) {
      this.isLoadingResidenceMunicipalities.set(false);
      return;
    }
    this.isLoadingResidenceMunicipalities.set(true);
    this.catalogs.getMunicipalitiesByDepartment(departmentId).pipe(finalize(() => {
      if (request === this.residenceMunicipalityRequest) this.isLoadingResidenceMunicipalities.set(false);
    })).subscribe({
      next: (municipalities) => {
        if (request !== this.residenceMunicipalityRequest) return;
        this.residenceMunicipalities.set(municipalities);
        this.form.id_municipio_residencia = selectedMunicipalityId;
      },
      error: (error) => {
        if (request !== this.residenceMunicipalityRequest) return;
        this.residenceMunicipalities.set([]);
        this.formError.set(apiErrorMessage(error, 'No fue posible cargar los municipios de residencia.'));
      },
    });
  }

  private nullableNumber(value: unknown): number | null {
    if (value === '' || value == null) return null;
    const numberValue = Number(value);
    return Number.isFinite(numberValue) ? numberValue : null;
  }

  onBirthDepartmentChange(departmentId: number | null): void {
    this.form.id_municipio_nacimiento = null;
    this.loadBirthMunicipalities(departmentId, null);
  }

  onResidenceDepartmentChange(departmentId: number | null): void {
    this.form.id_municipio_residencia = null;
    this.loadResidenceMunicipalities(departmentId, null);
  }

  private blankToNull(value: string | null | undefined): string | null {
    const text = value?.trim() ?? '';
    return text ? text : null;
  }

  private isValidDate(value: string): boolean {
    const match = /^(\d{4})-(\d{2})-(\d{2})$/.exec(value);
    if (!match) return false;
    const year = Number(match[1]);
    const month = Number(match[2]);
    const day = Number(match[3]);
    const date = new Date(Date.UTC(year, month - 1, day));
    return date.getUTCFullYear() === year && date.getUTCMonth() === month - 1 && date.getUTCDate() === day;
  }
}
