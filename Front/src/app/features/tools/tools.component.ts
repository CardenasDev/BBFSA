import { Component, OnInit, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { finalize } from 'rxjs';
import { Tool } from '../../core/models/api.models';
import { AuthService } from '../../core/services/auth.service';
import { ToolService } from '../../core/services/tool.service';
import { apiErrorMessage } from '../../shared/api-error';

@Component({
  standalone: true,
  imports: [FormsModule],
  template: `
    <div class="page-heading">
      <div><p class="eyebrow">Herramientas</p><h1>Catálogo</h1><p class="muted">Administra las herramientas disponibles para entrega.</p></div>
      @if (auth.hasPermission('HERRAMIENTAS_CREAR')) { <button class="btn primary" type="button" (click)="openForm()">Nueva herramienta</button> }
    </div>
    <section class="panel">
      <label class="check"><input type="checkbox" [(ngModel)]="includeInactive" (change)="load()" /> Mostrar inactivas</label>
      @if (error()) { <div class="alert error">{{ error() }}</div> }
      @if (success()) { <div class="alert success">{{ success() }}</div> }
      <div class="table-wrap"><table>
        <thead><tr><th>Nombre</th><th>Descripción</th><th>Estado</th><th>Acciones</th></tr></thead>
        <tbody>
          @for (tool of tools(); track tool.id_herramienta) {
            <tr><td><strong>{{ tool.nombre }}</strong></td><td>{{ tool.descripcion || 'Sin descripción' }}</td>
              <td><span class="badge" [class.success]="isActive(tool)">{{ isActive(tool) ? 'ACTIVA' : 'INACTIVA' }}</span></td>
              <td><div class="row-actions">
                @if (auth.hasPermission('HERRAMIENTAS_EDITAR')) {
                  <button class="btn small ghost" type="button" (click)="openForm(tool)">Editar</button>
                  <button class="btn small secondary" type="button" (click)="toggle(tool)" [disabled]="saving()">{{ isActive(tool) ? 'Inactivar' : 'Activar' }}</button>
                }
              </div></td>
            </tr>
          } @empty { <tr><td colspan="4" class="empty">{{ loading() ? 'Cargando herramientas...' : 'No hay herramientas.' }}</td></tr> }
        </tbody>
      </table></div>
    </section>
    @if (formOpen()) {
      <button class="drawer-backdrop" type="button" (click)="closeForm()" aria-label="Cerrar"></button>
      <aside class="role-drawer">
        <header class="drawer-header"><div><p class="eyebrow">Catálogo</p><h2>{{ editingId ? 'Editar herramienta' : 'Nueva herramienta' }}</h2></div><button class="icon-btn close-btn" type="button" (click)="closeForm()">×</button></header>
        <form class="narrow-form" (ngSubmit)="save()">
          <label>Nombre<input name="nombre" [(ngModel)]="form.nombre" required maxlength="150" /></label>
          <label>Descripción <span class="optional">opcional</span><textarea name="descripcion" [(ngModel)]="form.descripcion" maxlength="1000" rows="5"></textarea></label>
          @if (formError()) { <div class="alert error">{{ formError() }}</div> }
          <div class="form-actions"><button class="btn secondary" type="button" (click)="closeForm()">Cancelar</button><button class="btn primary" type="submit" [disabled]="saving()">{{ saving() ? 'Guardando...' : 'Guardar' }}</button></div>
        </form>
      </aside>
    }
  `,
})
export class ToolsComponent implements OnInit {
  readonly auth = inject(AuthService);
  private readonly service = inject(ToolService);
  readonly tools = signal<Tool[]>([]);
  readonly loading = signal(false);
  readonly saving = signal(false);
  readonly error = signal('');
  readonly formError = signal('');
  readonly success = signal('');
  readonly formOpen = signal(false);
  includeInactive = false;
  editingId: number | null = null;
  form = { nombre: '', descripcion: '' };

  ngOnInit(): void { this.load(); }
  load(): void {
    this.loading.set(true); this.error.set('');
    this.service.getTools(!this.includeInactive).pipe(finalize(() => this.loading.set(false))).subscribe({
      next: (tools) => this.tools.set(tools),
      error: (error) => this.error.set(apiErrorMessage(error, 'No fue posible cargar las herramientas.')),
    });
  }
  openForm(tool?: Tool): void {
    this.editingId = tool?.id_herramienta ?? null;
    this.form = { nombre: tool?.nombre ?? '', descripcion: tool?.descripcion ?? '' };
    this.formError.set(''); this.formOpen.set(true);
  }
  closeForm(): void { if (!this.saving()) this.formOpen.set(false); }
  save(): void {
    const nombre = this.form.nombre.trim();
    if (!nombre) { this.formError.set('El nombre es obligatorio.'); return; }
    const payload = { nombre, descripcion: this.form.descripcion.trim() || null };
    const request = this.editingId ? this.service.updateTool(this.editingId, payload) : this.service.createTool(payload);
    this.saving.set(true); this.formError.set('');
    request.pipe(finalize(() => this.saving.set(false))).subscribe({
      next: () => { this.success.set(this.editingId ? 'Herramienta actualizada correctamente.' : 'Herramienta creada correctamente.'); this.formOpen.set(false); this.load(); },
      error: (error) => this.formError.set(apiErrorMessage(error, 'No fue posible completar la operación.')),
    });
  }
  toggle(tool: Tool): void {
    const active = this.isActive(tool);
    if (active && !confirm(`¿Deseas inactivar ${tool.nombre}?`)) return;
    this.saving.set(true);
    this.service.changeToolStatus(tool.id_herramienta, !active).pipe(finalize(() => this.saving.set(false))).subscribe({
      next: () => { this.success.set('Estado actualizado correctamente.'); this.load(); },
      error: (error) => this.error.set(apiErrorMessage(error, 'No fue posible completar la operación.')),
    });
  }
  isActive(tool: Tool): boolean { return tool.activo === true || tool.activo === 1; }
}
