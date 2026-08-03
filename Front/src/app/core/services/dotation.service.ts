import { HttpClient, HttpParams, HttpResponse } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable, map } from 'rxjs';
import { environment } from '../../../environments/environment';
import {
  ApiResponse,
  ConfirmDotationDeliveryRequest,
  ConfirmedDotationDelivery,
  CreatedDotationDelivery,
  CreateDotationDeliveryRequest,
  DeleteDotationDeliveryResponse,
  DotationArticle,
  DotationArticleGender,
  DotationCombination,
  DotationCombinationDetail,
  DotationDelivery,
  DotationDeliveryDetail,
  DotationDeliveryFilters,
  DotationEmployeeFilters,
  DotationQuotationFilters,
  DotationEmployeeSummary,
  DotationSize,
  DotationType,
  EmployeeDotationHistory,
  EmployeeDotationSize,
  MyDotationDelivery,
  MyDotationSize,
  PrepareDotationDeliveryRequest,
  SaveMyDotationSizeRequest,
} from '../models/api.models';

export function resolveDotationEvidenceUrl(publicUrl?: string | null): string | null {
  const value = publicUrl?.trim();
  if (!value) return null;
  if (/^https?:\/\//i.test(value)) return value;
  return `${environment.backendUrl.replace(/\/$/, '')}/${value.replace(/^\//, '')}`;
}

@Injectable({ providedIn: 'root' })
export class DotationService {
  private readonly http = inject(HttpClient);
  private readonly url = `${environment.apiUrl}/dotations`;

  getTypes(soloActivos = true): Observable<DotationType[]> {
    const params = new HttpParams().set('solo_activos', String(soloActivos));
    return this.http
      .get<ApiResponse<DotationType[]>>(`${this.url}/types`, { params })
      .pipe(map((response) => response.data ?? []));
  }

  getSizes(idTipoDotacion?: number | null, soloActivos = true): Observable<DotationSize[]> {
    let params = new HttpParams().set('solo_activos', String(soloActivos));
    if (idTipoDotacion) {
      params = params.set('id_tipo_dotacion', String(idTipoDotacion));
    }
    return this.http
      .get<ApiResponse<DotationSize[]>>(`${this.url}/sizes`, { params })
      .pipe(map((response) => response.data ?? []));
  }

  getCombinations(): Observable<DotationCombination[]> {
    return this.http
      .get<ApiResponse<DotationCombination[]>>(`${this.url}/combinations`)
      .pipe(map((response) => response.data ?? []));
  }

  getCombinationDetail(combinationId: number): Observable<DotationCombinationDetail[]> {
    return this.http
      .get<ApiResponse<DotationCombinationDetail[]>>(`${this.url}/combinations/${combinationId}`)
      .pipe(map((response) => response.data ?? []));
  }

  getMySizes(): Observable<MyDotationSize[]> {
    return this.http
      .get<ApiResponse<MyDotationSize[]>>(`${this.url}/my-sizes`)
      .pipe(map((response) => response.data ?? []));
  }

  getMyDeliveries(): Observable<MyDotationDelivery[]> {
    return this.http
      .get<ApiResponse<MyDotationDelivery[]>>(`${this.url}/my-deliveries`)
      .pipe(map((response) => response.data ?? []));
  }

  saveMySize(payload: SaveMyDotationSizeRequest): Observable<MyDotationSize> {
    return this.http
      .post<ApiResponse<MyDotationSize>>(`${this.url}/my-sizes`, payload)
      .pipe(map((response) => response.data));
  }

  getEmployees(filters: DotationEmployeeFilters = {}): Observable<DotationEmployeeSummary[]> {
    return this.http
      .get<
        ApiResponse<DotationEmployeeSummary[]>
      >(`${this.url}/employees`, { params: this.params(filters) })
      .pipe(map((response) => response.data ?? []));
  }

  getEmployeeSizes(employeeId: number): Observable<EmployeeDotationSize[]> {
    return this.http
      .get<ApiResponse<EmployeeDotationSize[]>>(`${this.url}/employees/${employeeId}/sizes`)
      .pipe(map((response) => response.data ?? []));
  }

  getEmployeeHistory(employeeId: number): Observable<EmployeeDotationHistory[]> {
    return this.http
      .get<ApiResponse<EmployeeDotationHistory[]>>(`${this.url}/employees/${employeeId}/history`)
      .pipe(map((response) => response.data ?? []));
  }

  getDeliveries(filters: DotationDeliveryFilters = {}): Observable<DotationDelivery[]> {
    return this.http
      .get<
        ApiResponse<DotationDelivery[]>
      >(`${this.url}/deliveries`, { params: this.params(filters) })
      .pipe(map((response) => response.data ?? []));
  }

  createDelivery(payload: CreateDotationDeliveryRequest): Observable<CreatedDotationDelivery> {
    const formData = new FormData();
    formData.append('id_empleado', String(payload.id_empleado));
    formData.append('fecha_entrega', payload.fecha_entrega);
    formData.append('tipo_entrega', payload.tipo_entrega);
    formData.append('estado_inicial', payload.estado_inicial);
    if (payload.id_dotacion_combinacion != null) {
      formData.append('id_dotacion_combinacion', String(payload.id_dotacion_combinacion));
    }
    if (payload.observaciones) {
      formData.append('observaciones', payload.observaciones);
    }
    if (payload.estado_inicial === 'REGISTRADA') {
      if (payload.origen_evidencia) formData.append('origen_evidencia', payload.origen_evidencia);
      if (payload.evidencia_nombre_archivo) {
        formData.append('evidencia_nombre_archivo', payload.evidencia_nombre_archivo);
      }
      if (payload.origen_evidencia === 'ARCHIVO' && payload.evidencia_archivo) {
        formData.append('evidencia_archivo', payload.evidencia_archivo);
      }
      if (payload.origen_evidencia === 'URL' && payload.evidencia_url) {
        formData.append('evidencia_url', payload.evidencia_url);
      }
    }
    payload.detalles.forEach((detail, index) => {
      formData.append(
        `detalles[${index}][id_dotacion_articulo]`,
        String(detail.id_dotacion_articulo),
      );
      formData.append(`detalles[${index}][id_tipo_dotacion]`, String(detail.id_tipo_dotacion));
      if (detail.id_talla_dotacion != null) {
        formData.append(`detalles[${index}][id_talla_dotacion]`, String(detail.id_talla_dotacion));
      }
      formData.append(`detalles[${index}][cantidad]`, String(detail.cantidad));
      if (detail.observaciones) {
        formData.append(`detalles[${index}][observaciones]`, detail.observaciones);
      }
    });

    return this.http
      .post<ApiResponse<CreatedDotationDelivery>>(`${this.url}/deliveries`, formData)
      .pipe(map((response) => response.data));
  }

  exportQuotation(filters: DotationQuotationFilters = {}): Observable<HttpResponse<Blob>> {
    return this.http.get(`${this.url}/quotation/export`, {
      params: this.params(filters),
      observe: 'response',
      responseType: 'blob',
    });
  }

  getArticles(
    idTipoDotacion?: number | null,
    genero?: DotationArticleGender | null,
    incluirInactivos = false,
  ): Observable<DotationArticle[]> {
    let params = new HttpParams().set('incluir_inactivos', incluirInactivos ? '1' : '0');
    if (idTipoDotacion) params = params.set('id_tipo_dotacion', String(idTipoDotacion));
    if (genero) params = params.set('genero', genero);
    return this.http
      .get<ApiResponse<DotationArticle[]>>(`${this.url}/articles`, { params })
      .pipe(map((response) => response.data ?? []));
  }

  exportPurchaseQuotation(filters: DotationQuotationFilters = {}): Observable<HttpResponse<Blob>> {
    return this.http.get(`${this.url}/purchase-quotation/export`, {
      params: this.params(filters),
      observe: 'response',
      responseType: 'blob',
    });
  }

  prepareDelivery(
    deliveryId: number,
    payload: PrepareDotationDeliveryRequest,
  ): Observable<DotationDelivery> {
    const formData = new FormData();
    formData.append('fecha_entrega', payload.fecha_entrega);
    formData.append('origen_evidencia', payload.origen_evidencia);
    if (payload.evidencia_nombre_archivo)
      formData.append('evidencia_nombre_archivo', payload.evidencia_nombre_archivo);
    if (payload.origen_evidencia === 'ARCHIVO' && payload.evidencia_archivo)
      formData.append('evidencia_archivo', payload.evidencia_archivo);
    if (payload.origen_evidencia === 'URL' && payload.evidencia_url)
      formData.append('evidencia_url', payload.evidencia_url);
    return this.http
      .post<ApiResponse<DotationDelivery>>(`${this.url}/deliveries/${deliveryId}/prepare`, formData)
      .pipe(map((response) => response.data));
  }

  getDeliveryDetails(deliveryId: number): Observable<DotationDeliveryDetail[]> {
    return this.http
      .get<ApiResponse<DotationDeliveryDetail[]>>(`${this.url}/deliveries/${deliveryId}/details`)
      .pipe(map((response) => response.data ?? []));
  }

  confirmDeliveryReceived(
    deliveryId: number,
    payload: ConfirmDotationDeliveryRequest,
  ): Observable<ConfirmedDotationDelivery> {
    return this.http
      .post<
        ApiResponse<ConfirmedDotationDelivery>
      >(`${this.url}/deliveries/${deliveryId}/confirm`, payload)
      .pipe(map((response) => response.data));
  }

  deleteDelivery(
    deliveryId: number,
    motivoEliminacion?: string,
  ): Observable<DeleteDotationDeliveryResponse> {
    return this.http
      .request<ApiResponse<DeleteDotationDeliveryResponse>>(
        'DELETE',
        `${this.url}/deliveries/${deliveryId}`,
        {
          body: {
            motivo_eliminacion: motivoEliminacion,
          },
        },
      )
      .pipe(map((response) => response.data));
  }

  private params(filters: object): HttpParams {
    let params = new HttpParams();
    Object.entries(filters as Record<string, unknown>).forEach(([key, value]) => {
      if (value !== '' && value != null && value !== 0) {
        params = params.set(key, String(value));
      }
    });
    return params;
  }
}
