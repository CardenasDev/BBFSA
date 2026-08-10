import { CommonModule } from '@angular/common';
import { Component, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { forkJoin } from 'rxjs';
import { Training, TrainingTask } from '../../core/models/training.models';
import { AuthService } from '../../core/services/auth.service';
import { TrainingService } from '../../core/services/training.service';

@Component({
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: ` <header class="page-head">
      <span>CAPACITACIONES</span>
      <h1>Catálogo y configuración</h1>
      <p>Administra programas, reglas y labores evaluadas.</p>
    </header>
    @if (message()) {
      <div class="notice ok">{{ message() }}</div>
    }
    @if (error()) {
      <div class="notice bad">{{ error() }}</div>
    }
    <div class="stats">
      <article>
        <b>{{ trainings().length }}</b> capacitaciones
      </article>
      <article>
        <b>{{ tasks().length }}</b> labores
      </article>
      <article>
        <b>{{ attached().length }}</b> asociadas
      </article>
    </div>
    <div class="columns">
      <article class="card">
        <div class="title">
          <h2>Capacitaciones</h2>
          @if (canAdmin) {
            <button class="btn primary" (click)="newTraining()">Nueva</button>
          }
        </div>
        @for (item of trainings(); track item.id_capacitacion) {
          <button
            class="row"
            [class.active]="selected()?.id_capacitacion === item.id_capacitacion"
            (click)="select(item)"
          >
            <b>{{ item.nombre }}</b
            ><small
              >{{ item.tipo.replaceAll('_', ' ') }} ·
              {{
                item.puntaje_minimo == null ? 'Mínimo por definir' : 'Mínimo ' + item.puntaje_minimo
              }}</small
            >
          </button>
        }
      </article>
      <article class="card">
        @if (canAdmin && editing()) {
          <h2>{{ form.id_capacitacion ? 'Editar' : 'Nueva' }} capacitación</h2>
          <div class="form">
            <label>Código<input [(ngModel)]="form.codigo" /></label
            ><label>Nombre<input [(ngModel)]="form.nombre" /></label
            ><label
              >Tipo<select [(ngModel)]="form.tipo">
                <option value="CAPACITACION">Capacitación</option>
                <option value="INDUCCION">Inducción</option>
                <option value="REINDUCCION">Reinducción</option>
                <option value="EVALUACION_REINDUCCION">Evaluación y reinducción</option>
              </select></label
            ><label
              >Puntaje mínimo<input
                type="number"
                [(ngModel)]="form.puntaje_minimo"
                placeholder="Opcional" /></label
            ><label
              >Puntaje máximo<input
                type="number"
                [(ngModel)]="form.puntaje_maximo"
                placeholder="Opcional" /></label
            ><label
              >Días para evaluar<input type="number" [(ngModel)]="form.dias_para_evaluar" /></label
            ><label class="full"
              >Regla de cálculo<input
                [(ngModel)]="form.regla_calculo"
                placeholder="Configurable / por definir" /></label
            ><label class="full"
              >Descripción<textarea [(ngModel)]="form.descripcion"></textarea>
            </label>
          </div>
          <div class="checks">
            <label
              ><input type="checkbox" [(ngModel)]="form.requiere_evaluacion" /> Requiere
              evaluación</label
            ><label
              ><input type="checkbox" [(ngModel)]="form.requiere_confirmacion" /> Requiere
              confirmación</label
            ><label
              ><input type="checkbox" [(ngModel)]="form.generar_compromiso_no_aprobado" /> Generar
              compromiso</label
            >
          </div>
          <button class="btn primary" (click)="saveTraining()">Guardar</button>
        } @else if (selected()) {
          <h2>{{ selected()!.nombre }}</h2>
          <p>{{ selected()!.descripcion || 'Sin descripción' }}</p>
          <p><b>Regla:</b> {{ selected()!.regla_calculo || 'Pendiente de definir' }}</p>
          <p><b>Mínimo:</b> {{ selected()!.puntaje_minimo ?? 'No configurado' }}</p>
          @if (canAdmin) {
            <button class="btn" (click)="editSelected()">Editar</button>
          }
        } @else {
          <p>Selecciona una capacitación.</p>
        }
      </article>
    </div>
    <article class="card top">
      <div class="title">
        <h2>Labores de evaluación</h2>
        @if (canAdmin) {
          <button class="btn" (click)="newTask()">Nueva labor</button>
        }
      </div>
      @if (taskEditing()) {
        <div class="inline">
          <input placeholder="Código" [(ngModel)]="taskForm.codigo" /><input
            placeholder="Nombre"
            [(ngModel)]="taskForm.nombre"
          /><input type="number" placeholder="Orden" [(ngModel)]="taskForm.orden" /><button
            class="btn primary"
            (click)="saveTask()"
          >
            Guardar
          </button>
        </div>
      }
      <div class="chips">
        @for (task of tasks(); track task.id_capacitacion_labor) {
          <button
            class="chip"
            [class.on]="isAttached(task.id_capacitacion_labor)"
            (click)="canAdmin && selected() && attach(task)"
          >
            {{ task.nombre }} {{ isAttached(task.id_capacitacion_labor) ? '✓' : '+' }}
          </button>
        }
      </div>
      <small>Selecciona una capacitación y pulsa una labor para asociarla.</small>
    </article>`,
  styles: [
    `
      :host {
        display: block;
      }
      .page-head span {
        color: #08745b;
        font-weight: 800;
        letter-spacing: 0.15em;
      }
      .page-head h1 {
        font-size: 2.2rem;
        margin: 6px 0;
      }
      .stats,
      .columns {
        display: grid;
        gap: 16px;
      }
      .stats {
        grid-template-columns: repeat(3, 1fr);
        margin: 20px 0;
      }
      .stats article,
      .card {
        background: white;
        border: 1px solid #dce5e1;
        border-radius: 16px;
        padding: 18px;
      }
      .stats b {
        font-size: 1.6rem;
      }
      .columns {
        grid-template-columns: 1fr 1.4fr;
      }
      .title {
        display: flex;
        justify-content: space-between;
      }
      .row {
        display: block;
        width: 100%;
        padding: 11px;
        margin: 7px 0;
        text-align: left;
        border: 1px solid #dce5e1;
        border-radius: 9px;
        background: #f8faf9;
      }
      .row b,
      .row small {
        display: block;
      }
      .row.active {
        border-color: #08745b;
        background: #ecf8f3;
      }
      .form {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 10px;
      }
      .form label {
        display: grid;
        gap: 4px;
      }
      .full {
        grid-column: 1/-1;
      }
      input,
      select,
      textarea {
        border: 1px solid #cbd8d2;
        border-radius: 8px;
        padding: 9px;
      }
      .checks {
        display: flex;
        gap: 12px;
        flex-wrap: wrap;
        margin: 12px 0;
      }
      .btn {
        border: 1px solid #cbd8d2;
        border-radius: 8px;
        padding: 8px 13px;
        background: white;
      }
      .primary {
        background: #08745b;
        color: white;
      }
      .top {
        margin-top: 16px;
      }
      .chips {
        display: flex;
        gap: 8px;
        flex-wrap: wrap;
      }
      .chip {
        border: 1px solid #cbd8d2;
        border-radius: 20px;
        padding: 8px 11px;
        background: white;
      }
      .chip.on {
        background: #e8f7f1;
        border-color: #08745b;
      }
      .inline {
        display: grid;
        grid-template-columns: 1fr 2fr 100px auto;
        gap: 8px;
        margin: 10px 0;
      }
      .notice {
        padding: 10px;
        border-radius: 8px;
      }
      .ok {
        background: #e8f7f1;
      }
      .bad {
        background: #fff0f0;
        color: #a11;
      }
      @media (max-width: 800px) {
        .stats,
        .columns,
        .form,
        .inline {
          grid-template-columns: 1fr;
        }
        .full {
          grid-column: auto;
        }
      }
    `,
  ],
})
export class TrainingCatalogComponent {
  private api = inject(TrainingService);
  private auth = inject(AuthService);
  trainings = signal<Training[]>([]);
  tasks = signal<TrainingTask[]>([]);
  attached = signal<TrainingTask[]>([]);
  selected = signal<Training | null>(null);
  editing = signal(false);
  taskEditing = signal(false);
  message = signal('');
  error = signal('');
  readonly canAdmin = this.auth.hasPermission('CAPACITACIONES_ADMINISTRAR');
  form: any = {};
  taskForm: any = {};
  constructor() {
    this.load();
  }
  load() {
    forkJoin({ trainings: this.api.trainings(), tasks: this.api.tasks() }).subscribe({
      next: (r) => {
        this.trainings.set(r.trainings);
        this.tasks.set(r.tasks);
      },
      error: (e) => this.fail(e),
    });
  }
  select(t: Training) {
    this.selected.set(t);
    this.editing.set(false);
    this.api.attachedTasks(t.id_capacitacion).subscribe((r) => this.attached.set(r));
  }
  newTraining() {
    this.form = {
      codigo: '',
      nombre: '',
      tipo: 'CAPACITACION',
      requiere_evaluacion: true,
      requiere_confirmacion: true,
      generar_compromiso_no_aprobado: false,
      activo: true,
    };
    this.editing.set(true);
  }
  editSelected() {
    this.form = { ...this.selected() };
    this.editing.set(true);
  }
  saveTraining() {
    this.api.saveTraining(this.form).subscribe({
      next: () => {
        this.message.set('Capacitación guardada.');
        this.editing.set(false);
        this.load();
      },
      error: (e) => this.fail(e),
    });
  }
  newTask() {
    this.taskForm = { codigo: '', nombre: '', orden: 0, activo: true };
    this.taskEditing.set(true);
  }
  saveTask() {
    this.api.saveTask(this.taskForm).subscribe({
      next: () => {
        this.taskEditing.set(false);
        this.message.set('Labor guardada.');
        this.load();
      },
      error: (e) => this.fail(e),
    });
  }
  attach(t: TrainingTask) {
    if (this.isAttached(t.id_capacitacion_labor)) return;
    this.api
      .attachTask({
        id_capacitacion: this.selected()!.id_capacitacion,
        id_capacitacion_labor: t.id_capacitacion_labor,
        orden: t.orden ?? 0,
        activo: true,
      })
      .subscribe({
        next: () => {
          this.message.set('Labor asociada.');
          this.select(this.selected()!);
        },
        error: (e) => this.fail(e),
      });
  }
  isAttached(id: number) {
    return this.attached().some((x) => x.id_capacitacion_labor === id);
  }
  private fail(e: any) {
    this.error.set(e?.error?.message || 'No fue posible completar la operación.');
  }
}
