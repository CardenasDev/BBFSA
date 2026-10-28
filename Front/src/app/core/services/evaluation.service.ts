import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { map, Observable } from 'rxjs';
import { environment } from '../../../environments/environment';
import { ApiResponse } from '../models/api.models';
import {
  EvaluationDetail,
  EvaluationEmployee,
  EvaluationLabor,
  EvaluationList,
  EvaluationManagementPanel,
  EvaluationScoreInput,
} from '../models/evaluation.models';

@Injectable({ providedIn: 'root' })
export class EvaluationService {
  private readonly http = inject(HttpClient);
  private readonly url = `${environment.apiUrl}/evaluations`;

  private params(values: Record<string, unknown>): HttpParams {
    let params = new HttpParams();
    Object.entries(values).forEach(([key, value]) => {
      if (value !== '' && value != null) params = params.set(key, String(value));
    });
    return params;
  }

  getEvaluations(filters: Record<string, unknown> = {}): Observable<EvaluationList[]> {
    return this.http
      .get<ApiResponse<EvaluationList[]>>(this.url, { params: this.params(filters) })
      .pipe(map((r) => r.data));
  }

  createEvaluation(payload: Record<string, unknown>): Observable<EvaluationList> {
    return this.http
      .post<ApiResponse<EvaluationList>>(this.url, payload)
      .pipe(map((r) => r.data));
  }

  getEvaluationDetail(id: number): Observable<EvaluationDetail> {
    return this.http
      .get<ApiResponse<EvaluationDetail>>(`${this.url}/${id}`)
      .pipe(map((r) => r.data));
  }

  addEmployee(id: number, employeeId: number, observaciones?: string | null): Observable<EvaluationEmployee> {
    return this.http
      .post<ApiResponse<EvaluationEmployee>>(`${this.url}/${id}/employees`, {
        id_empleado: employeeId,
        observaciones: observaciones || null,
      })
      .pipe(map((r) => r.data));
  }

  addAllActiveEmployees(id: number): Observable<{
    insertados: number;
    omitidos_duplicados: number;
    mensaje: string;
    empleados: EvaluationEmployee[];
  }> {
    return this.http
      .post<
        ApiResponse<{
          insertados: number;
          omitidos_duplicados: number;
          mensaje: string;
          empleados: EvaluationEmployee[];
        }>
      >(`${this.url}/${id}/employees/add-all`, {})
      .pipe(
        map((r) => ({
          insertados: r.data.insertados,
          omitidos_duplicados: r.data.omitidos_duplicados,
          mensaje: r.data.mensaje,
          empleados: r.data.empleados,
        })),
      );
  }

  removeEmployee(evaluationId: number, employeeId: number): Observable<unknown> {
    return this.http
      .delete<ApiResponse<unknown>>(`${this.url}/${evaluationId}/employees/${employeeId}`)
      .pipe(map((r) => r.data));
  }

  saveScores(id: number, scores: EvaluationScoreInput[]): Observable<{ scores: unknown[] }> {
    return this.http
      .post<ApiResponse<{ scores: unknown[] }>>(`${this.url}/${id}/scores`, { calificaciones: scores })
      .pipe(map((r) => r.data));
  }

  getManagementPanel(id: number): Observable<EvaluationManagementPanel> {
    return this.http
      .get<ApiResponse<EvaluationManagementPanel>>(`${this.url}/${id}/management-panel`)
      .pipe(map((r) => r.data));
  }

  getLaborsCatalog(inactive = false): Observable<EvaluationLabor[]> {
    return this.http
      .get<ApiResponse<EvaluationLabor[]>>(`${this.url}/labors/catalog`, {
        params: this.params({ incluir_inactivas: inactive ? 1 : 0 }),
      })
      .pipe(map((r) => r.data));
  }
}
