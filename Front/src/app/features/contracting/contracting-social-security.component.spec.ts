import { ComponentFixture, TestBed } from '@angular/core/testing';
import { ActivatedRoute } from '@angular/router';
import { Observable, of, throwError } from 'rxjs';
import { describe, expect, it, vi } from 'vitest';
import { EmployeeSocialSecurity, SaveSocialSecurityRequest, SocialSecurityEntity, SocialSecurityType } from '../../core/models/api.models';
import { AuthService } from '../../core/services/auth.service';
import { CatalogService } from '../../core/services/catalog.service';
import { ContractingService } from '../../core/services/contracting.service';
import { ContractingSocialSecurityComponent } from './contracting-social-security.component';

const ids: Record<SocialSecurityType, number> = {
  EPS: 11,
  ARL: 22,
  PENSION: 33,
  CESANTIAS: 44,
  CAJA_COMPENSACION: 55,
};

function entity(type: SocialSecurityType): SocialSecurityEntity {
  return {
    id_entidad_seguridad_social: ids[type],
    tipo: type,
    nombre: `Entidad ${type}`,
    codigo: `COD-${type}`,
  };
}

function setup(
  catalogFactory: (type: SocialSecurityType) => Observable<SocialSecurityEntity[]> = (type) => of([entity(type)]),
): {
  fixture: ComponentFixture<ContractingSocialSecurityComponent>;
  component: ContractingSocialSecurityComponent;
  catalogs: { getSocialSecurityEntities: ReturnType<typeof vi.fn> };
  contracting: {
    getSocialSecurity: ReturnType<typeof vi.fn>;
    saveSocialSecurity: ReturnType<typeof vi.fn>;
  };
} {
  const current: EmployeeSocialSecurity = {
    id_empleado: 7,
    id_eps: 11,
    id_arl: 22,
    id_fondo_pension: 33,
    id_fondo_cesantias: 44,
    id_caja_compensacion: 55,
    observaciones: 'Conservar',
  };
  const catalogs = { getSocialSecurityEntities: vi.fn(catalogFactory) };
  const contracting = {
    getSocialSecurity: vi.fn(() => of(current)),
    saveSocialSecurity: vi.fn((_employeeId: number, payload: SaveSocialSecurityRequest) => of({ ...current, ...payload })),
  };

  TestBed.configureTestingModule({
    imports: [ContractingSocialSecurityComponent],
    providers: [
      { provide: ActivatedRoute, useValue: { snapshot: { paramMap: { get: () => '7' } } } },
      { provide: AuthService, useValue: { hasPermission: () => true } },
      { provide: CatalogService, useValue: catalogs },
      { provide: ContractingService, useValue: contracting },
    ],
  });

  const fixture = TestBed.createComponent(ContractingSocialSecurityComponent);
  fixture.detectChanges();
  return { fixture, component: fixture.componentInstance, catalogs, contracting };
}

describe('ContractingSocialSecurityComponent', () => {
  it('loads all five typed catalogs and keeps existing ids selected', async () => {
    const { fixture, component, catalogs } = setup();
    await fixture.whenStable();
    fixture.detectChanges();

    expect(catalogs.getSocialSecurityEntities.mock.calls.map((call) => call[0])).toEqual([
      'EPS', 'ARL', 'PENSION', 'CESANTIAS', 'CAJA_COMPENSACION',
    ]);
    expect(component.form).toMatchObject({
      id_eps: 11,
      id_arl: 22,
      id_fondo_pension: 33,
      id_fondo_cesantias: 44,
      id_caja_compensacion: 55,
    });

    const selects = Array.from(fixture.nativeElement.querySelectorAll('select')) as HTMLSelectElement[];
    expect(selects).toHaveLength(5);
    expect(selects.map((select) => select.options[select.selectedIndex]?.text)).toEqual([
      'Entidad EPS',
      'Entidad ARL',
      'Entidad PENSION',
      'Entidad CESANTIAS',
      'Entidad CAJA_COMPENSACION',
    ]);
  });

  it('sends internal ids and does not replace them with names or codes', () => {
    const { component, contracting } = setup();

    component.save();

    const payload = contracting.saveSocialSecurity.mock.calls[0][1] as SaveSocialSecurityRequest & Record<string, unknown>;
    expect(payload).toMatchObject({
      id_eps: 11,
      id_arl: 22,
      id_fondo_pension: 33,
      id_fondo_cesantias: 44,
      id_caja_compensacion: 55,
    });
    expect(payload['eps']).toBeUndefined();
    expect(payload['codigo_eps']).toBeUndefined();
  });

  it('leaves only a failed catalog empty without clearing the form or other catalogs', () => {
    const { component } = setup((type) =>
      type === 'ARL' ? throwError(() => new Error('falló ARL')) : of([entity(type)]),
    );

    expect(component.arlEntities()).toEqual([]);
    expect(component.epsEntities()).toEqual([entity('EPS')]);
    expect(component.pensionEntities()).toEqual([entity('PENSION')]);
    expect(component.form.id_arl).toBe(22);
    expect(component.form.observaciones).toBe('Conservar');
    expect(component.catalogsError()).toContain('ARL');
  });
});
