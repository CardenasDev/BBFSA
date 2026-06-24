import { Component, OnInit, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { finalize, forkJoin } from 'rxjs';
import { Area, ContractingEmployee, Position } from '../../core/models/api.models';
import { AuthService } from '../../core/services/auth.service';
import { CatalogService } from '../../core/services/catalog.service';
import { ContractingService } from '../../core/services/contracting.service';
import { apiErrorMessage } from '../../shared/api-error';

const EMPLOYEE_STATUSES = ['ACTIVO', 'RETIRADO', 'SUSPENDIDO', 'INCAPACITADO', 'EN_PROCESO_RETIRO'];

@Component({
  standalone: true,
  imports: [FormsModule, RouterLink],
  template: `
    <div class="page-heading">
      <div><p class="eyebrow">Contratacion</p><h1>Ficha de ingreso</h1><p class="muted">Seguimiento de ingreso, contratos, seguridad social, examenes y documentos.</p></div>
      @if (auth.hasPermission('CONTRATACION_ALERTAS_VER')) { <a class="btn secondary" routerLink="/admin/contracting/alerts">Alertas</a> }
    </div>

    <section class="panel">
      <form class="filters" (ngSubmit)="load()">
        <label>Buscar<input name="search" [(ngModel)]="search" placeholder="Documento, nombre, area o cargo" /></label>
        <label>Estado
          <select name="status" [(ngModel)]="status">
            <option value="">Todos</option>
            @for (item of statuses; track item) { <option [value]="item">{{ item }}</option> }
          </select>
        </label>
        <label>Area
          <select name="area" [(ngModel)]="areaId">
            <option [ngValue]="null">Todas</option>
            @for (area of areas(); track area.id_area) { <option [ngValue]="area.id_area">{{ area.nombre }}</option> }
          </select>
        </label>
        <label>Cargo
          <select name="position" [(ngModel)]="positionId">
            <option [ngValue]="null">Todos</option>
            @for (position of positions(); track position.id_cargo) { <option [ngValue]="position.id_cargo">{{ position.nombre }}</option> }
          </select>
        </label>
        <button class="btn secondary" type="submit" [disabled]="loading()">Filtrar</button>
      </form>

      @if (error()) { <div class="alert error" role="alert">{{ error() }} <button class="btn small ghost" type="button" (click)="load()" [disabled]="loading()">Reintentar</button></div> }

      <div class="table-wrap">
        <table>
          <thead><tr><th>Documento</th><th>Nombre</th><th>Area</th><th>Cargo</th><th>Contrato</th><th>Ficha</th><th>Fin contrato</th><th>Alertas</th><th>Acciones</th></tr></thead>
          <tbody>
            @for (employee of employees(); track employee.id_empleado) {
              <tr>
                <td><strong>{{ employee.numero_documento }}</strong><small class="muted">{{ employee.estado_empleado || 'Sin estado' }}</small></td>
                <td>{{ employee.nombre_completo }}</td>
                <td>{{ employee.area || 'Sin area' }}</td>
                <td>{{ employee.cargo || 'Sin cargo' }}</td>
                <td>
                  <span class="badge" [class.success]="employee.estado_contrato === 'ACTIVO'" [class.danger]="employee.estado_contrato === 'VENCIDO'">{{ employee.estado_contrato || 'Sin contrato' }}</span>
                  <small class="muted">{{ employee.tipo_contrato || '' }}</small>
                  <small class="muted">{{ employee.numero_contrato || 'Sin numero' }} - {{ employee.tipo_cargo_contrato || 'Sin tipo cargo' }}</small>
                  <small class="muted">{{ employee.periodo_pago || 'Sin periodo' }} - {{ employee.lugar_labores || 'Sin lugar' }}</small>
                </td>
                <td><span class="badge" [class.success]="!truthy(employee.ficha_pendiente)" [class.danger]="truthy(employee.ficha_pendiente)">{{ employee.estado_ficha || (truthy(employee.ficha_pendiente) ? 'PENDIENTE' : 'Sin dato') }}</span></td>
                <td>{{ employee.fecha_fin_contrato || 'Sin fecha' }}</td>
                <td>
                  <div class="chip-list">
                    @if (truthy(employee.ficha_pendiente)) { <span class="chip">Ficha pendiente</span> }
                    @if (truthy(employee.contrato_proximo_vencer)) { <span class="chip">Contrato proximo</span> }
                    @if (truthy(employee.contrato_vencido)) { <span class="chip">Contrato vencido</span> }
                  </div>
                </td>
                <td>
                  <div class="row-actions">
                    @if (auth.hasPermission('CONTRATACION_VER')) { <a class="btn small ghost" [routerLink]="['/admin/contracting/employees', employee.id_empleado, 'profile']">Ficha</a> }
                    @if (auth.hasPermission('CONTRATACION_HISTORIAL_VER')) { <a class="btn small ghost" [routerLink]="['/admin/contracting/employees', employee.id_empleado, 'contracts']">Contratos</a> }
                    @if (auth.hasPermission('CONTRATACION_SEGURIDAD_SOCIAL_VER')) { <a class="btn small ghost" [routerLink]="['/admin/contracting/employees', employee.id_empleado, 'social-security']">Seguridad social</a> }
                    @if (auth.hasPermission('CONTRATACION_EXAMENES_VER')) { <a class="btn small ghost" [routerLink]="['/admin/contracting/employees', employee.id_empleado, 'medical-exams']">Examenes</a> }
                    @if (auth.hasPermission('CONTRATACION_DOCUMENTOS_VER')) { <a class="btn small ghost" [routerLink]="['/admin/contracting/employees', employee.id_empleado, 'documents']">Documentos</a> }
                  </div>
                </td>
              </tr>
            } @empty {
              <tr><td colspan="9" class="empty">{{ loading() ? 'Cargando informacion de contratacion...' : 'No hay registros para mostrar.' }}</td></tr>
            }
          </tbody>
        </table>
      </div>
    </section>
  `,
})
export class ContractingEmployeesComponent implements OnInit {
  readonly auth = inject(AuthService);
  private readonly service = inject(ContractingService);
  private readonly catalogs = inject(CatalogService);
  readonly employees = signal<ContractingEmployee[]>([]);
  readonly areas = signal<Area[]>([]);
  readonly positions = signal<Position[]>([]);
  readonly loading = signal(false);
  readonly error = signal('');
  readonly statuses = EMPLOYEE_STATUSES;
  search = '';
  status = '';
  areaId: number | null = null;
  positionId: number | null = null;

  ngOnInit(): void {
    this.loadCatalogs();
    this.load();
  }

  load(): void {
    this.loading.set(true);
    this.error.set('');
    this.service.getEmployees({
      search: this.search,
      area_id: this.areaId,
      position_id: this.positionId,
      status: this.status,
    }).pipe(finalize(() => this.loading.set(false))).subscribe({
      next: (employees) => this.employees.set(employees),
      error: (error) => this.error.set(apiErrorMessage(error, 'No fue posible cargar la informacion de contratacion.')),
    });
  }

  loadCatalogs(): void {
    forkJoin({
      areas: this.catalogs.getAreas().pipe(finalize(() => undefined)),
      positions: this.catalogs.getPositions().pipe(finalize(() => undefined)),
    }).subscribe({
      next: ({ areas, positions }) => {
        this.areas.set(areas);
        this.positions.set(positions);
      },
      error: () => {
        this.areas.set([]);
        this.positions.set([]);
      },
    });
  }

  truthy(value: unknown): boolean {
    return value === true || value === 1 || value === '1';
  }
}
