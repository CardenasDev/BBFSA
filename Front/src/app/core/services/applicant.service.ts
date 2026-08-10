import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable, map } from 'rxjs';
import { environment } from '../../../environments/environment';
import {
  ApiResponse,
  Applicant,
  ApplicantDetail,
  ApplicantDocument,
  ApplicantFilters,
  ApplicantStatusHistory,
  ChangeApplicantStatusRequest,
  ConvertApplicantToEmployeeRequest,
  ConvertApplicantToEmployeeResponse,
  CreateApplicantRequest,
  CreateApplicantResponse,
  RegisterApplicantDocumentRequest,
  UpdateApplicantRequest,
} from '../models/api.models';

@Injectable({ providedIn: 'root' })
export class ApplicantService {
  private readonly http = inject(HttpClient);
  private readonly url = `${environment.apiUrl}/applicants`;

  getApplicants(filters: ApplicantFilters = {}): Observable<Applicant[]> {
    let params = new HttpParams();
    Object.entries(filters).forEach(([key, value]) => {
      if (value !== '' && value != null) {
        params = params.set(key, String(value));
      }
    });

    return this.http.get<ApiResponse<Applicant[]>>(this.url, { params }).pipe(map((response) => response.data ?? []));
  }

  getApplicant(applicantId: number): Observable<ApplicantDetail> {
    return this.http.get<ApiResponse<ApplicantDetail>>(`${this.url}/${applicantId}`).pipe(map((response) => response.data));
  }

  createApplicant(payload: CreateApplicantRequest): Observable<CreateApplicantResponse> {
    return this.http.post<ApiResponse<CreateApplicantResponse>>(this.url, payload).pipe(map((response) => response.data));
  }

  updateApplicant(applicantId: number, payload: UpdateApplicantRequest): Observable<ApplicantDetail> {
    return this.http.put<ApiResponse<ApplicantDetail>>(`${this.url}/${applicantId}`, payload).pipe(map((response) => response.data));
  }

  changeStatus(applicantId: number, payload: ChangeApplicantStatusRequest): Observable<ApplicantDetail> {
    return this.http.patch<ApiResponse<ApplicantDetail>>(`${this.url}/${applicantId}/status`, payload).pipe(map((response) => response.data));
  }

  approveForContracting(applicantId: number, observaciones?: string): Observable<ApplicantDetail> {
    return this.http.post<ApiResponse<ApplicantDetail>>(`${this.url}/${applicantId}/approve-contracting`, { observaciones: observaciones || null })
      .pipe(map((response) => response.data));
  }

  getDocuments(applicantId: number): Observable<ApplicantDocument[]> {
    return this.http.get<ApiResponse<ApplicantDocument[]>>(`${this.url}/${applicantId}/documents`).pipe(map((response) => response.data ?? []));
  }

  registerDocument(applicantId: number, payload: RegisterApplicantDocumentRequest | FormData): Observable<ApplicantDocument> {
    return this.http.post<ApiResponse<ApplicantDocument>>(`${this.url}/${applicantId}/documents`, payload).pipe(map((response) => response.data));
  }

  updateDocument(applicantId: number, documentId: number, payload: RegisterApplicantDocumentRequest | FormData): Observable<ApplicantDocument> {
    return this.http.post<ApiResponse<ApplicantDocument>>(`${this.url}/${applicantId}/documents/${documentId}`, payload).pipe(map((response) => response.data));
  }

  getStatusHistory(applicantId: number): Observable<ApplicantStatusHistory[]> {
    return this.http.get<ApiResponse<ApplicantStatusHistory[]>>(`${this.url}/${applicantId}/status-history`).pipe(map((response) => response.data ?? []));
  }

  convertToEmployee(applicantId: number, payload: ConvertApplicantToEmployeeRequest): Observable<ConvertApplicantToEmployeeResponse> {
    return this.http.post<ApiResponse<ConvertApplicantToEmployeeResponse>>(`${this.url}/${applicantId}/convert-to-employee`, payload)
      .pipe(map((response) => response.data));
  }
}
