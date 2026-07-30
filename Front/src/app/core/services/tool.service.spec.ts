import { provideHttpClient } from '@angular/common/http';
import { provideHttpClientTesting, HttpTestingController } from '@angular/common/http/testing';
import { TestBed } from '@angular/core/testing';
import { environment } from '../../../environments/environment';
import { buildToolDeliveryFormData, ToolService } from './tool.service';

describe('ToolService tool deliveries', () => {
  it('builds multipart data with JSON tools and every evidence file', () => {
    const front = new File(['front'], 'frente.jpg', { type: 'image/jpeg' });
    const side = new File(['side'], 'lateral.png', { type: 'image/png' });
    const data = buildToolDeliveryFormData({
      id_empleado: 18,
      fecha_entrega: '2026-07-27',
      observaciones: 'Entrega inicial',
      herramientas: [{ id_herramienta: 13, cantidad: 2, observaciones: 'Dos pares' }],
      evidencias: [front, side],
    });
    expect(data.get('id_empleado')).toBe('18');
    expect(data.get('fecha_entrega')).toBe('2026-07-27');
    expect(data.get('observaciones')).toBe('Entrega inicial');
    expect(JSON.parse(String(data.get('herramientas')))).toEqual([{ id_herramienta: 13, cantidad: 2, observaciones: 'Dos pares' }]);
    expect(data.getAll('evidencias[]')).toEqual([front, side]);
  });

  it('posts FormData and leaves multipart headers to the browser', () => {
    TestBed.configureTestingModule({ providers: [provideHttpClient(), provideHttpClientTesting()] });
    const service = TestBed.inject(ToolService);
    const http = TestBed.inject(HttpTestingController);
    service.createToolDelivery({
      id_empleado: 18, fecha_entrega: '2026-07-27', observaciones: null,
      herramientas: [{ id_herramienta: 13, cantidad: 1, observaciones: null }],
      evidencias: [new File(['x'], 'foto.webp', { type: 'image/webp' })],
    }).subscribe();
    const request = http.expectOne(`${environment.apiUrl}/tool-deliveries`);
    expect(request.request.method).toBe('POST');
    expect(request.request.body).toBeInstanceOf(FormData);
    expect(request.request.headers.has('Content-Type')).toBe(false);
    request.flush({ data: { id_entrega: 1, estado: 'pendiente' } });
    http.verify();
  });
});
