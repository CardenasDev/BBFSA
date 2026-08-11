import { Component, OnInit, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { finalize } from 'rxjs/operators';
import { ParametersService } from '../../core/services/parameters.service';
import { apiErrorMessage } from '../../shared/api-error';
import { Area } from '../../core/models/api.models';
import { AuthService } from '../../core/services/auth.service';

@Component({
  standalone: true,
  imports: [FormsModule],
  template: `
    <div class="page-heading">
      <div>
        <p class="eyebrow">Parámetros</p>
        <h1>Áreas</h1>
        <p class="muted">Administra las áreas internas de la organización.</p>
      </div>
      @if (auth.hasPermission('PARAMETROS_ADMINISTRAR')) {
        <button class="btn primary" type="button" (click)="openCreate()">Agregar área</button>
      }
    </div>

    <section class="panel">
      @if (error()) { <div class="alert error">{{ error() }}</div> }
      <div class="table-wrap">
        <table>
          <thead>
            <tr><th>Nombre</th><th>Descripción</th><th>Estado</th><th>Acciones</th></tr>
          </thead>
          <tbody>
            @for (area of areas(); track area.id_area) {
              <tr>
                <td><strong>{{ area.nombre }}</strong></td>
                <td>{{ area.descripcion }}</td>
                <td><span class="badge" [class.success]="area.activo">{{ area.activo ? 'ACTIVO' : 'INACTIVO' }}</span></td>
                <td>
                  @if (auth.hasPermission('PARAMETROS_ADMINISTRAR')) {
                    <button class="btn small secondary" type="button" (click)="toggleState(area)" [disabled]="loading()">{{ area.activo ? 'Inactivar' : 'Activar' }}</button>
                    <button class="btn small" type="button" (click)="openEdit(area)">Editar</button>
                  }
                </td>
              </tr>
            } @empty {
              <tr><td colspan="4" class="empty">Cargando áreas…</td></tr>
            }
          </tbody>
        </table>
      </div>
    </section>

    @if (createOpen()) {
      <section class="panel modal">
        <div class="modal-content">
          <header>
            <h2>{{ editMode() ? 'Editar área' : 'Agregar área' }}</h2>
            <button class="icon-btn" type="button" (click)="closeCreate()" aria-label="Cerrar">×</button>
          </header>
          <form (ngSubmit)="save()">
            <label>Nombre
              <input type="text" [(ngModel)]="form.nombre" name="nombre" required maxlength="255" />
            </label>
            <label>Descripción
              <input type="text" [(ngModel)]="form.descripcion" name="descripcion" maxlength="1000" />
            </label>
            @if (formError()) { <div class="alert error">{{ formError() }}</div> }
            <div class="modal-actions">
              <button class="btn secondary" type="button" (click)="closeCreate()">Cancelar</button>
              <button class="btn primary" type="submit" [disabled]="loading()">{{ editMode() ? 'Actualizar' : 'Crear' }}</button>
            </div>
          </form>
        </div>
      </section>
    }
  `,
})
export class ParametersAreasComponent implements OnInit {
  private readonly service = inject(ParametersService);
  readonly auth = inject(AuthService);

  readonly areas = signal<Area[]>([]);
  readonly error = signal('');
  readonly formError = signal('');
  readonly loading = signal(false);
  readonly createOpen = signal(false);
  readonly editMode = signal(false);
  private editingId: number | null = null;

  form: { nombre: string; descripcion?: string | null } = { nombre: '', descripcion: '' };

  ngOnInit(): void {
    this.load();
  }

  load(): void {
    this.error.set('');
    this.service.listAreas().subscribe({
      next: (areas) => this.areas.set(areas),
      error: (err) => this.error.set(apiErrorMessage(err, 'No fue posible cargar las áreas.')),
    });
  }

  openCreate(): void {
    this.formError.set('');
    this.form = { nombre: '', descripcion: '' };
    this.editingId = null;
    this.editMode.set(false);
    this.createOpen.set(true);
  }

  openEdit(area: Area): void {
    this.formError.set('');
    this.form = { nombre: area.nombre, descripcion: area.descripcion ?? '' };
    this.editingId = area.id_area;
    this.editMode.set(true);
    this.createOpen.set(true);
  }

  closeCreate(): void {
    this.createOpen.set(false);
  }

  save(): void {
    const nombre = this.form.nombre?.trim();
    if (!nombre) {
      this.formError.set('El nombre es obligatorio.');
      return;
    }

    this.loading.set(true);
    this.formError.set('');

    const op = this.editingId
      ? this.service.updateArea(this.editingId, { nombre, descripcion: this.form.descripcion })
      : this.service.createArea({ nombre, descripcion: this.form.descripcion });

    op.pipe(finalize(() => this.loading.set(false))).subscribe({
      next: () => {
        this.closeCreate();
        this.load();
      },
      error: (err) => this.formError.set(apiErrorMessage(err, 'No fue posible guardar el área.')),
    });
  }

  toggleState(area: Area): void {
    const next = area.activo ? 'INACTIVO' : 'ACTIVO';
    if (area.activo && !confirm(`¿Desea inactivar el área ${area.nombre}?`)) return;

    this.loading.set(true);
    this.service
      .updateArea(area.id_area, { nombre: area.nombre, descripcion: area.descripcion ?? '', activo: !area.activo })
      .pipe(finalize(() => this.loading.set(false)))
      .subscribe({
        next: () => this.load(),
        error: (err) => this.error.set(apiErrorMessage(err, 'No fue posible cambiar el estado del área.')),
      });
  }
}
