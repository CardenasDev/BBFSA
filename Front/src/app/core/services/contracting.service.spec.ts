import { provideHttpClient } from '@angular/common/http';
import { HttpTestingController, provideHttpClientTesting } from '@angular/common/http/testing';
import { TestBed } from '@angular/core/testing';
import { describe, expect, it } from 'vitest';
import { environment } from '../../../environments/environment';
import { ContractingService } from './contracting.service';

describe('ContractingService signContract', () => {
  function setup(): { service: ContractingService; http: HttpTestingController } {
    TestBed.configureTestingModule({
      providers: [ContractingService, provideHttpClient(), provideHttpClientTesting()],
    });

    return {
      service: TestBed.inject(ContractingService),
      http: TestBed.inject(HttpTestingController),
    };
  }

  it('sends a physical file as FormData without an external URL or manual content type', () => {
    const { service, http } = setup();
    const file = new File(['signed'], 'signed-contract.pdf', { type: 'application/pdf' });

    service
      .signContract(7, {
        fecha_firma: '2026-07-24',
        origen: 'ARCHIVO',
        archivo: file,
        url: 'https://must-not-be-sent.example',
        nombre_archivo: 'Contrato firmado',
        observaciones: 'Firma presencial',
      })
      .subscribe();

    const request = http.expectOne(`${environment.apiUrl}/contracting/contracts/7/sign`);
    const body = request.request.body as FormData;
    expect(request.request.method).toBe('POST');
    expect(request.request.headers.has('Content-Type')).toBe(false);
    expect(body).toBeInstanceOf(FormData);
    expect(body.get('fecha_firma')).toBe('2026-07-24');
    expect(body.get('origen')).toBe('ARCHIVO');
    expect((body.get('archivo') as File).name).toBe('signed-contract.pdf');
    expect(body.has('url')).toBe(false);
    expect(body.get('observaciones')).toBe('Firma presencial');
    request.flush({ success: true, message: 'ok', data: {} });
    http.verify();
  });

  it('sends an external URL as FormData without a file or manual content type', () => {
    const { service, http } = setup();
    const file = new File(['unused'], 'unused.pdf', { type: 'application/pdf' });

    service
      .signContract(8, {
        fecha_firma: '2026-07-25',
        origen: 'URL',
        archivo: file,
        url: ' https://example.com/signed-contract.pdf ',
        nombre_archivo: 'Contrato firmado',
        observaciones: 'Firma externa',
      })
      .subscribe();

    const request = http.expectOne(`${environment.apiUrl}/contracting/contracts/8/sign`);
    const body = request.request.body as FormData;
    expect(request.request.headers.has('Content-Type')).toBe(false);
    expect(body.get('origen')).toBe('URL');
    expect(body.get('url')).toBe('https://example.com/signed-contract.pdf');
    expect(body.has('archivo')).toBe(false);
    request.flush({ success: true, message: 'ok', data: {} });
    http.verify();
  });

  it('registers a physical employee document as multipart data', () => {
    const { service, http } = setup();
    const payload = new FormData();
    payload.append('id_tipo_documento_laboral', '3');
    payload.append('nombre_archivo', 'Certificado laboral');
    payload.append('archivo', new File(['document'], 'certificado.pdf', { type: 'application/pdf' }));

    service.registerDocument(11, payload).subscribe();

    const request = http.expectOne(`${environment.apiUrl}/contracting/employees/11/documents`);
    expect(request.request.method).toBe('POST');
    expect(request.request.body).toBe(payload);
    expect(request.request.headers.has('Content-Type')).toBe(false);
    request.flush({ success: true, message: 'ok', data: {} });
    http.verify();
  });

  it('downloads a private employee document as a blob', () => {
    const { service, http } = setup();

    service.downloadDocument(11, 27).subscribe((file) => expect(file).toBeInstanceOf(Blob));

    const request = http.expectOne(`${environment.apiUrl}/contracting/employees/11/documents/27/file`);
    expect(request.request.method).toBe('GET');
    expect(request.request.responseType).toBe('blob');
    request.flush(new Blob(['document'], { type: 'application/pdf' }));
    http.verify();
  });

  it('keeps GENERAL certificate calls on GET and sends salary declarations by POST', () => {
    const { service, http } = setup();
    const supplied = { fondo_solidaridad: 'No aplica', retencion_fuente: 'Declarado por RRHH' };

    service.getCertificateGenerationData(5, 'CERTIFICADO_LABORAL_ACTIVO', 7).subscribe();
    const generalData = http.expectOne(request => request.url.endsWith('/employees/5/certificates/CERTIFICADO_LABORAL_ACTIVO/generation-data'));
    expect(generalData.request.method).toBe('GET');
    expect(generalData.request.params.get('id_empleado_contrato')).toBe('7');
    generalData.flush({ success: true, message: 'ok', data: {} });

    service.getCertificateGenerationData(5, 'CERTIFICADO_LABORAL_ACTIVO', 7, 'SALARIO_AFILIACIONES', supplied).subscribe();
    const salaryData = http.expectOne(request => request.url.endsWith('/employees/5/certificates/CERTIFICADO_LABORAL_ACTIVO/generation-data'));
    expect(salaryData.request.method).toBe('POST');
    expect(salaryData.request.body).toEqual({
      id_empleado_contrato: 7,
      variante: 'SALARIO_AFILIACIONES',
      ...supplied,
    });
    salaryData.flush({ success: true, message: 'ok', data: {} });

    service.downloadCertificate(5, 'CERTIFICADO_LABORAL_ACTIVO', 7, 'SALARIO_AFILIACIONES', supplied).subscribe();
    const salaryDownload = http.expectOne(request => request.url.endsWith('/employees/5/certificates/CERTIFICADO_LABORAL_ACTIVO/download'));
    expect(salaryDownload.request.method).toBe('POST');
    expect(salaryDownload.request.body).toEqual({
      id_empleado_contrato: 7,
      variante: 'SALARIO_AFILIACIONES',
      ...supplied,
    });
    expect(salaryDownload.request.responseType).toBe('blob');
    salaryDownload.flush(new Blob(['%PDF-1.4']));
    http.verify();
  });
});
