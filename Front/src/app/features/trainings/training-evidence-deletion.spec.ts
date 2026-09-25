import { TestBed } from '@angular/core/testing';
import { ActivatedRoute } from '@angular/router';
import { of, throwError } from 'rxjs';
import { vi } from 'vitest';
import { TrainingSessionDetailComponent } from './training-session-detail.component';
import { TrainingService } from '../../core/services/training.service';
import { EmployeeService } from '../../core/services/employee.service';
import { AuthService } from '../../core/services/auth.service';
import { TrainingEvidence } from '../../core/models/training.models';

describe('training evidence deletion', () => {
  const evidence = { id_capacitacion_evidencia: 9 } as TrainingEvidence;
  let component: TrainingSessionDetailComponent;
  let api: { deleteEvidence: ReturnType<typeof vi.fn> };
  beforeEach(() => {
    api = { deleteEvidence: vi.fn().mockReturnValue(of({})) };
    vi.spyOn(TrainingSessionDetailComponent.prototype, 'load').mockImplementation(() => {});
    TestBed.configureTestingModule({ providers: [
      { provide: TrainingService, useValue: api },
      { provide: EmployeeService, useValue: {} },
      { provide: AuthService, useValue: { hasPermission: () => true } },
      { provide: ActivatedRoute, useValue: { snapshot: { paramMap: { get: () => '4' } } } },
    ] });
    component = TestBed.runInInjectionContext(() => new TrainingSessionDetailComponent());
    component.evidenceList.set([evidence, { id_capacitacion_evidencia: 10 } as TrainingEvidence]);
    vi.mocked(component.load).mockClear();
  });
  afterEach(() => { vi.restoreAllMocks(); TestBed.resetTestingModule(); });
  it('cancels without issuing DELETE', () => {
    vi.spyOn(window, 'confirm').mockReturnValue(false);
    component.deleteEvidence(evidence);
    expect(api.deleteEvidence).not.toHaveBeenCalled();
    expect(component.evidenceList()).toHaveLength(2);
  });
  it('updates only the evidence list after successful DELETE', () => {
    vi.spyOn(window, 'confirm').mockReturnValue(true);
    component.deleteEvidence(evidence);
    expect(api.deleteEvidence).toHaveBeenCalledWith(4, 9);
    expect(component.evidenceList().map(x => x.id_capacitacion_evidencia)).toEqual([10]);
    expect(component.message()).toBe('Evidencia eliminada correctamente.');
    expect(component.load).not.toHaveBeenCalled();
  });
  it('keeps the row and shows the error on failure', () => {
    vi.spyOn(window, 'confirm').mockReturnValue(true);
    api.deleteEvidence.mockReturnValue(throwError(() => ({ error: { message: 'No fue posible eliminar.' } })));
    component.deleteEvidence(evidence);
    expect(component.evidenceList()).toHaveLength(2);
    expect(component.error()).toBe('No fue posible eliminar.');
    expect(component.message()).toBe('');
  });
});
