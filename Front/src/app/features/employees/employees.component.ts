import { Component, OnInit, inject, signal } from '@angular/core';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { FormsModule } from '@angular/forms';
import { catchError, finalize, forkJoin, map, of, switchMap } from 'rxjs';
import { Area, ContractType, DocumentType, Employee, EmployeePayload, EmployeeStatus, Position } from '../../core/models/api.models';
import { AuthService } from '../../core/services/auth.service';
import { CatalogService } from '../../core/services/catalog.service';
import { EmployeeService } from '../../core/services/employee.service';
import { apiErrorMessage } from '../../shared/api-error';
import { environment } from '../../../environments/environment';

const EMPLOYEE_STATUSES: EmployeeStatus[] = ['ACTIVO', 'RETIRADO', 'SUSPENDIDO', 'INCAPACITADO', 'EN_PROCESO_RETIRO'];

@Component({
  standalone: true,
  imports: [FormsModule, ReactiveFormsModule],
  template: `
    <div class="page-heading">
      <div>
        <p class="eyebrow">Talento humano</p>
        <h1>Empleados</h1>
        <p class="muted">Administra la informacion laboral del personal.</p>
      </div>
      <div class="heading-actions">
        @if (auth.hasAnyPermission(['EMPLEADOS_LISTAR', 'EMPLEADOS_VER'])) {
          <button class="btn secondary" type="button" (click)="exportEmployees()" [disabled]="isExporting()">
            {{ isExporting() ? 'Exportando...' : 'Exportar XLS' }}
          </button>
        }
        @if (auth.hasPermission('EMPLEADOS_CREAR')) {
          <button class="btn primary" type="button" (click)="openCreate()">Crear empleado</button>
        }
      </div>
    </div>

    <section class="panel">
      <form class="filters" (ngSubmit)="loadEmployees()">
        <label>Buscar
          <input name="texto_busqueda" [(ngModel)]="textoBusqueda" placeholder="Documento, nombres, apellidos o correo" />
        </label>
        <label>Estado
          <select name="estado_empleado" [(ngModel)]="estadoEmpleado">
            <option value="">Todos</option>
            @for (status of statusOptions; track status) { <option [value]="status">{{ status }}</option> }
          </select>
        </label>
        <label>ID area
          <input type="number" min="1" name="id_area" [(ngModel)]="idArea" placeholder="Opcional" />
        </label>
        <label>ID cargo
          <input type="number" min="1" name="id_cargo" [(ngModel)]="idCargo" placeholder="Opcional" />
        </label>
        <button class="btn secondary" type="submit" [disabled]="loading()">Filtrar</button>
      </form>

      @if (success()) { <div class="alert success" role="status">{{ success() }}</div> }
      @if (error()) { <div class="alert error" role="alert">{{ error() }}</div> }

      <div class="table-wrap">
        <table>
          <thead>
            <tr>
              <th>Foto</th>
              <th>Documento</th>
              <th>Nombre completo</th>
              <th>Correo</th>
              <th>Telefono</th>
              <th>Area</th>
              <th>Cargo</th>
              <th>Estado</th>
              <th>Acciones</th>
            </tr>
          </thead>
          <tbody>
            @for (employee of employees(); track employee.id_empleado) {
              <tr>
                <td>
                  @if (employee.foto_url) {
                    <img class="employee-photo" [src]="publicPhotoUrl(employee.foto_url)" [alt]="employee.nombre_completo || employee.nombres" />
                  } @else {
                    <div class="employee-photo placeholder">{{ employeeInitials(employee) }}</div>
                  }
                </td>
                <td><strong>{{ employee.numero_documento }}</strong><small class="muted">{{ employee.tipo_documento || ('Tipo ID ' + displayId(employee.id_tipo_documento)) }}</small></td>
                <td>{{ employee.nombre_completo || (employee.nombres + ' ' + employee.apellidos) }}</td>
                <td>{{ employee.correo || 'Sin correo' }}</td>
                <td>{{ employee.telefono || 'Sin telefono' }}</td>
                <td>{{ employee.area || displayId(employee.id_area) }}</td>
                <td>{{ employee.cargo || displayId(employee.id_cargo) }}</td>
                <td><span class="badge" [class.success]="employee.estado_empleado === 'ACTIVO'" [class.danger]="employee.estado_empleado === 'RETIRADO'">{{ employee.estado_empleado }}</span></td>
                <td>
                  <div class="row-actions">
                    @if (auth.hasPermission('EMPLEADOS_VER')) {
                      <button class="btn small ghost" type="button" (click)="openView(employee)">Ver</button>
                    }
                    @if (auth.hasPermission('EMPLEADOS_EDITAR')) {
                      <button class="btn small secondary" type="button" (click)="openEdit(employee)" [disabled]="loading()">Editar</button>
                    }
                    @if (auth.hasPermission('EMPLEADOS_CAMBIAR_ESTADO')) {
                      <button class="btn small tertiary" type="button" (click)="openStatus(employee)" [disabled]="loading()">Cambiar estado</button>
                    }
                    @if (auth.hasPermission('EMPLEADOS_ELIMINAR')) {
                      <button class="btn small danger-outline" type="button" (click)="deleteEmployee(employee)" [disabled]="loading()">Eliminar</button>
                    }
                  </div>
                </td>
              </tr>
            } @empty {
              <tr><td colspan="9" class="empty">{{ loading() ? 'Cargando empleados...' : 'No se encontraron empleados.' }}</td></tr>
            }
          </tbody>
        </table>
      </div>
    </section>

    @if (formOpen()) {
      <button class="drawer-backdrop" type="button" aria-label="Cerrar formulario" (click)="closeForm()"></button>
      <aside class="role-drawer" aria-label="Formulario de empleado" aria-modal="true">
        <header class="drawer-header">
          <div>
            <p class="eyebrow">{{ formMode() === 'create' ? 'Nuevo empleado' : 'Actualizar empleado' }}</p>
            <h2>{{ formMode() === 'create' ? 'Crear empleado' : 'Editar empleado' }}</h2>
          </div>
          <button class="icon-btn close-btn" type="button" (click)="closeForm()" aria-label="Cerrar">x</button>
        </header>
        <form class="form-grid" [formGroup]="employeeForm" (ngSubmit)="saveEmployee()">
          @if (formError()) { <div class="alert error form-wide">{{ formError() }}</div> }
          @if (documentTypesError()) {
            <div class="alert error form-wide">
              {{ documentTypesError() }}
              <button class="btn small ghost" type="button" (click)="loadDocumentTypes()" [disabled]="loadingDocumentTypes()">Reintentar</button>
            </div>
          }
          @if (catalogsError()) {
            <div class="alert error form-wide">
              {{ catalogsError() }}
              <button class="btn small ghost" type="button" (click)="loadEmployeeCatalogs()" [disabled]="loadingCatalogs()">Reintentar</button>
            </div>
          }
          @if (photoError()) { <div class="alert error form-wide">{{ photoError() }}</div> }
          <div class="form-wide photo-field">
            <div>
              <label>Foto del empleado
                <input type="file" accept="image/png,image/jpeg,image/jpg,image/webp" (change)="selectPhoto($event)" />
              </label>
              <small class="muted">JPG, PNG o WebP. Maximo 2 MB.</small>
            </div>
            @if (photoPreviewUrl()) {
              <img class="photo-preview" [src]="photoPreviewUrl()" alt="Vista previa de foto" />
            } @else {
              <div class="photo-preview placeholder">Sin foto</div>
            }
          </div>
          <label>Tipo de documento
            <select formControlName="id_tipo_documento" required>
              <option [ngValue]="null">{{ loadingDocumentTypes() ? 'Cargando...' : 'Seleccione...' }}</option>
              @for (item of documentTypes(); track item.id_tipo_documento) {
                <option [ngValue]="item.id_tipo_documento">{{ item.nombre }}</option>
              }
            </select>
            @if (invalid('id_tipo_documento')) { <small class="field-error">Selecciona un tipo de documento.</small> }
          </label>
          <label>Numero documento<input type="text" formControlName="numero_documento" required />@if (invalid('numero_documento')) { <small class="field-error">Campo requerido.</small> }</label>
          <label>Nombres<input type="text" formControlName="nombres" required />@if (invalid('nombres')) { <small class="field-error">Campo requerido.</small> }</label>
          <label>Apellidos<input type="text" formControlName="apellidos" required />@if (invalid('apellidos')) { <small class="field-error">Campo requerido.</small> }</label>
          <label>Correo<input type="email" formControlName="correo" />@if (invalid('correo')) { <small class="field-error">Correo invalido.</small> }</label>
          <label>Telefono<input type="text" formControlName="telefono" /></label>
          <label>Area
            <select formControlName="id_area">
              <option [ngValue]="null">{{ loadingCatalogs() ? 'Cargando...' : 'Seleccione...' }}</option>
              @for (area of areas(); track area.id_area) {
                <option [ngValue]="area.id_area">{{ area.nombre }}</option>
              }
            </select>
          </label>
          <label>Cargo
            <select formControlName="id_cargo">
              <option [ngValue]="null">{{ loadingCatalogs() ? 'Cargando...' : 'Seleccione...' }}</option>
              @for (position of positions(); track position.id_cargo) {
                <option [ngValue]="position.id_cargo">{{ position.nombre }}</option>
              }
            </select>
          </label>
          <label>Tipo de contrato
            <select formControlName="id_tipo_contrato">
              <option [ngValue]="null">{{ loadingCatalogs() ? 'Cargando...' : 'Seleccione...' }}</option>
              @for (contractType of contractTypes(); track contractType.id_tipo_contrato) {
                <option [ngValue]="contractType.id_tipo_contrato">{{ contractType.nombre }}</option>
              }
            </select>
          </label>
          <label>Fecha ingreso<input type="date" formControlName="fecha_ingreso" /></label>
          <label>Fecha retiro<input type="date" formControlName="fecha_retiro" /></label>
          <label>Estado empleado
            <select formControlName="estado_empleado" required>
              @for (status of statusOptions; track status) { <option [value]="status">{{ status }}</option> }
            </select>
          </label>
          <label class="form-wide">Observaciones<textarea rows="4" formControlName="observaciones"></textarea></label>
          <div class="form-actions form-wide">
            <button class="btn secondary" type="button" (click)="closeForm()" [disabled]="formLoading()">Cancelar</button>
            <button class="btn primary" type="submit" [disabled]="employeeForm.invalid || formLoading()">{{ formLoading() ? 'Guardando...' : 'Guardar' }}</button>
          </div>
        </form>
      </aside>
    }

    @if (viewEmployee(); as current) {
      <button class="drawer-backdrop" type="button" aria-label="Cerrar detalle" (click)="closeView()"></button>
      <aside class="role-drawer" aria-label="Detalle de empleado" aria-modal="true">
        <header class="drawer-header">
          <div><p class="eyebrow">Solo lectura</p><h2>Detalle de empleado</h2></div>
          <button class="icon-btn close-btn" type="button" (click)="closeView()" aria-label="Cerrar">x</button>
        </header>
        @if (viewError()) { <div class="alert error">{{ viewError() }}</div> }
        <section class="drawer-user">
          @if (current.foto_url) {
            <img class="avatar large employee-photo large" [src]="publicPhotoUrl(current.foto_url)" [alt]="current.nombre_completo || current.nombres" />
          } @else {
            <div class="avatar large">{{ current.nombres[0].toUpperCase() }}</div>
          }
          <div>
            <strong>{{ current.nombre_completo || (current.nombres + ' ' + current.apellidos) }}</strong>
            <small>{{ current.numero_documento }}</small>
            <span class="badge" [class.success]="current.estado_empleado === 'ACTIVO'">{{ current.estado_empleado }}</span>
          </div>
        </section>
        <section class="drawer-section">
          <h3>Datos personales</h3>
          <dl>
            <dt>Tipo documento</dt><dd>{{ current.tipo_documento || displayId(current.id_tipo_documento) }}</dd>
            <dt>Documento</dt><dd>{{ current.numero_documento }}</dd>
            <dt>Correo</dt><dd>{{ current.correo || 'Sin correo' }}</dd>
            <dt>Telefono</dt><dd>{{ current.telefono || 'Sin telefono' }}</dd>
          </dl>
        </section>
        <section class="drawer-section">
          <h3>Datos laborales</h3>
          <dl>
            <dt>Area</dt><dd>{{ current.area || displayId(current.id_area) }}</dd>
            <dt>Cargo</dt><dd>{{ current.cargo || displayId(current.id_cargo) }}</dd>
            <dt>Contrato</dt><dd>{{ current.tipo_contrato || displayId(current.id_tipo_contrato) }}</dd>
            <dt>Ingreso</dt><dd>{{ current.fecha_ingreso || 'Sin fecha' }}</dd>
            <dt>Retiro</dt><dd>{{ current.fecha_retiro || 'Sin fecha' }}</dd>
          </dl>
        </section>
        <section class="drawer-section">
          <h3>Observaciones</h3>
          <p class="muted">{{ current.observaciones || 'Sin observaciones.' }}</p>
        </section>
      </aside>
    }

    @if (statusEmployee(); as employee) {
      <button class="drawer-backdrop" type="button" aria-label="Cerrar cambio de estado" (click)="closeStatus()"></button>
      <aside class="role-drawer" aria-label="Cambiar estado laboral" aria-modal="true">
        <header class="drawer-header">
          <div><p class="eyebrow">Estado laboral</p><h2>Cambiar estado</h2></div>
          <button class="icon-btn close-btn" type="button" (click)="closeStatus()" aria-label="Cerrar">x</button>
        </header>
        <div class="drawer-user">
          <div class="avatar large">{{ employee.nombres[0].toUpperCase() }}</div>
          <div><strong>{{ employee.nombre_completo || (employee.nombres + ' ' + employee.apellidos) }}</strong><small>{{ employee.numero_documento }}</small></div>
        </div>
        @if (statusError()) { <div class="alert error">{{ statusError() }}</div> }
        <form class="narrow-form" [formGroup]="statusForm" (ngSubmit)="saveStatus()">
          <label>Estado empleado
            <select formControlName="estado_empleado">
              @for (status of statusOptions; track status) { <option [value]="status">{{ status }}</option> }
            </select>
          </label>
          <label>Fecha retiro<input type="date" formControlName="fecha_retiro" /></label>
          <div class="form-actions">
            <button class="btn secondary" type="button" (click)="closeStatus()" [disabled]="statusLoading()">Cancelar</button>
            <button class="btn primary" type="submit" [disabled]="statusForm.invalid || statusLoading()">{{ statusLoading() ? 'Guardando...' : 'Actualizar estado' }}</button>
          </div>
        </form>
      </aside>
    }
  `,
  styles: [`
    .heading-actions {
      display: flex;
      flex-wrap: wrap;
      justify-content: flex-end;
      gap: .75rem;
    }

    @media (max-width: 640px) {
      .heading-actions {
        width: 100%;
        justify-content: flex-start;
      }
    }
  `],
})
export class EmployeesComponent implements OnInit {
  readonly auth = inject(AuthService);
  private readonly service = inject(EmployeeService);
  private readonly catalogService = inject(CatalogService);
  private readonly fb = inject(FormBuilder);

  readonly statusOptions = EMPLOYEE_STATUSES;
  readonly documentTypes = signal<DocumentType[]>([]);
  readonly loadingDocumentTypes = signal(false);
  readonly documentTypesError = signal('');
  readonly areas = signal<Area[]>([]);
  readonly positions = signal<Position[]>([]);
  readonly contractTypes = signal<ContractType[]>([]);
  readonly loadingCatalogs = signal(false);
  readonly catalogsError = signal('');
  readonly employees = signal<Employee[]>([]);
  readonly loading = signal(false);
  readonly isExporting = signal(false);
  readonly error = signal('');
  readonly success = signal('');
  readonly formOpen = signal(false);
  readonly formMode = signal<'create' | 'edit'>('create');
  readonly selectedEmployeeId = signal<number | null>(null);
  readonly formLoading = signal(false);
  readonly formError = signal('');
  readonly selectedPhoto = signal<File | null>(null);
  readonly photoPreviewUrl = signal('');
  readonly photoError = signal('');
  readonly viewEmployee = signal<Employee | null>(null);
  readonly viewError = signal('');
  readonly statusEmployee = signal<Employee | null>(null);
  readonly statusLoading = signal(false);
  readonly statusError = signal('');

  textoBusqueda = '';
  estadoEmpleado: EmployeeStatus | '' = '';
  idArea: number | null = null;
  idCargo: number | null = null;

  readonly employeeForm: FormGroup = this.fb.group({
    id_tipo_documento: [null, Validators.required],
    numero_documento: ['', [Validators.required, Validators.maxLength(50)]],
    nombres: ['', [Validators.required, Validators.maxLength(150)]],
    apellidos: ['', [Validators.required, Validators.maxLength(150)]],
    correo: ['', [Validators.email, Validators.maxLength(150)]],
    telefono: ['', [Validators.maxLength(50)]],
    foto_url: [null],
    id_area: [null],
    id_cargo: [null],
    id_tipo_contrato: [null],
    fecha_ingreso: [null],
    fecha_retiro: [null],
    estado_empleado: ['ACTIVO', Validators.required],
    observaciones: [''],
  });

  readonly statusForm: FormGroup = this.fb.group({
    estado_empleado: ['ACTIVO', Validators.required],
    fecha_retiro: [null],
  });

  ngOnInit(): void {
    this.loadDocumentTypes();
    this.loadEmployeeCatalogs();
    this.loadEmployees();
  }

  loadDocumentTypes(): void {
    this.loadingDocumentTypes.set(true);
    this.documentTypesError.set('');
    this.catalogService.getDocumentTypes(true).pipe(finalize(() => this.loadingDocumentTypes.set(false))).subscribe({
      next: (documentTypes) => this.documentTypes.set(documentTypes),
      error: (error) => this.documentTypesError.set(apiErrorMessage(error, 'No fue posible cargar los tipos de documento.')),
    });
  }

  loadEmployeeCatalogs(): void {
    this.loadingCatalogs.set(true);
    this.catalogsError.set('');
    forkJoin({
      areas: this.catalogService.getAreas(true),
      positions: this.catalogService.getPositions(true),
      contractTypes: this.catalogService.getContractTypes(true),
    }).pipe(finalize(() => this.loadingCatalogs.set(false))).subscribe({
      next: ({ areas, positions, contractTypes }) => {
        this.areas.set(areas);
        this.positions.set(positions);
        this.contractTypes.set(contractTypes);
      },
      error: (error) => this.catalogsError.set(apiErrorMessage(error, 'No fue posible cargar areas, cargos o tipos de contrato.')),
    });
  }

  loadEmployees(): void {
    this.loading.set(true);
    this.error.set('');
    this.service.listEmployees({
      texto_busqueda: this.textoBusqueda.trim(),
      estado_empleado: this.estadoEmpleado,
      id_area: this.toNullableNumber(this.idArea),
      id_cargo: this.toNullableNumber(this.idCargo),
    }).pipe(finalize(() => this.loading.set(false))).subscribe({
      next: (employees) => this.employees.set(employees),
      error: (error) => this.error.set(apiErrorMessage(error, 'No fue posible cargar los empleados.')),
    });
  }

  exportEmployees(): void {
    if (this.isExporting()) {
      return;
    }

    this.isExporting.set(true);
    this.error.set('');
    this.service.exportEmployees().pipe(
      finalize(() => this.isExporting.set(false)),
    ).subscribe({
      next: (response) => {
        if (!response.body) {
          this.error.set('No fue posible exportar la informacion de empleados.');
          return;
        }

        const filename = employeeExportFilename(response.headers.get('Content-Disposition'));
        this.downloadBlob(response.body, filename);
      },
      error: () => this.error.set('No fue posible exportar la informacion de empleados.'),
    });
  }

  openCreate(): void {
    this.formMode.set('create');
    this.selectedEmployeeId.set(null);
    this.formError.set('');
    this.resetPhotoSelection();
    this.employeeForm.reset({
      id_tipo_documento: null,
      numero_documento: '',
      nombres: '',
      apellidos: '',
      correo: '',
      telefono: '',
      foto_url: null,
      id_area: null,
      id_cargo: null,
      id_tipo_contrato: null,
      fecha_ingreso: null,
      fecha_retiro: null,
      estado_empleado: 'ACTIVO',
      observaciones: '',
    });
    this.formOpen.set(true);
  }

  openEdit(employee: Employee): void {
    this.formMode.set('edit');
    this.selectedEmployeeId.set(employee.id_empleado);
    this.formError.set('');
    this.formLoading.set(true);
    this.service.getEmployee(employee.id_empleado).pipe(finalize(() => this.formLoading.set(false))).subscribe({
      next: (loaded) => {
        this.patchEmployeeForm(loaded);
        this.formOpen.set(true);
      },
      error: (error) => this.error.set(apiErrorMessage(error, 'No fue posible cargar el empleado.')),
    });
  }

  closeForm(): void {
    if (this.formLoading()) return;
    this.formOpen.set(false);
    this.formError.set('');
    this.resetPhotoSelection();
  }

  saveEmployee(): void {
    if (this.employeeForm.invalid) {
      this.employeeForm.markAllAsTouched();
      return;
    }
    this.formLoading.set(true);
    this.formError.set('');
    this.success.set('');
    const payload = this.employeePayload();
    const createdMessage = this.formMode() === 'create' ? 'Empleado creado exitosamente.' : 'Empleado actualizado exitosamente.';
    const photoFailedMessage = this.formMode() === 'create'
      ? 'Empleado creado, pero no fue posible cargar la foto.'
      : 'Empleado actualizado, pero no fue posible cargar la foto.';
    const request = this.formMode() === 'create'
      ? this.service.createEmployee(payload)
      : this.service.updateEmployee(this.selectedEmployeeId()!, payload);

    request.pipe(
      switchMap((employee) => {
        const photo = this.selectedPhoto();
        if (!photo) {
          return of({ photoFailed: false });
        }

        return this.service.uploadPhoto(employee.id_empleado, photo).pipe(
          map(() => ({ photoFailed: false })),
          catchError(() => of({ photoFailed: true })),
        );
      }),
      finalize(() => this.formLoading.set(false)),
    ).subscribe({
      next: ({ photoFailed }) => {
        this.success.set(photoFailed ? photoFailedMessage : createdMessage);
        this.resetPhotoSelection();
        this.closeForm();
        this.loadEmployees();
      },
      error: (error) => this.formError.set(apiErrorMessage(error, 'No fue posible guardar el empleado.')),
    });
  }

  openView(employee: Employee): void {
    this.viewError.set('');
    this.service.getEmployee(employee.id_empleado).subscribe({
      next: (loaded) => this.viewEmployee.set(loaded),
      error: (error) => this.viewError.set(apiErrorMessage(error, 'No fue posible cargar el detalle.')),
    });
  }

  closeView(): void {
    this.viewEmployee.set(null);
    this.viewError.set('');
  }

  openStatus(employee: Employee): void {
    this.statusError.set('');
    this.statusEmployee.set(employee);
    this.statusForm.reset({
      estado_empleado: employee.estado_empleado,
      fecha_retiro: employee.fecha_retiro || null,
    });
  }

  closeStatus(): void {
    if (this.statusLoading()) return;
    this.statusEmployee.set(null);
    this.statusError.set('');
  }

  saveStatus(): void {
    const employee = this.statusEmployee();
    if (!employee || this.statusForm.invalid) return;
    const status = this.statusForm.value.estado_empleado as EmployeeStatus;
    this.statusLoading.set(true);
    this.statusError.set('');
    this.success.set('');
    this.service.changeEmployeeStatus(employee.id_empleado, {
      estado_empleado: status,
      fecha_retiro: this.blankToNull(this.statusForm.value.fecha_retiro),
    }).pipe(finalize(() => this.statusLoading.set(false))).subscribe({
      next: () => {
        this.success.set('Estado laboral actualizado exitosamente.');
        this.closeStatus();
        this.loadEmployees();
      },
      error: (error) => this.statusError.set(apiErrorMessage(error, 'No fue posible cambiar el estado.')),
    });
  }

  deleteEmployee(employee: Employee): void {
    if (!confirm('Esta accion eliminara logicamente el empleado. No se borrara su historial. ¿Deseas continuar?')) {
      return;
    }
    this.loading.set(true);
    this.error.set('');
    this.success.set('');
    this.service.deleteEmployee(employee.id_empleado).pipe(finalize(() => this.loading.set(false))).subscribe({
      next: () => {
        this.success.set('Empleado eliminado exitosamente.');
        this.loadEmployees();
      },
      error: (error) => this.error.set(apiErrorMessage(error, 'No fue posible eliminar el empleado.')),
    });
  }

  invalid(controlName: string): boolean {
    const control = this.employeeForm.get(controlName);
    return Boolean(control?.invalid && (control.dirty || control.touched));
  }

  displayId(value: number | null | undefined): string {
    return value ? `ID ${value}` : 'Sin dato';
  }

  selectPhoto(event: Event): void {
    const input = event.target as HTMLInputElement;
    const file = input.files?.[0] ?? null;
    this.photoError.set('');
    this.selectedPhoto.set(null);

    if (!file) {
      return;
    }

    const allowedTypes = new Set(['image/jpeg', 'image/png', 'image/webp']);
    if (!allowedTypes.has(file.type)) {
      this.photoPreviewUrl.set(this.currentEmployeePhotoPreview());
      this.photoError.set('La foto debe ser de tipo jpg, jpeg, png o webp.');
      input.value = '';
      return;
    }

    if (file.size > 2 * 1024 * 1024) {
      this.photoPreviewUrl.set(this.currentEmployeePhotoPreview());
      this.photoError.set('La foto no debe superar 2 MB.');
      input.value = '';
      return;
    }

    this.selectedPhoto.set(file);
    const reader = new FileReader();
    reader.onload = () => this.photoPreviewUrl.set(String(reader.result ?? ''));
    reader.readAsDataURL(file);
  }

  publicPhotoUrl(photoUrl: string | null | undefined): string {
    if (!photoUrl) {
      return '';
    }

    if (/^https?:\/\//i.test(photoUrl)) {
      return photoUrl;
    }

    const baseUrl = environment.backendUrl.replace(/\/$/, '');
    const path = photoUrl.startsWith('/') ? photoUrl : `/${photoUrl}`;

    return `${baseUrl}${path}`;
  }

  employeeInitials(employee: Employee): string {
    const first = employee.nombres?.[0] ?? employee.nombre_completo?.[0] ?? '?';
    const second = employee.apellidos?.[0] ?? '';

    return `${first}${second}`.toUpperCase();
  }

  private patchEmployeeForm(employee: Employee): void {
    this.employeeForm.patchValue({
      id_tipo_documento: employee.id_tipo_documento ?? null,
      numero_documento: employee.numero_documento,
      nombres: employee.nombres,
      apellidos: employee.apellidos,
      correo: employee.correo ?? '',
      telefono: employee.telefono ?? '',
      foto_url: employee.foto_url ?? null,
      id_area: employee.id_area ?? null,
      id_cargo: employee.id_cargo ?? null,
      id_tipo_contrato: employee.id_tipo_contrato ?? null,
      fecha_ingreso: employee.fecha_ingreso ?? null,
      fecha_retiro: employee.fecha_retiro ?? null,
      estado_empleado: employee.estado_empleado,
      observaciones: employee.observaciones ?? '',
    });
    this.resetPhotoSelection(this.publicPhotoUrl(employee.foto_url));
  }

  private employeePayload(): EmployeePayload {
    const value = this.employeeForm.value;
    return {
      id_tipo_documento: this.toNullableNumber(value.id_tipo_documento),
      numero_documento: String(value.numero_documento ?? '').trim(),
      nombres: String(value.nombres ?? '').trim(),
      apellidos: String(value.apellidos ?? '').trim(),
      correo: this.blankToNull(value.correo),
      telefono: this.blankToNull(value.telefono),
      foto_url: this.blankToNull(value.foto_url),
      id_area: this.toNullableNumber(value.id_area),
      id_cargo: this.toNullableNumber(value.id_cargo),
      id_tipo_contrato: this.toNullableNumber(value.id_tipo_contrato),
      fecha_ingreso: this.blankToNull(value.fecha_ingreso),
      fecha_retiro: this.blankToNull(value.fecha_retiro),
      estado_empleado: value.estado_empleado as EmployeeStatus,
      observaciones: this.blankToNull(value.observaciones),
    };
  }

  private toNullableNumber(value: unknown): number | null {
    if (value === '' || value == null) return null;
    const numberValue = Number(value);
    return Number.isFinite(numberValue) && numberValue > 0 ? numberValue : null;
  }

  private blankToNull(value: unknown): string | null {
    const text = String(value ?? '').trim();
    return text === '' ? null : text;
  }

  private resetPhotoSelection(previewUrl = ''): void {
    this.selectedPhoto.set(null);
    this.photoPreviewUrl.set(previewUrl);
    this.photoError.set('');
  }

  private currentEmployeePhotoPreview(): string {
    const currentUrl = this.employeeForm.value.foto_url as string | null | undefined;

    return this.publicPhotoUrl(currentUrl);
  }

  private downloadBlob(blob: Blob, filename: string): void {
    const objectUrl = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = objectUrl;
    link.download = filename;
    link.style.display = 'none';
    document.body.appendChild(link);

    try {
      link.click();
    } finally {
      link.remove();
      URL.revokeObjectURL(objectUrl);
    }
  }
}

export function employeeExportFilename(contentDisposition: string | null): string {
  const fallback = 'empleados_activos.xlsx';
  if (!contentDisposition) {
    return fallback;
  }

  const encodedMatch = contentDisposition.match(/filename\*\s*=\s*(?:UTF-8'')?([^;]+)/i);
  const regularMatch = contentDisposition.match(/filename\s*=\s*(?:"([^"]+)"|([^;]+))/i);
  const rawFilename = encodedMatch?.[1] ?? regularMatch?.[1] ?? regularMatch?.[2];
  if (!rawFilename) {
    return fallback;
  }

  let decodedFilename: string;
  try {
    decodedFilename = decodeURIComponent(rawFilename.trim().replace(/^["']|["']$/g, ''));
  } catch {
    decodedFilename = rawFilename.trim().replace(/^["']|["']$/g, '');
  }

  const safeFilename = decodedFilename
    .split(/[\\/]/)
    .pop()
    ?.replace(/[\u0000-\u001F\u007F]/g, '')
    .trim();

  return safeFilename || fallback;
}
