import { CommonModule } from '@angular/common';
import { Component, inject, signal } from '@angular/core';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { EvaluationList } from '../../core/models/evaluation.models';
import { EvaluationService } from '../../core/services/evaluation.service';
import { calculateEvaluationWeek } from './evaluation-week.util';

@Component({
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  template: `
    <header class="page-header">
      <div>
        <h1>Evaluaciones semanales</h1>
        <p>Historial de evaluaciones de labores agrícolas por semana.</p>
      </div>
      <button class="btn primary" type="button" (click)="openModal()">Nueva evaluación</button>
    </header>

    @if (message()) { <div class="notice ok">{{ message() }}</div> }
    @if (error()) { <div class="notice bad">{{ error() }}</div> }

    <section class="card">
      @if (loading()) {
        <p>Cargando evaluaciones...</p>
      } @else {
        <table>
          <thead>
            <tr>
              <th>Año</th>
              <th>Semana</th>
              <th>Nombre</th>
              <th>Fecha inicio</th>
              <th>Fecha fin</th>
              <th>Estado</th>
              <th>Acciones</th>
            </tr>
          </thead>
          <tbody>
            @for (item of evaluations(); track item.id_evaluacion) {
              <tr>
                <td>{{ item.anio }}</td>
                <td>{{ item.numero_semana }}</td>
                <td>{{ item.nombre_semana || 'Semana ' + item.numero_semana }}</td>
                <td>{{ item.fecha_inicio }}</td>
                <td>{{ item.fecha_fin || '-' }}</td>
                <td><span class="badge">{{ item.estado }}</span></td>
                <td class="actions">
                  <button class="btn tiny" type="button" (click)="openDetail(item.id_evaluacion)">Ver / Capturar</button>
                  <button class="btn tiny" type="button" (click)="openPanel(item.id_evaluacion)">Panel gerencial</button>
                </td>
              </tr>
            } @empty {
              <tr><td colspan="7">No hay evaluaciones registradas.</td></tr>
            }
          </tbody>
        </table>
      }
    </section>

    @if (showModal()) {
      <div class="modal">
        <article>
          <h2>Nueva evaluación</h2>
          <form [formGroup]="form" (ngSubmit)="create()">
            <label>Año<input type="number" formControlName="anio" readonly /></label>
            <label>Número de semana<input type="number" formControlName="numero_semana" min="1" max="53" readonly /></label>
            <label>Nombre (opcional)<input type="text" formControlName="nombre_semana" /></label>
            <label>Fecha inicio<input type="date" formControlName="fecha_inicio" required /></label>
            <label>Fecha fin<input type="date" formControlName="fecha_fin" readonly /></label>
            <label>Observaciones<textarea formControlName="observaciones"></textarea></label>
            @if (error()) { <div class="notice bad">{{ error() }}</div> }
            <div class="modal-actions">
              <button type="button" class="btn" (click)="closeModal()" [disabled]="creating()">Cancelar</button>
              <button type="submit" class="btn primary" [disabled]="form.invalid || creating()">
                @if (creating()) { <span class="spinner"></span> Guardando... } @else { Crear }
              </button>
            </div>
          </form>
        </article>
      </div>
    }
  `,
  styles: [`
    :host { display:block; }
    .page-header { display:flex; justify-content:space-between; align-items:center; margin-bottom:16px; }
    .card { background:#fff; border:1px solid #dce5e1; border-radius:14px; padding:16px; }
    table { width:100%; border-collapse:collapse; }
    th,td { padding:10px; border-bottom:1px solid #e4ebe7; text-align:left; }
    .actions { display:flex; gap:8px; }
    .btn { padding:8px 12px; border:1px solid #cbd8d2; border-radius:8px; background:#fff; cursor:pointer; }
    .btn.primary { background:#08745b; color:#fff; border-color:#08745b; }
    .btn.tiny { padding:5px 8px; font-size:.78rem; }
    .badge { background:#eef7f3; padding:4px 8px; border-radius:999px; font-size:.78rem; }
    .notice { padding:10px; margin:10px 0; border-radius:8px; }
    .notice.ok { background:#e7f7ef; }
    .notice.bad { background:#fff0f0; color:#a11; }
    .modal { position:fixed; inset:0; background:#0007; display:grid; place-items:center; z-index:20; }
    .modal article { background:#fff; border-radius:14px; padding:22px; width:min(520px,92vw); display:grid; gap:10px; }
    .modal label { display:grid; gap:4px; }
    .modal-actions { display:flex; justify-content:flex-end; gap:8px; margin-top:8px; }
    .spinner { display:inline-block; width:14px; height:14px; border:2px solid rgba(255,255,255,.45); border-top-color:#fff; border-radius:50%; animation:spin .75s linear infinite; margin-right:6px; vertical-align:-2px; }
    @keyframes spin { to { transform:rotate(360deg);} }
  `],
})
export class EvaluationListComponent {
  private readonly api = inject(EvaluationService);
  private readonly router = inject(Router);
  private readonly fb = inject(FormBuilder);

  evaluations = signal<EvaluationList[]>([]);
  loading = signal(false);
  error = signal('');
  message = signal('');
  showModal = signal(false);
  creating = signal(false);

  form: FormGroup = this.fb.group({
    anio: [{ value: new Date().getFullYear(), disabled: true }],
    numero_semana: [{ value: 1, disabled: true }, [Validators.min(1), Validators.max(53)]],
    nombre_semana: [''],
    fecha_inicio: ['', Validators.required],
    fecha_fin: [{ value: '', disabled: true }],
    observaciones: [''],
  });

  constructor() {
    this.load();
    this.form.get('fecha_inicio')?.valueChanges.subscribe((value) => {
      if (!value) {
        return;
      }
      const calculated = calculateEvaluationWeek(value);
      const currentName = String(this.form.get('nombre_semana')?.value ?? '').trim();
      this.form.patchValue(
        {
          anio: calculated.anio,
          numero_semana: calculated.numero_semana,
          fecha_fin: calculated.fecha_fin,
          ...(currentName ? {} : { nombre_semana: calculated.nombre_semana }),
        },
        { emitEvent: false },
      );
    });
  }

  load(): void {
    this.loading.set(true);
    this.error.set('');
    this.api.getEvaluations().subscribe({
      next: (rows) => {
        this.evaluations.set(rows);
        this.loading.set(false);
      },
      error: (e) => {
        this.loading.set(false);
        this.error.set(e?.error?.message || 'No fue posible consultar las evaluaciones.');
      },
    });
  }

  openModal(): void {
    this.showModal.set(true);
    this.message.set('');
    this.error.set('');
    this.resetForm();
  }

  closeModal(): void {
    if (this.creating()) return;
    this.showModal.set(false);
  }

  resetForm(): void {
    this.form.reset({
      anio: new Date().getFullYear(),
      numero_semana: 1,
      nombre_semana: '',
      fecha_inicio: '',
      fecha_fin: '',
      observaciones: '',
    });
  }

  create(): void {
    if (this.form.invalid || this.creating()) {
      this.form.markAllAsTouched();
      return;
    }
    this.creating.set(true);
    this.error.set('');
    const payload = this.form.getRawValue();
    this.api.createEvaluation(payload as Record<string, unknown>).subscribe({
      next: () => {
        this.creating.set(false);
        this.showModal.set(false);
        this.message.set('Evaluación creada correctamente.');
        this.load();
      },
      error: (e) => {
        this.creating.set(false);
        this.error.set(e?.error?.message || 'No fue posible crear la evaluación.');
      },
    });
  }

  openDetail(id: number): void {
    this.router.navigate(['/admin/evaluations', id]);
  }

  openPanel(id: number): void {
    this.router.navigate(['/admin/evaluations', id, 'management-panel']);
  }
}

export { calculateEvaluationWeek as calculateIsoWeek };