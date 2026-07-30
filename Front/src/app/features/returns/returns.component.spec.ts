import { ComponentFixture, TestBed } from '@angular/core/testing';
import { provideRouter } from '@angular/router';
import { of, throwError } from 'rxjs';
import { AuthService } from '../../core/services/auth.service';
import { ReturnService } from '../../core/services/return.service';
import { ReturnsComponent } from './returns.component';

describe('ReturnsComponent', () => {
  let fixture: ComponentFixture<ReturnsComponent>;
  let component: ReturnsComponent;
  let permissions: Set<string>;
  let service: {
    getReturns: ReturnType<typeof vi.fn>;
    confirmReturn: ReturnType<typeof vi.fn>;
    cancelReturn: ReturnType<typeof vi.fn>;
  };

  const registered = {
    id_devolucion: 1, tipo_devolucion: 'DOTACION' as const, id_empleado: 20, id_entrega: 8,
    fecha_devolucion: '2026-07-29', estado: 'REGISTRADA' as const,
  };

  beforeEach(async () => {
    permissions = new Set(['DEVOLUCIONES_VER']);
    service = {
      getReturns: vi.fn().mockReturnValue(of([registered])),
      confirmReturn: vi.fn().mockReturnValue(of({ id_devolucion: 1, estado: 'CONFIRMADA' })),
      cancelReturn: vi.fn().mockReturnValue(of({ id_devolucion: 1, estado: 'ANULADA' })),
    };
    await TestBed.configureTestingModule({
      imports: [ReturnsComponent],
      providers: [
        provideRouter([]),
        { provide: ReturnService, useValue: service },
        { provide: AuthService, useValue: { hasPermission: (code: string) => permissions.has(code) } },
      ],
    }).compileComponents();
    fixture = TestBed.createComponent(ReturnsComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('shows the section but hides create without DEVOLUCIONES_CREAR', () => {
    expect(fixture.nativeElement.textContent).toContain('Devoluciones');
    expect(fixture.nativeElement.textContent).not.toContain('Registrar devolución');
    permissions.add('DEVOLUCIONES_CREAR');
    fixture.detectChanges();
    expect(fixture.nativeElement.textContent).toContain('Registrar devolución');
  });

  it('applies independent confirm and cancel permissions', () => {
    expect(component.canConfirm(registered)).toBe(false);
    expect(component.canCancel(registered)).toBe(false);
    permissions.add('DEVOLUCIONES_CONFIRMAR');
    expect(component.canConfirm(registered)).toBe(true);
    permissions.add('DEVOLUCIONES_ANULAR');
    expect(component.canCancel(registered)).toBe(true);
  });

  it('confirms only registered records after explicit acceptance', () => {
    permissions.add('DEVOLUCIONES_CONFIRMAR');
    vi.spyOn(window, 'confirm').mockReturnValue(false);
    component.confirmReturn(registered);
    expect(service.confirmReturn).not.toHaveBeenCalled();
    vi.mocked(window.confirm).mockReturnValue(true);
    component.confirmReturn(registered);
    expect(service.confirmReturn).toHaveBeenCalledWith(1);
    expect(component.returns()[0].estado).toBe('CONFIRMADA');
  });

  it('requires a cancellation reason and keeps the cancelled row in history', () => {
    permissions.add('DEVOLUCIONES_ANULAR');
    vi.spyOn(window, 'prompt').mockReturnValue('');
    component.cancelReturn(registered);
    expect(service.cancelReturn).not.toHaveBeenCalled();
    expect(component.error()).toContain('obligatorio');
    vi.mocked(window.prompt).mockReturnValue('Registro duplicado');
    component.cancelReturn(registered);
    expect(service.cancelReturn).toHaveBeenCalledWith(1, 'Registro duplicado');
    expect(component.returns()).toHaveLength(1);
    expect(component.returns()[0].estado).toBe('ANULADA');
  });

  it('restores independent loading after a history error', () => {
    service.getReturns.mockReturnValue(throwError(() => new Error('fail')));
    component.load();
    expect(component.loading()).toBe(false);
    expect(component.error()).toContain('historial');
  });
});
