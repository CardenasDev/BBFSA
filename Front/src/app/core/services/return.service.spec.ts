import { provideHttpClient } from '@angular/common/http';
import { HttpTestingController, provideHttpClientTesting } from '@angular/common/http/testing';
import { TestBed } from '@angular/core/testing';
import { environment } from '../../../environments/environment';
import { CreateReturnPayload } from '../models/api.models';
import { buildReturnFormData, groupAvailableReturns, resolveReturnEvidenceUrl, ReturnService } from './return.service';

describe('ReturnService', () => {
  let service: ReturnService;
  let http: HttpTestingController;

  beforeEach(() => {
    TestBed.configureTestingModule({ providers: [provideHttpClient(), provideHttpClientTesting()] });
    service = TestBed.inject(ReturnService);
    http = TestBed.inject(HttpTestingController);
  });

  afterEach(() => http.verify());

  it('sends available type and employee and groups flat rows by delivery', () => {
    let result: unknown;
    service.getAvailableReturns('DOTACION', 20).subscribe((value) => result = value);
    const request = http.expectOne((candidate) => candidate.url === `${environment.apiUrl}/returns/available`);
    expect(request.request.params.get('type')).toBe('DOTACION');
    expect(request.request.params.get('employee_id')).toBe('20');
    request.flush({ success: true, message: 'ok', data: [
      { tipo_devolucion: 'DOTACION', id_entrega: 1, id_detalle: 10, id_empleado: 20, fecha_entrega: '2026-07-01', elemento: 'Camisa', cantidad_entregada: 2, cantidad_devuelta: 0, cantidad_disponible: 2 },
      { tipo_devolucion: 'DOTACION', id_entrega: 1, id_detalle: 11, id_empleado: 20, fecha_entrega: '2026-07-01', elemento: 'Pantalón', cantidad_entregada: 1, cantidad_devuelta: 1, cantidad_disponible: 0 },
    ] });
    expect(result).toEqual([expect.objectContaining({ id_entrega: 1, items: [expect.objectContaining({ id_detalle: 10 })] })]);
  });

  it('omits empty and zero history filters', () => {
    service.getReturns({ type: '', employee_id: 0, status: 'REGISTRADA', date_from: '', date_to: undefined }).subscribe();
    const request = http.expectOne((candidate) => candidate.url === `${environment.apiUrl}/returns`);
    expect(request.request.params.keys()).toEqual(['status']);
    expect(request.request.params.get('status')).toBe('REGISTRADA');
    request.flush({ success: true, message: 'ok', data: [] });
  });

  it('posts FormData without manually setting Content-Type', () => {
    const photo = new File(['photo'], 'tool.jpg', { type: 'image/jpeg' });
    const payload: CreateReturnPayload = {
      type: 'HERRAMIENTA', employee_id: 20, delivery_id: 5, return_date: '2026-07-29',
      reason: 'Fin de uso', observations: null,
      details: [{ id_detalle: 7, cantidad: 1, estado_elemento: 'DANADO', observaciones: null }],
      evidence: [photo],
    };
    service.createReturn(payload).subscribe();
    const request = http.expectOne(`${environment.apiUrl}/returns`);
    expect(request.request.body instanceof FormData).toBe(true);
    expect(request.request.headers.has('Content-Type')).toBe(false);
    const body = request.request.body as FormData;
    expect(JSON.parse(String(body.get('details')))).toEqual(payload.details);
    expect(body.getAll('evidence[]')).toEqual([photo]);
    request.flush({ success: true, message: 'ok', data: { id_devolucion: 9, estado: 'REGISTRADA' } });
  });

  it('uses expected endpoints for detail, confirm and cancel', () => {
    service.getReturnById(9).subscribe();
    http.expectOne(`${environment.apiUrl}/returns/9`).flush({ success: true, message: 'ok', data: { return: {}, details: [], evidence: [] } });
    service.confirmReturn(9).subscribe();
    const confirm = http.expectOne(`${environment.apiUrl}/returns/9/confirm`);
    expect(confirm.request.method).toBe('POST');
    confirm.flush({ success: true, message: 'ok', data: { id_devolucion: 9, estado: 'CONFIRMADA' } });
    service.cancelReturn(9, 'Error').subscribe();
    const cancel = http.expectOne(`${environment.apiUrl}/returns/9/cancel`);
    expect(cancel.request.body).toEqual({ reason: 'Error' });
    cancel.flush({ success: true, message: 'ok', data: { id_devolucion: 9, estado: 'ANULADA' } });
  });
});

describe('return utilities', () => {
  it('groups deliveries and removes unavailable rows', () => {
    expect(groupAvailableReturns([])).toEqual([]);
  });

  it('builds all exact multipart fields', () => {
    const file = new File(['x'], 'x.pdf', { type: 'application/pdf' });
    const form = buildReturnFormData({
      type: 'DOTACION', employee_id: 1, delivery_id: 2, return_date: '2026-07-29', reason: 'Cambio',
      observations: 'Obs', details: [{ id_detalle: 3, cantidad: 1, estado_elemento: 'BUENO' }], evidence: [file],
    });
    expect(form.get('type')).toBe('DOTACION');
    expect(form.get('employee_id')).toBe('1');
    expect(form.get('delivery_id')).toBe('2');
    expect(form.get('evidence[]')).toBe(file);
  });

  it('only resolves safe evidence URLs', () => {
    expect(resolveReturnEvidenceUrl({ archivo_ruta: 'uploads/returns/a.jpg' })).toBe(`${environment.backendUrl}/uploads/returns/a.jpg`);
    expect(resolveReturnEvidenceUrl({ archivo_url: 'javascript:alert(1)' })).toBeNull();
  });
});
