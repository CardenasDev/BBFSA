import { CommonModule } from '@angular/common';
import { Component, computed, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
import { Employee, EmployeeFilters } from '../../core/models/api.models';
import { EvaluationEmployee, EvaluationLabor, EvaluationScoreInput } from '../../core/models/evaluation.models';
import { EvaluationService } from '../../core/services/evaluation.service';
import { EmployeeService } from '../../core/services/employee.service';

@Component({
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    @if (detail(); as d) {
      <header class="page-header">
        <div>
          <h1>Evaluación semana {{ d.evaluation.numero_semana }} · {{ d.evaluation.anio }}</h1>
          <p>{{ d.evaluation.fecha_inicio }} a {{ d.evaluation.fecha_fin || '-' }} · {{ d.evaluation.estado }}</p>
        </div>
        <div class="header-actions">
          <button class="btn" (click)="goPanel()">Panel gerencial</button>
          <button class="btn primary" (click)="save()" [disabled]="saving() || touchedCount() === 0">
            @if (saving()) { <span class="spinner"></span> Guardando... } @else { Guardar cambios }
          </button>
        </div>
      </header>

      @if (message()) { <div class="notice ok">{{ message() }}</div> }
      @if (error()) { <div class="notice bad">{{ error() }}</div> }

      <section class="toolbar card">
        <div class="employee-autocomplete">
          <input
            type="text"
            placeholder="Buscar empleado por nombre o documento..."
            [value]="employeeSearch()"
            (input)="employeeSearch.set($any($event.target).value); selectedEmployeeId = null; employeeDropdownOpen.set(true)"
            (focus)="employeeDropdownOpen.set(true)"
            (blur)="closeEmployeeDropdown()"
          />
          @if (employeeDropdownOpen()) {
            <div class="dropdown">
              @for (e of filteredAvailableEmployees(); track e.id_empleado) {
                <button type="button" class="dropdown-item" (mousedown)="selectEmployee(e)">
                  {{ e.numero_documento }} - {{ e.nombres }} {{ e.apellidos }}
                </button>
              } @empty {
                <div class="dropdown-empty">No hay empleados disponibles.</div>
              }
            </div>
          }
        </div>
        <button class="btn" (click)="addEmployee()" [disabled]="!selectedEmployeeId || adding()">Agregar empleado</button>
        <button class="btn success" (click)="addAllActive()" [disabled]="addingAll()">
          @if (addingAll()) { <span class="spinner"></span> Agregando... } @else { Agregar todos los activos }
        </button>
        <span class="hint">Cambios pendientes: {{ touchedCount() }}</span>
      </section>

      <section class="card table-wrap">
        @if (loading()) {
          <p>Cargando matriz...</p>
        } @else {
          <table>
            <thead>
              <tr>
                <th>Empleado</th>
                @for (labor of labors(); track labor.id_evaluacion_labor) {
                  <th>{{ labor.nombre }}<br /><small>Máx. {{ maxFor(labor) }}</small></th>
                }
                <th>Total semana</th>
              </tr>
            </thead>
            <tbody>
              @for (emp of d.employees; track emp.id_evaluacion_empleado) {
                <tr>
                  <td>
                    <strong>{{ emp.empleado || (emp.nombres + ' ' + emp.apellidos) }}</strong>
                    <div class="doc">{{ emp.numero_documento }}</div>
                  </td>
                  @for (labor of labors(); track labor.id_evaluacion_labor) {
                    <td>
                      <input
                        type="number"
                        min="0"
                        [max]="maxFor(labor)"
                        [ngModel]="cellValue(emp.id_empleado, labor.id_evaluacion_labor)"
                        (ngModelChange)="setCell(emp.id_empleado, labor.id_evaluacion_labor, $event, maxFor(labor))"
                      />
                    </td>
                  }
                  <td class="total">{{ rowTotal(emp.id_empleado) }}</td>
                </tr>
              } @empty {
                <tr><td [attr.colspan]="labors().length + 2">
                  No hay empleados asignados a esta evaluación.
                </td></tr>
              }
            </tbody>
          </table>
        }
      </section>
    } @else if (loading()) {
      <p>Cargando evaluación...</p>
    } @else if (error()) {
      <div class="notice bad">{{ error() }}</div>
    }
  `,
  styles: [`
    :host { display:block; }
    .page-header { display:flex; justify-content:space-between; align-items:center; margin-bottom:16px; gap:12px; flex-wrap:wrap; }
    .header-actions { display:flex; gap:8px; }
    .card { background:#fff; border:1px solid #dce5e1; border-radius:14px; padding:16px; margin-bottom:16px; }
    .toolbar { display:flex; gap:10px; align-items:center; flex-wrap:wrap; }
    .employee-autocomplete { position:relative; width:320px; }
    .employee-autocomplete input { width:100%; padding:8px; border:1px solid #cbd8d2; border-radius:8px; }
    .dropdown { position:absolute; top:100%; left:0; right:0; max-height:240px; overflow:auto; background:#fff; border:1px solid #cbd8d2; border-radius:8px; margin-top:4px; z-index:20; box-shadow:0 8px 20px rgba(0,0,0,.08); }
    .dropdown-item { display:block; width:100%; text-align:left; padding:8px 10px; border:0; background:#fff; cursor:pointer; }
    .dropdown-item:hover { background:#eef7f3; }
    .dropdown-empty { padding:10px; color:#607068; }
    table { width:100%; border-collapse:collapse; }
    th,td { padding:10px; border-bottom:1px solid #e4ebe7; text-align:left; vertical-align:top; }
    th small { color:#607068; font-weight:400; }
    input { width:78px; padding:6px; border:1px solid #cbd8d2; border-radius:7px; }
    .total { font-weight:800; }
    .doc { color:#607068; font-size:.8rem; }
    .btn { padding:8px 12px; border:1px solid #cbd8d2; border-radius:8px; background:#fff; cursor:pointer; }
    .btn.primary { background:#08745b; color:#fff; border-color:#08745b; }
    .btn.success { background:#08745b; color:#fff; border-color:#08745b; }
    .btn:disabled { opacity:.6; cursor:not-allowed; }
    .hint { color:#607068; }
    .notice { padding:10px; margin:10px 0; border-radius:8px; }
    .notice.ok { background:#e7f7ef; }
    .notice.bad { background:#fff0f0; color:#a11; }
    .table-wrap { overflow:auto; }
    .spinner { display:inline-block; width:14px; height:14px; border:2px solid rgba(255,255,255,.45); border-top-color:#fff; border-radius:50%; animation:spin .75s linear infinite; margin-right:6px; vertical-align:-2px; }
    @keyframes spin { to { transform:rotate(360deg);} }
  `],
})
export class EvaluationDetailComponent {
  private readonly api = inject(EvaluationService);
  private readonly employeesApi = inject(EmployeeService);
  private readonly route = inject(ActivatedRoute);
  private readonly router = inject(Router);

  id = Number(this.route.snapshot.paramMap.get('id'));

  detail = signal<any>(null);
  labors = signal<EvaluationLabor[]>([]);
  availableEmployees = signal<Employee[]>([]);
  selectedEmployeeId: number | null = null;

  loading = signal(false);
  saving = signal(false);
  adding = signal(false);
  addingAll = signal(false);
  error = signal('');
  message = signal('');

  values = signal<Record<string, number | null>>({});
  touched = new Set<string>();

  employeeSearch = signal('');
  employeeDropdownOpen = signal(false);

  filteredAvailableEmployees = computed(() => {
    const query = this.employeeSearch().trim().toLowerCase();
    const employees = this.availableEmployees() || [];
    if (!query) return employees;
    return employees.filter((emp: any) => {
      const name = `${emp.nombres || ''} ${emp.apellidos || ''}`.toLowerCase();
      const document = String(emp.numero_documento || '').toLowerCase();
      return name.includes(query) || document.includes(query);
    });
  });

  selectEmployee(emp: any): void {
    this.selectedEmployeeId = emp.id_empleado;
    this.employeeSearch.set(`${emp.numero_documento} - ${emp.nombres} ${emp.apellidos}`);
    this.employeeDropdownOpen.set(false);
  }

  closeEmployeeDropdown(): void {
    setTimeout(() => this.employeeDropdownOpen.set(false), 150);
  }

  constructor() {
    this.load();
    this.employeesApi.listEmployees({ estado: 'ACTIVO' } as EmployeeFilters).subscribe({
      next: (rows) => this.availableEmployees.set(rows),
      error: () => this.availableEmployees.set([]),
    });
  }

  load(): void {
    this.loading.set(true);
    this.error.set('');
    this.api.getEvaluationDetail(this.id).subscribe({
      next: (d) => {
        this.detail.set(d);
        this.values.set(this.buildValues(d.employees || []));
        this.touched.clear();
        this.loading.set(false);
      },
      error: (e) => {
        this.loading.set(false);
        this.error.set(e?.error?.message || 'No fue posible consultar la evaluación.');
      },
    });
    this.api.getLaborsCatalog().subscribe({
      next: (rows) => this.labors.set(rows),
      error: () => this.labors.set([]),
    });
  }

  private buildValues(employees: EvaluationEmployee[]): Record<string, number | null> {
    const result: Record<string, number | null> = {};
    employees.forEach((emp) => {
      (emp.detalles || []).forEach((det) => {
        result[`${emp.id_empleado}-${det.id_evaluacion_labor}`] = det.valor_obtenido ?? null;
      });
    });
    return result;
  }

  cellValue(employeeId: number, laborId: number): number | null {
    return this.values()[`${employeeId}-${laborId}`] ?? null;
  }

  setCell(employeeId: number, laborId: number, value: any, max: number): void {
    const key = `${employeeId}-${laborId}`;
    const numeric = value === '' || value == null ? null : Number(value);
    if (numeric != null && numeric < 0) return;
    this.values.update((current) => ({ ...current, [key]: numeric }));
    this.touched.add(key);
  }

  rowTotal(employeeId: number): number {
    return this.labors().reduce((sum, labor) => {
      const value = this.cellValue(employeeId, labor.id_evaluacion_labor);
      return sum + (Number(value) || 0);
    }, 0);
  }

  maxFor(labor: EvaluationLabor): number {
    return Number(labor.ponderacion_maxima_default ?? labor.ponderacion_maxima ?? 0);
  }

  touchedCount(): number {
    return this.touched.size;
  }

  addEmployee(): void {
    if (!this.selectedEmployeeId) return;
    this.adding.set(true);
    this.error.set('');
    this.message.set('');
    this.api.addEmployee(this.id, this.selectedEmployeeId).subscribe({
      next: () => {
        this.adding.set(false);
        this.selectedEmployeeId = null;
        this.message.set('Empleado agregado correctamente.');
        this.load();
      },
      error: (e) => {
        this.adding.set(false);
        this.error.set(e?.error?.message || 'No fue posible agregar el empleado.');
      },
    });
  }

  addAllActive(): void {
    this.addingAll.set(true);
    this.error.set('');
    this.message.set('');
    this.api.addAllActiveEmployees(this.id).subscribe({
      next: (result) => {
        this.addingAll.set(false);
        this.message.set(result.mensaje || 'Empleados activos procesados.');
        this.load();
      },
      error: (e) => {
        this.addingAll.set(false);
        this.error.set(e?.error?.message || 'No fue posible agregar los empleados activos.');
      },
    });
  }

  save(): void {
    const d = this.detail();
    if (!d) return;
    const scores: EvaluationScoreInput[] = [];
    d.employees.forEach((emp: EvaluationEmployee) => {
      this.labors().forEach((labor) => {
        const key = `${emp.id_empleado}-${labor.id_evaluacion_labor}`;
        if (this.touched.has(key)) {
          scores.push({
            id_empleado: emp.id_empleado,
            id_evaluacion_labor: labor.id_evaluacion_labor,
            valor_obtenido: this.cellValue(emp.id_empleado, labor.id_evaluacion_labor) ?? 0,
            valor_maximo: this.maxFor(labor),
          });
        }
      });
    });

    if (!scores.length) {
      this.message.set('No hay cambios pendientes por guardar.');
      return;
    }

    this.saving.set(true);
    this.error.set('');
    this.message.set('');
    this.api.saveScores(this.id, scores).subscribe({
      next: () => {
        this.saving.set(false);
        this.touched.clear();
        this.message.set('Calificaciones guardadas correctamente.');
        this.load();
      },
      error: (e) => {
        this.saving.set(false);
        this.error.set(e?.error?.message || 'No fue posible guardar las calificaciones.');
      },
    });
  }

  goPanel(): void {
    this.router.navigate(['/admin/evaluations', this.id, 'management-panel']);
  }
}
