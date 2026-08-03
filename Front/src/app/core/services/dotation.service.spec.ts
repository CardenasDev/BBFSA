import { provideHttpClient } from '@angular/common/http';
import { HttpTestingController, provideHttpClientTesting } from '@angular/common/http/testing';
import { TestBed } from '@angular/core/testing';
import { describe, expect, it } from 'vitest';
import { environment } from '../../../environments/environment';
import { CreateDotationDeliveryRequest } from '../models/api.models';
import { DotationService, resolveDotationEvidenceUrl } from './dotation.service';

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

  it('resolves physical evidence against backendUrl and preserves external URLs', () => {
    expect(resolveDotationEvidenceUrl('/uploads/dotations/evidence.jpg')).toBe(
      `${environment.backendUrl}/uploads/dotations/evidence.jpg`,
    );
    expect(resolveDotationEvidenceUrl('https://cdn.example.com/evidence.jpg')).toBe(
      'https://cdn.example.com/evidence.jpg',
    );
    expect(resolveDotationEvidenceUrl(null)).toBeNull();
  });

  it('loads combinations and their detail from the backend', () => {
    const { service, http } = setup();
    service.getCombinations().subscribe((items) => expect(items[0].codigo).toBe('DOT-01'));
    const combinations = http.expectOne(`${environment.apiUrl}/dotations/combinations`);
    expect(combinations.request.method).toBe('GET');
    combinations.flush({
      success: true,
      message: 'ok',
      data: [
        { id_dotacion_combinacion: 1, codigo: 'DOT-01', nombre: 'Combinacion 1', activo: true },
      ],
    });

    service
      .getCombinationDetail(1)
      .subscribe((items) => expect(items[0].tipo_dotacion).toBe('Chaqueta'));
    const detail = http.expectOne(`${environment.apiUrl}/dotations/combinations/1`);
    expect(detail.request.method).toBe('GET');
    detail.flush({
      success: true,
      message: 'ok',
      data: [
        {
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
        },
      ],
    });
    http.verify();
  });

  it('exports quotation as a blob response with valid filters only', () => {
    const { service, http } = setup();

    service
      .exportQuotation({
        id_area: 5,
        id_cargo: 9,
        id_empleado: 12,
      })
      .subscribe((response) => expect(response.body).toBeInstanceOf(Blob));

    const request = http.expectOne(
      (candidate) => candidate.url === `${environment.apiUrl}/dotations/quotation/export`,
    );
    expect(request.request.method).toBe('GET');
    expect(request.request.responseType).toBe('blob');
    expect(request.request.params.get('id_area')).toBe('5');
    expect(request.request.params.get('id_cargo')).toBe('9');
    expect(request.request.params.get('id_empleado')).toBe('12');
    request.flush(new Blob(['xlsx']));
    http.verify();
  });

  it('omits empty and zero quotation filters', () => {
    const { service, http } = setup();

    service
      .exportQuotation({
        id_area: null,
        id_cargo: 0,
        id_empleado: undefined,
      })
      .subscribe();

    const request = http.expectOne(`${environment.apiUrl}/dotations/quotation/export`);
    expect(request.request.params.keys()).toEqual([]);
    request.flush(new Blob(['xlsx']));
    http.verify();
  });

  it('loads articles using family and gender filters', () => {
    const { service, http } = setup();
    service
      .getArticles(2, 'MUJER')
      .subscribe((items) => expect(items[0].articulo).toBe('Pantalón Mujer Drill'));
    const request = http.expectOne(
      (candidate) => candidate.url === `${environment.apiUrl}/dotations/articles`,
    );
    expect(request.request.params.get('id_tipo_dotacion')).toBe('2');
    expect(request.request.params.get('genero')).toBe('MUJER');
    expect(request.request.params.get('incluir_inactivos')).toBe('0');
    request.flush({
      success: true,
      message: 'ok',
      data: [{ id_dotacion_articulo: 12, articulo: 'Pantalón Mujer Drill' }],
    });
    http.verify();
  });

  it('exports pending purchase quotation through its independent endpoint', () => {
    const { service, http } = setup();
    service.exportPurchaseQuotation({ id_area: 5, id_cargo: 9 }).subscribe();
    const request = http.expectOne(
      (candidate) => candidate.url === `${environment.apiUrl}/dotations/purchase-quotation/export`,
    );
    expect(request.request.method).toBe('GET');
    expect(request.request.params.get('id_area')).toBe('5');
    expect(request.request.params.get('id_cargo')).toBe('9');
    request.flush(new Blob(['xlsx']));
    http.verify();
  });

  it('sends an ordinary delivery and physical evidence as FormData', () => {
    const { service, http } = setup();
    const file = new File(['evidence'], 'entrega.jpg', { type: 'image/jpeg' });
    const payload: CreateDotationDeliveryRequest = {
      id_empleado: 5,
      fecha_entrega: '2026-07-24',
      tipo_entrega: 'ORDINARIA',
      estado_inicial: 'REGISTRADA',
      id_dotacion_combinacion: 1,
      observaciones: null,
      origen_evidencia: 'ARCHIVO',
      evidencia_archivo: file,
      evidencia_nombre_archivo: 'Evidencia entrega',
      detalles: [
        { id_dotacion_articulo: 101, id_tipo_dotacion: 7, id_talla_dotacion: 30, cantidad: 1 },
      ],
    };
    service.createDelivery(payload).subscribe();
    const request = http.expectOne(`${environment.apiUrl}/dotations/deliveries`);
    const body = request.request.body as FormData;
    expect(request.request.method).toBe('POST');
    expect(request.request.headers.has('Content-Type')).toBe(false);
    expect(body).toBeInstanceOf(FormData);
    expect(body.get('tipo_entrega')).toBe('ORDINARIA');
    expect(body.get('estado_inicial')).toBe('REGISTRADA');
    expect(body.get('id_dotacion_combinacion')).toBe('1');
    expect(body.get('origen_evidencia')).toBe('ARCHIVO');
    expect(body.get('evidencia_archivo')).toBe(file);
    expect(body.has('evidencia_url')).toBe(false);
    expect(body.get('detalles[0][id_tipo_dotacion]')).toBe('7');
    expect(body.get('detalles[0][id_dotacion_articulo]')).toBe('101');
    expect(body.get('detalles[0][id_talla_dotacion]')).toBe('30');
    expect(body.get('detalles[0][cantidad]')).toBe('1');
    request.flush({ success: true, message: 'ok', data: { id_dotacion_entrega: 20 } });
    http.verify();
  });

  it('uses a strict POR_COMPRAR whitelist and omits every evidence key even with residual values', () => {
    const { service, http } = setup();
    const payload: CreateDotationDeliveryRequest = {
      id_empleado: 5,
      fecha_entrega: '2026-08-10',
      tipo_entrega: 'EXTRAORDINARIA',
      estado_inicial: 'POR_COMPRAR',
      id_dotacion_combinacion: null,
      origen_evidencia: 'ARCHIVO',
      evidencia_archivo: new File(['residual'], 'residual.jpg', { type: 'image/jpeg' }),
      evidencia_url: 'https://example.com/residual.jpg',
      evidencia_nombre_archivo: 'Residual',
      detalles: [{ id_dotacion_articulo: 103, id_tipo_dotacion: 3, cantidad: 1 }],
    };
    service.createDelivery(payload).subscribe();
    const request = http.expectOne(`${environment.apiUrl}/dotations/deliveries`);
    const body = request.request.body as FormData;
    [
      'origen_evidencia',
      'evidencia',
      'evidencia_archivo',
      'evidencia_url',
      'evidencia_nombre_archivo',
      'evidencia_nombre_original',
      'evidencia_ruta',
      'evidencia_mime_type',
      'evidencia_peso_bytes',
    ].forEach((key) => expect(body.has(key), key).toBe(false));
    request.flush({
      success: true,
      message: 'ok',
      data: { id_dotacion_entrega: 31, estado: 'POR_COMPRAR' },
    });
    http.verify();
  });

  it('prepares the same purchase request with multipart evidence', () => {
    const { service, http } = setup();
    const file = new File(['evidence'], 'lista.jpg', { type: 'image/jpeg' });
    service
      .prepareDelivery(31, {
        fecha_entrega: '2026-08-12',
        origen_evidencia: 'ARCHIVO',
        evidencia_archivo: file,
      })
      .subscribe();
    const request = http.expectOne(`${environment.apiUrl}/dotations/deliveries/31/prepare`);
    const body = request.request.body as FormData;
    expect(request.request.method).toBe('POST');
    expect(body.get('fecha_entrega')).toBe('2026-08-12');
    expect(body.get('evidencia_archivo')).toBe(file);
    request.flush({
      success: true,
      message: 'ok',
      data: { id_dotacion_entrega: 31, estado: 'REGISTRADA' },
    });
    http.verify();
  });

  it('sends an extraordinary delivery and external URL as FormData without a combination', () => {
    const { service, http } = setup();
    const payload: CreateDotationDeliveryRequest = {
      id_empleado: 5,
      fecha_entrega: '2026-07-24',
      tipo_entrega: 'EXTRAORDINARIA',
      estado_inicial: 'REGISTRADA',
      id_dotacion_combinacion: null,
      origen_evidencia: 'URL',
      evidencia_url: 'https://example.com/evidencia.jpg',
      detalles: [
        { id_dotacion_articulo: 103, id_tipo_dotacion: 3, id_talla_dotacion: 25, cantidad: 1 },
      ],
    };
    service.createDelivery(payload).subscribe();
    const request = http.expectOne(`${environment.apiUrl}/dotations/deliveries`);
    const body = request.request.body as FormData;
    expect(request.request.headers.has('Content-Type')).toBe(false);
    expect(body.get('tipo_entrega')).toBe('EXTRAORDINARIA');
    expect(body.has('id_dotacion_combinacion')).toBe(false);
    expect(body.get('origen_evidencia')).toBe('URL');
    expect(body.get('evidencia_url')).toBe('https://example.com/evidencia.jpg');
    expect(body.has('evidencia_archivo')).toBe(false);
    request.flush({ success: true, message: 'ok', data: { id_dotacion_entrega: 21 } });
    http.verify();
  });
});
