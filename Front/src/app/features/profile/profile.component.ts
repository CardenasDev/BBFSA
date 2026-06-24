import { Component, inject } from '@angular/core';
import { RouterLink } from '@angular/router';
import { AuthService } from '../../core/services/auth.service';

@Component({ standalone: true, imports: [RouterLink], template: `
  <div class="page-heading"><div><p class="eyebrow">Cuenta</p><h1>Mi perfil</h1><p class="muted">Información de tu sesión actual.</p></div><a class="btn secondary" routerLink="/admin/change-password">Cambiar contraseña</a></div>
  @if (auth.currentUser(); as user) { <section class="detail-grid"><article class="panel profile-card"><div class="avatar xlarge">{{ user.nombre_usuario[0].toUpperCase() }}</div><h2>{{ user.nombre_usuario }}</h2><p class="muted">{{ user.correo }}</p><span class="badge success">{{ user.estado }}</span></article><article class="panel"><h2>Datos de acceso</h2><dl><dt>Tipo de usuario</dt><dd>{{ user.tipo_usuario }}</dd><dt>Autenticación</dt><dd>{{ user.tipo_autenticacion }}</dd><dt>Roles</dt><dd>{{ roleNames() }}</dd></dl></article></section> }`, })
export class ProfileComponent { readonly auth = inject(AuthService); roleNames(): string { return this.auth.roles().map((role) => role.nombre).join(', ') || 'Sin roles'; } }
