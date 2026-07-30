import { Type } from '@angular/core';
import { TestBed } from '@angular/core/testing';
import { provideRouter } from '@angular/router';
import { ActivatedRoute } from '@angular/router';
import { of } from 'rxjs';
import { AuthService } from '../../core/services/auth.service';
import { ToolService } from '../../core/services/tool.service';
import { MyToolDeliveryDetailComponent } from './my-tool-delivery-detail.component';
import { ToolDeliveryDetailComponent } from './tool-delivery-detail.component';

describe('tool delivery evidence details', () => {
  const route = { snapshot: { paramMap: { get: () => '9' } } };
  const auth = { hasPermission: () => false };

  async function render(componentType: Type<unknown>, evidencias: unknown[]) {
    await TestBed.configureTestingModule({
      imports: [componentType],
      providers: [
        provideRouter([]),
        { provide: ActivatedRoute, useValue: route },
        { provide: AuthService, useValue: auth },
        { provide: ToolService, useValue: {
          getToolDelivery: () => of({ id_entrega: 9, fecha_entrega: '2026-07-27', herramientas: [], evidencias }),
          getMyToolDelivery: () => of({ id_entrega: 9, fecha_entrega: '2026-07-27', herramientas: [], evidencias }),
        } },
      ],
    }).compileComponents();
    const fixture = TestBed.createComponent(componentType);
    fixture.detectChanges();
    return fixture.nativeElement as HTMLElement;
  }

  afterEach(() => TestBed.resetTestingModule());

  for (const [name, type] of [
    ['administrative', ToolDeliveryDetailComponent],
    ['my delivery', MyToolDeliveryDetailComponent],
  ] as const) {
    it(`shows evidence thumbnails in ${name} detail`, async () => {
      const element = await render(type, [{ id_evidencia: 1, nombre_original: 'frente.jpg', archivo_url: '/uploads/frente.jpg', mime_type: 'image/jpeg', peso_bytes: 1024 }]);
      expect(element.querySelector('img')?.getAttribute('src')).toContain('/uploads/frente.jpg');
      expect(element.textContent).toContain('frente.jpg');
      expect(element.textContent).not.toContain('archivo_ruta');
    });

    it(`supports historical ${name} deliveries without evidence`, async () => {
      const element = await render(type, []);
      expect(element.textContent).toContain('Sin evidencia fotográfica registrada');
    });
  }
});
