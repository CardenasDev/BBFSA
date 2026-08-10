import { CommonModule } from '@angular/common';
import { Component, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { TrainingParticipant } from '../../core/models/training.models';
import { TrainingService } from '../../core/services/training.service';
@Component({
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `<header>
      <span>CAPACITACIONES</span>
      <h1>Mis capacitaciones</h1>
      <p>Consulta tus sesiones, resultados y confirmaciones pendientes.</p>
    </header>
    @if (message()) {
      <div class="notice">{{ message() }}</div>
    }
    <div class="cards">
      @for (r of records(); track r.id_capacitacion_participante) {
        <article>
          <div class="title">
            <span>{{ r.resultado || 'PENDIENTE' }}</span
            ><small>{{ r.estado_asistencia || 'PENDIENTE' }}</small>
          </div>
          <h2>{{ r['capacitacion'] || r['nombre_capacitacion'] || 'Capacitación' }}</h2>
          <p>{{ r['fecha_inicio'] || '' }} {{ r['fecha_fin'] ? 'a ' + r['fecha_fin'] : '' }}</p>
          <dl>
            <dt>Puntaje</dt>
            <dd>{{ r.puntaje_final ?? 'Pendiente' }}</dd>
            <dt>Mínimo</dt>
            <dd>{{ r.puntaje_minimo ?? 'No definido' }}</dd>
          </dl>
          @if (!r.confirmo_recibido) {
            <button class="btn" (click)="confirm(r)">Confirmar que recibí la capacitación</button>
          } @else {
            <b class="confirmed">✓ Capacitación confirmada</b>
          }
        </article>
      } @empty {
        <p>No tienes capacitaciones registradas.</p>
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
      .cards {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 15px;
        margin-top: 20px;
      }
      .cards article {
        background: white;
        border: 1px solid #dce5e1;
        border-radius: 15px;
        padding: 18px;
      }
      .title {
        display: flex;
        justify-content: space-between;
      }
      .title span {
        background: #fff3d8;
        border-radius: 12px;
        padding: 4px 8px;
        font-size: 0.75rem;
      }
      .btn {
        background: #08745b;
        color: white;
        border: 0;
        padding: 9px 12px;
        border-radius: 8px;
      }
      .confirmed {
        color: #08745b;
      }
      .notice {
        background: #e8f7f1;
        padding: 10px;
      }
      @media (max-width: 800px) {
        .cards {
          grid-template-columns: 1fr;
        }
      }
    `,
  ],
})
export class MyTrainingsComponent {
  private api = inject(TrainingService);
  records = signal<any[]>([]);
  message = signal('');
  constructor() {
    this.load();
  }
  load() {
    this.api.mine().subscribe((r) => this.records.set(r));
  }
  confirm(r: TrainingParticipant) {
    this.api.confirm(r.id_capacitacion_participante).subscribe(() => {
      this.message.set('Confirmación registrada.');
      this.load();
    });
  }
}
