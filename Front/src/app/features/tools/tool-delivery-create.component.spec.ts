import { HttpErrorResponse } from '@angular/common/http';
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { provideRouter, Router } from '@angular/router';
import { of, Subject, throwError } from 'rxjs';
import { EmployeeService } from '../../core/services/employee.service';
import { ToolService } from '../../core/services/tool.service';
import { ToolDeliveryCreateComponent, toolDeliveryErrorMessage } from './tool-delivery-create.component';

describe('ToolDeliveryCreateComponent', () => {
  let fixture: ComponentFixture<ToolDeliveryCreateComponent>;
  let component: ToolDeliveryCreateComponent;
  let tools: { getTools: ReturnType<typeof vi.fn>; createToolDelivery: ReturnType<typeof vi.fn> };

  beforeEach(async () => {
    tools = {
      getTools: vi.fn().mockReturnValue(of([{ id_herramienta: 13, nombre: 'Guantes' }])),
      createToolDelivery: vi.fn().mockReturnValue(of({ id_entrega: 9, estado: 'pendiente' })),
    };
    await TestBed.configureTestingModule({
      imports: [ToolDeliveryCreateComponent],
      providers: [
        provideRouter([]),
        { provide: ToolService, useValue: tools },
        { provide: EmployeeService, useValue: { listEmployees: () => of([]) } },
      ],
    }).compileComponents();
    fixture = TestBed.createComponent(ToolDeliveryCreateComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  function validForm(files = [new File(['photo'], 'frente.jpg', { type: 'image/jpeg' })]): void {
    component.employeeId = 18;
    component.deliveryDate = '2026-07-27';
    component.observations = 'Entrega inicial';
    component.details.set([{ key: 1, id_herramienta: 13, cantidad: 2, observaciones: 'Dos pares' }]);
    component.evidence.set(files.map((file, index) => ({ file, url: `blob:${index}` })));
  }

  it('requires at least one photo', () => {
    validForm([]);
    component.submit();
    expect(component.error()).toContain('al menos una fotografía');
    expect(tools.createToolDelivery).not.toHaveBeenCalled();
  });

  it('accepts multiple JPG, PNG and WEBP photos and sends them', () => {
    const files = [
      new File(['a'], 'a.jpeg', { type: 'image/jpeg' }),
      new File(['b'], 'b.png', { type: 'image/png' }),
      new File(['c'], 'c.webp', { type: 'image/webp' }),
    ];
    validForm(files);
    vi.spyOn(TestBed.inject(Router), 'navigate').mockResolvedValue(true);
    component.submit();
    expect(tools.createToolDelivery).toHaveBeenCalledWith(expect.objectContaining({ evidencias: files }));
  });

  it('rejects empty, oversized, extension-mismatched and invalid MIME files', () => {
    for (const [file, message] of [
      [new File([], 'empty.jpg', { type: 'image/jpeg' }), 'leer'],
      [new File([new Uint8Array(5 * 1024 * 1024 + 1)], 'large.jpg', { type: 'image/jpeg' }), '5 MB'],
      [new File(['x'], 'wrong.pdf', { type: 'image/jpeg' }), 'válida'],
      [new File(['x'], 'wrong.jpg', { type: 'text/plain' }), 'válida'],
    ] as Array<[File, string]>) {
      validForm([file]);
      component.submit();
      expect(component.error()).toContain(message);
    }
    expect(tools.createToolDelivery).not.toHaveBeenCalled();
  });

  it('blocks duplicate submits until the request finishes', () => {
    const request = new Subject<{ id_entrega: number; estado: string }>();
    tools.createToolDelivery.mockReturnValue(request);
    validForm();
    component.submit();
    component.submit();
    expect(tools.createToolDelivery).toHaveBeenCalledTimes(1);
    expect(component.saving()).toBe(true);
    request.error(new Error('fail'));
    expect(component.saving()).toBe(false);
  });

  it('preserves data and photos on error', () => {
    tools.createToolDelivery.mockReturnValue(throwError(() => new Error('fail')));
    validForm();
    component.submit();
    expect(component.employeeId).toBe(18);
    expect(component.details()).toHaveLength(1);
    expect(component.evidence()).toHaveLength(1);
  });

  it('cleans the form and revokes object URLs on success', () => {
    const revoke = vi.spyOn(URL, 'revokeObjectURL').mockImplementation(() => undefined);
    vi.spyOn(TestBed.inject(Router), 'navigate').mockResolvedValue(true);
    validForm();
    component.submit();
    expect(revoke).toHaveBeenCalledWith('blob:0');
    expect(component.employeeId).toBeNull();
    expect(component.evidence()).toEqual([]);
  });

  it('creates previews and revokes them when removed or destroyed', () => {
    const create = vi.spyOn(URL, 'createObjectURL').mockReturnValueOnce('blob:new');
    const revoke = vi.spyOn(URL, 'revokeObjectURL').mockImplementation(() => undefined);
    const file = new File(['x'], 'photo.png', { type: 'image/png' });
    component.selectFiles({ target: { files: [file], value: 'selected' } } as unknown as Event);
    expect(create).toHaveBeenCalledWith(file);
    component.removeFile(component.evidence()[0]);
    expect(revoke).toHaveBeenCalledWith('blob:new');
    component.evidence.set([{ file, url: 'blob:destroy' }]);
    component.ngOnDestroy();
    expect(revoke).toHaveBeenCalledWith('blob:destroy');
  });

  it('maps evidence validation errors safely', () => {
    expect(toolDeliveryErrorMessage(new HttpErrorResponse({ status: 422, error: { errors: { 'evidencias.0': ['invalid mime'] } } }))).toContain('formato');
    expect(toolDeliveryErrorMessage(new HttpErrorResponse({ status: 500, error: { message: 'SQL exception stack trace' } }))).not.toContain('SQL');
  });
});
