import { Component, OnInit, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { finalize, forkJoin } from 'rxjs';
import { DotationSize, MyDotationSize, SaveMyDotationSizeRequest } from '../../core/models/api.models';
import { AuthService } from '../../core/services/auth.service';
import { DotationService } from '../../core/services/dotation.service';
import { apiErrorMessage } from '../../shared/api-error';

@Component({
  standalone: true,
  imports: [FormsModule],
  template: `
    <div class="page-heading">
      <div>
        <p class="eyebrow">Dotaciones</p>
        <h1>Mis tallas</h1>
        <p class="muted">Consulta y actualiza la talla que utilizas para cada articulo.</p>
      </div>
    </div>

    <section class="panel">
      @if (!canEdit()) {
        <div class="alert error">Tienes permiso de consulta, pero no de edicion de tallas.</div>
      }
      @if (success()) { <div class="alert success" role="status">{{ success() }}</div> }
      @if (error()) {
        <div class="alert error" role="alert">
          {{ error() }}
          <button class="btn small ghost" type="button" (click)="load()" [disabled]="loading()">Reintentar</button>
        </div>
      }

      <p class="muted size-help">
        Las tallas especificas son las utilizadas actualmente. Una talla heredada proviene de la familia anterior y puedes confirmarla o cambiarla para el articulo.
      </p>

      <div class="table-wrap">
        <table>
          <thead>
            <tr>
              <th>Articulo</th>
              <th>Familia</th>
              <th>Genero / unidad</th>
              <th>Origen</th>
              <th>Talla</th>
              <th>Observaciones</th>
            </tr>
          </thead>
          <tbody>
            @for (item of mySizes(); track item.id_dotacion_articulo) {
              <tr [class.size-inherited]="item.origen_talla === 'HEREDADA_FAMILIA'">
                <td>
                  <strong>{{ item.articulo }}</strong>
                  @if (item.articulo_descripcion) { <small class="muted row-detail">{{ item.articulo_descripcion }}</small> }
                </td>
                <td>{{ item.tipo_dotacion }}</td>
                <td>{{ item.genero }} / {{ item.unidad_medida }}</td>
                <td>
                  <span class="badge" [class.success]="item.origen_talla === 'ESPECIFICA'">
                    {{ originLabel(item.origen_talla) }}
                  </span>
                </td>
                <td>
                  <select
                    [disabled]="!canEdit() || saving()"
                    [ngModel]="selectedSize(item)"
                    (ngModelChange)="setSelectedSize(item.id_dotacion_articulo, $event)"
                    [attr.aria-label]="'Talla para ' + item.articulo"
                  >
                    <option [ngValue]="null">Selecciona una talla</option>
                    @for (size of sizesByType(item.id_tipo_dotacion); track size.id_talla_dotacion) {
                      <option [ngValue]="size.id_talla_dotacion">
                        {{ size.talla }} @if (size.descripcion) { - {{ size.descripcion }} }
                      </option>
                    }
                  </select>
                </td>
                <td>
                  <input
                    type="text"
                    maxlength="250"
                    [disabled]="!canEdit() || saving()"
                    [ngModel]="observation(item)"
                    (ngModelChange)="setObservation(item.id_dotacion_articulo, $event)"
                    [attr.aria-label]="'Observaciones para ' + item.articulo"
                  />
                </td>
              </tr>
            } @empty {
              <tr><td colspan="6" class="empty">{{ loading() ? 'Cargando tallas...' : 'No hay articulos con talla disponibles para tu usuario.' }}</td></tr>
            }
          </tbody>
        </table>
      </div>

      @if (canEdit() && mySizes().length) {
        <div class="form-actions">
          <button class="btn primary" type="button" (click)="saveAll()" [disabled]="saving() || loading()">
            {{ saving() ? 'Guardando tallas...' : 'Guardar mis tallas' }}
          </button>
        </div>
      }
    </section>
  `,
  styles: [`
    .size-help { margin: 0 0 1rem; }
    .row-detail { display: block; margin-top: .25rem; max-width: 22rem; }
    .size-inherited { background: #fffbeb; }
    td select, td input { min-width: 11rem; }
    td:first-child { min-width: 15rem; }
  `],
})
export class MyDotationSizesComponent implements OnInit {
  readonly auth = inject(AuthService);
  private readonly service = inject(DotationService);
  readonly mySizes = signal<MyDotationSize[]>([]);
  readonly sizes = signal<DotationSize[]>([]);
  readonly selections = signal<Record<number, number | null>>({});
  readonly observations = signal<Record<number, string>>({});
  readonly loading = signal(false);
  readonly saving = signal(false);
  readonly error = signal('');
  readonly success = signal('');

  ngOnInit(): void {
    this.load();
  }

  canEdit(): boolean {
    return this.auth.hasPermission('DOTACIONES_MIS_TALLAS_EDITAR');
  }

  load(): void {
    this.loading.set(true);
    this.error.set('');
    forkJoin({ mySizes: this.service.getMySizes(), sizes: this.service.getSizes() })
      .pipe(finalize(() => this.loading.set(false)))
      .subscribe({
        next: ({ mySizes, sizes }) => {
          this.mySizes.set(mySizes);
          this.sizes.set(sizes);
          this.selections.set(Object.fromEntries(mySizes.map((item) => [item.id_dotacion_articulo, item.id_talla_dotacion ?? null])));
          this.observations.set(Object.fromEntries(mySizes.map((item) => [item.id_dotacion_articulo, item.observaciones ?? ''])));
        },
        error: (error) => this.error.set(apiErrorMessage(error, 'No fue posible cargar tus tallas. Solicita a RRHH que revise la vinculacion de tu usuario.')),
      });
  }

  sizesByType(typeId: number): DotationSize[] {
    return this.sizes().filter((size) => size.id_tipo_dotacion === typeId && size.activo);
  }

  selectedSize(item: MyDotationSize): number | null {
    return this.selections()[item.id_dotacion_articulo] ?? item.id_talla_dotacion ?? null;
  }

  observation(item: MyDotationSize): string {
    return this.observations()[item.id_dotacion_articulo] ?? item.observaciones ?? '';
  }

  setSelectedSize(articleId: number, sizeId: number | null): void {
    this.selections.update((current) => ({ ...current, [articleId]: sizeId }));
    this.success.set('');
  }

  setObservation(articleId: number, value: string): void {
    this.observations.update((current) => ({ ...current, [articleId]: value.slice(0, 250) }));
    this.success.set('');
  }

  originLabel(origin: MyDotationSize['origen_talla']): string {
    if (origin === 'ESPECIFICA') return 'Especifica';
    if (origin === 'HEREDADA_FAMILIA') return 'Heredada';
    return 'Sin registrar';
  }

  saveAll(): void {
    this.error.set('');
    this.success.set('');

    const configured = this.mySizes().filter((item) => this.selectedSize(item) !== null);
    if (!configured.length) {
      this.error.set('Selecciona al menos una talla antes de guardar.');
      return;
    }

    const payloads: SaveMyDotationSizeRequest[] = configured.map((item) => ({
      id_dotacion_articulo: item.id_dotacion_articulo,
      id_talla_dotacion: this.selectedSize(item) as number,
      observaciones: this.blankToNull(this.observation(item)),
    }));

    this.saving.set(true);
    forkJoin(payloads.map((payload) => this.service.saveMySize(payload)))
      .pipe(finalize(() => this.saving.set(false)))
      .subscribe({
        next: () => {
          this.success.set('Tus tallas por articulo fueron guardadas correctamente.');
          this.load();
        },
        error: (error) => this.error.set(apiErrorMessage(error, 'No fue posible guardar todas las tallas. Intenta nuevamente.')),
      });
  }

  private blankToNull(value: string): string | null {
    const text = value.trim();
    return text ? text : null;
  }
}
