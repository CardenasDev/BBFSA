import { Component, computed, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { finalize } from 'rxjs';
import { CreateUserRequest, Employee, UserType } from '../../core/models/api.models';
import { EmployeeService } from '../../core/services/employee.service';
import { UserService } from '../../core/services/user.service';
import { apiErrorMessage } from '../../shared/api-error';

@Component({ standalone: true, imports: [ReactiveFormsModule, RouterLink], template: `
  <div class="page-heading"><div><p class="eyebrow">Usuarios</p><h1>Crear usuario</h1><p class="muted">Registra una nueva cuenta de acceso.</p></div><a class="btn ghost" routerLink="/admin/users">Volver</a></div>
  <form class="panel form-grid" [formGroup]="form" (ngSubmit)="submit()">
    @if (error()) { <div class="alert error form-wide">{{ error() }}</div> }
    <label>Tipo de usuario<select formControlName="tipo_usuario"><option>EMPLEADO</option><option>PERSONAL_AUTORIZADO</option><option>ADMIN</option></select></label>
    <label>Tipo de autenticacion<select formControlName="tipo_autenticacion"><option>LOCAL</option><option>DOMINIO_EMPRESA</option></select></label>
    <div class="form-wide employee-combobox">
      <label>Empleado @if (form.controls.tipo_usuario.value !== 'EMPLEADO') { <span class="optional">Opcional</span> }
        <input type="search" [value]="employeeSearch()" (input)="updateEmployeeSearch($event)" (focus)="employeeDropdownOpen.set(true)"
          placeholder="Busca por nombre o documento" autocomplete="off" [disabled]="employeeLoading()" />
      </label>
      @if (employeeDropdownOpen() && !employeeLoading()) {
        <div class="employee-options" role="listbox" aria-label="Empleados disponibles">
          @for (item of filteredEmployees(); track item.id_empleado) {
            <button type="button" class="employee-option" role="option" [attr.aria-selected]="employee()?.id_empleado === item.id_empleado"
              (click)="selectEmployee(item)">
              <strong>{{ employeeName(item) }}</strong><span>{{ item.numero_documento }}</span>
            </button>
          } @empty {
            <p class="employee-option-empty">No se encontraron empleados.</p>
          }
        </div>
      }
    </div>
    @if (invalid('numero_documento_empleado')) { <small class="field-error form-wide">Selecciona un empleado.</small> }
    @if (employeeError()) { <div class="alert error form-wide">{{ employeeError() }}</div> }
    @if (employee(); as currentEmployee) {
      <article class="employee-summary form-wide">
        <div><small>Nombre completo</small><strong>{{ currentEmployee.nombre_completo || (currentEmployee.nombres + ' ' + currentEmployee.apellidos) }}</strong></div>
        <div><small>Documento</small><span>{{ currentEmployee.tipo_documento || 'Documento' }} {{ currentEmployee.numero_documento }}</span></div>
        <div><small>Correo</small><span>{{ currentEmployee.correo || 'Sin correo' }}</span></div>
        <div><small>Area</small><span>{{ currentEmployee.area || 'Sin area' }}</span></div>
        <div><small>Cargo</small><span>{{ currentEmployee.cargo || 'Sin cargo' }}</span></div>
        <div><small>Estado</small><span class="badge" [class.success]="currentEmployee.estado_empleado === 'ACTIVO'">{{ currentEmployee.estado_empleado }}</span></div>
      </article>
    }
    <label>Nombre de usuario<input formControlName="nombre_usuario" />@if (invalid('nombre_usuario')) { <small class="field-error">Campo obligatorio.</small> }</label>
    <label>Correo<input type="email" formControlName="correo" />@if (invalid('correo')) { <small class="field-error">Ingresa un correo valido.</small> }</label>
    <label>Contrasena<input type="password" formControlName="password" autocomplete="new-password" />@if (invalid('password')) { <small class="field-error">Minimo 8 caracteres, letras y numeros.</small> }</label>
    <label class="check"><input type="checkbox" formControlName="requiere_cambio_password" /> Solicitar cambio de contrasena en el proximo acceso</label>
    <label class="check"><input type="checkbox" formControlName="correo_verificado" /> Correo verificado</label>
    <div class="form-actions form-wide"><a class="btn ghost" routerLink="/admin/users">Cancelar</a><button class="btn primary" type="submit" [disabled]="loading()">{{ loading() ? 'Creando...' : 'Crear usuario' }}</button></div>
  </form>`, })
export class UserCreateComponent {
  private readonly fb = inject(FormBuilder);
  private readonly service = inject(UserService);
  private readonly employeeService = inject(EmployeeService);
  private readonly router = inject(Router);

  readonly loading = signal(false);
  readonly employeeLoading = signal(false);
  readonly error = signal('');
  readonly employeeError = signal('');
  readonly employee = signal<Employee | null>(null);
  readonly employees = signal<Employee[]>([]);
  readonly employeeSearch = signal('');
  readonly employeeDropdownOpen = signal(false);
  readonly filteredEmployees = computed(() => {
    const term = this.normalize(this.employeeSearch());
    const sorted = [...this.employees()].sort((a, b) => this.employeeName(a).localeCompare(
      this.employeeName(b), 'es', { sensitivity: 'base' },
    ));
    if (!term) return sorted;

    return sorted.filter((item) => this.normalize(
      `${this.employeeName(item)} ${item.numero_documento}`,
    ).includes(term));
  });
  readonly form = this.fb.nonNullable.group({
    numero_documento_empleado: [''],
    nombre_usuario: ['', Validators.required],
    correo: ['', [Validators.required, Validators.email]],
    password: ['', [Validators.required, Validators.minLength(8), Validators.pattern(/^(?=.*[A-Za-z])(?=.*\d).+$/)]],
    tipo_usuario: this.fb.nonNullable.control<UserType>('EMPLEADO'),
    tipo_autenticacion: this.fb.nonNullable.control<'LOCAL' | 'DOMINIO_EMPRESA'>('LOCAL'),
    requiere_cambio_password: true,
    correo_verificado: false,
  });

  constructor() {
    this.applyDocumentValidator();
    this.form.controls.tipo_usuario.valueChanges.subscribe(() => this.applyDocumentValidator());
    this.loadEmployees();
  }

  invalid(name: 'numero_documento_empleado' | 'nombre_usuario' | 'correo' | 'password'): boolean {
    const control = this.form.controls[name];
    return control.touched && control.invalid;
  }

  updateEmployeeSearch(event: Event): void {
    this.employeeSearch.set((event.target as HTMLInputElement).value);
    this.employeeDropdownOpen.set(true);
    this.employee.set(null);
    this.form.controls.numero_documento_empleado.setValue('');
    this.employeeError.set('');
  }

  selectEmployee(selected: Employee): void {
    this.employee.set(selected);
    this.employeeError.set('');
    this.employeeSearch.set(`${this.employeeName(selected)} — ${selected.numero_documento}`);
    this.employeeDropdownOpen.set(false);
    this.form.controls.numero_documento_empleado.setValue(selected.numero_documento);
    this.form.controls.correo.setValue(selected.correo?.trim() ?? '');
    this.form.controls.numero_documento_empleado.markAsTouched();
  }

  employeeName(employee: Employee): string {
    return employee.nombre_completo || `${employee.nombres} ${employee.apellidos}`.trim();
  }

  submit(): void {
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }

    if (this.form.controls.tipo_usuario.value === 'EMPLEADO' && !this.employee()) {
      this.employeeError.set('Busca y valida el empleado antes de crear el usuario.');
      return;
    }

    const raw = this.form.getRawValue();
    const payload: CreateUserRequest = {
      ...raw,
      numero_documento_empleado: raw.numero_documento_empleado.trim() || undefined,
    };

    this.loading.set(true);
    this.error.set('');
    this.service.createUser(payload).pipe(finalize(() => this.loading.set(false))).subscribe({
      next: (user) => void this.router.navigate(['/admin/users', user.id_usuario]),
      error: (error) => this.error.set(apiErrorMessage(error)),
    });
  }

  private applyDocumentValidator(): void {
    const control = this.form.controls.numero_documento_empleado;
    control.setValidators(this.form.controls.tipo_usuario.value === 'EMPLEADO' ? [Validators.required] : []);
    control.updateValueAndValidity({ emitEvent: false });
  }

  private loadEmployees(): void {
    this.employeeLoading.set(true);
    this.employeeError.set('');
    this.employeeService.listEmployees({ estado_empleado: 'ACTIVO' })
      .pipe(finalize(() => this.employeeLoading.set(false)))
      .subscribe({
        next: (employees) => this.employees.set(employees),
        error: (error) => this.employeeError.set(apiErrorMessage(error, 'No fue posible cargar los empleados.')),
      });
  }

  private normalize(value: string): string {
    return value.normalize('NFD').replace(/[\u0300-\u036f]/g, '').trim().toLowerCase();
  }
}
