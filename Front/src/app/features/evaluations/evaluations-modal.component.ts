import { CommonModule } from '@angular/common';
import { Component, EventEmitter, inject, input, Output, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { EvaluationService } from '../../core/services/evaluation.service';
import {
  calculateEvaluationWeek,
  toIsoDate,
} from './evaluation-week.util';

export * from './evaluation-week.util';

@Component({
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  templateUrl: './evaluations-modal.component.html',
  styles: [`
    .modal { position:fixed; inset:0; background:#0007; display:grid; place-items:center; z-index:20; }
    .modal article { background:#fff; border-radius:14px; padding:22px; width:min(520px,92vw); display:grid; gap:10px; }
    .modal label { display:grid; gap:4px; }
    .modal-actions { display:flex; justify-content:flex-end; gap:8px; margin-top:8px; }
    .notice { padding:10px; margin:10px 0; border-radius:8px; }
    .notice.bad { background:#fff0f0; color:#a11; }
    .spinner { display:inline-block; width:14px; height:14px; border:2px solid rgba(255,255,255,.45); border-top-color:#fff; border-radius:50%; animation:spin .75s linear infinite; margin-right:6px; vertical-align:-2px; }
    @keyframes spin { to { transform:rotate(360deg);} }
  `],
})
export class EvaluationsModalComponent {
  readonly open = input(false);
  readonly openModalFlag = signal(false);

  private readonly fb = inject(FormBuilder);
  private readonly api = inject(EvaluationService);

  readonly showModal = this.openModalFlag;
  readonly creating = signal(false);
  readonly error = signal('');

  readonly form = this.fb.group({
    anio: [{ value: new Date().getFullYear(), disabled: true }],
    numero_semana: [{ value: 1, disabled: true }, [Validators.min(1), Validators.max(53)]],
    nombre_semana: [''],
    fecha_inicio: ['', Validators.required],
    fecha_fin: [{ value: '', disabled: true }],
    observaciones: [''],
  });

  @Output() created = new EventEmitter<void>();
  @Output() closed = new EventEmitter<void>();

  constructor() {
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

  isOpen(): boolean {
    return this.open() || this.openModalFlag();
  }

  openModal(): void {
    this.error.set('');
    this.creating.set(false);
    this.resetForm();
    this.openModalFlag.set(true);
  }

  closeModal(): void {
    if (this.creating()) {
      return;
    }
    this.openModalFlag.set(false);
    this.error.set('');
    this.closed.emit();
  }

  close(): void {
    this.closeModal();
  }

  submit(): void {
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
        this.openModalFlag.set(false);
        this.created.emit();
      },
      error: (e) => {
        this.creating.set(false);
        this.error.set(e?.error?.message || 'No fue posible crear la evaluación.');
      },
    });
  }

  create(): void {
    this.submit();
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

  // Compatibility aliases used by existing callers.
  get anio() {
    return this.form.get('anio')?.value;
  }

  calculateWeek(fechaInicio: string | Date) {
    return calculateEvaluationWeek(fechaInicio);
  }

  getIsoWeek(fechaInicio: string | Date) {
    return calculateEvaluationWeek(fechaInicio);
  }
}

export { EvaluationsModalComponent as EvaluationModalComponent };
export { EvaluationsModalComponent as EvaluationsModal };
export { toIsoDate };