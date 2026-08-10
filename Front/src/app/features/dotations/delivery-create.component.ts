import { Component, OnInit, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, Router, RouterLink } from '@angular/router';
import { finalize, forkJoin } from 'rxjs';
import {
  CreateDotationDeliveryRequest,
  DotationArticle,
  DotationCombination,
  DotationEvidenceOrigin,
  DotationDeliveryType,
  DotationEmployeeSummary,
  DotationType,
  EmployeeDotationArticleSize,
  EmployeeDotationSize,
} from '../../core/models/api.models';
import { DotationService } from '../../core/services/dotation.service';
import { apiErrorMessage } from '../../shared/api-error';
import { CameraFilePickerComponent } from '../../shared/camera-file-picker.component';

interface DeliveryDetailDraft {
  clientId: number;
  id_dotacion_articulo?: number | null;
  articulo?: string;
  genero?: string;
  unidad_medida?: string;
  id_tipo_dotacion: number | null;
  tipo_dotacion: string;
  requiere_talla: boolean;
  id_talla_dotacion: number | null;
  talla: string | null;
  cantidad: number;
  observaciones: string;
}

@Component({
  standalone: true,
  imports: [FormsModule, RouterLink, CameraFilePickerComponent],
  template: `
    <div class="page-heading">
      <div>
        <p class="eyebrow">Dotaciones</p>
        <h1>
          {{ estadoInicial === 'POR_COMPRAR' ? 'Nueva solicitud de compra' : 'Nueva entrega' }}
        </h1>
        <p class="muted">Registra prendas por comprar o listas para entregar.</p>
      </div>
      <a class="btn ghost" routerLink="/admin/dotations/deliveries">Volver</a>
    </div>

    <section class="panel">
      @if (success()) {
        <div class="alert success">{{ success() }}</div>
      }
      @if (error()) {
        <div class="alert error">{{ error() }}</div>
      }
      @if (catalogError()) {
        <div class="alert error">
          {{ catalogError() }}
          <button
            class="btn small ghost"
            type="button"
            (click)="loadInitialData()"
            [disabled]="loading()"
          >
            Reintentar
          </button>
        </div>
      }

      <form class="form-grid" (ngSubmit)="submit()">
        <label class="form-wide"
          >Buscar empleado
          <input
            name="employeeSearch"
            [(ngModel)]="employeeSearch"
            placeholder="Documento, nombre, area o cargo"
          />
        </label>
        <label class="form-wide"
          >Empleado *
          <select
            name="id_empleado"
            [ngModel]="idEmpleado"
            (ngModelChange)="changeEmployee($event)"
            required
          >
            <option [ngValue]="null">
              {{ loading() ? 'Cargando...' : 'Selecciona un empleado' }}
            </option>
            @for (employee of filteredEmployees(); track employee.id_empleado) {
              <option [ngValue]="employee.id_empleado">
                {{ employee.numero_documento }} - {{ employee.nombre_completo }}
              </option>
            }
          </select>
        </label>

        <label
          >Tipo de entrega *
          <select
            name="tipo_entrega"
            [ngModel]="tipoEntrega"
            (ngModelChange)="changeDeliveryType($event)"
            required
          >
            <option value="ORDINARIA">Ordinaria</option>
            <option value="EXTRAORDINARIA">Extraordinaria</option>
          </select>
        </label>

        <label
          >Estado inicial *
          <select
            name="estado_inicial"
            [ngModel]="estadoInicial"
            (ngModelChange)="changeInitialStatus($event)"
            required
          >
            <option value="POR_COMPRAR">Por comprar</option>
            <option value="REGISTRADA">Lista para entregar</option>
          </select>
        </label>

        @if (tipoEntrega === 'ORDINARIA') {
          <label
            >Combinacion de dotacion <span class="optional">opcional</span>
            <select
              name="id_dotacion_combinacion"
              [ngModel]="idCombinacion"
              (ngModelChange)="changeCombination($event)"
              [disabled]="combinationLoading()"
            >
              <option [ngValue]="null">Sin combinacion</option>
              @for (combination of combinations(); track combination.id_dotacion_combinacion) {
                <option [ngValue]="combination.id_dotacion_combinacion">
                  {{ combination.codigo }} - {{ combination.nombre }}
                </option>
              }
            </select>
          </label>
        }

        <label
          >{{ estadoInicial === 'POR_COMPRAR' ? 'Fecha requerida' : 'Fecha de entrega' }} *<input
            type="date"
            name="fecha_entrega"
            [(ngModel)]="fechaEntrega"
            required
        /></label>
        <label class="form-wide"
          >Observaciones<textarea
            rows="3"
            name="observaciones"
            [(ngModel)]="observaciones"
          ></textarea>
        </label>

        @if (estadoInicial === 'REGISTRADA') {
          <div class="form-wide drawer-section">
            <div class="section-title">
              <div>
                <h2>Evidencia de entrega *</h2>
                <p class="muted">
                  Adjunta una fotografia o documento que evidencie la entrega de la dotacion al
                  empleado.
                </p>
              </div>
            </div>
            <div class="form-grid">
              <label
                >Origen de evidencia *
                <select
                  name="origen_evidencia"
                  [ngModel]="origenEvidencia"
                  (ngModelChange)="changeEvidenceOrigin($event)"
                  required
                >
                  <option value="ARCHIVO">Archivo</option>
                  <option value="URL">URL externa</option>
                </select>
              </label>
              @if (origenEvidencia === 'ARCHIVO') {
                <div class="form-wide">
                  <span class="field-label">Archivo de evidencia *</span>
                  <app-camera-file-picker
                    accept=".pdf,.jpg,.jpeg,.png,.webp,.doc,.docx"
                    galleryLabel="Seleccionar de galería o archivos"
                    (filesSelected)="setEvidenceFiles($event)"
                  />
                </div>
                @if (evidenciaArchivo) {
                  <div class="form-wide row-actions">
                    <span
                      ><strong>{{ evidenciaArchivo.name }}</strong>
                      <span class="muted">{{ readableFileSize(evidenciaArchivo.size) }}</span></span
                    >
                    <button
                      class="btn small danger-outline"
                      type="button"
                      (click)="removeEvidenceFile()"
                    >
                      Quitar
                    </button>
                  </div>
                }
              } @else {
                <label class="form-wide"
                  >URL de evidencia *
                  <input
                    type="url"
                    name="evidencia_url"
                    [(ngModel)]="evidenciaUrl"
                    maxlength="500"
                    placeholder="https://..."
                  />
                </label>
              }
              @if (evidenceError()) {
                <div class="form-wide alert error">{{ evidenceError() }}</div>
              }
            </div>
          </div>
        }

        <div class="form-wide section-title">
          <div>
            <h2>Articulos</h2>
            <p class="muted">
              Se muestran los articulos con talla especifica registrada para el empleado y los elementos que no requieren talla.
            </p>
          </div>
          <button class="btn secondary" type="button" (click)="addDetail()">
            Agregar articulo
          </button>
        </div>

        @if (employeeSizesLoading()) {
          <div class="form-wide empty">Cargando tallas registradas del empleado...</div>
        }

        <div class="form-wide table-wrap">
          <table>
            <thead>
              <tr>
                <th>Articulo</th>
                <th>Familia</th>
                <th>Genero / unidad</th>
                <th>Talla registrada</th>
                <th>Cantidad</th>
                <th>Observaciones</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              @for (detail of details(); track detail.clientId) {
                <tr>
                  <td>
                    <select
                      [ngModel]="detail.id_dotacion_articulo"
                      [name]="'articulo_' + detail.clientId"
                      (ngModelChange)="updateArticle(detail.clientId, $event)"
                    >
                      <option [ngValue]="null">
                        {{ filteredArticles(detail).length ? 'Selecciona un articulo' : 'No hay articulos disponibles' }}
                      </option>
                      @for (
                        article of filteredArticles(detail);
                        track article.id_dotacion_articulo
                      ) {
                        <option
                          [ngValue]="article.id_dotacion_articulo"
                          [disabled]="
                            isArticleSelected(article.id_dotacion_articulo, detail.clientId)
                          "
                        >
                          {{ article.articulo }}
                        </option>
                      }
                    </select>
                  </td>
                  <td>{{ detail.tipo_dotacion || 'Pendiente' }}</td>
                  <td>{{ detail.genero || '—' }} / {{ detail.unidad_medida || '—' }}</td>
                  <td>
                    @if (!detail.requiere_talla) {
                      <span class="muted">No requiere talla</span>
                    } @else if (detail.id_talla_dotacion) {
                      <strong>{{ detail.talla }}</strong>
                    } @else {
                      <span class="badge danger">Talla no registrada</span>
                    }
                  </td>
                  <td>
                    <input
                      type="number"
                      min="1"
                      [ngModel]="detail.cantidad"
                      [name]="'cantidad_' + detail.clientId"
                      (ngModelChange)="updateDetail(detail.clientId, 'cantidad', $event)"
                    />
                  </td>
                  <td>
                    <input
                      maxlength="250"
                      [ngModel]="detail.observaciones"
                      [name]="'observaciones_' + detail.clientId"
                      (ngModelChange)="updateDetail(detail.clientId, 'observaciones', $event)"
                    />
                  </td>
                  <td>
                    <button
                      class="btn small danger-outline"
                      type="button"
                      (click)="removeDetail(detail.clientId)"
                    >
                      Eliminar
                    </button>
                  </td>
                </tr>
              } @empty {
                <tr>
                  <td colspan="7" class="empty">Agrega al menos un articulo.</td>
                </tr>
              }
            </tbody>
          </table>
        </div>

        <div class="form-actions form-wide">
          <a class="btn ghost" routerLink="/admin/dotations/deliveries">Cancelar</a>
          <button
            class="btn primary"
            type="submit"
            [disabled]="saving() || loading() || employeeSizesLoading() || combinationLoading()"
          >
            {{
              saving()
                ? 'Guardando...'
                : estadoInicial === 'POR_COMPRAR'
                  ? 'Registrar solicitud'
                  : 'Registrar entrega'
            }}
          </button>
        </div>
      </form>
    </section>
  `,
})
export class DotationDeliveryCreateComponent implements OnInit {
  private readonly service = inject(DotationService);
  private readonly route = inject(ActivatedRoute);
  private readonly router = inject(Router);
  readonly employees = signal<DotationEmployeeSummary[]>([]);
  readonly types = signal<DotationType[]>([]);
  readonly articles = signal<DotationArticle[]>([]);
  readonly combinations = signal<DotationCombination[]>([]);
  readonly employeeSizes = signal<EmployeeDotationSize[]>([]);
  readonly employeeArticleSizes = signal<EmployeeDotationArticleSize[]>([]);
  readonly details = signal<DeliveryDetailDraft[]>([]);
  readonly loading = signal(false);
  readonly employeeSizesLoading = signal(false);
  readonly combinationLoading = signal(false);
  readonly saving = signal(false);
  readonly error = signal('');
  readonly catalogError = signal('');
  readonly success = signal('');
  readonly evidenceError = signal('');
  private nextDetailId = 1;
  employeeSearch = '';
  idEmpleado: number | null = null;
  tipoEntrega: DotationDeliveryType = 'ORDINARIA';
  estadoInicial: 'POR_COMPRAR' | 'REGISTRADA' = 'REGISTRADA';
  idCombinacion: number | null = null;
  fechaEntrega = new Date().toISOString().slice(0, 10);
  observaciones = '';
  origenEvidencia: DotationEvidenceOrigin | null = 'ARCHIVO';
  evidenciaArchivo: File | null = null;
  evidenciaUrl = '';

  ngOnInit(): void {
    const employeeId = Number(this.route.snapshot.queryParamMap.get('employeeId'));
    this.idEmpleado = Number.isFinite(employeeId) && employeeId > 0 ? employeeId : null;
    this.details.set([this.newDetail()]);
    this.loadInitialData();
  }

  loadInitialData(): void {
    this.loading.set(true);
    this.catalogError.set('');
    forkJoin({
      employees: this.service.getEmployees(),
      types: this.service.getTypes(true),
      articles: this.service.getArticles(),
      combinations: this.service.getCombinations(),
    })
      .pipe(finalize(() => this.loading.set(false)))
      .subscribe({
        next: ({ employees, types, articles, combinations }) => {
          this.employees.set(employees);
          this.types.set(types);
          this.articles.set(articles);
          this.combinations.set(combinations);
          if (this.idEmpleado) this.loadEmployeeSizes(this.idEmpleado);
        },
        error: (error) =>
          this.catalogError.set(
            apiErrorMessage(error, 'No fue posible cargar empleados, tipos o combinaciones.'),
          ),
      });
  }

  filteredEmployees(): DotationEmployeeSummary[] {
    const term = this.employeeSearch.trim().toLowerCase();
    if (!term) return this.employees();
    return this.employees().filter((employee) =>
      [
        employee.numero_documento,
        employee.nombre_completo,
        employee.area ?? '',
        employee.cargo ?? '',
      ].some((value) => value.toLowerCase().includes(term)),
    );
  }

  changeEmployee(employeeId: number | null): void {
    this.idEmpleado = employeeId ? Number(employeeId) : null;
    this.employeeSizes.set([]);
    this.details.update((details) =>
      details.map((detail) => ({ ...detail, id_talla_dotacion: null, talla: null })),
    );
    if (this.idEmpleado) this.loadEmployeeSizes(this.idEmpleado);
  }

  changeDeliveryType(type: DotationDeliveryType): void {
    this.tipoEntrega = type;
    this.idCombinacion = null;
    this.details.set([this.newDetail()]);
    this.error.set('');
  }

  changeInitialStatus(status: 'POR_COMPRAR' | 'REGISTRADA'): void {
    this.estadoInicial = status;
    this.evidenceError.set('');
    if (status === 'POR_COMPRAR') {
      this.origenEvidencia = null;
      this.evidenciaArchivo = null;
      this.evidenciaUrl = '';
    } else if (!this.origenEvidencia) {
      this.origenEvidencia = 'ARCHIVO';
    }
  }

  changeCombination(combinationId: number | null): void {
    this.idCombinacion = combinationId ? Number(combinationId) : null;
    this.details.set(this.idCombinacion ? [] : [this.newDetail()]);
    if (!this.idCombinacion) return;
    this.combinationLoading.set(true);
    this.error.set('');
    this.service
      .getCombinationDetail(this.idCombinacion)
      .pipe(finalize(() => this.combinationLoading.set(false)))
      .subscribe({
        next: (items) =>
          this.details.set(
            items.map((item) =>
              this.withEmployeeSize({
                clientId: this.nextDetailId++,
                id_dotacion_articulo: null,
                articulo: '',
                genero: '',
                unidad_medida: '',
                id_tipo_dotacion: item.id_tipo_dotacion,
                tipo_dotacion: item.tipo_dotacion,
                requiere_talla: item.requiere_talla,
                id_talla_dotacion: null,
                talla: null,
                cantidad: item.cantidad,
                observaciones: '',
              }),
            ),
          ),
        error: (error) =>
          this.error.set(
            apiErrorMessage(error, 'No fue posible cargar el detalle de la combinacion.'),
          ),
      });
  }

  addDetail(): void {
    this.details.update((details) => [...details, this.newDetail()]);
  }

  removeDetail(clientId: number): void {
    this.details.update((details) => details.filter((detail) => detail.clientId !== clientId));
  }

  updateArticle(clientId: number, articleId: number | null): void {
    const normalizedId = articleId ? Number(articleId) : null;
    const article = this.articles().find((item) => item.id_dotacion_articulo === normalizedId);
    this.details.update((details) =>
      details.map((detail) =>
        detail.clientId === clientId
          ? this.withEmployeeSize({
              ...detail,
              id_dotacion_articulo: normalizedId,
              articulo: article?.articulo ?? '',
              genero: article?.genero ?? '',
              unidad_medida: article?.unidad_medida ?? '',
              id_tipo_dotacion: article?.id_tipo_dotacion ?? detail.id_tipo_dotacion,
              tipo_dotacion: article?.tipo_dotacion ?? detail.tipo_dotacion,
              requiere_talla: Boolean(article?.requiere_talla),
              id_talla_dotacion: null,
              talla: null,
            })
          : detail,
      ),
    );
  }

  updateDetail(
    clientId: number,
    key: 'cantidad' | 'observaciones',
    value: number | string | null,
  ): void {
    this.details.update((details) =>
      details.map((detail) => {
        if (detail.clientId !== clientId) return detail;
        return key === 'cantidad'
          ? { ...detail, cantidad: Number(value) }
          : { ...detail, observaciones: String(value ?? '').slice(0, 250) };
      }),
    );
  }

  filteredArticles(detail: DeliveryDetailDraft): DotationArticle[] {
    if (!this.idEmpleado || this.employeeSizesLoading()) return [];

    const eligible = this.articles().filter((article) => this.employeeCanUseArticle(article));
    if (!detail.id_tipo_dotacion || detail.id_dotacion_articulo) return eligible;
    return eligible.filter(
      (article) => article.id_tipo_dotacion === detail.id_tipo_dotacion,
    );
  }

  private employeeCanUseArticle(article: DotationArticle): boolean {
    if (!article.requiere_talla) return true;

    return this.employeeArticleSizes().some(
      (size) =>
        size.id_dotacion_articulo === article.id_dotacion_articulo &&
        Boolean(size.id_talla_dotacion),
    );
  }

  isArticleSelected(articleId: number, currentClientId: number): boolean {
    return this.details().some(
      (detail) => detail.clientId !== currentClientId && detail.id_dotacion_articulo === articleId,
    );
  }

  changeEvidenceOrigin(origin: DotationEvidenceOrigin): void {
    this.origenEvidencia = origin;
    this.evidenciaArchivo = null;
    this.evidenciaUrl = '';
    this.evidenceError.set('');
  }

  selectEvidenceFile(event: Event): void {
    const input = event.target as HTMLInputElement;
    this.setEvidenceFiles([...(input.files ?? [])]);
    input.value = '';
  }

  setEvidenceFiles(files: File[]): void {
    const file = files[0] ?? null;
    this.evidenceError.set('');
    if (!file) {
      this.evidenciaArchivo = null;
      return;
    }
    const validation = this.validateEvidenceFile(file);
    if (validation) {
      this.evidenciaArchivo = null;
      this.evidenceError.set(validation);
      return;
    }
    this.evidenciaArchivo = file;
  }

  removeEvidenceFile(input?: HTMLInputElement): void {
    this.evidenciaArchivo = null;
    if (input) input.value = '';
    this.evidenceError.set('');
  }

  readableFileSize(bytes: number): string {
    return bytes < 1024 * 1024
      ? `${Math.max(1, Math.round(bytes / 1024))} KB`
      : `${(bytes / 1024 / 1024).toFixed(1)} MB`;
  }

  submit(): void {
    this.error.set('');
    this.success.set('');
    const validation = this.validate();
    if (validation) {
      this.error.set(validation);
      return;
    }

    const payload: CreateDotationDeliveryRequest = {
      id_empleado: this.idEmpleado!,
      fecha_entrega: this.fechaEntrega,
      tipo_entrega: this.tipoEntrega,
      id_dotacion_combinacion: this.tipoEntrega === 'ORDINARIA' ? this.idCombinacion : null,
      observaciones: this.blankToNull(this.observaciones),
      estado_inicial: this.estadoInicial,
      origen_evidencia: this.estadoInicial === 'REGISTRADA' ? this.origenEvidencia : undefined,
      evidencia_archivo:
        this.estadoInicial === 'REGISTRADA' && this.origenEvidencia === 'ARCHIVO'
          ? this.evidenciaArchivo
          : null,
      evidencia_url:
        this.estadoInicial === 'REGISTRADA' && this.origenEvidencia === 'URL'
          ? this.evidenciaUrl.trim()
          : null,
      ...(this.estadoInicial === 'REGISTRADA'
        ? { evidencia_nombre_archivo: 'Evidencia entrega' }
        : {}),
      detalles: this.details().map((detail) => ({
        id_dotacion_articulo: detail.id_dotacion_articulo!,
        id_tipo_dotacion: detail.id_tipo_dotacion!,
        id_talla_dotacion: detail.requiere_talla ? detail.id_talla_dotacion : null,
        cantidad: Number(detail.cantidad),
        observaciones: this.blankToNull(detail.observaciones),
      })),
    };

    this.saving.set(true);
    this.service
      .createDelivery(payload)
      .pipe(finalize(() => this.saving.set(false)))
      .subscribe({
        next: (result) => {
          this.evidenciaArchivo = null;
          this.evidenciaUrl = '';
          this.success.set(
            this.estadoInicial === 'POR_COMPRAR'
              ? 'Solicitud de compra registrada correctamente.'
              : 'Entrega de dotacion registrada correctamente.',
          );
          void this.router.navigate(['/admin/dotations/deliveries', result.id_dotacion_entrega]);
        },
        error: (error) =>
          this.error.set(
            apiErrorMessage(error, 'No fue posible registrar la entrega de dotacion.'),
          ),
      });
  }

  private loadEmployeeSizes(employeeId: number): void {
    this.employeeSizesLoading.set(true);
    forkJoin({
      family: this.service.getEmployeeSizes(employeeId),
      article: this.service.getEmployeeArticleSizes(employeeId),
    })
      .pipe(finalize(() => this.employeeSizesLoading.set(false)))
      .subscribe({
        next: ({ family, article }) => {
          if (employeeId !== this.idEmpleado) return;
          this.employeeSizes.set(family);
          this.employeeArticleSizes.set(article);
          this.details.update((details) => details.map((detail) => this.withEmployeeSize(detail)));
        },
        error: (error) =>
          this.error.set(apiErrorMessage(error, 'No fue posible cargar las tallas del empleado.')),
      });
  }

  private withEmployeeSize(detail: DeliveryDetailDraft): DeliveryDetailDraft {
    if (!detail.id_tipo_dotacion || !detail.requiere_talla) {
      return { ...detail, id_talla_dotacion: null, talla: null };
    }
    const exact = this.employeeArticleSizes().find(
      (item) => item.id_dotacion_articulo === detail.id_dotacion_articulo && item.id_talla_dotacion,
    );
    const registered = exact ?? this.employeeSizes().find(
      (item) => item.id_tipo_dotacion === detail.id_tipo_dotacion,
    );
    return {
      ...detail,
      id_talla_dotacion: registered?.id_talla_dotacion ?? null,
      talla: registered?.talla ?? null,
    };
  }

  private validate(): string {
    if (!this.idEmpleado) return 'Selecciona un empleado.';
    if (!this.tipoEntrega) return 'Selecciona el tipo de entrega.';
    if (!this.fechaEntrega)
      return this.estadoInicial === 'POR_COMPRAR'
        ? 'Selecciona la fecha requerida.'
        : 'Selecciona la fecha de entrega.';
    if (this.estadoInicial === 'REGISTRADA' && !this.origenEvidencia)
      return 'Selecciona el origen de la evidencia.';
    if (this.estadoInicial === 'REGISTRADA' && this.origenEvidencia === 'ARCHIVO') {
      if (!this.evidenciaArchivo) return 'Selecciona el archivo de evidencia.';
      const evidenceValidation = this.validateEvidenceFile(this.evidenciaArchivo);
      if (evidenceValidation) return evidenceValidation;
    } else if (this.estadoInicial === 'REGISTRADA' && !this.isValidHttpUrl(this.evidenciaUrl)) {
      return this.evidenciaUrl.trim()
        ? 'La URL de evidencia no es valida.'
        : 'Ingresa la URL de evidencia.';
    }
    if (!this.details().length) return 'Agrega al menos una prenda.';
    const selected = new Set<number>();
    for (const [index, detail] of this.details().entries()) {
      const row = index + 1;
      if (!detail.id_dotacion_articulo) return `Selecciona el articulo en la fila ${row}.`;
      if (!detail.id_tipo_dotacion)
        return `El articulo de la fila ${row} no tiene una familia valida.`;
      if (selected.has(detail.id_dotacion_articulo))
        return `El articulo ${detail.articulo} esta duplicado.`;
      selected.add(detail.id_dotacion_articulo);
      if (!Number.isFinite(Number(detail.cantidad)) || Number(detail.cantidad) < 1)
        return `La cantidad de la fila ${row} debe ser mayor a cero.`;
      if (detail.requiere_talla && !detail.id_talla_dotacion)
        return `El empleado no tiene registrada talla para ${detail.articulo}.`;
    }
    return '';
  }

  private validateEvidenceFile(file: File): string {
    if (file.size > 5 * 1024 * 1024) return 'El archivo de evidencia no puede superar 5 MB.';
    const extension = file.name.split('.').pop()?.toLowerCase() ?? '';
    if (!['pdf', 'jpg', 'jpeg', 'png', 'webp', 'doc', 'docx'].includes(extension))
      return 'Formato de evidencia no permitido.';
    return '';
  }

  private isValidHttpUrl(value: string): boolean {
    try {
      const url = new URL(value.trim());
      return url.protocol === 'http:' || url.protocol === 'https:';
    } catch {
      return false;
    }
  }

  private newDetail(): DeliveryDetailDraft {
    return {
      clientId: this.nextDetailId++,
      id_dotacion_articulo: null,
      articulo: '',
      genero: '',
      unidad_medida: '',
      id_tipo_dotacion: null,
      tipo_dotacion: '',
      requiere_talla: false,
      id_talla_dotacion: null,
      talla: null,
      cantidad: 1,
      observaciones: '',
    };
  }

  private blankToNull(value: string): string | null {
    const text = value.trim();
    return text ? text : null;
  }
}
