import { Component, OnInit, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { finalize } from 'rxjs/operators';
import { ParametersService } from '../../core/services/parameters.service';
import { apiErrorMessage } from '../../shared/api-error';
import { Position } from '../../core/models/api.models';
import { AuthService } from '../../core/services/auth.service';

@Component({
  standalone: true,
  imports: [FormsModule],
  template: `
    <div class="page-heading">
      <div>
        <p class="eyebrow">Parámetros</p>
        <h1>Cargos</h1>
        <p class="muted">Administra los cargos del sistema.</p>
      </div>
      @if (auth.hasPermission('PARAMETROS_ADMINISTRAR')) {
        <button class="btn primary" type="button" (click)="openCreate()">Agregar cargo</button>
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
            @for (pos of positions(); track pos.id_cargo) {
              <tr>
                <td><strong>{{ pos.nombre }}</strong></td>
                <td>{{ pos.descripcion }}</td>
                <td><span class="badge" [class.success]="pos.activo">{{ pos.activo ? 'ACTIVO' : 'INACTIVO' }}</span></td>
                <td>
                  @if (auth.hasPermission('PARAMETROS_ADMINISTRAR')) {
                    <button class="btn small secondary" type="button" (click)="toggleState(pos)" [disabled]="loading()">{{ pos.activo ? 'Inactivar' : 'Activar' }}</button>
                    <button class="btn small" type="button" (click)="openEdit(pos)">Editar</button>
                  }
                </td>
              </tr>
            } @empty {
              <tr><td colspan="4" class="empty">Cargando cargos…</td></tr>
            }
          </tbody>
        </table>
      </div>
    </section>

    @if (createOpen()) {
      <section class="panel modal">
        <div class="modal-content">
          <header>
            <h2>{{ editMode() ? 'Editar cargo' : 'Agregar cargo' }}</h2>
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
export class ParametersPositionsComponent implements OnInit {
  private readonly service = inject(ParametersService);
  readonly auth = inject(AuthService);

  readonly positions = signal<Position[]>([]);
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
    this.service.listPositions().subscribe({
      next: (items) => this.positions.set(items),
      error: (err) => this.error.set(apiErrorMessage(err, 'No fue posible cargar los cargos.')),
    });
  }

  openCreate(): void {
    this.formError.set('');
    this.form = { nombre: '', descripcion: '' };
    this.editingId = null;
    this.editMode.set(false);
    this.createOpen.set(true);
  }

  openEdit(pos: Position): void {
    this.formError.set('');
    this.form = { nombre: pos.nombre, descripcion: pos.descripcion ?? '' };
    this.editingId = pos.id_cargo;
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
      ? this.service.updatePosition(this.editingId, { nombre, descripcion: this.form.descripcion })
      : this.service.createPosition({ nombre, descripcion: this.form.descripcion });

    op.pipe(finalize(() => this.loading.set(false))).subscribe({
      next: () => {
        this.closeCreate();
        this.load();
      },
      error: (err) => this.formError.set(apiErrorMessage(err, 'No fue posible guardar el cargo.')),
    });
  }

  toggleState(pos: Position): void {
    const next = pos.activo ? 'INACTIVO' : 'ACTIVO';
    if (pos.activo && !confirm(`¿Desea inactivar el cargo ${pos.nombre}?`)) return;

    this.loading.set(true);
    this.service
      .updatePosition(pos.id_cargo, { nombre: pos.nombre, descripcion: pos.descripcion ?? '', activo: !pos.activo })
      .pipe(finalize(() => this.loading.set(false)))
      .subscribe({
        next: () => this.load(),
        error: (err) => this.error.set(apiErrorMessage(err, 'No fue posible cambiar el estado del cargo.')),
      });
  }
}
