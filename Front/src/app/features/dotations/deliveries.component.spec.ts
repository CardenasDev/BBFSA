import { TestBed } from '@angular/core/testing';
import { provideRouter } from '@angular/router';
import { of, throwError } from 'rxjs';
import { AuthService } from '../../core/services/auth.service';
import { DotationDelivery } from '../../core/models/api.models';
import { DotationService } from '../../core/services/dotation.service';
import { DotationDeliveriesComponent } from './deliveries.component';

describe('DotationDeliveriesComponent purchase preparation', () => {
  const prepareDelivery = vi.fn();
  const purchase = {
    id_dotacion_entrega: 31, id_empleado: 5, fecha_entrega: '2026-08-10',
    tipo_entrega: 'ORDINARIA' as const, estado: 'POR_COMPRAR' as const,
    numero_documento: '001234', nombre_completo: 'Ana Pérez', id_registrado_por: 99,
  } as unknown as DotationDelivery;

  beforeEach(async () => {
    prepareDelivery.mockReset();
    prepareDelivery.mockReturnValue(of({ ...purchase, estado: 'REGISTRADA' }));
    await TestBed.configureTestingModule({
      imports: [DotationDeliveriesComponent],
      providers: [
        provideRouter([]),
        { provide: AuthService, useValue: { hasPermission: (permission: string) => permission === 'DOTACIONES_ENTREGAS_CREAR' } },
        {
          provide: DotationService,
          useValue: {
            getDeliveries: () => of([purchase]),
            prepareDelivery,
            deleteDelivery: () => of(null),
          },
        },
      ],
    }).compileComponents();
  });

  it('shows the badge and prepares the same request with URL evidence', () => {
    const fixture = TestBed.createComponent(DotationDeliveriesComponent);
    fixture.detectChanges();
    expect(fixture.nativeElement.textContent).toContain('Por comprar');
    expect(fixture.nativeElement.textContent).toContain('Preparar entrega');

    const component = fixture.componentInstance;
    component.openPrepareDelivery(purchase);
    component.prepareDate = '2026-08-12';
    component.prepareOrigin = 'URL';
    component.prepareUrl = 'https://example.com/evidence.jpg';
    component.confirmPrepareDelivery();

    expect(prepareDelivery).toHaveBeenCalledWith(31, expect.objectContaining({
      fecha_entrega: '2026-08-12',
      origen_evidencia: 'URL',
      evidencia_url: 'https://example.com/evidence.jpg',
    }));
    expect(component.success()).toContain('lista para entregar');
  });

  it('keeps the drawer open and shows a controlled backend error', () => {
    const component = TestBed.createComponent(DotationDeliveriesComponent).componentInstance;
    component.openPrepareDelivery(purchase);
    component.prepareOrigin = 'URL';
    component.prepareUrl = 'https://example.com/evidence.jpg';
    prepareDelivery.mockReturnValue(throwError(() => new Error('backend')));

    component.confirmPrepareDelivery();

    expect(component.selectedPrepareDelivery()?.id_dotacion_entrega).toBe(31);
    expect(component.prepareError()).toContain('No fue posible preparar');
  });
});
