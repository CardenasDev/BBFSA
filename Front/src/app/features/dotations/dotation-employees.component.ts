import { Component, OnInit, inject, signal } from '@angular/core';
import { HttpErrorResponse, HttpResponse } from '@angular/common/http';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { finalize, forkJoin, of } from 'rxjs';
import { Area, DotationDelivery, DotationEmployeeSummary, Position } from '../../core/models/api.models';
import { AuthService } from '../../core/services/auth.service';
import { CatalogService } from '../../core/services/catalog.service';
import { DotationService } from '../../core/services/dotation.service';
import { apiErrorMessage } from '../../shared/api-error';
import { blobErrorMessage, downloadBlob, downloadFilename } from '../../shared/file-download';

interface EmployeeDeliverySummary {
  total: number;
  pending: number;
  lastDate: string | null;
}

@Component({
  standalone: true,
  imports: [FormsModule, RouterLink],
  template: `
    <div class="page-heading">
      <div><p class="eyebrow">Dotaciones</p><h1>Control de dotaciones</h1><p class="muted">Consulta el historial agrupado por empleado.</p></div>
      @if (auth.hasPermission('DOTACIONES_ADMIN_VER')) {
        <button
          class="btn secondary"
          type="button"
          aria-label="Exportar cotización de dotaciones"
          (click)="exportQuotation()"
          [disabled]="exporting()"
        >
          {{ exporting() ? 'Generando archivo...' : 'Exportar cotización' }}
        </button>
      }
    </div>

    <section class="panel">
      <form class="filters" (ngSubmit)="loadEmployees()">
        <label>Buscar<input name="texto_busqueda" [(ngModel)]="textoBusqueda" placeholder="Documento o nombre" /></label>
        <label>Area
          <select name="id_area" [(ngModel)]="idArea">
            <option [ngValue]="null">Todas</option>
            @for (area of areas(); track area.id_area) { <option [ngValue]="area.id_area">{{ area.nombre }}</option> }
          </select>
        </label>
        <label>Cargo
          <select name="id_cargo" [(ngModel)]="idCargo">
            <option [ngValue]="null">Todos</option>
            @for (position of positions(); track position.id_cargo) { <option [ngValue]="position.id_cargo">{{ position.nombre }}</option> }
          </select>
        </label>
        <button class="btn secondary" type="submit" [disabled]="loading()">Filtrar</button>
      </form>

      @if (catalogsError()) { <div class="alert error">{{ catalogsError() }} <button class="btn small ghost" type="button" (click)="loadCatalogs()" [disabled]="loadingCatalogs()">Reintentar</button></div> }
      @if (error()) { <div class="alert error">{{ error() }} <button class="btn small ghost" type="button" (click)="loadEmployees()" [disabled]="loading()">Reintentar</button></div> }
      @if (exportStatus()) { <div class="alert success" role="status" aria-live="polite">{{ exportStatus() }}</div> }
      @if (exportError()) { <div class="alert error" role="alert">{{ exportError() }}</div> }

      <div class="table-wrap">
        <table>
          <thead><tr><th>Documento</th><th>Nombre completo</th><th>Area</th><th>Cargo</th><th>Total entregas</th><th>Pendientes</th><th>Ultima entrega</th><th>Resumen tallas</th><th>Acciones</th></tr></thead>
          <tbody>
            @for (employee of employees(); track employee.id_empleado) {
              <tr>
                <td><strong>{{ employee.numero_documento }}</strong></td>
                <td>{{ employee.nombre_completo }}</td>
                <td>{{ employee.area || 'Sin area' }}</td>
                <td>{{ employee.cargo || 'Sin cargo' }}</td>
                <td>{{ deliverySummary(employee).total }}</td>
                <td><span class="badge" [class.danger]="deliverySummary(employee).pending > 0" [class.success]="deliverySummary(employee).pending === 0">{{ deliverySummary(employee).pending }}</span></td>
                <td>{{ deliverySummary(employee).lastDate || 'Sin entregas' }}</td>
                <td>{{ employee.resumen_tallas || 'Sin tallas' }}</td>
                <td><div class="row-actions">
                  <a class="btn small primary" [routerLink]="['/admin/dotations/employees', employee.id_empleado, 'history']">Ver historial</a>
                  <a class="btn small ghost" [routerLink]="['/admin/dotations/employees', employee.id_empleado, 'sizes']">Ver tallas</a>
                  <a class="btn small secondary" [routerLink]="['/admin/dotations/deliveries/create']" [queryParams]="{ employeeId: employee.id_empleado }">Registrar entrega</a>
                </div></td>
              </tr>
            } @empty {
              <tr><td colspan="9" class="empty">{{ loading() ? 'Cargando empleados...' : 'No se encontraron empleados.' }}</td></tr>
            }
          </tbody>
        </table>
      </div>
    </section>
  `,
})
export class DotationEmployeesComponent implements OnInit {
  readonly auth = inject(AuthService);
  private readonly service = inject(DotationService);
  private readonly catalogService = inject(CatalogService);
  readonly employees = signal<DotationEmployeeSummary[]>([]);
  readonly summaries = signal<Record<number, EmployeeDeliverySummary>>({});
  readonly areas = signal<Area[]>([]);
  readonly positions = signal<Position[]>([]);
  readonly loading = signal(false);
  readonly loadingCatalogs = signal(false);
  readonly exporting = signal(false);
  readonly error = signal('');
  readonly catalogsError = signal('');
  readonly exportStatus = signal('');
  readonly exportError = signal('');
  textoBusqueda = '';
  idArea: number | null = null;
  idCargo: number | null = null;

  ngOnInit(): void {
    this.loadCatalogs();
    this.loadEmployees();
  }

  loadCatalogs(): void {
    this.loadingCatalogs.set(true);
    this.catalogsError.set('');
    forkJoin({ areas: this.catalogService.getAreas(true), positions: this.catalogService.getPositions(true) })
      .pipe(finalize(() => this.loadingCatalogs.set(false)))
      .subscribe({
        next: ({ areas, positions }) => {
          this.areas.set(areas);
          this.positions.set(positions);
        },
        error: (error) => this.catalogsError.set(apiErrorMessage(error, 'No fue posible cargar areas o cargos.')),
      });
  }

  loadEmployees(): void {
    this.loading.set(true);
    this.error.set('');
    const employees = this.service.getEmployees({
      texto_busqueda: this.textoBusqueda.trim(),
      id_area: this.idArea,
      id_cargo: this.idCargo,
    });
    const deliveries = this.auth.hasPermission('DOTACIONES_ENTREGAS_VER') ? this.service.getDeliveries() : of([]);

    forkJoin({ employees, deliveries }).pipe(finalize(() => this.loading.set(false))).subscribe({
      next: ({ employees, deliveries }) => {
        this.employees.set(employees);
        this.summaries.set(this.buildSummaries(employees, deliveries));
      },
      error: (error) => this.error.set(apiErrorMessage(error, 'No fue posible cargar empleados con tallas.')),
    });
  }

  exportQuotation(): void {
    if (this.exporting()) {
      return;
    }

    this.exporting.set(true);
    this.exportError.set('');
    this.exportStatus.set('Generando archivo de cotización...');

    this.service.exportQuotation({
      id_area: this.idArea,
      id_cargo: this.idCargo,
    }).pipe(finalize(() => this.exporting.set(false))).subscribe({
      next: (response) => this.handleQuotationResponse(response),
      error: (error) => void this.handleQuotationError(error),
    });
  }

  deliverySummary(employee: DotationEmployeeSummary): EmployeeDeliverySummary {
    return this.summaries()[employee.id_empleado] ?? {
      total: employee.total_entregas ?? 0,
      pending: employee.entregas_pendientes_confirmacion ?? 0,
      lastDate: employee.ultima_fecha_entrega ?? null,
    };
  }

  private buildSummaries(employees: DotationEmployeeSummary[], deliveries: DotationDelivery[]): Record<number, EmployeeDeliverySummary> {
    const summaries: Record<number, EmployeeDeliverySummary> = {};
    const useEmployeeSummary = deliveries.length === 0;
    employees.forEach((employee) => {
      summaries[employee.id_empleado] = {
        total: useEmployeeSummary ? employee.total_entregas ?? 0 : 0,
        pending: useEmployeeSummary ? employee.entregas_pendientes_confirmacion ?? 0 : 0,
        lastDate: useEmployeeSummary ? employee.ultima_fecha_entrega ?? null : null,
      };
    });
    deliveries.forEach((delivery) => {
      const summary = summaries[delivery.id_empleado] ?? { total: 0, pending: 0, lastDate: null };
      summary.total += 1;
      if (!delivery.fecha_confirmacion && delivery.estado === 'REGISTRADA') {
        summary.pending += 1;
      }
      if (!summary.lastDate || delivery.fecha_entrega > summary.lastDate) {
        summary.lastDate = delivery.fecha_entrega;
      }
      summaries[delivery.id_empleado] = summary;
    });
    return summaries;
  }

  private handleQuotationResponse(response: HttpResponse<Blob>): void {
    if (!response.body) {
      this.exportStatus.set('');
      this.exportError.set('No fue posible generar el archivo de cotización. Intenta nuevamente.');
      return;
    }

    downloadBlob(
      response.body,
      downloadFilename(response.headers.get('Content-Disposition'), 'cotizacion-dotacion.xlsx'),
    );
    this.exportStatus.set('El archivo de cotización fue generado correctamente.');
  }

  private async handleQuotationError(error: unknown): Promise<void> {
    this.exportStatus.set('');
    const fallback = 'No fue posible generar el archivo de cotización. Intenta nuevamente.';
    const backendMessage = await blobErrorMessage(error, fallback);

    if (error instanceof HttpErrorResponse && error.status === 404) {
      this.exportError.set(
        backendMessage === fallback
          ? 'No se encontró información de dotación para los filtros seleccionados.'
          : backendMessage,
      );
      return;
    }

    this.exportError.set(fallback);
  }
}
