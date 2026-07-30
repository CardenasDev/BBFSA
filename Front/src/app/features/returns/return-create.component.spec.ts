import { signal } from '@angular/core';
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { provideRouter, Router } from '@angular/router';
import { of, Subject, throwError } from 'rxjs';
import { EmployeeService } from '../../core/services/employee.service';
import { ReturnService } from '../../core/services/return.service';
import { ReturnCreateComponent } from './return-create.component';

describe('ReturnCreateComponent', () => {
  let fixture: ComponentFixture<ReturnCreateComponent>;
  let component: ReturnCreateComponent;
  let returns: {
    getAvailableReturns: ReturnType<typeof vi.fn>;
    createReturn: ReturnType<typeof vi.fn>;
  };

  beforeEach(async () => {
    returns = {
      getAvailableReturns: vi.fn().mockReturnValue(of([])),
      createReturn: vi.fn().mockReturnValue(of({ id_devolucion: 10, estado: 'REGISTRADA' })),
    };
    await TestBed.configureTestingModule({
      imports: [ReturnCreateComponent],
      providers: [
        provideRouter([]),
        { provide: ReturnService, useValue: returns },
        { provide: EmployeeService, useValue: { listEmployees: () => of([]) } },
      ],
    }).compileComponents();
    fixture = TestBed.createComponent(ReturnCreateComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('loads available items with type and employee and handles empty lists', () => {
    component.changeEmployee(20);
    expect(returns.getAvailableReturns).toHaveBeenCalledWith('DOTACION', 20);
    expect(component.deliveries()).toEqual([]);
    expect(component.availableLoading()).toBe(false);
  });

  it('changing type clears delivery, drafts and evidence and revokes previews', () => {
    const revoke = vi.spyOn(URL, 'revokeObjectURL').mockImplementation(() => undefined);
    component.deliveryId = 7;
    component.drafts.set([{
      selected: true,
      item: { tipo_devolucion: 'DOTACION', id_entrega: 7, id_detalle: 1, id_empleado: 20, fecha_entrega: '2026-07-01', elemento: 'Camisa', cantidad_entregada: 2, cantidad_devuelta: 0, cantidad_disponible: 2 },
      cantidad: 1, estado_elemento: 'BUENO', observaciones: '',
    }]);
    component.evidence.set([{ file: new File(['x'], 'x.png', { type: 'image/png' }), url: 'blob:test' }]);
    component.changeType('HERRAMIENTA');
    expect(component.deliveryId).toBeNull();
    expect(component.drafts()).toEqual([]);
    expect(component.evidence()).toEqual([]);
    expect(revoke).toHaveBeenCalledWith('blob:test');
  });

  it('changing employee clears the previous delivery selection', () => {
    component.deliveryId = 7;
    component.changeEmployee(21);
    expect(component.employeeId).toBe(21);
    expect(component.deliveryId).toBeNull();
    expect(component.drafts()).toEqual([]);
  });

  it('allows a partial quantity and creates the expected payload', () => {
    vi.spyOn(TestBed.inject(Router), 'navigate').mockResolvedValue(true);
    component.employeeId = 20;
    component.deliveryId = 7;
    component.reason = 'Cambio';
    component.drafts.set([{
      selected: true,
      item: { tipo_devolucion: 'DOTACION', id_entrega: 7, id_detalle: 1, id_empleado: 20, fecha_entrega: '2026-07-01', elemento: 'Camisa', cantidad_entregada: 3, cantidad_devuelta: 0, cantidad_disponible: 3 },
      cantidad: 2, estado_elemento: 'BUENO', observaciones: '',
    }]);
    component.evidence.set([{ file: new File(['pdf'], 'acta.pdf', { type: 'application/pdf' }), url: null }]);
    component.submit();
    expect(returns.createReturn).toHaveBeenCalledWith(expect.objectContaining({
      details: [{ id_detalle: 1, cantidad: 2, estado_elemento: 'BUENO', observaciones: null }],
    }));
  });

  it('rejects zero, quantities above available, missing condition and missing evidence', () => {
    component.employeeId = 20; component.deliveryId = 7; component.reason = 'Cambio';
    component.drafts.set([{
      selected: true,
      item: { tipo_devolucion: 'DOTACION', id_entrega: 7, id_detalle: 1, id_empleado: 20, fecha_entrega: '2026-07-01', elemento: 'Camisa', cantidad_entregada: 2, cantidad_devuelta: 0, cantidad_disponible: 2 },
      cantidad: 0, estado_elemento: '', observaciones: '',
    }]);
    component.submit();
    expect(component.error()).toContain('mayores que cero');
    component.drafts.update((items) => [{ ...items[0], cantidad: 3 }]);
    component.submit();
    expect(component.error()).toContain('superar');
    component.drafts.update((items) => [{ ...items[0], cantidad: 1 }]);
    component.submit();
    expect(component.error()).toContain('estado físico');
    component.drafts.update((items) => [{ ...items[0], estado_elemento: 'BUENO' }]);
    component.submit();
    expect(component.error()).toContain('evidencia');
  });

  it('requires a photo for tools and preserves the form after a request error', () => {
    returns.createReturn.mockReturnValue(throwError(() => new Error('fail')));
    component.type = 'HERRAMIENTA'; component.employeeId = 20; component.deliveryId = 7; component.reason = 'Fin';
    component.drafts.set([{
      selected: true,
      item: { tipo_devolucion: 'HERRAMIENTA', id_entrega: 7, id_detalle: 1, id_empleado: 20, fecha_entrega: '2026-07-01', elemento: 'Taladro', cantidad_entregada: 1, cantidad_devuelta: 0, cantidad_disponible: 1 },
      cantidad: 1, estado_elemento: 'BUENO', observaciones: '',
    }]);
    component.evidence.set([{ file: new File(['pdf'], 'acta.pdf', { type: 'application/pdf' }), url: null }]);
    component.submit();
    expect(component.error()).toContain('fotografía');
    component.evidence.set([{ file: new File(['img'], 'tool.jpg', { type: 'image/jpeg' }), url: null }]);
    component.submit();
    expect(component.reason).toBe('Fin');
    expect(component.drafts()).toHaveLength(1);
    expect(component.saving()).toBe(false);
  });

  it('keeps the submit state disabled until the request finishes', () => {
    const request = new Subject<{ id_devolucion: number; estado: string }>();
    returns.createReturn.mockReturnValue(request);
    component.employeeId = 20; component.deliveryId = 7; component.reason = 'Cambio';
    component.drafts.set([{
      selected: true,
      item: { tipo_devolucion: 'DOTACION', id_entrega: 7, id_detalle: 1, id_empleado: 20, fecha_entrega: '2026-07-01', elemento: 'Camisa', cantidad_entregada: 1, cantidad_devuelta: 0, cantidad_disponible: 1 },
      cantidad: 1, estado_elemento: 'BUENO', observaciones: '',
    }]);
    component.evidence.set([{ file: new File(['pdf'], 'acta.pdf', { type: 'application/pdf' }), url: null }]);
    component.submit();
    expect(component.saving()).toBe(true);
    request.error(new Error('fail'));
    expect(component.saving()).toBe(false);
  });
});
