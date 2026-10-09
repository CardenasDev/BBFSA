import { ComponentFixture, TestBed } from '@angular/core/testing';
import { ActivatedRoute } from '@angular/router';
import { of } from 'rxjs';
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
    );
    expect(fixture.componentInstance.generationData()).toEqual(generationData);

    fixture.componentInstance.download();
    await fixture.whenStable();
    expect(certificateDownload).toHaveBeenCalledWith(5, 'CERTIFICADO_LABORAL_ACTIVO', 7);
  });
});
