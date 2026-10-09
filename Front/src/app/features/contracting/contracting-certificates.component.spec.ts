import { ComponentFixture, TestBed } from '@angular/core/testing';
import { ActivatedRoute } from '@angular/router';
import { of, Subject } from 'rxjs';
import { describe, expect, it, vi } from 'vitest';
import { AuthService } from '../../core/services/auth.service';
import { ContractingService } from '../../core/services/contracting.service';
import { ContractingCertificatesComponent } from './contracting-certificates.component';

const certificateFormats = [
  {
    id_documento_formato: 1,
    clave_formato: 'CERTIFICADO_LABORAL_ACTIVO',
    codigo_formato: 'BBTH-F-002',
    nombre: 'CERTIFICADO LABORAL A COLABORADOR',
    variante: 'GENERAL',
    version_formato: '1.0',
    titulo: 'Certificado laboral activo',
    proceso: 'Emisión de certificado laboral',
  },
];

const contracts = [
  {
    id_empleado_contrato: 7,
    id_empleado: 5,
    estado_contrato: 'ACTIVO',
    fecha_inicio: '2026-01-01',
    fecha_fin: null,
    cargo: 'Analista de datos',
  },
];

const generationData = {
  empleado: {
    nombre_completo: 'Ana Pérez',
    fecha_ingreso: '2026-01-01',
  },
  contrato: { id_empleado_contrato: 7 },
  formato: { codigo_formato: 'F-002' },
};

describe('ContractingCertificatesComponent', () => {
  it('loads the F-002 certificate list and generates data from the active contract', async () => {
    const certificates = vi.fn(() => of(certificateFormats));
    const certificateGenerationData = vi.fn(() => of(generationData));
    const contractsService = vi.fn(() => of(contracts));
    const certificateDownload = vi.fn(() => of(
      new Blob(['%PDF-1.4\n%%EOF'], { type: 'application/pdf' }),
    ));

    TestBed.configureTestingModule({
      imports: [ContractingCertificatesComponent],
      providers: [
        { provide: ActivatedRoute, useValue: { snapshot: { paramMap: { get: () => '5' } } } },
        { provide: AuthService, useValue: { hasPermission: () => true } },
        {
          provide: ContractingService,
          useValue: {
            getCertificates: certificates,
            getCertificateGenerationData: certificateGenerationData,
            downloadCertificate: certificateDownload,
            getContracts: contractsService,
          },
        },
      ],
    });

    const fixture: ComponentFixture<ContractingCertificatesComponent> = TestBed.createComponent(
      ContractingCertificatesComponent,
    );
    fixture.detectChanges();
    await fixture.whenStable();
    fixture.detectChanges();

    expect(certificates).toHaveBeenCalledWith(5);
    expect(contractsService).toHaveBeenCalledWith(5);
    expect(fixture.componentInstance.certificates()).toEqual(certificateFormats);
    expect(fixture.componentInstance.isFirstCertificate(certificateFormats[0])).toBe(true);
    expect(fixture.nativeElement.textContent).toContain('BBTH - F-002');
    expect(fixture.nativeElement.textContent).toContain('CERTIFICADO LABORAL A COLABORADOR');

    fixture.componentInstance.generate(certificateFormats[0]);
    await fixture.whenStable();

    expect(certificateGenerationData).toHaveBeenCalledWith(
      5,
      'CERTIFICADO_LABORAL_ACTIVO',
      7,
      'GENERAL',
      undefined,
    );
    expect(fixture.componentInstance.generationData()).toEqual(generationData);

    fixture.componentInstance.download();
    await fixture.whenStable();
    expect(certificateDownload).toHaveBeenCalledWith(5, 'CERTIFICADO_LABORAL_ACTIVO', 7, 'GENERAL', undefined);

    const second = { ...certificateFormats[0], id_documento_formato: 2, variante: 'SALARIO_AFILIACIONES', nombre: 'Salario y afiliaciones' };
    fixture.componentInstance.generate(second);
    expect(fixture.componentInstance.generationData()).toBeNull();
    expect(fixture.componentInstance.error()).toContain('Complete fondo');
    fixture.componentInstance.updateSupplied('solidarity', 'No aplica');
    fixture.componentInstance.updateSupplied('withholding', 'Valor declarado');
    fixture.componentInstance.generate(second);
    await fixture.whenStable();
    expect(certificateGenerationData).toHaveBeenLastCalledWith(5, 'CERTIFICADO_LABORAL_ACTIVO', 7, 'SALARIO_AFILIACIONES', { fondo_solidaridad: 'No aplica', retencion_fuente: 'Valor declarado' });
    fixture.componentInstance.contracts.set([{ ...contracts[0], id_empleado_contrato: 99 }]);
    fixture.componentInstance.download();
    await fixture.whenStable();
    expect(certificateDownload).toHaveBeenLastCalledWith(5, 'CERTIFICADO_LABORAL_ACTIVO', 7, 'SALARIO_AFILIACIONES', { fondo_solidaridad: 'No aplica', retencion_fuente: 'Valor declarado' });
    fixture.componentInstance.updateSupplied('withholding', 'Cambió');
    expect(fixture.componentInstance.generationData()).toBeNull();
    const calls = certificateDownload.mock.calls.length;
    fixture.componentInstance.download();
    expect(certificateDownload.mock.calls.length).toBe(calls);
    expect(fixture.componentInstance.isFirstCertificate({ ...second, variante: 'OTRA' })).toBe(false);
  });

  it('ignores late responses and errors from an obsolete variant request', async () => {
    const requests: Subject<Record<string, unknown>>[] = [];
    const certificateGenerationData = vi.fn(() => {
      const request = new Subject<Record<string, unknown>>();
      requests.push(request);
      return request;
    });
    TestBed.configureTestingModule({
      imports: [ContractingCertificatesComponent],
      providers: [
        { provide: ActivatedRoute, useValue: { snapshot: { paramMap: { get: () => '5' } } } },
        { provide: AuthService, useValue: { hasPermission: () => true } },
        {
          provide: ContractingService,
          useValue: {
            getCertificates: () => of(certificateFormats),
            getCertificateGenerationData: certificateGenerationData,
            downloadCertificate: () => of(new Blob()),
            getContracts: () => of(contracts),
          },
        },
      ],
    });

    const fixture = TestBed.createComponent(ContractingCertificatesComponent);
    fixture.detectChanges();
    await fixture.whenStable();
    const component = fixture.componentInstance;
    const salary = { ...certificateFormats[0], variante: 'SALARIO_AFILIACIONES' };
    component.generate(certificateFormats[0]);
    component.updateSupplied('solidarity', 'No aplica');
    component.updateSupplied('withholding', 'No aplica');
    component.generate(salary);

    requests[0].next({ stale: true });
    requests[0].complete();
    expect(component.generationData()).toBeNull();
    expect(component.generating()).toBe(true);

    const currentData = { salario: { cifra: '$1.000,00' } };
    requests[1].next(currentData);
    requests[1].complete();
    expect(component.generationData()).toEqual(currentData);
    expect(component.generating()).toBe(false);

    component.generate(certificateFormats[0]);
    component.generate(salary);
    requests[2].error(new Error('respuesta anterior'));
    expect(component.error()).toBe('');
    expect(component.generating()).toBe(true);
    requests[3].next(currentData);
    requests[3].complete();
    expect(component.generationData()).toEqual(currentData);
    expect(component.error()).toBe('');
    expect(component.generating()).toBe(false);
  });
});
