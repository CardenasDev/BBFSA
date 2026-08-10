import { CommonModule } from '@angular/common';
import { Component, ElementRef, ViewChild, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { forkJoin } from 'rxjs';
import { Employee, EmployeeFilters } from '../../core/models/api.models';
import {
  TrainingEvaluation,
  TrainingParticipant,
  TrainingSessionDetail,
  TrainingTask,
} from '../../core/models/training.models';
import { AuthService } from '../../core/services/auth.service';
import { EmployeeService } from '../../core/services/employee.service';
import { TrainingService } from '../../core/services/training.service';
@Component({
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink],
  template: `@if (detail()) {
      <header>
        <div>
          <span>SEMANA {{ detail()!.session.numero_semana ?? detail()!.session.semana }}</span>
          <h1>
            {{
              detail()!.session.capacitacion ||
                detail()!.session.nombre_capacitacion ||
                'Sesión de capacitación'
            }}
          </h1>
          <p>
            {{ detail()!.session.fecha_inicio }} a {{ detail()!.session.fecha_fin }} ·
            {{ detail()!.session.estado.replaceAll('_', ' ') }}
          </p>
        </div>
        <a class="btn" routerLink="/admin/trainings/sessions">Volver</a>
      </header>
      @if (message()) {
        <div class="notice ok">{{ message() }}</div>
      }
      @if (error()) {
        <div class="notice bad">{{ error() }}</div>
      }
      <nav class="tabs">
        <button (click)="tab.set('matrix')" [class.on]="tab() === 'matrix'">Matriz de evaluacion</button
        ><button (click)="tab.set('people')" [class.on]="tab() === 'people'">Participantes</button
        ><button (click)="tab.set('import')" [class.on]="tab() === 'import'">Importar XLSX</button>
      </nav>
      @if (tab() === 'people') {
        <article class="card">
          @if (canAdmin) {
            <div class="toolbar">
              <select [(ngModel)]="employeeId">
                <option [ngValue]="null">Selecciona empleado</option>
                @for (e of employees(); track e.id_empleado) {
                  <option [ngValue]="e.id_empleado">
                    {{ e.numero_documento }} - {{ e.nombres }} {{ e.apellidos }}
                  </option>
                }</select
              ><button class="btn primary" (click)="addParticipant()">Agregar</button
              ><select [(ngModel)]="newStatus">
                <option>PENDIENTE</option>
                <option>PROGRAMADA</option>
                <option>EN_EJECUCION</option>
                <option>CERRADA</option>
                <option>ANULADA</option></select
              ><button class="btn" (click)="changeStatus()">Cambiar estado</button>
            </div>
          }
          <table>
            <thead>
              <tr>
                <th>Empleado</th>
                <th>Asistencia</th>
                <th>Confirmación</th>
                <th>Resultado</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              @for (p of detail()!.participants; track p.id_capacitacion_participante) {
                <tr>
                  <td>{{ name(p) }}</td>
                  <td>
                    <select
                      [ngModel]="p.estado_asistencia || 'PENDIENTE'"
                      (ngModelChange)="saveAttendance(p, $event)"
                      [disabled]="!canAdmin"
                    >
                      <option>PENDIENTE</option>
                      <option>ASISTIO</option>
                      <option>NO_ASISTIO</option>
                      <option>JUSTIFICADO</option>
                      <option>INCAPACITADO</option>
                    </select>
                  </td>
                  <td>{{ p.confirmo_recibido ? 'Confirmada' : 'Pendiente' }}</td>
                  <td>{{ p.resultado || 'PENDIENTE' }}</td>
                  <td>
                    @if (canAdmin && !p.confirmo_recibido) {
                      <button class="btn tiny" (click)="confirmHr(p)">Confirmar presencial</button>
                    }
                    @if (canCreateCommitment(p)) {
                      <button class="btn tiny warning" (click)="openCommitment(p)">
                        Generar compromiso
                      </button>
                    } @else if (p.id_capacitacion_compromiso) {
                      <a class="btn tiny" routerLink="/admin/trainings/follow-up">
                        Ver compromiso
                      </a>
                    }
                  </td>
                </tr>
              }
            </tbody>
          </table>
        </article>
      }
      @if (tab() === 'matrix') {
        <article class="matrix-card">
          @if (saving()) {
            <div class="saving-overlay" role="status" aria-live="polite">
              <span class="spinner" aria-hidden="true"></span>
              <strong>Guardando información...</strong>
              <small>Espera mientras registramos los valores de la matriz.</small>
            </div>
          }
          <p class="hint">
            El acumulado es informativo. El resultado final y su regla se registran por separado.
          </p>
          <div
            #matrixTopScroll
            class="matrix-top-scroll"
            aria-label="Desplazamiento horizontal superior de la matriz"
            (scroll)="syncFromTop()"
          >
            <div [style.width.px]="matrixWidth()"></div>
          </div>
          <div #matrixScroll class="scroll" (scroll)="syncFromMatrix()">
            <table class="matrix" [style.min-width.px]="matrixWidth()">
              <thead>
                <tr>
                  <th>Empleado / labor</th>
                  @for (day of days(); track day) {
                    <th>{{ dayLabel(day) }}</th>
                  }
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                @for (p of detail()!.participants; track p.id_capacitacion_participante) {
                  <tr class="person">
                    <th [attr.colspan]="days().length + 2">{{ name(p) }} · {{ p.estado_asistencia || 'PENDIENTE' }}</th>
                  </tr>
                  @for (task of tasks(); track task.id_capacitacion_labor) {
                    <tr>
                      <th>{{ task.nombre }}</th>
                      @for (day of days(); track day) {
                        <td>
                          <input
                            type="number"
                            min="0"
                            [class.attention]="cell(p, task, day).attention"
                            [ngModel]="cell(p, task, day).value"
                            (ngModelChange)="setCell(p, task, day, $event)"
                            [disabled]="!canEvaluate || saving()"
                          />
                        </td>
                      }
                      <td>
                        <b>{{ taskTotal(p, task) }}</b>
                      </td>
                    </tr>
                  }
                  <tr class="total">
                    <th>Acumulado del periodo</th>
                    <td [attr.colspan]="days().length">{{ participantTotal(p) }}</td>
                    <td>
                      <button class="btn tiny" (click)="openResult(p)" [disabled]="!canEvaluate">
                        Resultado final
                      </button>
                    </td>
                  </tr>
                }
              </tbody>
            </table>
          </div>
          <button
            class="btn primary save"
            (click)="saveMatrix()"
            [disabled]="!canEvaluate || saving()"
          >
            @if (saving()) {
              <span class="button-spinner" aria-hidden="true"></span>
              Guardando información...
            } @else {
              Guardar cambios de matriz
            }
          </button>
        </article>
      }
      @if (tab() === 'import') {
        <article class="card import">
          <h2>Importar matriz semanal</h2>
          <p>
            Archivo XLSX. Primero se valida completo; si contiene errores no se aplica ningún valor.
          </p>
          <input type="file" accept=".xlsx" (change)="pickFile($event)" /><button
            class="btn primary"
            (click)="importFile()"
            [disabled]="!file || !canImport"
          >
            Validar e importar
          </button>
          @if (importResult()) {
            <h3>
              {{ importResult()!.errores.length ? 'Archivo no aplicado' : 'Importación exitosa' }}
            </h3>
            <p>{{ importResult()!.aplicados }} valores aplicados.</p>
            @for (e of importResult()!.errores; track $index) {
              <div class="error-row">{{ e.hoja }} {{ e.celda }}: {{ e.mensaje }}</div>
            }
          }
        </article>
      }
    }
    @if (resultParticipant()) {
      <div class="modal">
        <article>
          <h2>Resultado de {{ name(resultParticipant()!) }}</h2>
          <label>Puntaje final<input type="number" [(ngModel)]="resultForm.puntaje_final" /></label
          ><label
            >Puntaje mínimo<input
              type="number"
              [(ngModel)]="resultForm.puntaje_minimo"
              placeholder="Opcional" /></label
          ><label
            >Resultado<select [(ngModel)]="resultForm.resultado">
              <option>PENDIENTE</option>
              <option>APROBADO</option>
              <option>NO_APROBADO</option>
              <option>REQUIERE_REINDUCCION</option>
            </select></label
          ><label
            >Regla aplicada<input
              [(ngModel)]="resultForm.regla_aplicada"
              placeholder="Opcional" /></label
          ><label
            ><input type="checkbox" [(ngModel)]="resultForm.requiere_reinduccion" /> Requiere
            reinducción</label
          ><label
            ><input type="checkbox" [(ngModel)]="resultForm.requiere_compromiso" /> Requiere
            compromiso</label
          >
          <div>
            <button class="btn" (click)="resultParticipant.set(null)">Cancelar</button
            ><button class="btn primary" (click)="saveResult()">Guardar</button>
          </div>
        </article>
      </div>
    }
    @if (commitmentParticipant()) {
      <div class="modal">
        <article>
          <h2>Compromiso de {{ name(commitmentParticipant()!) }}</h2>
          <p>Resultado: {{ commitmentParticipant()!.resultado }}</p>
          <label>Fecha<input type="date" [(ngModel)]="commitmentForm.fecha_compromiso" /></label>
          <label>Fecha límite<input type="date" [(ngModel)]="commitmentForm.fecha_limite" /></label>
          <label>Motivo<textarea [(ngModel)]="commitmentForm.motivo"></textarea></label>
          <label
            >Compromisos del empleado<textarea
              [(ngModel)]="commitmentForm.compromisos_empleado"
            ></textarea>
          </label>
          <label
            >Observaciones<textarea [(ngModel)]="commitmentForm.observaciones"></textarea>
          </label>
          <div>
            <button class="btn" (click)="commitmentParticipant.set(null)">Cancelar</button>
            <button class="btn primary" (click)="createCommitment()">Crear compromiso</button>
          </div>
        </article>
      </div>
    }`,
  styles: [
    `
      :host {
        display: block;
      }
      header {
        display: flex;
        justify-content: space-between;
      }
      header span {
        color: #08745b;
        font-weight: 800;
      }
      .tabs {
        display: flex;
        gap: 5px;
        margin: 20px 0;
      }
      .tabs button {
        padding: 10px 14px;
        background: white;
        border: 0;
        border-bottom: 3px solid transparent;
      }
      .tabs .on {
        border-color: #08745b;
      }
      .card,
      .matrix-card {
        background: #fff;
        border: 1px solid #dce5e1;
        border-radius: 14px;
        padding: 18px;
      }
      .matrix-card {
        position: relative;
      }
      .saving-overlay {
        position: absolute;
        inset: 0;
        z-index: 10;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        gap: 8px;
        min-height: 220px;
        border-radius: 14px;
        background: rgba(255, 255, 255, 0.88);
        backdrop-filter: blur(2px);
        color: #183e34;
      }
      .saving-overlay small {
        color: #607068;
      }
      .spinner,
      .button-spinner {
        display: inline-block;
        border-radius: 50%;
        border-style: solid;
        border-color: #c9ddd6;
        border-top-color: #08745b;
        animation: training-spin 0.75s linear infinite;
      }
      .spinner {
        width: 42px;
        height: 42px;
        border-width: 4px;
      }
      .button-spinner {
        width: 14px;
        height: 14px;
        margin-right: 7px;
        border-width: 2px;
        border-color: rgba(255, 255, 255, 0.45);
        border-top-color: white;
        vertical-align: -2px;
      }
      @keyframes training-spin {
        to {
          transform: rotate(360deg);
        }
      }
      .toolbar {
        display: flex;
        gap: 8px;
        margin-bottom: 14px;
      }
      select,
      input {
        padding: 8px;
        border: 1px solid #cbd8d2;
        border-radius: 7px;
      }
      .btn {
        padding: 8px 12px;
        border: 1px solid #cbd8d2;
        border-radius: 8px;
        background: white;
        text-decoration: none;
        color: #18221e;
      }
      .primary {
        background: #08745b;
        color: white;
      }
      .tiny {
        font-size: 0.78rem;
        padding: 5px 8px;
      }
      table {
        width: 100%;
        border-collapse: collapse;
      }
      th,
      td {
        padding: 9px;
        border-bottom: 1px solid #e4ebe7;
        text-align: left;
      }
      .scroll {
        overflow: auto;
        max-width: 100%;
        scrollbar-gutter: stable;
      }
      .matrix-top-scroll {
        width: 100%;
        height: 18px;
        overflow-x: auto;
        overflow-y: hidden;
        margin-bottom: 8px;
        scrollbar-gutter: stable;
      }
      .matrix-top-scroll > div {
        height: 1px;
      }
      .matrix {
        min-width: 850px;
      }
      .matrix thead th:first-child,
      .matrix tbody tr:not(.person) > th:first-child {
        position: sticky;
        left: 0;
        z-index: 2;
        background: white;
        box-shadow: 2px 0 0 #e4ebe7;
      }
      .matrix thead th:first-child {
        z-index: 3;
      }
      .matrix .total > th:first-child {
        background: #eef7f3;
      }
      .matrix td input {
        width: 70px;
      }
      .matrix .person th {
        background: #183e34;
        color: white;
      }
      .total {
        background: #eef7f3;
      }
      .attention {
        background: #fff2a8 !important;
        border-color: #d6a900 !important;
      }
      .save {
        margin-top: 14px;
      }
      .notice {
        padding: 10px;
        margin: 10px 0;
      }
      .ok {
        background: #e7f7ef;
      }
      .bad,
      .error-row {
        background: #fff0f0;
        color: #a11;
      }
      .import {
        display: grid;
        gap: 12px;
      }
      .modal {
        position: fixed;
        inset: 0;
        background: #0007;
        display: grid;
        place-items: center;
        z-index: 20;
      }
      .modal article {
        background: white;
        border-radius: 14px;
        padding: 22px;
        width: min(460px, 90vw);
        display: grid;
        gap: 10px;
      }
      .modal label {
        display: grid;
        gap: 4px;
      }
      .hint {
        color: #607068;
      }
      .warning {
        border-color: #c88700;
        color: #805800;
        margin-left: 6px;
      }
    `,
  ],
})
export class TrainingSessionDetailComponent {
  @ViewChild('matrixScroll') private matrixScroll?: ElementRef<HTMLDivElement>;
  @ViewChild('matrixTopScroll') private matrixTopScroll?: ElementRef<HTMLDivElement>;
  private api = inject(TrainingService);
  private employeesApi = inject(EmployeeService);
  private auth = inject(AuthService);
  private id = Number(inject(ActivatedRoute).snapshot.paramMap.get('sessionId'));
  detail = signal<TrainingSessionDetail | null>(null);
  tasks = signal<TrainingTask[]>([]);
  employees = signal<Employee[]>([]);
  tab = signal<'matrix' | 'people' | 'import'>('matrix');
  message = signal('');
  error = signal('');
  saving = signal(false);
  employeeId: number | null = null;
  newStatus: any = 'EN_EJECUCION';
  file?: File;
  importResult = signal<any>(null);
  resultParticipant = signal<TrainingParticipant | null>(null);
  resultForm: any = {};
  commitmentParticipant = signal<TrainingParticipant | null>(null);
  commitmentForm: any = {};
  private changes = new Map<
    string,
    { p: TrainingParticipant; t: TrainingTask; d: string; v: number }
  >();
  readonly canAdmin = this.auth.hasPermission('CAPACITACIONES_ADMINISTRAR');
  readonly canEvaluate = this.auth.hasPermission('CAPACITACIONES_EVALUAR');
  readonly canImport = this.auth.hasPermission('CAPACITACIONES_IMPORTAR');
  readonly canCommitments = this.auth.hasPermission('CAPACITACIONES_COMPROMISOS');
  constructor() {
    this.load();
  }
  load() {
    this.api.session(this.id).subscribe({
      next: (d) => {
        this.detail.set(d);
        forkJoin({
          tasks: this.api.attachedTasks(d.session.id_capacitacion),
          employees: this.employeesApi.listEmployees({ estado: 'ACTIVO' } as EmployeeFilters),
        }).subscribe((x) => {
          this.tasks.set(x.tasks);
          this.employees.set(x.employees);
        });
      },
      error: (e) => this.fail(e),
    });
  }
  name(p: TrainingParticipant) {
    return p.empleado || p.nombre_completo || `Empleado ${p.id_empleado}`;
  }
  days() {
    const session = this.detail()!.session;
    const start = new Date(session.fecha_inicio + 'T12:00:00');
    const end = new Date(session.fecha_fin + 'T12:00:00');
    if (Number.isNaN(start.getTime()) || Number.isNaN(end.getTime()) || end < start) return [];

    const result: string[] = [];
    const current = new Date(start);
    while (current <= end && result.length < 366) {
      result.push(current.toISOString().slice(0, 10));
      current.setDate(current.getDate() + 1);
    }
    return result;
  }
  dayLabel(d: string) {
    const date = new Date(d + 'T12:00:00');
    const day = ['DO', 'LU', 'MA', 'MI', 'JU', 'VI', 'SA'][date.getDay()];
    return `${day} ${String(date.getDate()).padStart(2, '0')}`;
  }
  matrixWidth() {
    return 280 + this.days().length * 90;
  }
  syncFromTop() {
    if (this.matrixScroll && this.matrixTopScroll) {
      this.matrixScroll.nativeElement.scrollLeft = this.matrixTopScroll.nativeElement.scrollLeft;
    }
  }
  syncFromMatrix() {
    if (this.matrixScroll && this.matrixTopScroll) {
      this.matrixTopScroll.nativeElement.scrollLeft = this.matrixScroll.nativeElement.scrollLeft;
    }
  }
  cell(p: TrainingParticipant, t: TrainingTask, d: string) {
    const c = this.changes.get(`${p.id_capacitacion_participante}-${t.id_capacitacion_labor}-${d}`);
    const e = this.detail()!.evaluations.find(
      (x) =>
        x.id_capacitacion_participante === p.id_capacitacion_participante &&
        x.id_capacitacion_labor === t.id_capacitacion_labor &&
        x.fecha_evaluacion.slice(0, 10) === d,
    );
    return { value: c?.v ?? e?.valor_obtenido ?? null, attention: e?.requiere_atencion ?? false };
  }
  setCell(p: TrainingParticipant, t: TrainingTask, d: string, v: any) {
    const key = `${p.id_capacitacion_participante}-${t.id_capacitacion_labor}-${d}`;
    if (v === '' || v == null) this.changes.delete(key);
    else this.changes.set(key, { p, t, d, v: Number(v) });
  }
  taskTotal(p: TrainingParticipant, t: TrainingTask) {
    return this.days().reduce((s, d) => s + (Number(this.cell(p, t, d).value) || 0), 0);
  }
  participantTotal(p: TrainingParticipant) {
    return this.tasks().reduce((s, t) => s + this.taskTotal(p, t), 0);
  }
  saveMatrix() {
    const calls = [...this.changes.values()].map((x) =>
      this.api.evaluation({
        id_capacitacion_participante: x.p.id_capacitacion_participante,
        id_capacitacion_labor: x.t.id_capacitacion_labor,
        fecha_evaluacion: x.d,
        valor_obtenido: x.v,
        requiere_atencion: false,
      }),
    );
    if (!calls.length) {
      this.message.set('No hay cambios pendientes por guardar.');
      return;
    }

    this.saving.set(true);
    forkJoin(calls).subscribe({
      next: () => {
        this.saving.set(false);
        this.changes.clear();
        this.message.set('Matriz guardada.');
        this.load();
      },
      error: (e) => {
        this.saving.set(false);
        this.fail(e);
      },
    });
  }
  addParticipant() {
    if (!this.employeeId) return;
    this.api
      .addParticipant(this.id, this.employeeId)
      .subscribe({ next: () => this.load(), error: (e) => this.fail(e) });
  }
  saveAttendance(p: TrainingParticipant, s: any) {
    this.api
      .attendance(p.id_capacitacion_participante, s)
      .subscribe({ next: () => this.load(), error: (e) => this.fail(e) });
  }
  changeStatus() {
    this.api
      .status(this.id, this.newStatus)
      .subscribe({ next: () => this.load(), error: (e) => this.fail(e) });
  }
  confirmHr(p: TrainingParticipant) {
    this.api
      .confirmHr(p.id_capacitacion_participante, 'Confirmación presencial registrada por RR. HH.')
      .subscribe({ next: () => this.load(), error: (e) => this.fail(e) });
  }
  openResult(p: TrainingParticipant) {
    this.resultParticipant.set(p);
    this.resultForm = {
      id_capacitacion_participante: p.id_capacitacion_participante,
      puntaje_final: p.puntaje_final ?? this.participantTotal(p),
      puntaje_minimo: p.puntaje_minimo ?? null,
      resultado: p.resultado ?? 'PENDIENTE',
      requiere_reinduccion: false,
      requiere_compromiso: false,
    };
  }
  saveResult() {
    this.api.result(this.resultForm).subscribe({
      next: () => {
        this.resultParticipant.set(null);
        this.message.set('Resultado final guardado.');
        this.load();
      },
      error: (e) => this.fail(e),
    });
  }
  canCreateCommitment(p: TrainingParticipant) {
    return (
      this.canCommitments &&
      !p.id_capacitacion_compromiso &&
      !!p.id_capacitacion_resultado &&
      (p.resultado === 'NO_APROBADO' || p.resultado === 'REQUIERE_REINDUCCION')
    );
  }
  openCommitment(p: TrainingParticipant) {
    if (!this.canCreateCommitment(p)) return;
    this.commitmentParticipant.set(p);
    this.commitmentForm = {
      id_capacitacion_resultado: p.id_capacitacion_resultado,
      fecha_compromiso: new Date().toISOString().slice(0, 10),
      fecha_limite: null,
      motivo: `Resultado ${p.resultado} en la capacitación.`,
      compromisos_empleado: '',
      observaciones: '',
    };
  }
  createCommitment() {
    if (!this.commitmentParticipant() || !this.commitmentForm.motivo?.trim()) {
      this.error.set('El motivo del compromiso es obligatorio.');
      return;
    }
    this.api.createCommitment(this.commitmentForm).subscribe({
      next: () => {
        this.commitmentParticipant.set(null);
        this.message.set('Carta de compromiso creada en estado borrador.');
        this.load();
      },
      error: (e) => this.fail(e),
    });
  }
  pickFile(e: Event) {
    this.file = (e.target as HTMLInputElement).files?.[0] ?? undefined;
  }
  importFile() {
    if (!this.file) return;
    this.api.import(this.id, this.file).subscribe({
      next: (r) => {
        this.importResult.set(r);
        if (!r.errores.length) {
          this.message.set('Archivo importado sin errores.');
          this.load();
        }
      },
      error: (e) => this.fail(e),
    });
  }
  private fail(e: any) {
    this.error.set(e?.error?.message || 'No fue posible completar la operación.');
  }
}
