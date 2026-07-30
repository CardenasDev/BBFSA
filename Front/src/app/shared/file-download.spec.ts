import { HttpErrorResponse } from '@angular/common/http';
import { blobErrorMessage, downloadFilename } from './file-download';

describe('file download utilities', () => {
  it('supports filename and filename* while removing unsafe paths', () => {
    expect(downloadFilename(
      'attachment; filename="cotizacion-dotacion.xlsx"',
      'fallback.xlsx',
    )).toBe('cotizacion-dotacion.xlsx');
    expect(downloadFilename(
      "attachment; filename*=UTF-8''cotizaci%C3%B3n%20dotaci%C3%B3n.xlsx",
      'fallback.xlsx',
    )).toBe('cotización dotación.xlsx');
    expect(downloadFilename(
      'attachment; filename="../../reporte.xlsx"',
      'fallback.xlsx',
    )).toBe('reporte.xlsx');
  });

  it('uses the fallback for an absent filename', () => {
    expect(downloadFilename(null, 'fallback.xlsx')).toBe('fallback.xlsx');
    expect(downloadFilename('attachment', 'fallback.xlsx')).toBe('fallback.xlsx');
  });

  it('reads controlled JSON blob errors and ignores non-JSON content', async () => {
    const jsonError = new HttpErrorResponse({
      status: 404,
      error: new Blob([JSON.stringify({ message: 'Sin información.' })], { type: 'application/json' }),
    });
    const htmlError = new HttpErrorResponse({
      status: 500,
      error: new Blob(['<html>trace</html>'], { type: 'text/html' }),
    });

    await expect(blobErrorMessage(jsonError, 'Fallback')).resolves.toBe('Sin información.');
    await expect(blobErrorMessage(htmlError, 'Fallback')).resolves.toBe('Fallback');
  });
});
