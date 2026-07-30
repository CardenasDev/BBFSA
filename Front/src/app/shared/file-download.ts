import { HttpErrorResponse } from '@angular/common/http';

export async function blobErrorMessage(error: unknown, fallback: string): Promise<string> {
  if (!(error instanceof HttpErrorResponse) || !(error.error instanceof Blob)) {
    return fallback;
  }

  const contentType = error.error.type.toLowerCase();
  if (!contentType.includes('application/json') && !contentType.includes('+json')) {
    return fallback;
  }

  try {
    const body = JSON.parse(await error.error.text()) as { message?: unknown };
    return typeof body.message === 'string' && body.message.trim() ? body.message : fallback;
  } catch {
    return fallback;
  }
}

export function downloadFilename(contentDisposition: string | null, fallback: string): string {
  if (!contentDisposition) {
    return fallback;
  }

  const encodedMatch = contentDisposition.match(/filename\*\s*=\s*(?:UTF-8'')?([^;]+)/i);
  const regularMatch = contentDisposition.match(/filename\s*=\s*(?:"([^"]+)"|([^;]+))/i);
  const rawFilename = encodedMatch?.[1] ?? regularMatch?.[1] ?? regularMatch?.[2];
  if (!rawFilename) {
    return fallback;
  }

  let decodedFilename: string;
  try {
    decodedFilename = decodeURIComponent(rawFilename.trim().replace(/^["']|["']$/g, ''));
  } catch {
    decodedFilename = rawFilename.trim().replace(/^["']|["']$/g, '');
  }

  return decodedFilename.split(/[\\/]/).pop()?.replace(/[\u0000-\u001F\u007F]/g, '').trim() || fallback;
}

export function downloadBlob(blob: Blob, filename: string): void {
  const objectUrl = URL.createObjectURL(blob);
  const link = document.createElement('a');
  link.href = objectUrl;
  link.download = filename;
  link.style.display = 'none';
  document.body.appendChild(link);

  try {
    link.click();
  } finally {
    link.remove();
    URL.revokeObjectURL(objectUrl);
  }
}
