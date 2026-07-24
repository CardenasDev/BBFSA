import { ComponentFixture, TestBed } from '@angular/core/testing';
import { ActivatedRoute } from '@angular/router';
import { of, throwError } from 'rxjs';
import { describe, expect, it, vi } from 'vitest';
import { CreateMedicalExamRequest, MedicalExamType } from '../../core/models/api.models';
import { AuthService } from '../../core/services/auth.service';
import { CatalogService } from '../../core/services/catalog.service';
import { ContractingService } from '../../core/services/contracting.service';
import { ContractingMedicalExamsComponent } from './contracting-medical-exams.component';

const examTypes: MedicalExamType[] = [
  { id_tipo_examen_medico: 1, nombre: 'Ingreso' },
  { id_tipo_examen_medico: 2, nombre: 'Periódico' },
  { id_tipo_examen_medico: 3, nombre: 'Retiro' },
];

function setup(catalogFails = false): {
  fixture: ComponentFixture<ContractingMedicalExamsComponent>;
  component: ContractingMedicalExamsComponent;
  catalogs: { getMedicalExamTypes: ReturnType<typeof vi.fn> };
  contracting: {
    getMedicalExams: ReturnType<typeof vi.fn>;
    createMedicalExam: ReturnType<typeof vi.fn>;
  };
} {
  const catalogs = {
    getMedicalExamTypes: vi.fn(() => catalogFails
      ? throwError(() => new Error('falló catálogo'))
      : of(examTypes)),
  };
  const contracting = {
    getMedicalExams: vi.fn(() => of([])),
    createMedicalExam: vi.fn((_employeeId: number, payload: CreateMedicalExamRequest) => of({
      id_empleado: 7,
      ...payload,
    })),
  };

  TestBed.configureTestingModule({
    imports: [ContractingMedicalExamsComponent],
    providers: [
      { provide: ActivatedRoute, useValue: { snapshot: { paramMap: { get: () => '7' } } } },
      { provide: AuthService, useValue: { hasPermission: () => true } },
      { provide: CatalogService, useValue: catalogs },
      { provide: ContractingService, useValue: contracting },
    ],
  });

  const fixture = TestBed.createComponent(ContractingMedicalExamsComponent);
  fixture.detectChanges();
  return { fixture, component: fixture.componentInstance, catalogs, contracting };
}

describe('ContractingMedicalExamsComponent', () => {
  it('loads the catalog once and shows names backed by internal ids', async () => {
    const { fixture, component, catalogs } = setup();
    component.openCreate();
    fixture.detectChanges();
    await fixture.whenStable();
    fixture.detectChanges();

    expect(catalogs.getMedicalExamTypes).toHaveBeenCalledTimes(1);
    expect(component.medicalExamTypes()).toEqual(examTypes);
    const select = fixture.nativeElement.querySelector('select[name="id_tipo_examen_medico"]') as HTMLSelectElement;
    expect(Array.from(select.options).map((option) => option.text)).toEqual([
      'Seleccione tipo de examen',
      'Ingreso',
      'Periódico',
      'Retiro',
    ]);
    expect(fixture.nativeElement.textContent).not.toContain('ID tipo examen');

    select.selectedIndex = 2;
    select.dispatchEvent(new Event('change'));
    fixture.detectChanges();
    await fixture.whenStable();
    expect(component.form.id_tipo_examen_medico).toBe(2);
    expect(component.form.id_tipo_examen_medico).not.toBe('Periódico');

    component.closeCreate();
    component.openCreate();
    expect(catalogs.getMedicalExamTypes).toHaveBeenCalledTimes(1);
  });

  it('keeps id_tipo_examen_medico in the create payload', () => {
    const { component, contracting } = setup();
    component.openCreate();
    component.form = {
      id_tipo_examen_medico: 3,
      fecha_examen: '2026-07-24',
      entidad_realiza: 'IPS Ejemplo',
    };

    component.createExam();

    const payload = contracting.createMedicalExam.mock.calls[0][1] as CreateMedicalExamRequest & Record<string, unknown>;
    expect(payload.id_tipo_examen_medico).toBe(3);
    expect(payload['tipo_examen']).toBeUndefined();
    expect(payload['nombre_tipo_examen']).toBeUndefined();
  });

  it('does not clear form data or the exam list when the catalog fails', () => {
    const { component } = setup(true);
    component.form.entidad_realiza = 'Valor conservado';

    expect(component.medicalExamTypes()).toEqual([]);
    expect(component.form.entidad_realiza).toBe('Valor conservado');
    expect(component.exams()).toEqual([]);
    expect(component.medicalExamTypesError()).toContain('tipos de examen médico');
  });

  it('uses the catalog name in the table only when the API did not provide one', () => {
    const { component } = setup();

    expect(component.displayExamType({
      id_empleado: 7,
      id_tipo_examen_medico: 1,
      fecha_examen: '2026-07-24',
    })).toBe('Ingreso');
    expect(component.displayExamType({
      id_empleado: 7,
      id_tipo_examen_medico: 1,
      tipo_examen_medico: 'Nombre provisto por API',
      fecha_examen: '2026-07-24',
    })).toBe('Nombre provisto por API');
  });
});
