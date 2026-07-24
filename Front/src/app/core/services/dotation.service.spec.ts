import { provideHttpClient } from '@angular/common/http';
import { HttpTestingController, provideHttpClientTesting } from '@angular/common/http/testing';
import { TestBed } from '@angular/core/testing';
import { describe, expect, it } from 'vitest';
import { environment } from '../../../environments/environment';
import { CreateDotationDeliveryRequest } from '../models/api.models';
import { DotationService } from './dotation.service';

describe('DotationService combinations and deliveries', () => {
  function setup(): { service: DotationService; http: HttpTestingController } {
    TestBed.configureTestingModule({
      providers: [DotationService, provideHttpClient(), provideHttpClientTesting()],
    });
    return {
      service: TestBed.inject(DotationService),
      http: TestBed.inject(HttpTestingController),
    };
  }

  it('loads combinations and their detail from the backend', () => {
    const { service, http } = setup();
    service.getCombinations().subscribe((items) => expect(items[0].codigo).toBe('DOT-01'));
    const combinations = http.expectOne(`${environment.apiUrl}/dotations/combinations`);
    expect(combinations.request.method).toBe('GET');
    combinations.flush({ success: true, message: 'ok', data: [{ id_dotacion_combinacion: 1, codigo: 'DOT-01', nombre: 'Combinacion 1', activo: true }] });

    service.getCombinationDetail(1).subscribe((items) => expect(items[0].tipo_dotacion).toBe('Chaqueta'));
    const detail = http.expectOne(`${environment.apiUrl}/dotations/combinations/1`);
    expect(detail.request.method).toBe('GET');
    detail.flush({ success: true, message: 'ok', data: [{
      id_dotacion_combinacion_detalle: 1,
      id_dotacion_combinacion: 1,
      codigo_combinacion: 'DOT-01',
      combinacion: 'Combinacion 1',
      id_tipo_dotacion: 7,
      tipo_dotacion: 'Chaqueta',
      requiere_talla: true,
      cantidad: 1,
      orden: 1,
      activo: true,
    }] });
    http.verify();
  });

  it('sends the ordinary delivery type, combination and generated details unchanged', () => {
    const { service, http } = setup();
    const payload: CreateDotationDeliveryRequest = {
      id_empleado: 5,
      fecha_entrega: '2026-07-24',
      tipo_entrega: 'ORDINARIA',
      id_dotacion_combinacion: 1,
      observaciones: null,
      detalles: [{ id_tipo_dotacion: 7, id_talla_dotacion: 30, cantidad: 1 }],
    };
    service.createDelivery(payload).subscribe();
    const request = http.expectOne(`${environment.apiUrl}/dotations/deliveries`);
    expect(request.request.method).toBe('POST');
    expect(request.request.body).toEqual(payload);
    request.flush({ success: true, message: 'ok', data: { id_dotacion_entrega: 20 } });
    http.verify();
  });

  it('sends extraordinary deliveries with a null combination', () => {
    const { service, http } = setup();
    const payload: CreateDotationDeliveryRequest = {
      id_empleado: 5,
      fecha_entrega: '2026-07-24',
      tipo_entrega: 'EXTRAORDINARIA',
      id_dotacion_combinacion: null,
      detalles: [{ id_tipo_dotacion: 3, id_talla_dotacion: 25, cantidad: 1 }],
    };
    service.createDelivery(payload).subscribe();
    const request = http.expectOne(`${environment.apiUrl}/dotations/deliveries`);
    expect(request.request.body.tipo_entrega).toBe('EXTRAORDINARIA');
    expect(request.request.body.id_dotacion_combinacion).toBeNull();
    request.flush({ success: true, message: 'ok', data: { id_dotacion_entrega: 21 } });
    http.verify();
  });
});
