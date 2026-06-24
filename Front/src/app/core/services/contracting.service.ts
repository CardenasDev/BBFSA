import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable, map } from 'rxjs';
import { environment } from '../../../environments/environment';
import {
  ApiResponse,
  ContractingAlert,
  ContractingEmployee,
  ContractingProfile,
  CreateEmployeeContractRequest,
  CreateMedicalExamRequest,
  EmployeeContract,
  EmployeeLaborDocument,
  EmployeeMedicalExam,
  EmployeeSocialSecurity,
  RegisterEmployeeDocumentRequest,
  SaveContractingProfileRequest,
  SaveSocialSecurityRequest,
} from '../models/api.models';

export interface ContractingEmployeeFilters {
  search?: string;
  area_id?: number | null;
  position_id?: number | null;
  status?: string;
}

@Injectable({ providedIn: 'root' })
export class ContractingService {
  private readonly http = inject(HttpClient);
  private readonly url = `${environment.apiUrl}/contracting`;

  getEmployees(filters: ContractingEmployeeFilters = {}): Observable<ContractingEmployee[]> {
    let params = new HttpParams();
    if (filters.search?.trim()) params = params.set('texto_busqueda', filters.search.trim());
    if (filters.area_id) params = params.set('id_area', String(filters.area_id));
    if (filters.position_id) params = params.set('id_cargo', String(filters.position_id));
    if (filters.status?.trim()) params = params.set('estado_empleado', filters.status.trim());

    return this.http.get<ApiResponse<ContractingEmployee[]>>(`${this.url}/employees`, { params }).pipe(
      map((response) => response.data ?? []),
    );
  }

  getProfile(employeeId: number): Observable<ContractingProfile | null> {
    return this.http.get<ApiResponse<ContractingProfile | null>>(`${this.url}/employees/${employeeId}/profile`).pipe(
      map((response) => response.data ?? null),
    );
  }

  saveProfile(employeeId: number, payload: SaveContractingProfileRequest): Observable<ContractingProfile> {
    return this.http.post<ApiResponse<ContractingProfile>>(`${this.url}/employees/${employeeId}/profile`, payload).pipe(
      map((response) => response.data),
    );
  }

  getContracts(employeeId: number): Observable<EmployeeContract[]> {
    return this.http.get<ApiResponse<EmployeeContract[]>>(`${this.url}/employees/${employeeId}/contracts`).pipe(
      map((response) => response.data ?? []),
    );
  }

  createContract(employeeId: number, payload: CreateEmployeeContractRequest): Observable<EmployeeContract> {
    return this.http.post<ApiResponse<EmployeeContract>>(`${this.url}/employees/${employeeId}/contracts`, payload).pipe(
      map((response) => response.data),
    );
  }

  getSocialSecurity(employeeId: number): Observable<EmployeeSocialSecurity | null> {
    return this.http.get<ApiResponse<EmployeeSocialSecurity | null>>(`${this.url}/employees/${employeeId}/social-security`).pipe(
      map((response) => response.data ?? null),
    );
  }

  saveSocialSecurity(employeeId: number, payload: SaveSocialSecurityRequest): Observable<EmployeeSocialSecurity> {
    return this.http.post<ApiResponse<EmployeeSocialSecurity>>(`${this.url}/employees/${employeeId}/social-security`, payload).pipe(
      map((response) => response.data),
    );
  }

  getMedicalExams(employeeId: number): Observable<EmployeeMedicalExam[]> {
    return this.http.get<ApiResponse<EmployeeMedicalExam[]>>(`${this.url}/employees/${employeeId}/medical-exams`).pipe(
      map((response) => response.data ?? []),
    );
  }

  createMedicalExam(employeeId: number, payload: CreateMedicalExamRequest): Observable<EmployeeMedicalExam> {
    return this.http.post<ApiResponse<EmployeeMedicalExam>>(`${this.url}/employees/${employeeId}/medical-exams`, payload).pipe(
      map((response) => response.data),
    );
  }

  getDocuments(employeeId: number): Observable<EmployeeLaborDocument[]> {
    return this.http.get<ApiResponse<EmployeeLaborDocument[]>>(`${this.url}/employees/${employeeId}/documents`).pipe(
      map((response) => response.data ?? []),
    );
  }

  registerDocument(employeeId: number, payload: RegisterEmployeeDocumentRequest): Observable<EmployeeLaborDocument> {
    return this.http.post<ApiResponse<EmployeeLaborDocument>>(`${this.url}/employees/${employeeId}/documents`, payload).pipe(
      map((response) => response.data),
    );
  }

  getAlerts(days?: number | null): Observable<ContractingAlert[]> {
    const params = days != null ? new HttpParams().set('dias', String(days)) : undefined;
    return this.http.get<ApiResponse<ContractingAlert[]>>(`${this.url}/alerts`, { params }).pipe(
      map((response) => response.data ?? []),
    );
  }
}
