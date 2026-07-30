import { ComponentFixture, TestBed } from '@angular/core/testing';
import { HttpResponse } from '@angular/common/http';
import { of, Subject, throwError } from 'rxjs';
import { AuthService } from '../../core/services/auth.service';
import { BulkLoadService, BulkLoadValidation } from '../../core/services/bulk-load.service';
import { EmployeeBulkLoadComponent } from './employee-bulk-load.component';

describe('EmployeeBulkLoadComponent', () => {
  let fixture: ComponentFixture<EmployeeBulkLoadComponent>;
  let component: EmployeeBulkLoadComponent;
  let service: {
    downloadEmployeeTemplate: ReturnType<typeof vi.fn>;
    validateEmployees: ReturnType<typeof vi.fn>;
    importEmployees: ReturnType<typeof vi.fn>;
  };

  const valid: BulkLoadValidation = { total: 2, valid: 2, invalid: 0, warnings: [], errors: [] };

  beforeEach(async () => {
    service = {
      downloadEmployeeTemplate: vi.fn().mockReturnValue(of(new HttpResponse({ body: new Blob(['xlsx']) }))),
      validateEmployees: vi.fn().mockReturnValue(of(valid)),
      importEmployees: vi.fn().mockReturnValue(of({ created: 2, total: 2 })),
    };
    await TestBed.configureTestingModule({
      imports: [EmployeeBulkLoadComponent],
      providers: [
        { provide: BulkLoadService, useValue: service },
        { provide: AuthService, useValue: { hasPermission: (code: string) => code === 'EMPLEADOS_CREAR' } },
      ],
    }).compileComponents();
    fixture = TestBed.createComponent(EmployeeBulkLoadComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('rejects non-xlsx files before calling the server', () => {
    component.onFileInput({ target: { files: [new File(['x'], 'empleados.csv')] } } as unknown as Event);
    expect(component.error()).toContain('.xlsx');
    expect(component.file()).toBeNull();
  });

  it('validates the selected file and displays the structured result', () => {
    const file = new File(['xlsx'], 'empleados.xlsx', { type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' });
    component.onFileInput({ target: { files: [file] } } as unknown as Event);
    component.validate();
    expect(service.validateEmployees).toHaveBeenCalledWith(file);
    expect(component.validation()).toEqual(valid);
  });

  it('explains the delivered-format compatibility and renders informational warnings', () => {
    component.validation.set({
      total: 1,
      valid: 1,
      invalid: 0,
      errors: [],
      warnings: [{ row: 2, field: 'salario', message: 'Dato informativo; no se persiste.' }],
    });
    fixture.detectChanges();
    expect(fixture.nativeElement.textContent).toContain('único cambio es separar NOMBRES y APELLIDOS');
    expect(fixture.nativeElement.textContent).toContain('Advertencias informativas');
    expect(fixture.nativeElement.textContent).toContain('no se persiste');
  });

  it('shows numeric document conversion as safe, keeps import enabled, and includes it in the report', () => {
    const conversionMessage = 'El documento llegó como número y se convertirá a texto. Verifica que no tuviera ceros iniciales.';
    component.onFileInput({ target: { files: [new File(['xlsx'], 'empleados.xlsx')] } } as unknown as Event);
    component.validation.set({
      total: 1,
      valid: 1,
      invalid: 0,
      errors: [],
      warnings: [{ row: 3, field: 'numero_documento', message: conversionMessage }],
    });
    fixture.detectChanges();

    const content = fixture.nativeElement.textContent;
    const importButton = [...fixture.nativeElement.querySelectorAll('button')]
      .find((button: HTMLButtonElement) => button.textContent?.includes('Importar 1 empleados')) as HTMLButtonElement;
    expect(content).toContain('Conversión segura');
    expect(content).toContain(conversionMessage);
    expect(importButton.disabled).toBe(false);
    expect(component['reportText']()).toContain(conversionMessage);
    expect(component['reportText']()).toContain('ADVERTENCIA');
  });

  it('prevents double validation while a request is active', () => {
    const request = new Subject<BulkLoadValidation>();
    service.validateEmployees.mockReturnValue(request);
    component.onFileInput({ target: { files: [new File(['x'], 'empleados.xlsx')] } } as unknown as Event);
    component.validate();
    component.validate();
    expect(service.validateEmployees).toHaveBeenCalledTimes(1);
    request.next(valid); request.complete();
    expect(component.validating()).toBe(false);
  });

  it('asks for confirmation, imports, and clears state after success', () => {
    vi.spyOn(window, 'confirm').mockReturnValue(true);
    component.onFileInput({ target: { files: [new File(['x'], 'empleados.xlsx')] } } as unknown as Event);
    component.validation.set(valid);
    component.import();
    expect(service.importEmployees).toHaveBeenCalledTimes(1);
    expect(component.file()).toBeNull();
    expect(component.message()).toContain('2 empleados');
  });

  it('invalidates the previous validation when server revalidation fails', () => {
    vi.spyOn(window, 'confirm').mockReturnValue(true);
    service.importEmployees.mockReturnValue(throwError(() => new Error('fail')));
    component.onFileInput({ target: { files: [new File(['x'], 'empleados.xlsx')] } } as unknown as Event);
    component.validation.set(valid);
    component.import();
    expect(component.validation()).toBeNull();
    expect(component.error()).toContain('No se creó ningún registro');
  });
});
