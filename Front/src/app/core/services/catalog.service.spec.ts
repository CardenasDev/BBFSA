import { provideHttpClient } from '@angular/common/http';
import { HttpTestingController, provideHttpClientTesting } from '@angular/common/http/testing';
import { TestBed } from '@angular/core/testing';
import { describe, expect, it } from 'vitest';
import { environment } from '../../../environments/environment';
import { CatalogService } from './catalog.service';

describe('CatalogService geographic catalogs', () => {
  function setup(): { service: CatalogService; http: HttpTestingController } {
    TestBed.configureTestingModule({
      providers: [CatalogService, provideHttpClient(), provideHttpClientTesting()],
    });

    return {
      service: TestBed.inject(CatalogService),
      http: TestBed.inject(HttpTestingController),
    };
  }

  it('loads departments from the shared catalog endpoint', () => {
    const { service, http } = setup();
    let departmentId: number | undefined;

    service.getDepartments().subscribe((departments) => departmentId = departments[0]?.id_departamento);

    const request = http.expectOne(`${environment.apiUrl}/catalogs/departments`);
    expect(request.request.method).toBe('GET');
    request.flush({
      success: true,
      message: 'ok',
      data: [{ id_departamento: 9, codigo_dane: '25', nombre: 'Cundinamarca' }],
    });

    expect(departmentId).toBe(9);
    http.verify();
  });

  it('uses the internal department id in the municipalities URL', () => {
    const { service, http } = setup();
    let municipalityId: number | undefined;

    service.getMunicipalitiesByDepartment(9).subscribe((municipalities) => municipalityId = municipalities[0]?.id_municipio);

    const request = http.expectOne(`${environment.apiUrl}/catalogs/departments/9/municipalities`);
    expect(request.request.url).not.toContain('/25/municipalities');
    request.flush({
      success: true,
      message: 'ok',
      data: [{ id_municipio: 41, id_departamento: 9, codigo_dane: '25126', nombre: 'Cajica' }],
    });

    expect(municipalityId).toBe(41);
    http.verify();
  });
});

describe('CatalogService social security catalogs', () => {
  it.each(['EPS', 'ARL', 'PENSION', 'CESANTIAS', 'CAJA_COMPENSACION'] as const)(
    'requests and returns only entities of type %s',
    (type) => {
      TestBed.configureTestingModule({
        providers: [CatalogService, provideHttpClient(), provideHttpClientTesting()],
      });
      const service = TestBed.inject(CatalogService);
      const http = TestBed.inject(HttpTestingController);
      let result: string[] = [];

      service.getSocialSecurityEntities(type).subscribe((entities) => result = entities.map((entity) => entity.tipo));

      const request = http.expectOne((candidate) =>
        candidate.url === `${environment.apiUrl}/catalogs/social-security-entities`
        && candidate.params.get('type') === type,
      );
      expect(request.request.method).toBe('GET');
      request.flush({
        success: true,
        message: 'ok',
        data: [
          { id_entidad_seguridad_social: 1, tipo: type, nombre: `Entidad ${type}` },
          { id_entidad_seguridad_social: 2, tipo: 'OTRO', nombre: 'Entidad incorrecta' },
        ],
      });

      expect(result).toEqual([type]);
      http.verify();
    },
  );
});

describe('CatalogService medical exam types', () => {
  it('loads medical exam types with their internal ids', () => {
    TestBed.configureTestingModule({
      providers: [CatalogService, provideHttpClient(), provideHttpClientTesting()],
    });
    const service = TestBed.inject(CatalogService);
    const http = TestBed.inject(HttpTestingController);
    let result: { id_tipo_examen_medico: number; nombre: string }[] = [];

    service.getMedicalExamTypes().subscribe((examTypes) => result = examTypes);

    const request = http.expectOne(`${environment.apiUrl}/catalogs/medical-exam-types`);
    expect(request.request.method).toBe('GET');
    request.flush({
      success: true,
      message: 'ok',
      data: [{ id_tipo_examen_medico: 1, nombre: 'Ingreso' }],
    });

    expect(result).toEqual([{ id_tipo_examen_medico: 1, nombre: 'Ingreso' }]);
    http.verify();
  });
});
