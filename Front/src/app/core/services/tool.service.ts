import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable, map } from 'rxjs';
import { environment } from '../../../environments/environment';
import {
  ApiResponse,
  CreateToolDeliveryRequest,
  Tool,
  ToolDelivery,
  ToolDeliveryFilters,
  ToolPayload,
} from '../models/api.models';

@Injectable({ providedIn: 'root' })
export class ToolService {
  private readonly http = inject(HttpClient);
  private readonly toolsUrl = `${environment.apiUrl}/tools`;
  private readonly deliveriesUrl = `${environment.apiUrl}/tool-deliveries`;
  private readonly myDeliveriesUrl = `${environment.apiUrl}/my-tool-deliveries`;

  getTools(active = true): Observable<Tool[]> {
    return this.http.get<ApiResponse<Tool[]>>(this.toolsUrl, {
      params: new HttpParams().set('active', active ? '1' : '0'),
    }).pipe(map((response) => response.data ?? []));
  }

  createTool(payload: ToolPayload): Observable<Tool> {
    return this.http.post<ApiResponse<Tool>>(this.toolsUrl, payload).pipe(map((response) => response.data));
  }

  updateTool(id: number, payload: ToolPayload): Observable<Tool> {
    return this.http.put<ApiResponse<Tool>>(`${this.toolsUrl}/${id}`, payload).pipe(map((response) => response.data));
  }

  changeToolStatus(id: number, activo: boolean): Observable<Tool> {
    return this.http.patch<ApiResponse<Tool>>(`${this.toolsUrl}/${id}/status`, { activo }).pipe(map((response) => response.data));
  }

  getToolDeliveries(filters: ToolDeliveryFilters = {}): Observable<ToolDelivery[]> {
    let params = new HttpParams();
    if (filters.id_empleado) params = params.set('id_empleado', String(filters.id_empleado));
    if (filters.estado) params = params.set('estado', filters.estado);
    return this.http.get<ApiResponse<ToolDelivery[]>>(this.deliveriesUrl, { params }).pipe(map((response) => response.data ?? []));
  }

  createToolDelivery(payload: CreateToolDeliveryRequest): Observable<{ id_entrega: number; estado: string }> {
    return this.http.post<ApiResponse<{ id_entrega: number; estado: string }>>(this.deliveriesUrl, payload).pipe(map((response) => response.data));
  }

  getToolDelivery(id: number): Observable<ToolDelivery> {
    return this.http.get<ApiResponse<ToolDelivery>>(`${this.deliveriesUrl}/${id}`).pipe(map((response) => response.data));
  }

  confirmToolDelivery(id: number): Observable<ToolDelivery> {
    return this.http.post<ApiResponse<ToolDelivery>>(`${this.deliveriesUrl}/${id}/confirm`, {}).pipe(map((response) => response.data));
  }

  deleteToolDelivery(id: number): Observable<{ id_entrega: number }> {
    return this.http.delete<ApiResponse<{ id_entrega: number }>>(`${this.deliveriesUrl}/${id}`).pipe(map((response) => response.data));
  }

  getMyToolDeliveries(): Observable<ToolDelivery[]> {
    return this.http.get<ApiResponse<ToolDelivery[]>>(this.myDeliveriesUrl).pipe(
      map((response) => response.data ?? []),
    );
  }

  getMyToolDelivery(id: number): Observable<ToolDelivery> {
    return this.http.get<ApiResponse<ToolDelivery>>(`${this.myDeliveriesUrl}/${id}`).pipe(
      map((response) => response.data),
    );
  }

  confirmMyToolDelivery(id: number): Observable<ToolDelivery> {
    return this.http.post<ApiResponse<ToolDelivery>>(`${this.myDeliveriesUrl}/${id}/confirm`, {}).pipe(
      map((response) => response.data),
    );
  }
}
