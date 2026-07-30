import { TestBed } from '@angular/core/testing';
import { provideRouter } from '@angular/router';
import { of } from 'rxjs';
import { routes } from '../../app.routes';
import { AuthService } from '../../core/services/auth.service';
import { AdminLayoutComponent } from '../../layout/admin-layout.component';

describe('bulk load navigation and guards', () => {
  it('protects the general and employee routes with existing employee permissions', () => {
    const children = routes.find((route) => route.path === 'admin')?.children ?? [];
    expect(children.find((route) => route.path === 'bulk-load')?.data?.['permissions']).toEqual(['EMPLEADOS_VER', 'EMPLEADOS_CREAR']);
    expect(children.find((route) => route.path === 'bulk-load/employees')?.data?.['permissions']).toEqual(['EMPLEADOS_VER', 'EMPLEADOS_CREAR']);
  });

  it('only exposes the menu entry with an employee permission', async () => {
    const granted = new Set<string>();
    await TestBed.configureTestingModule({
      imports: [AdminLayoutComponent],
      providers: [
        provideRouter([]),
        { provide: AuthService, useValue: {
          hasAnyPermission: (codes: string[]) => codes.some((code) => granted.has(code)),
          currentUser: () => null,
          logout: () => of(undefined),
        } },
      ],
    }).compileComponents();
    const component = TestBed.createComponent(AdminLayoutComponent).componentInstance;
    expect(component.visibleItems().map((item) => item.label)).not.toContain('Carga masiva');
    granted.add('EMPLEADOS_VER');
    expect(component.visibleItems().map((item) => item.label)).toContain('Carga masiva');
  });
});
