import { HttpErrorResponse } from '@angular/common/http';

export function apiErrorMessage(error: unknown, fallback = 'No fue posible completar la operación.'): string {
  if (error instanceof HttpErrorResponse) {
    const body = error.error as { message?: string; errors?: Record<string, string[]> } | null;
    const validation = body?.errors ? Object.values(body.errors).flat()[0] : undefined;
    const message = validation ?? body?.message ?? fallback;
    if (/evidencia.*(field is prohibited|prohibited when)/i.test(message)) {
      return 'Una solicitud por comprar no debe incluir datos de evidencia. Cambia a “Lista para entregar” si necesitas adjuntarla.';
    }
    return message;
  }
  return fallback;
}
