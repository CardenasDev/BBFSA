import { Component, OnInit, computed, inject, signal } from '@angular/core';
import { FormsModule, ReactiveFormsModule, FormBuilder, FormGroup, Validators } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { finalize, forkJoin, of } from 'rxjs';
import { Employee, Permission, Role, User, UserStatus, UserType } from '../../core/models/api.models';
import { AuthService } from '../../core/services/auth.service';
import { EmployeeService } from '../../core/services/employee.service';
import { RoleService } from '../../core/services/catalog.service';
import { UserService } from '../../core/services/user.service';
import { apiErrorMessage } from '../../shared/api-error';

@Component({
  standalone: true,
  imports: [FormsModule, ReactiveFormsModule, RouterLink],
  template: `
    <div class="page-heading">
      <div><p class="eyebrow">Seguridad y acceso</p><h1>Usuarios</h1><p class="muted">Administra las cuentas de acceso al sistema.</p></div>
      @if (auth.hasPermission('USUARIOS_CREAR')) { <a class="btn primary" routerLink="/admin/users/create">+ Crear usuario</a> }
    </div>
    <section class="panel">
      <form class="filters" (ngSubmit)="load()">
        <label>Buscar<input name="buscar" [(ngModel)]="buscar" placeholder="Nombre, usuario o correo" /></label>
        <label>Estado<select name="estado" [(ngModel)]="estado"><option value="">Todos</option><option>ACTIVO</option><option>INACTIVO</option><option>BLOQUEADO</option></select></label>
        <label>Tipo<select name="tipo" [(ngModel)]="tipo"><option value="">Todos</option><option>EMPLEADO</option><option>PERSONAL_AUTORIZADO</option><option>ADMIN</option></select></label>
        <button class="btn secondary" type="submit">Filtrar</button>
      </form>
      @if (error()) { <div class="alert error" role="alert">{{ error() }}</div> }
      <div class="table-wrap"><table><thead><tr><th>Usuario</th><th>Tipo</th><th>Autenticación</th><th>Estado</th><th>Acciones</th></tr></thead><tbody>
        @for (user of users(); track user.id_usuario) {
          <tr>
            <td><a class="user-link" [routerLink]="['/admin/users', user.id_usuario]"><strong>{{ user.nombre_usuario }}</strong><small>{{ user.correo }}</small></a></td>
            <td>{{ user.tipo_usuario }}</td><td>{{ user.tipo_autenticacion }}</td>
            <td><span class="badge" [class.success]="user.estado === 'ACTIVO'" [class.danger]="user.estado === 'BLOQUEADO'">{{ user.estado }}</span></td>
            <td><div class="row-actions">
              <a class="btn small ghost" [routerLink]="['/admin/users', user.id_usuario]">Ver</a>
              @if (auth.hasPermission('USUARIOS_EDITAR')) { <button class="btn small secondary" type="button" (click)="openEdit(user)">Editar</button> }
              @if (canOpenRoles()) { <button class="btn small secondary" type="button" (click)="openRoles(user)">Roles</button> }
              @if (auth.hasPermission('USUARIOS_CAMBIAR_ESTADO')) {
                <button class="btn small warning-outline" type="button" (click)="inactivateUser(user)" [disabled]="loading()">{{ user.estado === 'ACTIVO' ? 'Inactivar' : 'Activar' }}</button>
                <button class="btn small danger-outline" type="button" (click)="deleteAccess(user)" [disabled]="loading()">Eliminar acceso</button>
              }
            </div></td>
          </tr>
        } @empty { <tr><td colspan="5" class="empty">{{ loading() ? 'Cargando usuarios…' : 'No se encontraron usuarios.' }}</td></tr> }
      </tbody></table></div>
    </section>

    @if (editingUser(); as editUser) {
      <button class="drawer-backdrop" type="button" aria-label="Cerrar edición" (click)="closeEdit()"></button>
      <aside class="role-drawer" aria-label="Editar usuario" aria-modal="true">
        <header class="drawer-header"><div><p class="eyebrow">Actualizar datos</p><h2>Editar usuario</h2></div><button class="icon-btn close-btn" type="button" (click)="closeEdit()" aria-label="Cerrar">×</button></header>
        <form class="drawer-form" [formGroup]="editForm" (ngSubmit)="saveUser()">
          @if (editError()) { <div class="alert error">{{ editError() }}</div> }
          @if (editUser.id_empleado && !editEmployee()) { <p class="muted">Este usuario ya tiene un empleado asociado. Busca un documento solo si necesitas cambiar la asociacion.</p> }
          <div class="employee-lookup">
            <label>Documento del empleado @if (editForm.get('tipo_usuario')?.value !== 'EMPLEADO') { <span class="optional">Opcional</span> }<input type="text" formControlName="numero_documento_empleado" /></label>
            <button class="btn secondary" type="button" (click)="searchEditEmployee()" [disabled]="editEmployeeLoading()">{{ editEmployeeLoading() ? 'Buscando...' : 'Buscar empleado' }}</button>
          </div>
          @if (editEmployeeError()) { <div class="alert error">{{ editEmployeeError() }}</div> }
          @if (editEmployee(); as currentEmployee) {
            <article class="employee-summary compact">
              <div><small>Nombre completo</small><strong>{{ currentEmployee.nombre_completo || (currentEmployee.nombres + ' ' + currentEmployee.apellidos) }}</strong></div>
              <div><small>Documento</small><span>{{ currentEmployee.tipo_documento || 'Documento' }} {{ currentEmployee.numero_documento }}</span></div>
              <div><small>Correo</small><span>{{ currentEmployee.correo || 'Sin correo' }}</span></div>
              <div><small>Area</small><span>{{ currentEmployee.area || 'Sin area' }}</span></div>
              <div><small>Cargo</small><span>{{ currentEmployee.cargo || 'Sin cargo' }}</span></div>
              <div><small>Estado</small><span class="badge" [class.success]="currentEmployee.estado_empleado === 'ACTIVO'">{{ currentEmployee.estado_empleado }}</span></div>
            </article>
          }
          <label>Nombre de usuario<input type="text" formControlName="nombre_usuario" required />@if (editForm.get('nombre_usuario')?.invalid) { <small class="field-error">Campo requerido.</small> }</label>
          <label>Correo<input type="email" formControlName="correo" required />@if (editForm.get('correo')?.invalid) { <small class="field-error">Correo válido requerido.</small> }</label>
          <label>Tipo de usuario<select formControlName="tipo_usuario"><option>EMPLEADO</option><option>PERSONAL_AUTORIZADO</option><option>ADMIN</option></select></label>
          <label>Autenticación<select formControlName="tipo_autenticacion"><option>LOCAL</option><option>DOMINIO_EMPRESA</option></select></label>
          <label class="check"><input type="checkbox" formControlName="requiere_cambio_password" /> Solicitar cambio de contraseña en próximo acceso</label>
          <label class="check"><input type="checkbox" formControlName="correo_verificado" /> Correo verificado</label>
          <div class="modal-actions">
            <button class="btn secondary" type="button" (click)="closeEdit()" [disabled]="editLoading()">Cancelar</button>
            <button class="btn primary" type="submit" [disabled]="editForm.invalid || editLoading()">{{ editLoading() ? 'Guardando…' : 'Guardar cambios' }}</button>
          </div>
        </form>
      </aside>
    }

    @if (selectedUser(); as selected) {
      <button class="drawer-backdrop" type="button" aria-label="Cerrar gestión de roles" (click)="closeRoles()"></button>
      <aside class="role-drawer" aria-label="Gestión de roles" aria-modal="true">
        <header class="drawer-header"><div><p class="eyebrow">Acceso del usuario</p><h2>Roles y permisos</h2></div><button class="icon-btn close-btn" type="button" (click)="closeRoles()" aria-label="Cerrar">×</button></header>
        <div class="drawer-user"><div class="avatar large">{{ selected.nombre_usuario[0].toUpperCase() }}</div><div><strong>{{ selected.nombre_usuario }}</strong><small>{{ selected.correo }}</small><span class="badge" [class.success]="selected.estado === 'ACTIVO'">{{ selected.estado }}</span></div></div>
        @if (panelError()) { <div class="alert error" role="alert">{{ panelError() }}</div> }
        @if (panelLoading()) { <div class="empty">Cargando roles y permisos…</div> } @else {
          @if (auth.hasPermission('USUARIOS_ASIGNAR_ROL')) {
            <section class="drawer-section"><h3>Asignar rol</h3><div class="assign-role-row"><select aria-label="Rol disponible" [(ngModel)]="selectedRoleId"><option [ngValue]="null">Selecciona un rol</option>@for (role of assignableRoles(); track role.id_rol) { <option [ngValue]="role.id_rol">{{ role.nombre }}</option> }</select><button class="btn primary" type="button" [disabled]="!selectedRoleId || actionLoading()" (click)="assignRole()">Asignar</button></div>@if (!assignableRoles().length) { <small class="muted">No hay roles adicionales disponibles.</small> }</section>
          }
          <section class="drawer-section"><div class="section-title"><h3>Roles actuales</h3><span class="count-pill">{{ currentRoles().length }}</span></div>
            <div class="role-list">@for (role of currentRoles(); track role.id_rol) { <article class="role-item"><div><strong>{{ role.nombre }}</strong><small>{{ role.descripcion || 'Sin descripción' }}</small></div>@if (auth.hasPermission('USUARIOS_QUITAR_ROL')) { <button class="btn small danger-outline" type="button" [disabled]="actionLoading()" (click)="removeRole(role)">Retirar</button> }</article> } @empty { <p class="empty compact">El usuario no tiene roles asignados.</p> }</div>
          </section>
          <section class="drawer-section"><div class="section-title"><h3>Permisos efectivos</h3><span class="count-pill">{{ effectivePermissions().length }}</span></div>
            <div class="permission-list">@for (permission of effectivePermissions(); track permission.codigo) { <div class="permission-item"><code>{{ permission.codigo }}</code><span>{{ permission.nombre }}</span><small>{{ permission.modulo }}</small></div> } @empty { <p class="empty compact">El usuario no tiene permisos efectivos.</p> }</div>
          </section>
        }
      </aside>
    }
  `,
})
export class UsersComponent implements OnInit {
  readonly auth = inject(AuthService);
  private readonly service = inject(UserService);
  private readonly employeeService = inject(EmployeeService);
  private readonly roleService = inject(RoleService);
  private readonly fb = inject(FormBuilder);
  readonly users = signal<User[]>([]);
  readonly loading = signal(false);
  readonly error = signal('');
  readonly editingUser = signal<User | null>(null);
  readonly editForm: FormGroup;
  readonly editLoading = signal(false);
  readonly editError = signal('');
  readonly editEmployee = signal<Employee | null>(null);
  readonly editEmployeeLoading = signal(false);
  readonly editEmployeeError = signal('');
  readonly selectedUser = signal<User | null>(null);
  readonly currentRoles = signal<Role[]>([]);
  readonly availableRoles = signal<Role[]>([]);
  readonly effectivePermissions = signal<Permission[]>([]);
  readonly panelLoading = signal(false);
  readonly actionLoading = signal(false);
  readonly panelError = signal('');
  readonly assignableRoles = computed(() => {
    const assigned = new Set(this.currentRoles().map((role) => role.id_rol));
    return this.availableRoles().filter((role) => Boolean(role.activo) && !assigned.has(role.id_rol));
  });
  buscar = '';
  estado: UserStatus | '' = '';
  tipo: UserType | '' = '';
  selectedRoleId: number | null = null;

  constructor() {
    this.editForm = this.fb.group({
      numero_documento_empleado: [''],
      nombre_usuario: ['', [Validators.required, Validators.maxLength(255)]],
      correo: ['', [Validators.required, Validators.email, Validators.maxLength(255)]],
      tipo_usuario: ['EMPLEADO', Validators.required],
      tipo_autenticacion: ['LOCAL', Validators.required],
      requiere_cambio_password: [false],
      correo_verificado: [false],
    });
    this.editForm.get('numero_documento_empleado')?.valueChanges.subscribe(() => {
      this.editEmployee.set(null);
      this.editEmployeeError.set('');
    });
  }

  ngOnInit(): void { this.load(); }
  canOpenRoles(): boolean { return this.auth.hasAnyPermission(['USUARIOS_VER_ROLES', 'USUARIOS_VER_PERMISOS', 'USUARIOS_ASIGNAR_ROL', 'USUARIOS_QUITAR_ROL']); }
  load(): void { this.loading.set(true); this.error.set(''); this.service.listUsers({ buscar: this.buscar.trim(), estado: this.estado, tipo_usuario: this.tipo }).pipe(finalize(() => this.loading.set(false))).subscribe({ next: (users) => this.users.set(users), error: (error) => this.error.set(apiErrorMessage(error)) }); }

  openEdit(user: User): void {
    this.editingUser.set(user);
    this.editError.set('');
    this.editEmployee.set(null);
    this.editEmployeeError.set('');
    this.editForm.patchValue({
      numero_documento_empleado: '',
      nombre_usuario: user.nombre_usuario,
      correo: user.correo,
      tipo_usuario: user.tipo_usuario,
      tipo_autenticacion: user.tipo_autenticacion,
      requiere_cambio_password: user.requiere_cambio_password,
      correo_verificado: user.correo_verificado,
    });
  }

  closeEdit(): void {
    if (this.editLoading()) return;
    this.editingUser.set(null);
    this.editError.set('');
    this.editEmployee.set(null);
    this.editEmployeeError.set('');
    this.editForm.reset();
  }

  saveUser(): void {
    if (!this.editForm.valid || !this.editingUser()) return;
    const document = String(this.editForm.value.numero_documento_empleado ?? '').trim();
    if (document && !this.editEmployee()) {
      this.editEmployeeError.set('Busca y valida el empleado antes de guardar.');
      return;
    }
    if (this.editForm.value.tipo_usuario === 'EMPLEADO' && !this.editingUser()!.id_empleado && !this.editEmployee()) {
      this.editEmployeeError.set('El documento del empleado es obligatorio para usuarios de tipo EMPLEADO.');
      return;
    }

    const payload = { ...this.editForm.value, numero_documento_empleado: document || undefined };
    this.editLoading.set(true);
    this.editError.set('');
    this.service.updateUser(this.editingUser()!.id_usuario, payload).pipe(finalize(() => this.editLoading.set(false))).subscribe({
      next: (updated) => {
        this.users.update((users) => users.map((u) => u.id_usuario === updated.id_usuario ? updated : u));
        this.closeEdit();
      },
      error: (error) => this.editError.set(apiErrorMessage(error, 'No fue posible actualizar el usuario.')),
    });
  }

  searchEditEmployee(): void {
    const document = String(this.editForm.value.numero_documento_empleado ?? '').trim();
    this.editEmployee.set(null);
    this.editEmployeeError.set('');
    if (!document) {
      this.editEmployeeError.set('Ingresa el documento del empleado.');
      return;
    }

    this.editEmployeeLoading.set(true);
    this.employeeService.getEmployeeByDocument(document).pipe(finalize(() => this.editEmployeeLoading.set(false))).subscribe({
      next: (employee) => this.editEmployee.set(employee),
      error: (error) => this.editEmployeeError.set(apiErrorMessage(error, 'No se encontro un empleado con ese documento.')),
    });
  }

  inactivateUser(user: User): void {
    const nextState: UserStatus = user.estado === 'ACTIVO' ? 'INACTIVO' : 'ACTIVO';
    if (user.estado === 'ACTIVO' && !confirm(`¿Seguro que deseas inactivar a ${user.nombre_usuario}?`)) {
      return;
    }
    this.service.changeUserStatus(user.id_usuario, nextState).subscribe({
      next: (updated) => this.users.update((users) => users.map((u) => u.id_usuario === updated.id_usuario ? updated : u)),
      error: (error) => this.error.set(apiErrorMessage(error)),
    });
  }

  deleteAccess(user: User): void {
    if (!confirm(`¿Seguro que deseas eliminar el acceso de ${user.nombre_usuario}? Esta acción no borra el usuario físicamente.`)) {
      return;
    }
    this.service.changeUserStatus(user.id_usuario, 'ELIMINADO').subscribe({
      next: () => this.users.update((users) => users.filter((u) => u.id_usuario !== user.id_usuario)),
      error: (error) => this.error.set(apiErrorMessage(error, 'No fue posible eliminar el acceso.')),
    });
  }

  openRoles(user: User): void { this.selectedUser.set(user); this.selectedRoleId = null; this.refreshRoleData(); }
  closeRoles(): void { if (this.actionLoading()) return; this.selectedUser.set(null); this.currentRoles.set([]); this.availableRoles.set([]); this.effectivePermissions.set([]); this.panelError.set(''); }
  assignRole(): void { const user = this.selectedUser(); if (!user || !this.selectedRoleId) { this.panelError.set('Selecciona un rol para continuar.'); return; } this.actionLoading.set(true); this.panelError.set(''); this.service.assignRole(user.id_usuario, this.selectedRoleId).pipe(finalize(() => this.actionLoading.set(false))).subscribe({ next: () => { this.selectedRoleId = null; this.refreshRoleData(); }, error: (error) => this.panelError.set(apiErrorMessage(error, 'No fue posible asignar el rol.')) }); }
  removeRole(role: Role): void { const user = this.selectedUser(); if (!user) return; this.actionLoading.set(true); this.panelError.set(''); this.service.removeRole(user.id_usuario, role.id_rol).pipe(finalize(() => this.actionLoading.set(false))).subscribe({ next: () => this.refreshRoleData(), error: (error) => this.panelError.set(apiErrorMessage(error, 'No fue posible retirar el rol.')) }); }

  private refreshRoleData(): void {
    const user = this.selectedUser();
    if (!user) return;
    this.panelLoading.set(true); this.panelError.set('');
    const roles = this.auth.hasPermission('USUARIOS_VER_ROLES') ? this.service.getUserRoles(user.id_usuario) : of([] as Role[]);
    const permissions = this.auth.hasPermission('USUARIOS_VER_PERMISOS') ? this.service.getUserPermissions(user.id_usuario) : of([] as Permission[]);
    const available = this.auth.hasPermission('USUARIOS_ASIGNAR_ROL') ? this.roleService.listRoles() : of([] as Role[]);
    forkJoin({ roles, permissions, available }).pipe(finalize(() => this.panelLoading.set(false))).subscribe({
      next: (data) => { this.currentRoles.set(data.roles); this.effectivePermissions.set(data.permissions); this.availableRoles.set(data.available); },
      error: (error) => this.panelError.set(apiErrorMessage(error, 'No fue posible cargar los roles y permisos del usuario.')),
    });
  }
}
