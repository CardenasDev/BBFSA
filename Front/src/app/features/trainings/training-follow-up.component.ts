import { CommonModule } from '@angular/common';
import { Component, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';
import {
  TrainingAlert,
  TrainingCommitment,
  CommitmentStatus,
} from '../../core/models/training.models';
import { TrainingService } from '../../core/services/training.service';
@Component({
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink],
  template: `<header>
      <span>CAPACITACIONES</span>
      <h1>Alertas y compromisos</h1>
      <p>Da seguimiento a evaluaciones pendientes y resultados no aprobados.</p>
    </header>
    @if (message()) {
      <div class="notice ok">{{ message() }}</div>
    }
    @if (error()) {
      <div class="notice bad">{{ error() }}</div>
    }
    <div class="stats">
      <article>
        <b>{{ alerts().length }}</b
        ><span>Alertas activas</span>
      </article>
      <article>
        <b>{{ commitments().length }}</b
        ><span>Compromisos</span>
      </article>
      <article>
        <b>{{ critical() }}</b
        ><span>Resultados por atender</span>
      </article>
    </div>
    <div class="columns">
      <article class="card">
        <h2>Alertas</h2>
        @for (a of alerts(); track $index) {
          <div class="item">
            <b>{{ a.empleado || a.nombre_completo || 'Empleado' }}</b
            ><span>{{ a.tipo_alerta || a.resultado || 'EVALUACIÓN PENDIENTE' }}</span>
            <p>{{ a.mensaje || a.capacitacion || 'Requiere seguimiento.' }}</p>
            @if (a.id_capacitacion_resultado && !a.id_capacitacion_compromiso) {
              <button class="btn" (click)="newCommitment(a)">Crear compromiso</button>
            } @else if (a.id_capacitacion_compromiso) {
              <span>Compromiso #{{ a.id_capacitacion_compromiso }} ya creado</span>
            }
          </div>
        } @empty {
          <p>Sin alertas pendientes.</p>
        }
      </article>
      <article class="card">
        <div class="title">
          <h2>Compromisos</h2>
          <select [(ngModel)]="status" (change)="loadCommitments()">
            <option value="">Todos</option>
            <option>BORRADOR</option>
            <option>PENDIENTE_FIRMA</option>
            <option>FIRMADO</option>
            <option>CUMPLIDO</option>
            <option>INCUMPLIDO</option>
            <option>ANULADO</option>
          </select>
        </div>
        @for (c of commitments(); track c.id_capacitacion_compromiso) {
          <div class="item">
            <b>{{ c.empleado || c.nombre_completo }}</b
            ><span>{{ c.estado.replaceAll('_', ' ') }}</span>
            <p>{{ c.motivo }}</p>
            <a
              class="btn letter-link"
              [routerLink]="['/admin/trainings/commitments', c.id_capacitacion_compromiso, 'print']"
              target="_blank"
              rel="noopener"
            >
              Ver / imprimir carta
            </a>
            <label class="field">
              Estado
              <select
                [ngModel]="selectedStatus[c.id_capacitacion_compromiso] || c.estado"
                (ngModelChange)="selectedStatus[c.id_capacitacion_compromiso] = $event"
              >
                <option>BORRADOR</option>
                <option>PENDIENTE_FIRMA</option>
                <option>FIRMADO</option>
                <option>CUMPLIDO</option>
                <option>INCUMPLIDO</option>
                <option>ANULADO</option>
              </select>
            </label>
            <label class="field">
              Documento de compromiso
              <input
                type="file"
                accept=".pdf,.doc,.docx"
                (change)="setDocument(c.id_capacitacion_compromiso, $event)"
              />
            </label>
            <label class="field">
              Firma
              <input
                type="file"
                accept="image/png,image/jpeg"
                (change)="setSignature(c.id_capacitacion_compromiso, $event)"
              />
            </label>
            <button
              class="btn primary confirm"
              [disabled]="savingId() === c.id_capacitacion_compromiso"
              (click)="confirmStatus(c)"
            >
              {{
                savingId() === c.id_capacitacion_compromiso ? 'Guardando...' : 'Confirmar estado'
              }}
            </button>
          </div>
        } @empty {
          <p>Sin compromisos.</p>
        }
      </article>
    </div>
    @if (creating()) {
      <div class="modal">
        <article>
          <h2>Nuevo compromiso</h2>
          <label>Fecha<input type="date" [(ngModel)]="form.fecha_compromiso" /></label
          ><label>Fecha límite<input type="date" [(ngModel)]="form.fecha_limite" /></label
          ><label>Motivo<textarea [(ngModel)]="form.motivo"></textarea></label
          ><label
            >Compromisos del empleado<textarea [(ngModel)]="form.compromisos_empleado"></textarea>
          </label>
          <div>
            <button class="btn" (click)="creating.set(false)">Cancelar</button
            ><button class="btn primary" (click)="create()">Crear</button>
          </div>
        </article>
      </div>
    }`,
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
      .stats,
      .columns {
        display: grid;
        gap: 15px;
      }
      .stats {
        grid-template-columns: repeat(3, 1fr);
        margin: 20px 0;
      }
      .stats article,
      .card {
        background: #fff;
        border: 1px solid #dce5e1;
        border-radius: 14px;
        padding: 18px;
      }
      .stats b,
      .stats span {
        display: block;
      }
      .stats b {
        font-size: 1.7rem;
      }
      .columns {
        grid-template-columns: 1fr 1fr;
      }
      .notice {
        margin: 15px 0;
        padding: 12px 14px;
        border-radius: 9px;
      }
      .notice.ok {
        color: #075f49;
        background: #e8f7f1;
        border: 1px solid #9fd8c6;
      }
      .notice.bad {
        color: #9f2424;
        background: #fff0f0;
        border: 1px solid #efb4b4;
      }
      .item {
        border-top: 1px solid #e1e9e5;
        padding: 13px 0;
      }
      .item b,
      .item span {
        display: block;
      }
      .item span {
        color: #a36d00;
        font-size: 0.78rem;
      }
      .title {
        display: flex;
        justify-content: space-between;
      }
      select,
      input,
      textarea {
        padding: 8px;
        border: 1px solid #cbd8d2;
        border-radius: 7px;
      }
      .item input {
        display: block;
        margin-top: 6px;
      }
      .field {
        display: grid;
        gap: 5px;
        margin-top: 9px;
        font-size: 0.82rem;
      }
      .letter-link {
        display: inline-block;
        margin: 3px 0 5px;
        color: #075f49;
        text-decoration: none;
      }
      .confirm {
        margin-top: 10px;
      }
      .btn:disabled {
        cursor: wait;
        opacity: 0.65;
      }
      .btn {
        padding: 8px 12px;
        border: 1px solid #cbd8d2;
        border-radius: 8px;
        background: white;
      }
      .primary {
        background: #08745b;
        color: #fff;
      }
      .modal {
        position: fixed;
        inset: 0;
        background: #0007;
        display: grid;
        place-items: center;
      }
      .modal article {
        background: white;
        padding: 22px;
        border-radius: 14px;
        width: min(450px, 90vw);
        display: grid;
        gap: 10px;
      }
      .modal label {
        display: grid;
      }
      @media (max-width: 800px) {
        .stats,
        .columns {
          grid-template-columns: 1fr;
        }
      }
    `,
  ],
})
export class TrainingFollowUpComponent {
  private api = inject(TrainingService);
  alerts = signal<TrainingAlert[]>([]);
  commitments = signal<TrainingCommitment[]>([]);
  creating = signal(false);
  savingId = signal<number | null>(null);
  message = signal('');
  error = signal('');
  status = '';
  form: any = {};
  selectedStatus: Record<number, CommitmentStatus> = {};
  documentFiles: Record<number, File | undefined> = {};
  signatureFiles: Record<number, File | undefined> = {};
  constructor() {
    this.load();
  }
  load() {
    this.api.alerts().subscribe((r) => this.alerts.set(r));
    this.loadCommitments();
  }
  loadCommitments() {
    this.api.commitments(undefined, this.status).subscribe({
      next: (rows) => {
        this.commitments.set(rows);
        rows.forEach((commitment) => {
          this.selectedStatus[commitment.id_capacitacion_compromiso] = commitment.estado;
        });
      },
      error: (e) => this.fail(e),
    });
  }
  critical() {
    return this.alerts().filter(
      (a) => a.resultado === 'NO_APROBADO' || a.resultado === 'REQUIERE_REINDUCCION',
    ).length;
  }
  newCommitment(a: TrainingAlert) {
    this.form = {
      id_capacitacion_resultado: a.id_capacitacion_resultado,
      fecha_compromiso: new Date().toISOString().slice(0, 10),
      motivo: 'Resultado de capacitación no aprobado',
      compromisos_empleado: '',
      observaciones: '',
    };
    this.creating.set(true);
  }
  create() {
    this.api.createCommitment(this.form).subscribe(() => {
      this.creating.set(false);
      this.load();
    });
  }
  setDocument(id: number, event: Event) {
    this.documentFiles[id] = (event.target as HTMLInputElement).files?.[0];
  }
  setSignature(id: number, event: Event) {
    this.signatureFiles[id] = (event.target as HTMLInputElement).files?.[0];
  }
  confirmStatus(c: TrainingCommitment) {
    const id = c.id_capacitacion_compromiso;
    const estado = this.selectedStatus[id] || c.estado;
    this.message.set('');
    this.error.set('');
    this.savingId.set(id);
    this.api
      .updateCommitment(id, {
        estado,
        documento: this.documentFiles[id],
        firma: this.signatureFiles[id],
      })
      .subscribe({
        next: () => {
          delete this.documentFiles[id];
          delete this.signatureFiles[id];
          this.savingId.set(null);
          this.message.set(`El compromiso #${id} quedó en estado ${estado.replaceAll('_', ' ')}.`);
          this.loadCommitments();
        },
        error: (e) => {
          this.savingId.set(null);
          this.fail(e);
        },
      });
  }
  private fail(e: any) {
    this.error.set(e?.error?.message || 'No fue posible completar la operación.');
  }
}
