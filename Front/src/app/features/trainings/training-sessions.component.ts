import { CommonModule } from '@angular/common';
import { Component, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { forkJoin } from 'rxjs';
import { Training, TrainingSession } from '../../core/models/training.models';
import { AuthService } from '../../core/services/auth.service';
import { TrainingService } from '../../core/services/training.service';
@Component({
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink],
  template: `<header>
      <span>CAPACITACIONES</span>
      <h1>Sesiones semanales</h1>
      <p>Programa y consulta evaluaciones por semana.</p>
    </header>
    @if (error()) {
      <div class="notice">{{ error() }}</div>
    }
    <div class="toolbar">
      <select [(ngModel)]="filterTraining" (change)="load()">
        <option value="">Todas las capacitaciones</option>
        @for (t of trainings(); track t.id_capacitacion) {
          <option [value]="t.id_capacitacion">{{ t.nombre }}</option>
        }</select
      ><select [(ngModel)]="filterStatus" (change)="load()">
        <option value="">Todos los estados</option>
        <option>BORRADOR</option>
        <option>PROGRAMADA</option>
        <option>EN_EJECUCION</option>
        <option>CERRADA</option>
        <option>ANULADA</option>
      </select>
      @if (canAdmin) {
        <button class="btn primary" (click)="creating.set(!creating())">Nueva sesión</button>
      }
    </div>
    @if (creating()) {
      <article class="card form">
        <label
          >Capacitación<select [(ngModel)]="form.id_capacitacion">
            <option [ngValue]="null">Selecciona</option>
            @for (t of trainings(); track t.id_capacitacion) {
              <option [ngValue]="t.id_capacitacion">{{ t.nombre }}</option>
            }
          </select></label
        ><label>Fecha inicial<input type="date" [(ngModel)]="form.fecha_inicio" /></label
        ><label>Fecha final<input type="date" [(ngModel)]="form.fecha_fin" /></label
        ><label>Instructor<input [(ngModel)]="form.instructor_externo" /></label
        ><label>Lugar<input [(ngModel)]="form.lugar" /></label
        ><label>Observaciones<input [(ngModel)]="form.observaciones" /></label
        ><button class="btn primary" (click)="create()">Crear sesión</button>
      </article>
    }
    <div class="cards">
      @for (s of sessions(); track s.id_capacitacion_sesion) {
        <article class="card">
          <div class="title">
            <span class="badge">{{ s.estado.replaceAll('_', ' ') }}</span
            ><b>Semana {{ s.numero_semana ?? s.semana ?? '—' }}</b>
          </div>
          <h2>{{ s.capacitacion || s.nombre_capacitacion || 'Capacitación' }}</h2>
          <p>{{ s.fecha_inicio }} a {{ s.fecha_fin }}</p>
          <p>
            {{ s.total_participantes ?? 0 }} participantes · {{ s.lugar || 'Lugar no registrado' }}
          </p>
          <a class="btn" [routerLink]="['/admin/trainings/sessions', s.id_capacitacion_sesion]"
            >Abrir sesión</a
          >
        </article>
      } @empty {
        <p>No hay sesiones con estos filtros.</p>
      }
    </div>`,
  styles: [
    `
      :host {
        display: block;
      }
      header span {
        color: #08745b;
        font-weight: 800;
        letter-spacing: 0.15em;
      }
      h1 {
        font-size: 2.2rem;
        margin: 6px 0;
      }
      .toolbar {
        display: flex;
        gap: 10px;
        margin: 20px 0;
      }
      .toolbar select,
      input {
        padding: 10px;
        border: 1px solid #ccd8d3;
        border-radius: 8px;
      }
      .btn {
        display: inline-block;
        padding: 9px 13px;
        border: 1px solid #ccd8d3;
        border-radius: 8px;
        background: #fff;
        text-decoration: none;
        color: #17211d;
      }
      .primary {
        background: #08745b;
        color: #fff;
      }
      .cards {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 14px;
      }
      .card {
        background: #fff;
        border: 1px solid #dce5e1;
        border-radius: 14px;
        padding: 17px;
      }
      .title {
        display: flex;
        justify-content: space-between;
      }
      .badge {
        font-size: 0.75rem;
        background: #fff3d8;
        border-radius: 12px;
        padding: 4px 8px;
      }
      .form {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 10px;
        margin-bottom: 16px;
      }
      .form label {
        display: grid;
        gap: 4px;
      }
      .notice {
        background: #fff0f0;
        color: #a11;
        padding: 10px;
      }
      @media (max-width: 800px) {
        .cards,
        .form {
          grid-template-columns: 1fr;
        }
        .toolbar {
          flex-wrap: wrap;
        }
      }
    `,
  ],
})
export class TrainingSessionsComponent {
  private api = inject(TrainingService);
  private auth = inject(AuthService);
  trainings = signal<Training[]>([]);
  sessions = signal<TrainingSession[]>([]);
  creating = signal(false);
  error = signal('');
  filterTraining: any = '';
  filterStatus = '';
  form: any = {
    id_capacitacion: null,
    fecha_inicio: '',
    fecha_fin: '',
    instructor_externo: '',
    lugar: '',
    observaciones: '',
  };
  readonly canAdmin = this.auth.hasPermission('CAPACITACIONES_ADMINISTRAR');
  constructor() {
    forkJoin({ t: this.api.trainings(), s: this.api.sessions() }).subscribe((r) => {
      this.trainings.set(r.t);
      this.sessions.set(r.s);
    });
  }
  load() {
    this.api
      .sessions({ id_capacitacion: this.filterTraining, estado: this.filterStatus })
      .subscribe((r) => this.sessions.set(r));
  }
  create() {
    this.api.createSession(this.form).subscribe({
      next: () => {
        this.creating.set(false);
        this.load();
      },
      error: (e) => this.error.set(e?.error?.message || 'No fue posible crear la sesión.'),
    });
  }
}
