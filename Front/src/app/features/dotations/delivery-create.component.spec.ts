import { TestBed } from '@angular/core/testing';
import { provideRouter } from '@angular/router';
import { of, throwError } from 'rxjs';
import { DotationService } from '../../core/services/dotation.service';
import { DotationDeliveryCreateComponent } from './delivery-create.component';

describe('DotationDeliveryCreateComponent camera integration', () => {
  const createDelivery = vi.fn();

  beforeEach(async () => {
    createDelivery.mockReset();
    createDelivery.mockReturnValue(of({ id_dotacion_entrega: 30 }));
    await TestBed.configureTestingModule({
      imports: [DotationDeliveryCreateComponent],
      providers: [
        provideRouter([]),
        {
          provide: DotationService,
          useValue: {
            getEmployees: () => of([]),
            getTypes: () => of([]),
            getCombinations: () => of([]),
            createDelivery,
          },
        },
      ],
    }).compileComponents();
  });

  it('uses a captured File under evidencia_archivo and preserves it on backend error', () => {
    const fixture = TestBed.createComponent(DotationDeliveryCreateComponent);
    fixture.detectChanges();
    const component = fixture.componentInstance;
    const capture = new File(['camera'], 'evidencia-camera.jpg', { type: 'image/jpeg' });
    component.setEvidenceFiles([capture]);
    component.idEmpleado = 10;
    component.tipoEntrega = 'EXTRAORDINARIA';
    component.details.set([{
      clientId: 1, id_tipo_dotacion: 4, tipo_dotacion: 'Camisa', requiere_talla: false,
      id_talla_dotacion: null, talla: null, cantidad: 1, observaciones: '',
    }]);
    createDelivery.mockReturnValue(throwError(() => new Error('backend')));
    component.submit();
    expect(createDelivery).toHaveBeenCalledWith(expect.objectContaining({ evidencia_archivo: capture }));
    expect(component.evidenciaArchivo).toBe(capture);
  });

  it('rejects an oversized captured image with the existing 5 MB rule', () => {
    const component = TestBed.createComponent(DotationDeliveryCreateComponent).componentInstance;
    component.setEvidenceFiles([
      new File([new Uint8Array(5 * 1024 * 1024 + 1)], 'grande.jpg', { type: 'image/jpeg' }),
    ]);
    expect(component.evidenciaArchivo).toBeNull();
    expect(component.evidenceError()).toContain('5 MB');
  });
});
