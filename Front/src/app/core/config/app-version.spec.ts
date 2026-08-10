import { TestBed } from '@angular/core/testing';
import { provideRouter } from '@angular/router';
import { of } from 'rxjs';
import { LoginComponent } from '../../features/auth/login.component';
import { AdminLayoutComponent } from '../../layout/admin-layout.component';
import { AuthService } from '../services/auth.service';
import { APP_VERSION, APP_VERSION_LABEL } from './app-version';

describe('centralized application version', () => {
  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [LoginComponent, AdminLayoutComponent],
      providers: [
        provideRouter([]),
        {
          provide: AuthService,
          useValue: {
            login: () => of(undefined),
            logout: () => of(undefined),
            currentUser: () => ({ nombre_usuario: 'Admin', tipo_usuario: 'ADMIN' }),
            hasAnyPermission: () => false,
          },
        },
      ],
    }).compileComponents();
  });

  it('defines the initial version in one typed source', () => {
    expect(APP_VERSION).toBe('0.0.2');
    expect(APP_VERSION_LABEL).toBe(`v${APP_VERSION}`);
  });

  it('shows the centralized label in the login card', () => {
    const fixture = TestBed.createComponent(LoginComponent);
    fixture.detectChanges();
    const label = fixture.nativeElement.querySelector('.login-version') as HTMLElement;
    expect(label.textContent?.trim()).toBe(APP_VERSION_LABEL);
    expect(label.getAttribute('aria-label')).toBe('Versión de la aplicación');
  });

  it('shows the same centralized label at the bottom of the authenticated sidebar', () => {
    const fixture = TestBed.createComponent(AdminLayoutComponent);
    fixture.detectChanges();
    const label = fixture.nativeElement.querySelector('.sidebar-footer .sidebar-version') as HTMLElement;
    expect(label.textContent?.trim()).toBe(APP_VERSION_LABEL);
    expect(label.getAttribute('aria-label')).toBe('Versión de la aplicación');
  });
});
