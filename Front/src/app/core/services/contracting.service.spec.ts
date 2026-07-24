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
});
