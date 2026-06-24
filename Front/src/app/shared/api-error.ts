import { HttpErrorResponse } from '@angular/common/http';

export function apiErrorMessage(error: unknown, fallback = 'No fue posible completar la operación.'): string {
  if (error instanceof HttpErrorResponse) {
    const body = error.error as { message?: string; errors?: Record<string, string[]> } | null;
    const validation = body?.errors ? Object.values(body.errors).flat()[0] : undefined;
    return validation ?? body?.message ?? fallback;
  }
  return fallback;
}
