import { Component, OnInit, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Permission } from '../../core/models/api.models';
import { PermissionService } from '../../core/services/catalog.service';
import { apiErrorMessage } from '../../shared/api-error';

@Component({ standalone: true, imports: [FormsModule], template: `
  <div class="page-heading"><div><p class="eyebrow">Control de acceso</p><h1>Permisos</h1><p class="muted">Capacidades disponibles por módulo.</p></div></div>
  <section class="panel"><div class="filters compact"><label>Módulo<select [(ngModel)]="module" (ngModelChange)="load()"><option value="">Todos</option>@for (item of modules(); track item) { <option [value]="item">{{ item }}</option> }</select></label></div>@if (error()) { <div class="alert error">{{ error() }}</div> }<div class="table-wrap"><table><thead><tr><th>Código</th><th>Nombre</th><th>Módulo</th><th>Estado</th></tr></thead><tbody>@for (permission of permissions(); track permission.codigo) { <tr><td><code>{{ permission.codigo }}</code></td><td>{{ permission.nombre }}</td><td>{{ permission.modulo }}</td><td><span class="badge" [class.success]="permission.activo">{{ permission.activo ? 'ACTIVO' : 'INACTIVO' }}</span></td></tr> } @empty { <tr><td colspan="4" class="empty">No hay permisos para mostrar.</td></tr> }</tbody></table></div></section>`, })
export class PermissionsComponent implements OnInit { private readonly service = inject(PermissionService); readonly permissions = signal<Permission[]>([]); readonly modules = signal<string[]>([]); readonly error = signal(''); module = ''; ngOnInit(): void { this.load(true); } load(initial = false): void { this.error.set(''); this.service.listPermissions(this.module).subscribe({ next: (permissions) => { this.permissions.set(permissions); if (initial) this.modules.set([...new Set(permissions.map((p) => p.modulo))].sort()); }, error: (error) => this.error.set(apiErrorMessage(error)) }); } }
