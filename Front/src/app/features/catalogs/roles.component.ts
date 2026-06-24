import { Component, OnInit, computed, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { finalize } from 'rxjs/operators';
import { AuthService } from '../../core/services/auth.service';
import { PermissionService, RoleService } from '../../core/services/catalog.service';
import { apiErrorMessage } from '../../shared/api-error';
import { Permission, Role } from '../../core/models/api.models';

@Component({ standalone: true, imports: [FormsModule], template: `
  <div class="page-heading">
    <div>
      <p class="eyebrow">Control de acceso</p>
      <h1>Roles</h1>
      <p class="muted">Catálogo de perfiles disponibles.</p>
    </div>
    @if (auth.hasPermission('ROLES_CREAR')) {
      <button class="btn primary" type="button" (click)="openCreate()">Crear rol</button>
    }
  </div>

  <section class="panel">
    @if (success()) { <div class="alert success">{{ success() }}</div> }
    @if (error()) { <div class="alert error">{{ error() }}</div> }
    <div class="table-wrap">
      <table>
        <thead>
          <tr><th>Nombre</th><th>Descripción</th><th>Estado</th><th>Acciones</th></tr>
        </thead>
        <tbody>
          @for (role of roles(); track role.id_rol) {
            <tr>
              <td><strong>{{ role.nombre }}</strong></td>
              <td>{{ role.descripcion || 'Sin descripción' }}</td>
              <td><span class="badge" [class.success]="role.activo">{{ role.activo ? 'ACTIVO' : 'INACTIVO' }}</span></td>
              <td>
                @if (auth.hasPermission('ROLES_EDITAR')) {
                  <button class="btn small secondary" type="button" (click)="toggleState(role)" [disabled]="loading()">{{ role.activo ? 'Inactivar' : 'Activar' }}</button>
                  <button class="btn small tertiary" type="button" (click)="openPermissions(role)" [disabled]="loading()">Permisos</button>
                }
                @if (canDeleteRoles()) {
                  @if (isSuperAdmin(role)) {
                    <button class="btn small danger-outline" type="button" disabled title="El rol SUPER_ADMIN no se puede eliminar.">Eliminar</button>
                  } @else {
                    <button class="btn small danger-outline" type="button" (click)="deleteRole(role)" [disabled]="loading()">Eliminar</button>
                  }
                }
              </td>
            </tr>
          } @empty {
            <tr><td colspan="4" class="empty">Cargando roles…</td></tr>
          }
        </tbody>
      </table>
    </div>
  </section>

  @if (createOpen()) {
    <section class="panel modal">
      <div class="modal-content">
        <header>
          <h2>Crear rol</h2>
          <button class="icon-btn" type="button" (click)="closeCreate()" aria-label="Cerrar">×</button>
        </header>
        <form (ngSubmit)="createRole()">
          <label>Nombre
            <input type="text" [(ngModel)]="createForm.nombre" name="nombre" required maxlength="100" />
          </label>
          <label>Descripción
            <textarea [(ngModel)]="createForm.descripcion" name="descripcion" maxlength="255"></textarea>
          </label>
          @if (formError()) { <div class="alert error">{{ formError() }}</div> }
          <div class="modal-actions">
            <button class="btn secondary" type="button" (click)="closeCreate()">Cancelar</button>
            <button class="btn primary" type="submit" [disabled]="loading()">Crear</button>
          </div>
        </form>
      </div>
    </section>
  }

  @if (permissionsOpen()) {
    <section class="panel modal">
      <div class="modal-content">
        <header>
          <h2>Permisos de {{ selectedRole()?.nombre }}</h2>
          <button class="icon-btn" type="button" (click)="closePermissions()" aria-label="Cerrar">×</button>
        </header>
        @if (permissionsError()) { <div class="alert error">{{ permissionsError() }}</div> }
        <div class="modal-body">
          <div class="form-row">
            <label>Permiso disponible
              <select [(ngModel)]="selectedPermissionId" name="permission">
                <option [ngValue]="null">Selecciona un permiso</option>
                @for (permission of unassignedPermissions(); track permission.id_permiso) {
                  <option [ngValue]="permission.id_permiso">{{ permission.codigo }} - {{ permission.nombre }}</option>
                }
              </select>
            </label>
            <button class="btn primary" type="button" [disabled]="!selectedPermissionId || loading()" (click)="assignPermission()">Asignar</button>
          </div>
          <div class="table-wrap">
            <table>
              <thead><tr><th>Código</th><th>Nombre</th><th>Módulo</th><th>Acción</th></tr></thead>
              <tbody>
                @for (permission of rolePermissions(); track permission.id_permiso) {
                  <tr>
                    <td><code>{{ permission.codigo }}</code></td>
                    <td>{{ permission.nombre }}</td>
                    <td>{{ permission.modulo }}</td>
                    <td><button class="btn small danger-outline" type="button" (click)="removePermission(permission)" [disabled]="loading()">Retirar</button></td>
                  </tr>
                } @empty {
                  <tr><td colspan="4" class="empty">No hay permisos asignados.</td></tr>
                }
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </section>
  }
`, })
export class RolesComponent implements OnInit {
  private readonly service = inject(RoleService);
  private readonly permissionService = inject(PermissionService);
  readonly auth = inject(AuthService);

  readonly roles = signal<Role[]>([]);
  readonly rolePermissions = signal<Permission[]>([]);
  readonly availablePermissions = signal<Permission[]>([]);
  readonly error = signal('');
  readonly success = signal('');
  readonly formError = signal('');
  readonly permissionsError = signal('');
  readonly loading = signal(false);
  readonly createOpen = signal(false);
  readonly permissionsOpen = signal(false);
  readonly selectedRole = signal<Role | null>(null);
  selectedPermissionId: number | null = null;
  createForm = { nombre: '', descripcion: '' };

  readonly unassignedPermissions = computed(() => {
    const assignedIds = new Set(this.rolePermissions().map((permission) => permission.id_permiso));
    return this.availablePermissions().filter((permission) => !assignedIds.has(permission.id_permiso));
  });

  ngOnInit(): void {
    this.loadRoles();
  }

  loadRoles(): void {
    this.error.set('');
    this.service.listRoles().subscribe({
      next: (roles) => this.roles.set(roles),
      error: (error) => this.error.set(apiErrorMessage(error, 'No fue posible cargar los roles.')),
    });
  }

  openCreate(): void {
    this.formError.set('');
    this.createForm = { nombre: '', descripcion: '' };
    this.createOpen.set(true);
  }

  closeCreate(): void {
    this.createOpen.set(false);
  }

  createRole(): void {
    if (!this.createForm.nombre.trim()) {
      this.formError.set('El nombre del rol es obligatorio.');
      return;
    }
    this.loading.set(true);
    this.formError.set('');
    this.service.createRole(this.createForm).pipe(finalize(() => this.loading.set(false))).subscribe({
      next: () => {
        this.closeCreate();
        this.loadRoles();
      },
      error: (error) => this.formError.set(apiErrorMessage(error, 'No fue posible crear el rol.')),
    });
  }

  toggleState(role: Role): void {
    const nextState = role.activo ? 'INACTIVO' : 'ACTIVO';
    if (role.activo && !confirm(`¿Seguro que deseas inactivar el rol ${role.nombre}?`)) {
      return;
    }
    this.loading.set(true);
    this.service.changeRoleState(role.id_rol, nextState).pipe(finalize(() => this.loading.set(false))).subscribe({
      next: () => this.loadRoles(),
      error: (error) => this.error.set(apiErrorMessage(error, 'No fue posible cambiar el estado del rol.')),
    });
  }

  canDeleteRoles(): boolean {
    return this.auth.hasAnyPermission(['ROLES_ELIMINAR', 'ROLES_EDITAR']);
  }

  isSuperAdmin(role: Role): boolean {
    return role.nombre.toUpperCase() === 'SUPER_ADMIN';
  }

  deleteRole(role: Role): void {
    this.error.set('');
    this.success.set('');
    if (this.isSuperAdmin(role)) {
      this.error.set('El rol SUPER_ADMIN no se puede eliminar.');
      return;
    }
    const confirmed = confirm('Esta acción eliminará lógicamente el rol. No se borrará su historial ni sus relaciones. ¿Deseas continuar?');
    if (!confirmed) {
      return;
    }
    this.loading.set(true);
    this.service.deleteRole(role.id_rol).pipe(finalize(() => this.loading.set(false))).subscribe({
      next: () => {
        this.success.set(`Rol ${role.nombre} eliminado exitosamente.`);
        if (this.selectedRole()?.id_rol === role.id_rol) {
          this.closePermissions();
        }
        this.loadRoles();
      },
      error: (error) => this.error.set(apiErrorMessage(error, 'No fue posible eliminar el rol.')),
    });
  }

  openPermissions(role: Role): void {
    this.selectedRole.set(role);
    this.permissionsError.set('');
    this.permissionsOpen.set(true);
    this.selectedPermissionId = null;
    this.loadRolePermissions(role.id_rol);
    this.loadAvailablePermissions();
  }

  closePermissions(): void {
    this.permissionsOpen.set(false);
    this.selectedRole.set(null);
    this.rolePermissions.set([]);
    this.availablePermissions.set([]);
    this.selectedPermissionId = null;
  }

  loadRolePermissions(roleId: number): void {
    this.service.getRolePermissions(roleId).subscribe({
      next: (permissions) => this.rolePermissions.set(permissions),
      error: (error) => this.permissionsError.set(apiErrorMessage(error, 'No fue posible cargar los permisos del rol.')),
    });
  }

  loadAvailablePermissions(): void {
    this.permissionService.listPermissions().subscribe({
      next: (permissions) => this.availablePermissions.set(permissions),
      error: (error) => this.permissionsError.set(apiErrorMessage(error, 'No fue posible cargar el catálogo de permisos.')),
    });
  }

  assignPermission(): void {
    const role = this.selectedRole();
    if (!role || !this.selectedPermissionId) { return; }
    this.loading.set(true);
    this.service.assignRolePermission(role.id_rol, this.selectedPermissionId).pipe(finalize(() => this.loading.set(false))).subscribe({
      next: () => {
        this.selectedPermissionId = null;
        this.loadRolePermissions(role.id_rol);
      },
      error: (error) => this.permissionsError.set(apiErrorMessage(error, 'No fue posible asignar el permiso.')),
    });
  }

  removePermission(permission: Permission): void {
    const role = this.selectedRole();
    if (!role) { return; }
    if (!confirm(`¿Deseas retirar el permiso ${permission.codigo} del rol ${role.nombre}?`)) { return; }
    this.loading.set(true);
    this.service.removeRolePermission(role.id_rol, permission.id_permiso).pipe(finalize(() => this.loading.set(false))).subscribe({
      next: () => this.loadRolePermissions(role.id_rol),
      error: (error) => this.permissionsError.set(apiErrorMessage(error, 'No fue posible retirar el permiso.')),
    });
  }
}
