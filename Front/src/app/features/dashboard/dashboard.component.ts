import { Component, OnInit, inject, signal } from '@angular/core';
import { AuthService } from '../../core/services/auth.service';
import { HealthService } from '../../core/services/catalog.service';

@Component({ standalone: true, template: `
  <div class="page-heading"><div><p class="eyebrow">Resumen general</p><h1>Hola, {{ auth.currentUser()?.nombre_usuario }}</h1><p class="muted">Este es el estado actual de tu acceso administrativo.</p></div><span class="badge" [class.success]="backendOnline()">API {{ backendOnline() ? 'conectada' : healthDone() ? 'sin conexión' : 'verificando' }}</span></div>
  <section class="stats-grid">
    <article class="stat-card"><span>Tipo de usuario</span><strong>{{ auth.currentUser()?.tipo_usuario }}</strong><small>{{ auth.currentUser()?.correo }}</small></article>
    <article class="stat-card"><span>Roles asignados</span><strong>{{ auth.roles().length }}</strong><small>{{ roleNames() }}</small></article>
    <article class="stat-card"><span>Permisos activos</span><strong>{{ auth.permissions().length }}</strong><small>Accesos efectivos en esta sesión</small></article>
  </section>
  <section class="panel"><div class="panel-heading"><div><h2>Permisos principales</h2><p class="muted">Capacidades habilitadas por tus roles.</p></div></div>
    <div class="chip-list">@for (permission of auth.permissions().slice(0, 12); track permission.codigo) { <span class="chip">{{ permission.nombre || permission.codigo }}</span> } @empty { <p class="empty">No hay permisos asignados.</p> }</div>
  </section>`, })
export class DashboardComponent implements OnInit {
  readonly auth = inject(AuthService); private readonly health = inject(HealthService);
  readonly backendOnline = signal(false); readonly healthDone = signal(false);
  ngOnInit(): void { this.auth.me().subscribe({ error: () => undefined }); this.health.check().subscribe({ next: (data) => { this.backendOnline.set(data.status === 'ok'); this.healthDone.set(true); }, error: () => this.healthDone.set(true) }); }
  roleNames(): string { return this.auth.roles().map((role) => role.nombre).join(', ') || 'Sin roles'; }
}
