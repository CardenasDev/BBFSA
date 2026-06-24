import { Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
import { finalize } from 'rxjs';
import { AuthService } from '../../core/services/auth.service';
import { apiErrorMessage } from '../../shared/api-error';

@Component({
  standalone: true, imports: [ReactiveFormsModule],
  template: `
    <main class="auth-page">
      <section class="auth-brand">
        <div class="brand-mark">BBF</div>
        <p class="eyebrow">Barro Blanco Farms</p>
        <h1>Administración clara para una operación que no se detiene.</h1>
        <p class="brand-copy">Accede de forma segura a usuarios, roles y procesos administrativos.</p>
      </section>
      <section class="auth-panel">
        <form class="auth-card" [formGroup]="form" (ngSubmit)="submit()">
          <p class="eyebrow">Sistema Administrativo</p><h2>Iniciar sesión</h2>
          <p class="muted">Ingresa con tu usuario o correo corporativo.</p>
          @if (error()) { <div class="alert error" role="alert">{{ error() }}</div> }
          <label>Usuario o correo<input formControlName="usuario" autocomplete="username" placeholder="usuario@barroblanco.com" /></label>
          @if (form.controls.usuario.touched && form.controls.usuario.invalid) { <small class="field-error">El usuario es obligatorio.</small> }
          <label>Contraseña<input type="password" formControlName="password" autocomplete="current-password" placeholder="••••••••" /></label>
          @if (form.controls.password.touched && form.controls.password.invalid) { <small class="field-error">La contraseña es obligatoria.</small> }
          <button class="btn primary full" type="submit" [disabled]="loading()">{{ loading() ? 'Validando…' : 'Iniciar sesión' }}</button>
          <p class="security-note">Conexión protegida con autenticación JWT.</p>
        </form>
      </section>
    </main>`,
})
export class LoginComponent {
  private readonly fb = inject(FormBuilder); private readonly auth = inject(AuthService); private readonly router = inject(Router); private readonly route = inject(ActivatedRoute);
  readonly loading = signal(false); readonly error = signal('');
  readonly form = this.fb.nonNullable.group({ usuario: ['', Validators.required], password: ['', Validators.required] });
  submit(): void {
    if (this.form.invalid) { this.form.markAllAsTouched(); return; }
    this.loading.set(true); this.error.set('');
    const { usuario, password } = this.form.getRawValue();
    this.auth.login(usuario, password).pipe(finalize(() => this.loading.set(false))).subscribe({
      next: () => void this.router.navigateByUrl(this.returnUrl()),
      error: (error) => this.error.set(apiErrorMessage(error, 'Credenciales incorrectas.')),
    });
  }

  private returnUrl(): string {
    return this.route.snapshot.queryParamMap.get('returnUrl') || '/admin/dashboard';
  }
}
