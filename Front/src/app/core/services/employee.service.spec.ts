import { provideHttpClient } from '@angular/common/http';
import { HttpTestingController, provideHttpClientTesting } from '@angular/common/http/testing';
import { TestBed } from '@angular/core/testing';
import { environment } from '../../../environments/environment';
import { EmployeeService } from './employee.service';

describe('EmployeeService', () => {
  let service: EmployeeService;
  let http: HttpTestingController;

  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [
        provideHttpClient(),
        provideHttpClientTesting(),
      ],
    });
    service = TestBed.inject(EmployeeService);
    http = TestBed.inject(HttpTestingController);
  });

  afterEach(() => http.verify());

  it('solicita la exportacion como blob y conserva la respuesta HTTP', () => {
    service.exportEmployees().subscribe((response) => {
      expect(response.body).toBeInstanceOf(Blob);
      expect(response.headers.get('Content-Disposition')).toContain('.xlsx');
    });

    const request = http.expectOne(`${environment.apiUrl}/employees/export`);
    expect(request.request.method).toBe('GET');
    expect(request.request.responseType).toBe('blob');
    request.flush(new Blob(['xlsx'], {
      type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    }), {
      headers: {
        'Content-Disposition': 'attachment; filename="empleados_activos_20260723_150000.xlsx"',
      },
    });
  });
});
