import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { map, Observable } from 'rxjs';
import { environment } from '../../../environments/environment';
import { ApiResponse } from '../models/api.models';
import {
  AttendanceStatus,
  CommitmentStatus,
  Training,
  TrainingAlert,
  TrainingCommitment,
  TrainingEvaluation,
  TrainingImportResult,
  TrainingParticipant,
  TrainingSession,
  TrainingSessionDetail,
  TrainingSessionStatus,
  TrainingTask,
} from '../models/training.models';

@Injectable({ providedIn: 'root' })
export class TrainingService {
  private readonly http = inject(HttpClient);
  private readonly url = `${environment.apiUrl}/trainings`;
  private params(values: Record<string, unknown>): HttpParams {
    let params = new HttpParams();
    Object.entries(values).forEach(([key, value]) => {
      if (value !== '' && value != null) params = params.set(key, String(value));
    });
    return params;
  }
  tasks(inactive = false): Observable<TrainingTask[]> {
    return this.http
      .get<
        ApiResponse<TrainingTask[]>
      >(`${this.url}/tasks`, { params: this.params({ incluir_inactivas: inactive ? 1 : 0 }) })
      .pipe(map((r) => r.data));
  }
  saveTask(payload: Partial<TrainingTask>): Observable<TrainingTask> {
    return this.http
      .post<ApiResponse<TrainingTask>>(`${this.url}/tasks`, payload)
      .pipe(map((r) => r.data));
  }
  trainings(type = '', inactive = false): Observable<Training[]> {
    return this.http
      .get<
        ApiResponse<Training[]>
      >(this.url, { params: this.params({ tipo: type, incluir_inactivas: inactive ? 1 : 0 }) })
      .pipe(map((r) => r.data));
  }
  saveTraining(payload: Partial<Training>): Observable<Training> {
    return this.http.post<ApiResponse<Training>>(this.url, payload).pipe(map((r) => r.data));
  }
  attachedTasks(trainingId: number): Observable<TrainingTask[]> {
    return this.http
      .get<
        ApiResponse<TrainingTask[]>
      >(`${this.url}/${trainingId}/tasks`, { params: this.params({ incluir_inactivas: 0 }) })
      .pipe(map((r) => r.data));
  }
  attachTask(payload: Record<string, unknown>): Observable<unknown> {
    return this.http
      .post<ApiResponse<unknown>>(`${this.url}/tasks/attach`, payload)
      .pipe(map((r) => r.data));
  }
  sessions(filters: Record<string, unknown> = {}): Observable<TrainingSession[]> {
    return this.http
      .get<ApiResponse<TrainingSession[]>>(`${this.url}/sessions`, { params: this.params(filters) })
      .pipe(map((r) => r.data));
  }
  createSession(payload: Record<string, unknown>): Observable<TrainingSession> {
    return this.http
      .post<ApiResponse<TrainingSession>>(`${this.url}/sessions`, payload)
      .pipe(map((r) => r.data));
  }
  session(id: number): Observable<TrainingSessionDetail> {
    return this.http
      .get<ApiResponse<TrainingSessionDetail>>(`${this.url}/sessions/${id}`)
      .pipe(map((r) => r.data));
  }
  status(id: number, estado: TrainingSessionStatus): Observable<unknown> {
    return this.http
      .patch<ApiResponse<unknown>>(`${this.url}/sessions/${id}/status`, { estado })
      .pipe(map((r) => r.data));
  }
  addParticipant(
    sessionId: number,
    employeeId: number,
    observaciones?: string,
  ): Observable<TrainingParticipant> {
    return this.http
      .post<
        ApiResponse<TrainingParticipant>
      >(`${this.url}/sessions/${sessionId}/participants`, { id_empleado: employeeId, observaciones: observaciones || null })
      .pipe(map((r) => r.data));
  }
  attendance(id: number, estado: AttendanceStatus, observaciones?: string): Observable<unknown> {
    return this.http
      .patch<
        ApiResponse<unknown>
      >(`${this.url}/participants/${id}/attendance`, { estado, observaciones: observaciones || null })
      .pipe(map((r) => r.data));
  }
  evaluation(payload: TrainingEvaluation): Observable<unknown> {
    return this.http
      .post<ApiResponse<unknown>>(`${this.url}/evaluations`, payload)
      .pipe(map((r) => r.data));
  }
  result(payload: Record<string, unknown>): Observable<unknown> {
    return this.http
      .post<ApiResponse<unknown>>(`${this.url}/results`, payload)
      .pipe(map((r) => r.data));
  }
  confirm(id: number, observation = ''): Observable<unknown> {
    return this.http
      .post<
        ApiResponse<unknown>
      >(`${this.url}/participants/${id}/confirm`, { observacion: observation || null })
      .pipe(map((r) => r.data));
  }
  confirmHr(id: number, observation = ''): Observable<unknown> {
    return this.http
      .post<
        ApiResponse<unknown>
      >(`${this.url}/participants/${id}/confirm-by-hr`, { observacion: observation || null })
      .pipe(map((r) => r.data));
  }
  mine(): Observable<TrainingParticipant[]> {
    return this.http
      .get<ApiResponse<TrainingParticipant[]>>(`${this.url}/my/records`)
      .pipe(map((r) => r.data));
  }
  alerts(employeeId?: number): Observable<TrainingAlert[]> {
    return this.http
      .get<
        ApiResponse<TrainingAlert[]>
      >(`${this.url}/alerts`, { params: this.params({ id_empleado: employeeId }) })
      .pipe(map((r) => r.data));
  }
  commitments(employeeId?: number, status = ''): Observable<TrainingCommitment[]> {
    return this.http
      .get<
        ApiResponse<TrainingCommitment[]>
      >(`${this.url}/commitments`, { params: this.params({ id_empleado: employeeId, estado: status }) })
      .pipe(map((r) => r.data));
  }
  commitment(id: number): Observable<TrainingCommitment> {
    return this.http
      .get<ApiResponse<TrainingCommitment>>(`${this.url}/commitments/${id}`)
      .pipe(map((r) => r.data));
  }
  createCommitment(payload: Record<string, unknown>): Observable<TrainingCommitment> {
    return this.http
      .post<ApiResponse<TrainingCommitment>>(`${this.url}/commitments`, payload)
      .pipe(map((r) => r.data));
  }
  updateCommitment(
    id: number,
    payload: {
      estado: CommitmentStatus;
      documento_url?: string;
      firma_url?: string;
      observaciones?: string;
      documento?: File;
      firma?: File;
    },
  ): Observable<TrainingCommitment> {
    const form = new FormData();
    form.append('_method', 'PATCH');
    Object.entries(payload).forEach(([k, v]) => {
      if (v != null && v !== '') form.append(k, v instanceof File ? v : String(v));
    });
    return this.http
      .post<ApiResponse<TrainingCommitment>>(`${this.url}/commitments/${id}`, form)
      .pipe(map((r) => r.data));
  }
  import(sessionId: number, file: File): Observable<TrainingImportResult> {
    const form = new FormData();
    form.append('archivo', file);
    return this.http
      .post<ApiResponse<TrainingImportResult>>(`${this.url}/sessions/${sessionId}/import`, form)
      .pipe(map((r) => r.data));
  }
}
