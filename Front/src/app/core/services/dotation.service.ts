import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable, map } from 'rxjs';
import { environment } from '../../../environments/environment';
import {
  ApiResponse,
  ConfirmDotationDeliveryRequest,
  ConfirmedDotationDelivery,
  CreateDotationDeliveryRequest,
  DeleteDotationDeliveryResponse,
  DotationCombination,
  DotationCombinationDetail,
  DotationDelivery,
  DotationDeliveryDetail,
  DotationDeliveryFilters,
  DotationEmployeeFilters,
  DotationEmployeeSummary,
  DotationSize,
  DotationType,
  EmployeeDotationHistory,
  EmployeeDotationSize,
  MyDotationDelivery,
  MyDotationSize,
  SaveMyDotationSizeRequest,
} from '../models/api.models';

@Injectable({ providedIn: 'root' })
export class DotationService {
  private readonly http = inject(HttpClient);
  private readonly url = `${environment.apiUrl}/dotations`;

  getTypes(soloActivos = true): Observable<DotationType[]> {
    const params = new HttpParams().set('solo_activos', String(soloActivos));
    return this.http.get<ApiResponse<DotationType[]>>(`${this.url}/types`, { params }).pipe(
      map((response) => response.data ?? []),
    );
  }

  getSizes(idTipoDotacion?: number | null, soloActivos = true): Observable<DotationSize[]> {
    let params = new HttpParams().set('solo_activos', String(soloActivos));
    if (idTipoDotacion) {
      params = params.set('id_tipo_dotacion', String(idTipoDotacion));
    }
    return this.http.get<ApiResponse<DotationSize[]>>(`${this.url}/sizes`, { params }).pipe(
      map((response) => response.data ?? []),
    );
  }

  getCombinations(): Observable<DotationCombination[]> {
    return this.http.get<ApiResponse<DotationCombination[]>>(`${this.url}/combinations`).pipe(
      map((response) => response.data ?? []),
    );
  }

  getCombinationDetail(combinationId: number): Observable<DotationCombinationDetail[]> {
    return this.http.get<ApiResponse<DotationCombinationDetail[]>>(`${this.url}/combinations/${combinationId}`).pipe(
      map((response) => response.data ?? []),
    );
  }

  getMySizes(): Observable<MyDotationSize[]> {
    return this.http.get<ApiResponse<MyDotationSize[]>>(`${this.url}/my-sizes`).pipe(
      map((response) => response.data ?? []),
    );
  }

  getMyDeliveries(): Observable<MyDotationDelivery[]> {
    return this.http.get<ApiResponse<MyDotationDelivery[]>>(`${this.url}/my-deliveries`).pipe(
      map((response) => response.data ?? []),
    );
  }

  saveMySize(payload: SaveMyDotationSizeRequest): Observable<MyDotationSize> {
    return this.http.post<ApiResponse<MyDotationSize>>(`${this.url}/my-sizes`, payload).pipe(
      map((response) => response.data),
    );
  }

  getEmployees(filters: DotationEmployeeFilters = {}): Observable<DotationEmployeeSummary[]> {
    return this.http.get<ApiResponse<DotationEmployeeSummary[]>>(`${this.url}/employees`, { params: this.params(filters) }).pipe(
      map((response) => response.data ?? []),
    );
  }

  getEmployeeSizes(employeeId: number): Observable<EmployeeDotationSize[]> {
    return this.http.get<ApiResponse<EmployeeDotationSize[]>>(`${this.url}/employees/${employeeId}/sizes`).pipe(
      map((response) => response.data ?? []),
    );
  }

  getEmployeeHistory(employeeId: number): Observable<EmployeeDotationHistory[]> {
    return this.http.get<ApiResponse<EmployeeDotationHistory[]>>(`${this.url}/employees/${employeeId}/history`).pipe(
      map((response) => response.data ?? []),
    );
  }

  getDeliveries(filters: DotationDeliveryFilters = {}): Observable<DotationDelivery[]> {
    return this.http.get<ApiResponse<DotationDelivery[]>>(`${this.url}/deliveries`, { params: this.params(filters) }).pipe(
      map((response) => response.data ?? []),
    );
  }

  createDelivery(payload: CreateDotationDeliveryRequest): Observable<{ id_dotacion_entrega: number }> {
    return this.http.post<ApiResponse<{ id_dotacion_entrega: number }>>(`${this.url}/deliveries`, payload).pipe(
      map((response) => response.data),
    );
  }

  getDeliveryDetails(deliveryId: number): Observable<DotationDeliveryDetail[]> {
    return this.http.get<ApiResponse<DotationDeliveryDetail[]>>(`${this.url}/deliveries/${deliveryId}/details`).pipe(
      map((response) => response.data ?? []),
    );
  }

  confirmDeliveryReceived(deliveryId: number, payload: ConfirmDotationDeliveryRequest): Observable<ConfirmedDotationDelivery> {
    return this.http.post<ApiResponse<ConfirmedDotationDelivery>>(`${this.url}/deliveries/${deliveryId}/confirm`, payload).pipe(
      map((response) => response.data),
    );
  }

  deleteDelivery(deliveryId: number, motivoEliminacion?: string): Observable<DeleteDotationDeliveryResponse> {
    return this.http.request<ApiResponse<DeleteDotationDeliveryResponse>>('DELETE', `${this.url}/deliveries/${deliveryId}`, {
      body: {
        motivo_eliminacion: motivoEliminacion,
      },
    }).pipe(
      map((response) => response.data),
    );
  }

  private params(filters: object): HttpParams {
    let params = new HttpParams();
    Object.entries(filters as Record<string, unknown>).forEach(([key, value]) => {
      if (value !== '' && value != null) {
        params = params.set(key, String(value));
      }
    });
    return params;
  }
}
