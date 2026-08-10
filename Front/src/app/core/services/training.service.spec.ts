import { provideHttpClient } from '@angular/common/http';
import { HttpTestingController, provideHttpClientTesting } from '@angular/common/http/testing';
import { TestBed } from '@angular/core/testing';
import { environment } from '../../../environments/environment';
import { TrainingService } from './training.service';

describe('TrainingService', () => {
  function setup() {
    TestBed.configureTestingModule({
      providers: [TrainingService, provideHttpClient(), provideHttpClientTesting()],
    });
    return {
      service: TestBed.inject(TrainingService),
      http: TestBed.inject(HttpTestingController),
    };
  }
  it('uses numeric booleans when listing tasks', () => {
    const { service, http } = setup();
    service.tasks().subscribe((r) => expect(r).toEqual([]));
    const request = http.expectOne((r) => r.url === `${environment.apiUrl}/trainings/tasks`);
    expect(request.request.params.get('incluir_inactivas')).toBe('0');
    request.flush({ success: true, message: 'ok', data: [] });
  });
  it('sends the exact daily evaluation contract', () => {
    const { service, http } = setup();
    const payload = {
      id_capacitacion_participante: 3,
      id_capacitacion_labor: 2,
      fecha_evaluacion: '2026-08-03',
      valor_obtenido: 50,
      requiere_atencion: false,
    };
    service.evaluation(payload).subscribe();
    const request = http.expectOne(`${environment.apiUrl}/trainings/evaluations`);
    expect(request.request.method).toBe('POST');
    expect(request.request.body).toEqual(payload);
    request.flush({ success: true, message: 'ok', data: {} });
  });
  it('uploads the XLSX as archivo', () => {
    const { service, http } = setup();
    service.import(9, new File(['xlsx'], 'week.xlsx')).subscribe();
    const request = http.expectOne(`${environment.apiUrl}/trainings/sessions/9/import`);
    expect(request.request.body.get('archivo').name).toBe('week.xlsx');
    request.flush({ success: true, message: 'ok', data: { errores: [], aplicados: 1 } });
  });
  it('confirms a commitment status using the update contract', () => {
    const { service, http } = setup();
    service.updateCommitment(7, { estado: 'INCUMPLIDO' }).subscribe();
    const request = http.expectOne(`${environment.apiUrl}/trainings/commitments/7`);
    expect(request.request.method).toBe('POST');
    expect(request.request.body.get('_method')).toBe('PATCH');
    expect(request.request.body.get('estado')).toBe('INCUMPLIDO');
    request.flush({ success: true, message: 'ok', data: { id_capacitacion_compromiso: 7 } });
  });
  it('loads one commitment for the printable letter', () => {
    const { service, http } = setup();
    service.commitment(7).subscribe((row) => expect(row.id_capacitacion_compromiso).toBe(7));
    const request = http.expectOne(`${environment.apiUrl}/trainings/commitments/7`);
    expect(request.request.method).toBe('GET');
    request.flush({
      success: true,
      message: 'ok',
      data: { id_capacitacion_compromiso: 7, estado: 'BORRADOR', motivo: 'Seguimiento' },
    });
  });
});
