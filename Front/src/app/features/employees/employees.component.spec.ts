import { HttpHeaders, HttpResponse } from '@angular/common/http';
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { of, Subject } from 'rxjs';
import { AuthService } from '../../core/services/auth.service';
import { CatalogService } from '../../core/services/catalog.service';
import { EmployeeService } from '../../core/services/employee.service';
import { employeeExportFilename, EmployeesComponent } from './employees.component';

describe('EmployeesComponent export', () => {
  let fixture: ComponentFixture<EmployeesComponent>;
  let exportResponse: Subject<HttpResponse<Blob>>;
  let downloadedFilename: string | undefined;

  const exportEmployees = vi.fn();
  const createObjectURL = vi.fn(() => 'blob:employees-export');
  const revokeObjectURL = vi.fn();
  const click = vi.fn(function (this: HTMLAnchorElement) {
    downloadedFilename = this.download;
  });

  beforeEach(async () => {
    exportResponse = new Subject<HttpResponse<Blob>>();
    exportEmployees.mockReturnValue(exportResponse.asObservable());
    downloadedFilename = undefined;

    Object.defineProperty(URL, 'createObjectURL', {
      configurable: true,
      value: createObjectURL,
    });
    Object.defineProperty(URL, 'revokeObjectURL', {
      configurable: true,
      value: revokeObjectURL,
    });
    vi.spyOn(HTMLAnchorElement.prototype, 'click').mockImplementation(click);

    await TestBed.configureTestingModule({
      imports: [EmployeesComponent],
      providers: [
        {
          provide: EmployeeService,
          useValue: {
            exportEmployees,
            listEmployees: () => of([]),
          },
        },
        {
          provide: CatalogService,
          useValue: {
            getDocumentTypes: () => of([]),
            getAreas: () => of([]),
            getPositions: () => of([]),
            getContractTypes: () => of([]),
          },
        },
        {
          provide: AuthService,
          useValue: {
            hasPermission: () => false,
            hasAnyPermission: () => true,
          },
        },
      ],
    }).compileComponents();

    fixture = TestBed.createComponent(EmployeesComponent);
    fixture.detectChanges();
  });

  afterEach(() => {
    vi.restoreAllMocks();
    exportEmployees.mockClear();
    createObjectURL.mockClear();
    revokeObjectURL.mockClear();
    click.mockClear();
  });

  it('invoca el servicio, bloquea el boton y descarga con el nombre del backend', () => {
    const button = exportButton();
    button.click();
    fixture.detectChanges();

    expect(exportEmployees).toHaveBeenCalledOnce();
    expect(fixture.componentInstance.isExporting()).toBe(true);
    expect(button.disabled).toBe(true);
    expect(button.textContent).toContain('Exportando...');

    const blob = new Blob(['xlsx']);
    exportResponse.next(new HttpResponse({
      body: blob,
      headers: new HttpHeaders({
        'Content-Disposition': 'attachment; filename="empleados_activos_20260723_150000.xlsx"',
      }),
    }));
    exportResponse.complete();
    fixture.detectChanges();

    expect(fixture.componentInstance.isExporting()).toBe(false);
    expect(downloadedFilename).toBe('empleados_activos_20260723_150000.xlsx');
    expect(createObjectURL).toHaveBeenCalledWith(blob);
    expect(revokeObjectURL).toHaveBeenCalledWith('blob:employees-export');
  });

  it('acepta un File JPEG capturado por cámara y conserva la validación de 2 MB', () => {
    const component = fixture.componentInstance;
    const capture = new File(['camera'], 'evidencia-camera.jpg', { type: 'image/jpeg' });
    component.setPhotoFiles([capture]);
    expect(component.selectedPhoto()).toBe(capture);
    expect(component.photoError()).toBe('');

    const oversized = new File([new Uint8Array(2 * 1024 * 1024 + 1)], 'grande.jpg', { type: 'image/jpeg' });
    component.setPhotoFiles([oversized]);
    expect(component.selectedPhoto()).toBeNull();
    expect(component.photoError()).toContain('2 MB');
  });

  it('usa el nombre fallback cuando Content-Disposition no esta disponible', () => {
    exportButton().click();
    exportResponse.next(new HttpResponse({ body: new Blob(['xlsx']) }));
    exportResponse.complete();

    expect(downloadedFilename).toBe('empleados_activos.xlsx');
  });

  it('restaura el estado y muestra el error sin intentar descargar', () => {
    exportButton().click();
    expect(fixture.componentInstance.isExporting()).toBe(true);

    exportResponse.error(new Error('fallo de red'));
    fixture.detectChanges();

    expect(fixture.componentInstance.isExporting()).toBe(false);
    expect(fixture.componentInstance.error()).toBe('No fue posible exportar la informacion de empleados.');
    expect(createObjectURL).not.toHaveBeenCalled();
    expect(click).not.toHaveBeenCalled();
  });

  function exportButton(): HTMLButtonElement {
    const element = fixture.nativeElement as HTMLElement;

    return Array.from(element.querySelectorAll<HTMLButtonElement>('button'))
      .find((button) => button.textContent?.includes('Export')) as HTMLButtonElement;
  }
});

describe('employeeExportFilename', () => {
  it('extrae filename y filename* de forma segura', () => {
    expect(employeeExportFilename('attachment; filename="empleados_activos.xlsx"'))
      .toBe('empleados_activos.xlsx');
    expect(employeeExportFilename("attachment; filename*=UTF-8''empleados%20activos.xlsx"))
      .toBe('empleados activos.xlsx');
    expect(employeeExportFilename('attachment; filename="../../reporte.xlsx"'))
      .toBe('reporte.xlsx');
  });

  it('usa fallback cuando no hay filename', () => {
    expect(employeeExportFilename(null)).toBe('empleados_activos.xlsx');
    expect(employeeExportFilename('attachment')).toBe('empleados_activos.xlsx');
  });
});
