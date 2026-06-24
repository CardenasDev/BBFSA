import { ComponentFixture, TestBed } from '@angular/core/testing';
import { Router } from '@angular/router';
import { of } from 'rxjs';
import { AuthService } from '../../core/services/auth.service';
import { ChangePasswordComponent } from './change-password.component';

describe('ChangePasswordComponent', () => {
  let fixture: ComponentFixture<ChangePasswordComponent>;
  const changePassword = vi.fn();
  const navigate = vi.fn();

  beforeEach(async () => {
    changePassword.mockReturnValue(of({
      usuario: {
        id_usuario: 1, nombre_usuario: 'admin', correo: 'tester@example.com',
        tipo_usuario: 'ADMIN', tipo_autenticacion: 'LOCAL', estado: 'ACTIVO',
        requiere_cambio_password: false,
      },
      roles: [],
      permisos: [],
    }));
    await TestBed.configureTestingModule({
      imports: [ChangePasswordComponent],
      providers: [
        { provide: AuthService, useValue: { changePassword } },
        { provide: Router, useValue: { navigate } },
      ],
    }).compileComponents();
    fixture = TestBed.createComponent(ChangePasswordComponent);
    fixture.detectChanges();
  });

  afterEach(() => {
    changePassword.mockClear();
    navigate.mockClear();
  });

  it('muestra errores al enviar un formulario inválido', () => {
    fixture.nativeElement.querySelector('button[type="submit"]').click();
    fixture.detectChanges();

    expect(changePassword).not.toHaveBeenCalled();
    expect(fixture.nativeElement.querySelector('[role="alert"]').textContent).toContain('Revisa los campos');
    expect(fixture.nativeElement.querySelectorAll('.field-error').length).toBe(3);
  });

  it('envía el payload exacto y navega al dashboard', () => {
    fixture.componentInstance.form.setValue({
      current_password: 'clave-actual',
      password: 'NuevaClave1*',
      password_confirmation: 'NuevaClave1*',
    });
    fixture.detectChanges();
    fixture.nativeElement.querySelector('button[type="submit"]').click();

    expect(changePassword).toHaveBeenCalledWith({
      current_password: 'clave-actual',
      password: 'NuevaClave1*',
      password_confirmation: 'NuevaClave1*',
    });
    expect(navigate).toHaveBeenCalledWith(['/admin/dashboard']);
  });
});
