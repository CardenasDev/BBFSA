import { HttpErrorResponse, HttpHeaders, HttpResponse } from '@angular/common/http';
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { provideRouter } from '@angular/router';
import { of, Subject } from 'rxjs';
import { AuthService } from '../../core/services/auth.service';
import { CatalogService } from '../../core/services/catalog.service';
import { DotationService } from '../../core/services/dotation.service';
import { DotationEmployeesComponent } from './dotation-employees.component';

describe('DotationEmployeesComponent quotation export', () => {
  let fixture: ComponentFixture<DotationEmployeesComponent>;
  let exportResponse: Subject<HttpResponse<Blob>>;
  let hasAdminPermission: boolean;
  let downloadedFilename: string | undefined;

  const exportQuotation = vi.fn();
  const exportPurchaseQuotation = vi.fn(() => of(new HttpResponse({ body: new Blob(['xlsx']) })));
  const createObjectURL = vi.fn(() => 'blob:quotation-export');
  const revokeObjectURL = vi.fn();
  const click = vi.fn(function (this: HTMLAnchorElement) {
    downloadedFilename = this.download;
  });

  beforeEach(async () => {
    hasAdminPermission = true;
    downloadedFilename = undefined;
    exportResponse = new Subject<HttpResponse<Blob>>();
    exportQuotation.mockReturnValue(exportResponse.asObservable());

    Object.defineProperty(URL, 'createObjectURL', { configurable: true, value: createObjectURL });
    Object.defineProperty(URL, 'revokeObjectURL', { configurable: true, value: revokeObjectURL });
    vi.spyOn(HTMLAnchorElement.prototype, 'click').mockImplementation(click);

    await TestBed.configureTestingModule({
      imports: [DotationEmployeesComponent],
      providers: [
        provideRouter([]),
        {
          provide: DotationService,
          useValue: {
            exportQuotation,
            exportPurchaseQuotation,
            getEmployees: () => of([]),
            getDeliveries: () => of([]),
          },
        },
        {
          provide: CatalogService,
          useValue: {
            getAreas: () => of([]),
            getPositions: () => of([]),
          },
        },
        {
          provide: AuthService,
          useValue: {
            hasPermission: (permission: string) => permission === 'DOTACIONES_ADMIN_VER' && hasAdminPermission,
          },
        },
      ],
    }).compileComponents();

    fixture = TestBed.createComponent(DotationEmployeesComponent);
    fixture.detectChanges();
  });

  afterEach(() => {
    vi.restoreAllMocks();
    exportQuotation.mockClear();
    createObjectURL.mockClear();
    revokeObjectURL.mockClear();
    click.mockClear();
  });

  it('shows the button only with DOTACIONES_ADMIN_VER', () => {
    expect(exportButton()).toBeTruthy();

    hasAdminPermission = false;
    fixture.detectChanges();

    expect(exportButton()).toBeUndefined();
  });

  it('uses visible filters, prevents duplicates and restores loading after success', () => {
    fixture.componentInstance.idArea = 5;
    fixture.componentInstance.idCargo = 9;
    const button = exportButton()!;

    button.click();
    button.click();
    fixture.detectChanges();

    expect(exportQuotation).toHaveBeenCalledOnce();
    expect(exportQuotation).toHaveBeenCalledWith({ id_area: 5, id_cargo: 9 });
    expect(fixture.componentInstance.exportingSizes()).toBe(true);
    expect(button.disabled).toBe(true);
    expect(button.textContent).toContain('Generando tallas...');
    expect(fixture.componentInstance.exportStatus()).toBe('Generando archivo de tallas...');

    const blob = new Blob(['xlsx']);
    exportResponse.next(new HttpResponse({
      body: blob,
      headers: new HttpHeaders({
        'Content-Disposition': "attachment; filename*=UTF-8''cotizacion-dotacion-20260729.xlsx",
      }),
    }));
    exportResponse.complete();
    fixture.detectChanges();

    expect(fixture.componentInstance.exportingSizes()).toBe(false);
    expect(downloadedFilename).toBe('cotizacion-dotacion-20260729.xlsx');
    expect(createObjectURL).toHaveBeenCalledWith(blob);
    expect(revokeObjectURL).toHaveBeenCalledWith('blob:quotation-export');
    expect(fixture.componentInstance.exportStatus()).toBe('El archivo de tallas fue generado correctamente.');
  });

  it('uses the fallback filename when Content-Disposition is absent', () => {
    exportButton()!.click();
    exportResponse.next(new HttpResponse({ body: new Blob(['xlsx']) }));
    exportResponse.complete();

    expect(downloadedFilename).toBe('tallas-dotacion.xlsx');
  });

  it('restores loading and shows the controlled 404 blob message without downloading', async () => {
    exportButton()!.click();
    exportResponse.error(new HttpErrorResponse({
      status: 404,
      error: new Blob([
        JSON.stringify({ message: 'No se encontró información de dotación para los filtros seleccionados.' }),
      ], { type: 'application/json' }),
    }));
    await fixture.whenStable();
    fixture.detectChanges();

    expect(fixture.componentInstance.exportingSizes()).toBe(false);
    expect(fixture.componentInstance.exportError()).toBe(
      'No se encontró información de dotación para los filtros seleccionados.',
    );
    expect(click).not.toHaveBeenCalled();
  });

  it('restores loading and hides technical details on a general error', async () => {
    exportButton()!.click();
    exportResponse.error(new HttpErrorResponse({
      status: 500,
      error: new Blob(['<html>trace</html>'], { type: 'text/html' }),
    }));
    await fixture.whenStable();
    fixture.detectChanges();

    expect(fixture.componentInstance.exportingSizes()).toBe(false);
    expect(fixture.componentInstance.exportError()).toBe(
      'No fue posible generar el archivo de cotización. Intenta nuevamente.',
    );
    expect(fixture.nativeElement.textContent).not.toContain('trace');
  });

  function exportButton(): HTMLButtonElement | undefined {
    return Array.from((fixture.nativeElement as HTMLElement).querySelectorAll<HTMLButtonElement>('button'))
      .find((button) => button.textContent?.includes('Exportar tallas')
        || button.textContent?.includes('Generando tallas'));
  }
});
