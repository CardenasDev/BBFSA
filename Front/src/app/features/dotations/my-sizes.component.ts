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
      <div><p class="eyebrow">Dotaciones</p><h1>Mis tallas</h1><p class="muted">Consulta y actualiza tus tallas de dotacion.</p></div>
    </div>

    <section class="panel">
      @if (!canEdit()) { <div class="alert error">Tienes permiso de consulta, pero no de edicion de tallas.</div> }
      @if (success()) { <div class="alert success" role="status">{{ success() }}</div> }
      @if (error()) { <div class="alert error" role="alert">{{ error() }} <button class="btn small ghost" type="button" (click)="load()" [disabled]="loading()">Reintentar</button></div> }

      <div class="dotation-grid">
        @for (item of mySizes(); track item.id_tipo_dotacion) {
          <article class="drawer-section dotation-card" [class.missing-required]="isMissingRequired(item)">
            <div class="section-title">
              <div>
                <h3>{{ item.tipo_dotacion }}</h3>
                <p class="muted">{{ item.tipo_dotacion_descripcion || 'Sin descripcion.' }}</p>
              </div>
              @if (item.requiere_talla) { <span class="badge">Requiere talla</span> }
            </div>
            <label>Talla
              <select [disabled]="!canEdit() || saving()" [ngModel]="selectedSize(item)" (ngModelChange)="setSelectedSize(item.id_tipo_dotacion, $event)">
                <option [ngValue]="null">{{ item.requiere_talla ? 'Selecciona una talla' : 'Sin talla' }}</option>
                @for (size of sizesByType(item.id_tipo_dotacion); track size.id_talla_dotacion) {
                  <option [ngValue]="size.id_talla_dotacion">{{ size.talla }} @if (size.descripcion) { - {{ size.descripcion }} }</option>
                }
              </select>
              @if (isMissingRequired(item)) { <small class="field-error">Talla requerida.</small> }
            </label>
            <label>Observaciones
              <textarea rows="3" maxlength="250" [disabled]="!canEdit() || saving()" [ngModel]="observation(item)" (ngModelChange)="setObservation(item.id_tipo_dotacion, $event)"></textarea>
            </label>
          </article>
        } @empty {
          <div class="empty tall">{{ loading() ? 'Cargando tallas...' : 'No hay tallas de dotacion disponibles para tu usuario.' }}</div>
        }
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
})
export class MyDotationSizesComponent implements OnInit {
  readonly auth = inject(AuthService);
  private readonly service = inject(DotationService);
  readonly mySizes = signal<MyDotationSize[]>([]);
  readonly sizes = signal<DotationSize[]>([]);
  readonly selections = signal<Record<number, number | null>>({});
  readonly observations = signal<Record<number, string>>({});
  readonly missingRequired = signal<Record<number, boolean>>({});
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
          const selections: Record<number, number | null> = {};
          const observations: Record<number, string> = {};
          mySizes.forEach((item) => {
            selections[item.id_tipo_dotacion] = item.id_talla_dotacion ?? null;
            observations[item.id_tipo_dotacion] = item.observaciones ?? '';
          });
          this.selections.set(selections);
          this.observations.set(observations);
          this.missingRequired.set({});
        },
        error: (error) => this.error.set(apiErrorMessage(error, 'No fue posible cargar tus tallas. Si tu usuario no tiene empleado asociado, solicita la vinculacion a RRHH.')),
      });
  }

  sizesByType(typeId: number): DotationSize[] {
    return this.sizes().filter((size) => size.id_tipo_dotacion === typeId);
  }

  selectedSize(item: MyDotationSize): number | null {
    return this.selections()[item.id_tipo_dotacion] ?? item.id_talla_dotacion ?? null;
  }

  observation(item: MyDotationSize): string {
    return this.observations()[item.id_tipo_dotacion] ?? item.observaciones ?? '';
  }

  setSelectedSize(typeId: number, sizeId: number | null): void {
    this.selections.update((current) => ({ ...current, [typeId]: sizeId }));
    this.missingRequired.update((current) => ({ ...current, [typeId]: false }));
  }

  setObservation(typeId: number, value: string): void {
    this.observations.update((current) => ({ ...current, [typeId]: value.slice(0, 250) }));
  }

  isMissingRequired(item: MyDotationSize): boolean {
    return Boolean(this.missingRequired()[item.id_tipo_dotacion]);
  }

  saveAll(): void {
    this.error.set('');
    this.success.set('');

    const missing = this.mySizes().filter((item) => item.requiere_talla && !this.selectedSize(item));
    if (missing.length) {
      this.missingRequired.set(Object.fromEntries(missing.map((item) => [item.id_tipo_dotacion, true])));
      this.error.set('Debes seleccionar todas las tallas requeridas antes de guardar.');
      return;
    }

    const payloads: SaveMyDotationSizeRequest[] = this.mySizes().map((item) => ({
      id_tipo_dotacion: item.id_tipo_dotacion,
      id_talla_dotacion: this.selectedSize(item),
      observaciones: this.blankToNull(this.observation(item)),
    }));

    this.saving.set(true);
    this.missingRequired.set({});
    forkJoin(payloads.map((payload) => this.service.saveMySize(payload)))
      .pipe(finalize(() => this.saving.set(false)))
      .subscribe({
      next: () => {
        this.success.set('Todas tus tallas fueron guardadas correctamente.');
        this.load();
      },
      error: () => this.error.set('No fue posible guardar todas las tallas. Intenta nuevamente.'),
    });
  }

  private blankToNull(value: string): string | null {
    const text = value.trim();
    return text ? text : null;
  }
}
