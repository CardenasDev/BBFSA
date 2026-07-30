import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable, map } from 'rxjs';
import { environment } from '../../../environments/environment';
import {
  ApiResponse,
  AvailableReturnDelivery,
  AvailableReturnItem,
  CreateReturnPayload,
  ReturnFilters,
  ReturnListItem,
  ReturnRecordResponse,
  ReturnType,
} from '../models/api.models';

@Injectable({ providedIn: 'root' })
export class ReturnService {
  private readonly http = inject(HttpClient);
  private readonly url = `${environment.apiUrl}/returns`;

  getAvailableReturns(type: ReturnType, employeeId: number): Observable<AvailableReturnDelivery[]> {
    const params = new HttpParams().set('type', type).set('employee_id', employeeId);
    return this.http
      .get<ApiResponse<AvailableReturnDelivery[] | AvailableReturnItem[]>>(`${this.url}/available`, { params })
      .pipe(map((response) => groupAvailableReturns(response.data)));
  }

  createReturn(payload: CreateReturnPayload): Observable<{ id_devolucion: number; estado: string }> {
    const formData = buildReturnFormData(payload);
    return this.http
      .post<ApiResponse<{ id_devolucion: number; estado: string }>>(this.url, formData)
      .pipe(map((response) => response.data));
  }

  getReturns(filters: ReturnFilters = {}): Observable<ReturnListItem[]> {
    let params = new HttpParams();
    Object.entries(filters).forEach(([key, value]) => {
      if (value !== null && value !== undefined && value !== '' && value !== 0) {
        params = params.set(key, String(value));
      }
    });
    return this.http.get<ApiResponse<ReturnListItem[]>>(this.url, { params }).pipe(map((response) => response.data));
  }

  getReturnById(id: number): Observable<ReturnRecordResponse> {
    return this.http.get<ApiResponse<ReturnRecordResponse>>(`${this.url}/${id}`).pipe(map((response) => response.data));
  }

  confirmReturn(id: number): Observable<{ id_devolucion: number; estado: string }> {
    return this.http
      .post<ApiResponse<{ id_devolucion: number; estado: string }>>(`${this.url}/${id}/confirm`, {})
      .pipe(map((response) => response.data));
  }

  cancelReturn(id: number, reason: string): Observable<{ id_devolucion: number; estado: string }> {
    return this.http
      .post<ApiResponse<{ id_devolucion: number; estado: string }>>(`${this.url}/${id}/cancel`, { reason })
      .pipe(map((response) => response.data));
  }
}

export function groupAvailableReturns(
  source: AvailableReturnDelivery[] | AvailableReturnItem[] | null | undefined,
): AvailableReturnDelivery[] {
  if (!source?.length) return [];
  const rows = source.flatMap((entry) => ('items' in entry ? entry.items : [entry]))
    .filter((item) => Number(item.cantidad_disponible) > 0);
  const grouped = new Map<number, AvailableReturnDelivery>();
  rows.forEach((item) => {
    const current = grouped.get(Number(item.id_entrega));
    if (current) {
      current.items.push(item);
      return;
    }
    grouped.set(Number(item.id_entrega), {
      tipo_devolucion: item.tipo_devolucion,
      id_entrega: Number(item.id_entrega),
      id_empleado: Number(item.id_empleado),
      fecha_entrega: item.fecha_entrega,
      items: [item],
    });
  });
  return [...grouped.values()];
}

export function buildReturnFormData(payload: CreateReturnPayload): FormData {
  const formData = new FormData();
  formData.append('type', payload.type);
  formData.append('employee_id', String(payload.employee_id));
  formData.append('delivery_id', String(payload.delivery_id));
  formData.append('return_date', payload.return_date);
  formData.append('reason', payload.reason);
  formData.append('observations', payload.observations ?? '');
  formData.append('details', JSON.stringify(payload.details));
  payload.evidence.forEach((file) => formData.append('evidence[]', file));
  return formData;
}

export function resolveReturnEvidenceUrl(evidence: { archivo_url?: string | null; archivo_ruta?: string | null }): string | null {
  const value = evidence.archivo_url?.trim() || evidence.archivo_ruta?.trim();
  if (!value) return null;
  if (/^https?:\/\//i.test(value)) return value;
  if (/^[a-z][a-z\d+.-]*:/i.test(value) || value.startsWith('//')) return null;
  return `${environment.backendUrl}/${value.replace(/^\/+/, '')}`;
}
