import { Component, OnInit, inject, signal } from '@angular/core';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { forkJoin } from 'rxjs';
import { Permission, Role, User } from '../../core/models/api.models';
import { AuthService } from '../../core/services/auth.service';
import { UserService } from '../../core/services/user.service';
import { apiErrorMessage } from '../../shared/api-error';

@Component({ standalone: true, imports: [RouterLink], template: `
  <div class="page-heading"><div><p class="eyebrow">Usuarios</p><h1>Detalle de usuario</h1></div><a class="btn ghost" routerLink="/admin/users">Volver</a></div>
  @if (error()) { <div class="alert error">{{ error() }}</div> }
  @if (user(); as current) {
    <section class="panel profile-summary"><div class="avatar large">{{ current.nombre_usuario[0].toUpperCase() }}</div><div><h2>{{ current.nombre_usuario }}</h2><p class="muted">{{ current.correo }}</p></div><span class="badge" [class.success]="current.estado === 'ACTIVO'">{{ current.estado }}</span></section>
    <section class="detail-grid"><article class="panel"><h2>Información</h2><dl><dt>Tipo de usuario</dt><dd>{{ current.tipo_usuario }}</dd><dt>Autenticación</dt><dd>{{ current.tipo_autenticacion }}</dd><dt>ID de usuario</dt><dd>{{ current.id_usuario }}</dd><dt>ID empleado</dt><dd>{{ current.id_empleado || 'No asociado' }}</dd></dl></article>
      <article class="panel"><h2>Roles</h2><div class="chip-list">@for (role of roles(); track role.id_rol) { <span class="chip">{{ role.nombre }}</span> } @empty { <p class="empty">Sin roles visibles.</p> }</div></article></section>
    <section class="panel"><h2>Permisos efectivos</h2><div class="chip-list">@for (permission of permissions(); track permission.codigo) { <span class="chip">{{ permission.codigo }}</span> } @empty { <p class="empty">Sin permisos visibles.</p> }</div></section>
  } @else if (!error()) { <div class="panel empty">Cargando usuario…</div> }`, })
export class UserDetailComponent implements OnInit {
  private readonly route = inject(ActivatedRoute); private readonly service = inject(UserService); private readonly auth = inject(AuthService);
  readonly user = signal<User | null>(null); readonly roles = signal<Role[]>([]); readonly permissions = signal<Permission[]>([]); readonly error = signal('');
  ngOnInit(): void { const id = Number(this.route.snapshot.paramMap.get('id')); const requests = { user: this.service.getUserById(id), ...(this.auth.hasPermission('USUARIOS_VER_ROLES') ? { roles: this.service.getUserRoles(id) } : {}), ...(this.auth.hasPermission('USUARIOS_VER_PERMISOS') ? { permissions: this.service.getUserPermissions(id) } : {}) }; forkJoin(requests).subscribe({ next: (data) => { this.user.set(data.user); this.roles.set('roles' in data ? data.roles as Role[] : []); this.permissions.set('permissions' in data ? data.permissions as Permission[] : []); }, error: (error) => this.error.set(apiErrorMessage(error, 'No fue posible cargar el usuario.')) }); }
}
