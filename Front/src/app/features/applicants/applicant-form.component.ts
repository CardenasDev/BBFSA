import { Component, OnInit, inject, signal } from '@angular/core';
import { NgClass } from '@angular/common';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { ActivatedRoute, Router, RouterLink } from '@angular/router';
import { finalize, forkJoin } from 'rxjs';
import {
  ApplicantCivilState,
  ApplicantDetail,
  ApplicantEducationLevel,
  Area,
  ContractType,
  CreateApplicantRequest,
  Department,
  DocumentType,
  Municipality,
  Position,
} from '../../core/models/api.models';
import { ApplicantService } from '../../core/services/applicant.service';
import { CatalogService } from '../../core/services/catalog.service';
import { apiErrorMessage } from '../../shared/api-error';
import { applicantName, applicantStatusClass, blankToNull, toNullableNumber } from './applicant-utils';
import { SearchableSelectComponent } from '../../shared/searchable-select.component';

const CIVIL_STATES: ApplicantCivilState[] = ['SOLTERO', 'CASADO', 'UNION_LIBRE', 'SEPARADO', 'DIVORCIADO', 'VIUDO', 'OTRO'];
const EDUCATION_LEVELS: ApplicantEducationLevel[] = ['PRIMARIA', 'BACHILLER', 'TECNICO', 'TECNOLOGO', 'PROFESIONAL', 'POSGRADO', 'NINGUNO', 'OTRO'];

@Component({
  standalone: true,
  imports: [NgClass, ReactiveFormsModule, RouterLink, SearchableSelectComponent],
  template: `
    <div class="page-heading">
      <div>
        <p class="eyebrow">Aspirantes</p>
        <h1>{{ editMode() ? 'Editar aspirante' : 'Registrar aspirante' }}</h1>
        <p class="muted">Datos basicos previos al proceso de contratacion.</p>
      </div>
      <a class="btn ghost" routerLink="/admin/applicants">Volver</a>
    </div>

    <section class="panel">
      @if (success()) { <div class="alert success">{{ success() }}</div> }
      @if (error()) { <div class="alert error">{{ error() }}</div> }
      @if (catalogsError()) { <div class="alert error">{{ catalogsError() }}</div> }
      @if (converted()) { <div class="alert error">Este aspirante ya fue convertido en empleado. Los campos quedan en solo lectura.</div> }

      @if (currentApplicant(); as applicant) {
        <section class="profile-summary" style="margin-bottom:1rem">
          <div class="avatar large">{{ initials(applicant) }}</div>
          <div>
            <h2>{{ applicantName(applicant) }}</h2>
            <p class="muted">Documento {{ applicant.numero_documento }}</p>
          </div>
          <span class="badge" [ngClass]="statusClass(applicant.estado_aspirante)">{{ applicant.estado_aspirante }}</span>
        </section>
      }

      <form class="form-grid" [formGroup]="form" (ngSubmit)="save()">
        <div class="form-wide section-title"><h2>Datos basicos</h2></div>
        <label>Tipo de documento
          <select formControlName="id_tipo_documento">
            <option [ngValue]="null">{{ loadingCatalogs() ? 'Cargando...' : 'Seleccione...' }}</option>
            @for (item of documentTypes(); track item.id_tipo_documento) {
              <option [ngValue]="item.id_tipo_documento">{{ item.nombre }}</option>
            }
          </select>
        </label>
        <label>Numero documento
          <input type="text" formControlName="numero_documento" required maxlength="50" />
          @if (invalid('numero_documento')) { <small class="field-error">Documento requerido, maximo 50 caracteres.</small> }
        </label>
        <label>Nombres
          <input type="text" formControlName="nombres" required maxlength="150" />
          @if (invalid('nombres')) { <small class="field-error">Nombres requeridos, maximo 150 caracteres.</small> }
        </label>
        <label>Apellidos
          <input type="text" formControlName="apellidos" required maxlength="150" />
          @if (invalid('apellidos')) { <small class="field-error">Apellidos requeridos, maximo 150 caracteres.</small> }
        </label>
        <label>Correo
          <input type="email" formControlName="correo" maxlength="150" />
          @if (invalid('correo')) { <small class="field-error">Correo invalido.</small> }
        </label>
        <label>Telefono<input type="text" formControlName="telefono" maxlength="50" /></label>

        <div class="form-wide section-title"><h2>Datos personales</h2></div>
        <label>Fecha nacimiento<input type="date" formControlName="fecha_nacimiento" /></label>
        <label>Departamento nacimiento
          <app-searchable-select formControlName="id_departamento_nacimiento" [options]="departmentOptions()" [placeholder]="isLoadingDepartments() ? 'Cargando...' : 'Escriba para buscar departamento'" />
          @if (!form.controls.id_departamento_nacimiento.value && currentApplicant()?.departamento_nacimiento) {
            <small class="muted">Valor registrado anteriormente: {{ currentApplicant()?.departamento_nacimiento }}</small>
          }
        </label>
        <label>Lugar/Ciudad nacimiento
          <app-searchable-select formControlName="id_municipio_nacimiento" [options]="birthMunicipalityOptions()" [placeholder]="isLoadingBirthMunicipalities() ? 'Cargando...' : 'Escriba para buscar municipio'" />
          @if (!form.controls.id_municipio_nacimiento.value && currentApplicant()?.lugar_nacimiento) {
            <small class="muted">Valor registrado anteriormente: {{ currentApplicant()?.lugar_nacimiento }}</small>
          }
        </label>
        <label>Nacionalidad<input type="text" formControlName="nacionalidad" maxlength="100" /></label>
        <label>Estado civil
          <select formControlName="estado_civil">
            <option [ngValue]="null">Seleccione...</option>
            @for (item of civilStates; track item) { <option [value]="item">{{ item }}</option> }
          </select>
        </label>
        <label>Nivel educativo
          <select formControlName="nivel_educativo">
            <option [ngValue]="null">Seleccione...</option>
            @for (item of educationLevels; track item) { <option [value]="item">{{ item }}</option> }
          </select>
        </label>
        <label>Personas a cargo
          <input type="number" min="0" formControlName="personas_a_cargo" />
          @if (invalid('personas_a_cargo')) { <small class="field-error">Debe ser mayor o igual a cero.</small> }
        </label>
        <label>Numero hijos
          <input type="number" min="0" formControlName="numero_hijos" />
          @if (invalid('numero_hijos')) { <small class="field-error">Debe ser mayor o igual a cero.</small> }
        </label>

        <div class="form-wide section-title"><h2>Residencia</h2></div>
        <label class="form-wide">Direccion<input type="text" formControlName="direccion" maxlength="250" /></label>
        <label>Departamento residencia
          <app-searchable-select formControlName="id_departamento_residencia" [options]="departmentOptions()" [placeholder]="isLoadingDepartments() ? 'Cargando...' : 'Escriba para buscar departamento'" />
          @if (!form.controls.id_departamento_residencia.value && currentApplicant()?.departamento_residencia) {
            <small class="muted">Valor registrado anteriormente: {{ currentApplicant()?.departamento_residencia }}</small>
          }
        </label>
        <label>Ciudad residencia
          <app-searchable-select formControlName="id_municipio_residencia" [options]="residenceMunicipalityOptions()" [placeholder]="isLoadingResidenceMunicipalities() ? 'Cargando...' : 'Escriba para buscar municipio'" />
          @if (!form.controls.id_municipio_residencia.value && currentApplicant()?.ciudad_residencia) {
            <small class="muted">Valor registrado anteriormente: {{ currentApplicant()?.ciudad_residencia }}</small>
          }
        </label>

        <div class="form-wide section-title"><h2>Aspiracion laboral</h2></div>
        <label>Area aspirada
          <select formControlName="id_area_aspira">
            <option [ngValue]="null">{{ loadingCatalogs() ? 'Cargando...' : 'Seleccione...' }}</option>
            @for (area of areas(); track area.id_area) {
              <option [ngValue]="area.id_area">{{ area.nombre }}</option>
            }
          </select>
        </label>
        <label>Cargo aspirado
          <select formControlName="id_cargo_aspira">
            <option [ngValue]="null">{{ loadingCatalogs() ? 'Cargando...' : 'Seleccione...' }}</option>
            @for (position of positions(); track position.id_cargo) {
              <option [ngValue]="position.id_cargo">{{ position.nombre }}</option>
            }
          </select>
        </label>
        <label class="form-wide">Observaciones<textarea rows="4" formControlName="observaciones"></textarea></label>
        <div class="form-actions form-wide">
          <a class="btn secondary" routerLink="/admin/applicants">Cancelar</a>
          <button class="btn primary" type="submit" [disabled]="form.invalid || saving() || converted()">{{ saving() ? 'Guardando...' : 'Guardar' }}</button>
        </div>
      </form>
    </section>
  `,
})
export class ApplicantFormComponent implements OnInit {
  private readonly route = inject(ActivatedRoute);
  private readonly router = inject(Router);
  private readonly fb = inject(FormBuilder);
  private readonly service = inject(ApplicantService);
  private readonly catalogs = inject(CatalogService);
  readonly editMode = signal(false);
  readonly loading = signal(false);
  readonly saving = signal(false);
  readonly loadingCatalogs = signal(false);
  readonly isLoadingDepartments = signal(false);
  readonly isLoadingBirthMunicipalities = signal(false);
  readonly isLoadingResidenceMunicipalities = signal(false);
  readonly error = signal('');
  readonly success = signal('');
  readonly catalogsError = signal('');
  readonly currentApplicant = signal<ApplicantDetail | null>(null);
  readonly documentTypes = signal<DocumentType[]>([]);
  readonly areas = signal<Area[]>([]);
  readonly positions = signal<Position[]>([]);
  readonly contractTypes = signal<ContractType[]>([]);
  readonly departments = signal<Department[]>([]);
  readonly birthMunicipalities = signal<Municipality[]>([]);
  readonly residenceMunicipalities = signal<Municipality[]>([]);
  readonly converted = signal(false);
  readonly civilStates = CIVIL_STATES;
  readonly educationLevels = EDUCATION_LEVELS;
  applicantId = 0;
  private birthMunicipalityRequest = 0;
  private residenceMunicipalityRequest = 0;

  readonly form = this.fb.group({
    id_tipo_documento: [null as number | null],
    numero_documento: ['', [Validators.required, Validators.maxLength(50)]],
    nombres: ['', [Validators.required, Validators.maxLength(150)]],
    apellidos: ['', [Validators.required, Validators.maxLength(150)]],
    correo: ['', [Validators.email, Validators.maxLength(150)]],
    telefono: ['', [Validators.maxLength(50)]],
    direccion: ['', [Validators.maxLength(250)]],
    fecha_nacimiento: [null as string | null],
    id_departamento_nacimiento: [null as number | null],
    id_municipio_nacimiento: [null as number | null],
    nacionalidad: ['', [Validators.maxLength(100)]],
    id_departamento_residencia: [null as number | null],
    id_municipio_residencia: [null as number | null],
    estado_civil: [null as ApplicantCivilState | null, [Validators.pattern(/^(SOLTERO|CASADO|UNION_LIBRE|SEPARADO|DIVORCIADO|VIUDO|OTRO)$/)]],
    nivel_educativo: [null as ApplicantEducationLevel | null, [Validators.pattern(/^(PRIMARIA|BACHILLER|TECNICO|TECNOLOGO|PROFESIONAL|POSGRADO|NINGUNO|OTRO)$/)]],
    personas_a_cargo: [null as number | null, [Validators.min(0)]],
    numero_hijos: [null as number | null, [Validators.min(0)]],
    id_area_aspira: [null as number | null],
    id_cargo_aspira: [null as number | null],
    observaciones: [''],
  });

  ngOnInit(): void {
    this.applicantId = Number(this.route.snapshot.paramMap.get('applicantId'));
    this.editMode.set(this.route.snapshot.routeConfig?.path?.includes('edit') ?? false);
    this.loadCatalogs();
    this.loadDepartments();
    this.form.controls.id_departamento_nacimiento.valueChanges.subscribe((id) => this.onBirthDepartmentChange(id));
    this.form.controls.id_departamento_residencia.valueChanges.subscribe((id) => this.onResidenceDepartmentChange(id));
    if (this.editMode()) {
      this.loadApplicant();
    }
  }

  departmentOptions() { return this.departments().map((item) => ({ value: item.id_departamento, label: item.nombre })); }
  birthMunicipalityOptions() { return this.birthMunicipalities().map((item) => ({ value: item.id_municipio, label: item.nombre })); }
  residenceMunicipalityOptions() { return this.residenceMunicipalities().map((item) => ({ value: item.id_municipio, label: item.nombre })); }

  loadDepartments(): void {
    this.isLoadingDepartments.set(true);
    this.catalogs.getDepartments().pipe(finalize(() => this.isLoadingDepartments.set(false))).subscribe({
      next: (departments) => this.departments.set(departments),
      error: (error) => {
        this.departments.set([]);
        this.catalogsError.set(apiErrorMessage(error, 'No fue posible cargar los departamentos.'));
      },
    });
  }

  onBirthDepartmentChange(departmentId: number | null): void {
    this.form.controls.id_municipio_nacimiento.setValue(null);
    this.loadBirthMunicipalities(departmentId, null);
  }

  onResidenceDepartmentChange(departmentId: number | null): void {
    this.form.controls.id_municipio_residencia.setValue(null);
    this.loadResidenceMunicipalities(departmentId, null);
  }

  loadCatalogs(): void {
    this.loadingCatalogs.set(true);
    this.catalogsError.set('');
    forkJoin({
      documentTypes: this.catalogs.getDocumentTypes(),
      areas: this.catalogs.getAreas(),
      positions: this.catalogs.getPositions(),
      contractTypes: this.catalogs.getContractTypes(),
    }).pipe(finalize(() => this.loadingCatalogs.set(false))).subscribe({
      next: ({ documentTypes, areas, positions, contractTypes }) => {
        this.documentTypes.set(documentTypes);
        this.areas.set(areas);
        this.positions.set(positions);
        this.contractTypes.set(contractTypes);
      },
      error: (error) => this.catalogsError.set(apiErrorMessage(error, 'No fue posible cargar los catalogos.')),
    });
  }

  loadApplicant(): void {
    this.loading.set(true);
    this.error.set('');
    this.service.getApplicant(this.applicantId).pipe(finalize(() => this.loading.set(false))).subscribe({
      next: (applicant) => {
        this.currentApplicant.set(applicant);
        this.converted.set(applicant.estado_aspirante === 'CONVERTIDO_EMPLEADO');
        this.patchForm(applicant);
        if (this.converted()) this.form.disable();
      },
      error: (error) => this.error.set(apiErrorMessage(error, 'No fue posible cargar el aspirante.')),
    });
  }

  save(): void {
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }
    this.saving.set(true);
    this.error.set('');
    this.success.set('');
    const payload = this.payload();
    const request = this.editMode()
      ? this.service.updateApplicant(this.applicantId, payload)
      : this.service.createApplicant(payload);

    request.pipe(finalize(() => this.saving.set(false))).subscribe({
      next: (saved) => {
        const id = this.editMode() ? this.applicantId : saved.id_aspirante;
        this.success.set(this.editMode() ? 'Aspirante actualizado correctamente.' : 'Aspirante registrado correctamente.');
        void this.router.navigate(['/admin/applicants', id]);
      },
      error: (error) => this.error.set(apiErrorMessage(error, this.editMode() ? 'No fue posible actualizar el aspirante.' : 'No fue posible registrar el aspirante.')),
    });
  }

  invalid(controlName: string): boolean {
    const control = this.form.get(controlName);
    return Boolean(control?.invalid && (control.dirty || control.touched));
  }

  applicantName(applicant: ApplicantDetail): string {
    return applicantName(applicant);
  }

  initials(applicant: ApplicantDetail): string {
    return applicantName(applicant).split(/\s+/).slice(0, 2).map((part) => part[0]).join('').toUpperCase();
  }

  statusClass(status: string): string {
    return applicantStatusClass(status);
  }

  private patchForm(applicant: ApplicantDetail): void {
    this.form.patchValue({
      id_tipo_documento: applicant.id_tipo_documento ?? null,
      numero_documento: applicant.numero_documento,
      nombres: applicant.nombres,
      apellidos: applicant.apellidos,
      correo: applicant.correo ?? '',
      telefono: applicant.telefono ?? '',
      direccion: applicant.direccion ?? '',
      fecha_nacimiento: applicant.fecha_nacimiento ?? null,
      id_departamento_nacimiento: applicant.id_departamento_nacimiento ?? null,
      id_municipio_nacimiento: null,
      nacionalidad: applicant.nacionalidad ?? '',
      id_departamento_residencia: applicant.id_departamento_residencia ?? null,
      id_municipio_residencia: null,
      estado_civil: applicant.estado_civil ?? null,
      nivel_educativo: applicant.nivel_educativo ?? null,
      personas_a_cargo: applicant.personas_a_cargo ?? null,
      numero_hijos: applicant.numero_hijos ?? null,
      id_area_aspira: applicant.id_area_aspira ?? null,
      id_cargo_aspira: applicant.id_cargo_aspira ?? null,
      observaciones: applicant.observaciones ?? '',
    });
    this.loadBirthMunicipalities(applicant.id_departamento_nacimiento ?? null, applicant.id_municipio_nacimiento ?? null);
    this.loadResidenceMunicipalities(applicant.id_departamento_residencia ?? null, applicant.id_municipio_residencia ?? null);
  }

  private payload(): CreateApplicantRequest {
    const value = this.form.getRawValue();
    return {
      id_tipo_documento: toNullableNumber(value.id_tipo_documento),
      numero_documento: String(value.numero_documento ?? '').trim(),
      nombres: String(value.nombres ?? '').trim(),
      apellidos: String(value.apellidos ?? '').trim(),
      correo: blankToNull(value.correo),
      telefono: blankToNull(value.telefono),
      direccion: blankToNull(value.direccion),
      fecha_nacimiento: blankToNull(value.fecha_nacimiento),
      id_departamento_nacimiento: toNullableNumber(value.id_departamento_nacimiento),
      id_municipio_nacimiento: toNullableNumber(value.id_municipio_nacimiento),
      nacionalidad: blankToNull(value.nacionalidad),
      id_departamento_residencia: toNullableNumber(value.id_departamento_residencia),
      id_municipio_residencia: toNullableNumber(value.id_municipio_residencia),
      estado_civil: value.estado_civil ?? null,
      nivel_educativo: value.nivel_educativo ?? null,
      personas_a_cargo: this.toNullableNonNegativeNumber(value.personas_a_cargo),
      numero_hijos: this.toNullableNonNegativeNumber(value.numero_hijos),
      id_area_aspira: toNullableNumber(value.id_area_aspira),
      id_cargo_aspira: toNullableNumber(value.id_cargo_aspira),
      observaciones: blankToNull(value.observaciones),
    };
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
        this.form.controls.id_municipio_nacimiento.setValue(selectedMunicipalityId);
      },
      error: (error) => {
        if (request !== this.birthMunicipalityRequest) return;
        this.birthMunicipalities.set([]);
        this.catalogsError.set(apiErrorMessage(error, 'No fue posible cargar los municipios de nacimiento.'));
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
        this.form.controls.id_municipio_residencia.setValue(selectedMunicipalityId);
      },
      error: (error) => {
        if (request !== this.residenceMunicipalityRequest) return;
        this.residenceMunicipalities.set([]);
        this.catalogsError.set(apiErrorMessage(error, 'No fue posible cargar los municipios de residencia.'));
      },
    });
  }

  private toNullableNonNegativeNumber(value: unknown): number | null {
    if (value === '' || value == null) return null;
    const numberValue = Number(value);
    return Number.isFinite(numberValue) && numberValue >= 0 ? numberValue : null;
  }
}
