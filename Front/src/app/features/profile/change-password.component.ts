import { Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { finalize } from 'rxjs';
import { AuthService } from '../../core/services/auth.service';
import { apiErrorMessage } from '../../shared/api-error';

@Component({ standalone: true, imports: [ReactiveFormsModule], template: `
  <div class="page-heading"><div><p class="eyebrow">Seguridad</p><h1>Cambiar contraseña</h1><p class="muted">Utiliza al menos 8 caracteres, con letras y números.</p></div></div>
  <form class="panel narrow-form" [formGroup]="form" (ngSubmit)="submit()" novalidate>
    @if (error()) { <div class="alert error" role="alert">{{ error() }}</div> }
    @if (success()) { <div class="alert success" role="status">Contraseña actualizada correctamente.</div> }
    <label>Contraseña actual<input type="password" formControlName="current_password" autocomplete="current-password" /></label>
    @if (invalid('current_password')) { <small class="field-error">Ingresa tu contraseña actual.</small> }
    <label>Nueva contraseña<input type="password" formControlName="password" autocomplete="new-password" /></label>
    @if (invalid('password')) { <small class="field-error">La nueva contraseña debe tener mínimo 8 caracteres, letras y números.</small> }
    <label>Confirmar contraseña<input type="password" formControlName="password_confirmation" autocomplete="new-password" /></label>
    @if (invalid('password_confirmation')) { <small class="field-error">Confirma la nueva contraseña.</small> }
    @if (mismatch()) { <small class="field-error">Las contraseñas no coinciden.</small> }
    <button class="btn primary" type="submit" [disabled]="loading()">{{ loading() ? 'Actualizando…' : 'Actualizar contraseña' }}</button>
  </form>`, })
export class ChangePasswordComponent {
  private readonly fb = inject(FormBuilder); private readonly auth = inject(AuthService); private readonly router = inject(Router);
  readonly loading = signal(false); readonly error = signal(''); readonly success = signal(false); readonly submitted = signal(false);
  readonly form = this.fb.nonNullable.group({ current_password: ['', Validators.required], password: ['', [Validators.required, Validators.minLength(8), Validators.pattern(/^(?=.*[A-Za-z])(?=.*\d).+$/)]], password_confirmation: ['', Validators.required] });
  invalid(name: keyof typeof this.form.controls): boolean { const control = this.form.controls[name]; return control.invalid && (control.touched || this.submitted()); }
  mismatch(): boolean { const value = this.form.getRawValue(); return (this.submitted() || this.form.controls.password_confirmation.touched) && !!value.password_confirmation && value.password !== value.password_confirmation; }
  submit(): void { this.submitted.set(true); this.form.markAllAsTouched(); if (this.form.invalid || this.mismatch()) { this.error.set('Revisa los campos marcados antes de continuar.'); return; } this.loading.set(true); this.error.set(''); this.success.set(false); this.auth.changePassword(this.form.getRawValue()).pipe(finalize(() => this.loading.set(false))).subscribe({ next: () => { this.success.set(true); this.form.reset(); this.submitted.set(false); void this.router.navigate(['/admin/dashboard']); }, error: (error) => this.error.set(apiErrorMessage(error, 'No fue posible actualizar la contraseña.')) }); }
}
