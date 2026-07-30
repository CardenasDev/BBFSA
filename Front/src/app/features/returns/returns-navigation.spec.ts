import { TestBed } from '@angular/core/testing';
import { provideRouter } from '@angular/router';
import { of } from 'rxjs';
import { routes } from '../../app.routes';
import { AuthService } from '../../core/services/auth.service';
import { AdminLayoutComponent } from '../../layout/admin-layout.component';

describe('returns navigation and guards', () => {
  it('protects list, creation and detail with their operation permissions', () => {
    const admin = routes.find((route) => route.path === 'admin');
    const children = admin?.children ?? [];
    expect(children.find((route) => route.path === 'returns')?.data?.['permissions']).toEqual(['DEVOLUCIONES_VER']);
    expect(children.find((route) => route.path === 'returns/create')?.data?.['permissions']).toEqual(['DEVOLUCIONES_CREAR']);
    expect(children.find((route) => route.path === 'returns/:id')?.data?.['permissions']).toEqual(['DEVOLUCIONES_VER']);
  });

  it('only exposes the Devoluciones menu entry with DEVOLUCIONES_VER', async () => {
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
    const menuLabels = () => component.visibleItems().flatMap((item) => [item.label, ...(item.children ?? []).map((child) => child.label)]);
    expect(menuLabels()).not.toContain('Devoluciones');
    granted.add('DEVOLUCIONES_VER');
    expect(menuLabels()).toContain('Devoluciones');
  });
});
