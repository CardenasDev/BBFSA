import { Component, OnInit, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { finalize, forkJoin } from 'rxjs';
import { DotationSize, EmployeeDotationArticleSize } from '../../core/models/api.models';
import { DotationService } from '../../core/services/dotation.service';
import { apiErrorMessage } from '../../shared/api-error';

@Component({
  standalone: true,
  imports: [FormsModule, RouterLink],
  template: `
    <div class="page-heading">
      <div>
        <p class="eyebrow">Dotaciones</p>
        <h1>Tallas de empleado</h1>
        <p class="muted">{{ employeeName() || 'Consulta y actualiza las tallas por articulo.' }}</p>
      </div>
      <a class="btn ghost" routerLink="/admin/dotations/employees">Volver</a>
    </div>

    <section class="panel">
      @if (error()) { <div class="alert error">{{ error() }} <button class="btn small ghost" type="button" (click)="load()" [disabled]="loading()">Reintentar</button></div> }
      @if (success()) { <div class="alert success">{{ success() }}</div> }
      <p class="muted">Las tallas importadas desde el XLSX aparecen en su articulo exacto. Los articulos sin dato pueden completarse aqui.</p>
      <div class="table-wrap">
        <table>
          <thead><tr><th>Articulo</th><th>Familia</th><th>Genero / unidad</th><th>Talla</th><th>Observaciones</th><th>Accion</th></tr></thead>
          <tbody>
            @for (row of sizes(); track row.id_dotacion_articulo) {
              <tr>
                <td><strong>{{ row.articulo }}</strong></td>
                <td>{{ row.tipo_dotacion }}</td>
                <td>{{ row.genero || '—' }} / {{ row.unidad_medida || '—' }}</td>
                <td>
                  @if (row.requiere_talla) {
                    <select [ngModel]="row.id_talla_dotacion" (ngModelChange)="changeSize(row, $event)">
                      <option [ngValue]="null">Sin talla</option>
                      @for (option of sizeOptions(row.id_tipo_dotacion); track option.id_talla_dotacion) {
                        <option [ngValue]="option.id_talla_dotacion">{{ option.talla }}</option>
                      }
                    </select>
                  } @else { <span class="muted">No requiere talla</span> }
                </td>
                <td><input [ngModel]="row.observaciones || ''" (ngModelChange)="changeObservation(row, $event)" maxlength="250" /></td>
                <td><button class="btn small primary" type="button" (click)="save(row)" [disabled]="!row.requiere_talla || !row.id_talla_dotacion || savingArticleId() === row.id_dotacion_articulo">{{ savingArticleId() === row.id_dotacion_articulo ? 'Guardando...' : 'Guardar' }}</button></td>
              </tr>
            } @empty {
              <tr><td colspan="6" class="empty">{{ loading() ? 'Cargando tallas...' : 'No se encontraron articulos para este empleado.' }}</td></tr>
            }
          </tbody>
        </table>
      </div>
    </section>
  `,
})
export class EmployeeDotationSizesComponent implements OnInit {
  private readonly route = inject(ActivatedRoute);
  private readonly service = inject(DotationService);
  readonly sizes = signal<EmployeeDotationArticleSize[]>([]);
  readonly catalogSizes = signal<DotationSize[]>([]);
  readonly loading = signal(false);
  readonly savingArticleId = signal<number | null>(null);
  readonly error = signal('');
  readonly success = signal('');
  private employeeId = 0;

  ngOnInit(): void {
    this.employeeId = Number(this.route.snapshot.paramMap.get('employeeId'));
    this.load();
  }

  employeeName(): string { return this.sizes()[0]?.nombre_completo ?? ''; }

  load(): void {
    if (!this.employeeId) { this.error.set('Empleado no valido.'); return; }
    this.loading.set(true);
    this.error.set('');
    forkJoin({
      rows: this.service.getEmployeeArticleSizes(this.employeeId),
      catalog: this.service.getSizes(null, true),
    }).pipe(finalize(() => this.loading.set(false))).subscribe({
      next: ({ rows, catalog }) => { this.sizes.set(rows); this.catalogSizes.set(catalog); },
      error: (error) => this.error.set(apiErrorMessage(error, 'No fue posible cargar las tallas del empleado.')),
    });
  }

  sizeOptions(typeId: number): DotationSize[] {
    return this.catalogSizes().filter((size) => size.id_tipo_dotacion === typeId);
  }

  changeSize(row: EmployeeDotationArticleSize, sizeId: number | null): void {
    const selected = this.catalogSizes().find((size) => size.id_talla_dotacion === Number(sizeId));
    this.patchRow(row.id_dotacion_articulo, {
      id_talla_dotacion: sizeId ? Number(sizeId) : null,
      talla: selected?.talla ?? null,
    });
  }

  changeObservation(row: EmployeeDotationArticleSize, observations: string): void {
    this.patchRow(row.id_dotacion_articulo, { observaciones: observations });
  }

  save(row: EmployeeDotationArticleSize): void {
    if (!row.id_talla_dotacion) return;
    this.savingArticleId.set(row.id_dotacion_articulo);
    this.error.set(''); this.success.set('');
    this.service.saveEmployeeArticleSize(this.employeeId, row.id_dotacion_articulo, {
      id_talla_dotacion: row.id_talla_dotacion,
      observaciones: row.observaciones?.trim() || null,
    }).pipe(finalize(() => this.savingArticleId.set(null))).subscribe({
      next: (saved) => { this.patchRow(row.id_dotacion_articulo, saved); this.success.set(`Talla de ${saved.articulo} guardada correctamente.`); },
      error: (error) => this.error.set(apiErrorMessage(error, 'No fue posible guardar la talla.')),
    });
  }

  private patchRow(articleId: number, patch: Partial<EmployeeDotationArticleSize>): void {
    this.sizes.update((rows) => rows.map((row) => row.id_dotacion_articulo === articleId ? { ...row, ...patch } : row));
  }
}
