import { TestBed } from '@angular/core/testing';
import { provideRouter } from '@angular/router';
import { of } from 'rxjs';
import { routes } from '../../app.routes';
import { AuthService } from '../../core/services/auth.service';
import { AdminLayoutComponent } from '../../layout/admin-layout.component';
describe('training navigation and permissions', () => {
  it('protects administration and employee routes with existing permissions', () => {
    const children = routes.find((r) => r.path === 'admin')?.children ?? [];
    expect(children.find((r) => r.path === 'trainings/sessions')?.data?.['permissions']).toEqual([
      'CAPACITACIONES_VER',
    ]);
    expect(children.find((r) => r.path === 'trainings/my-records')?.data?.['permissions']).toEqual([
      'CAPACITACIONES_MIS_REGISTROS_VER',
    ]);
  });
  it('shows only allowed training menu options', async () => {
    const granted = new Set<string>(['CAPACITACIONES_MIS_REGISTROS_VER']);
    await TestBed.configureTestingModule({
      imports: [AdminLayoutComponent],
      providers: [
        provideRouter([]),
        {
          provide: AuthService,
          useValue: {
            hasAnyPermission: (p: string[]) => p.some((x) => granted.has(x)),
            currentUser: () => null,
            logout: () => of(undefined),
          },
        },
      ],
    }).compileComponents();
    const c = TestBed.createComponent(AdminLayoutComponent).componentInstance;
    const training = () => c.visibleItems().find((x) => x.label === 'Capacitaciones');
    expect(training()?.children?.map((x) => x.label)).toEqual(['Mis capacitaciones']);
    granted.add('CAPACITACIONES_VER');
    expect(training()?.children?.map((x) => x.label)).toContain('Sesiones');
  });
});
