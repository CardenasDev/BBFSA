import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable, map } from 'rxjs';
import { environment } from '../../../environments/environment';
import {
  ApiResponse,
  ContractGenerationData,
  ContractTemplate,
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
  SignedEmployeeContract,
  SignEmployeeContractRequest,
} from '../models/api.models';

export interface ContractingEmployeeFilters {
  search?: string;
  area_id?: number | null;
  position_id?: number | null;
  status?: string;
}

export interface ContractTemplateFilters {
  id_tipo_contrato?: number | null;
  solo_activas?: number | boolean | null;
}

export interface CurrentSystemParameter {
  id_parametro: number;
  codigo: string;
  nombre: string;
  valor: string;
  valor_numerico: number;
  vigencia_desde: string;
  vigencia_hasta?: string | null;
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

    return this.http
      .get<ApiResponse<ContractingEmployee[]>>(`${this.url}/employees`, { params })
      .pipe(map((response) => response.data ?? []));
  }

  getProfile(employeeId: number): Observable<ContractingProfile | null> {
    return this.http
      .get<ApiResponse<ContractingProfile | null>>(`${this.url}/employees/${employeeId}/profile`)
      .pipe(map((response) => response.data ?? null));
  }

  getCertificates(employeeId: number): Observable<Record<string, unknown>[]> {
    return this.http
      .get<ApiResponse<Record<string, unknown>[]>>(`${this.url}/employees/${employeeId}/certificates`)
      .pipe(map((response) => response.data ?? []));
  }

  getRetirementCertificates(employeeId: number): Observable<Record<string, unknown>[]> {
    return this.http
      .get<ApiResponse<Record<string, unknown>[]>>(`${this.url}/employees/${employeeId}/certificates/retirement`)
      .pipe(map((response) => response.data ?? []));
  }

  getCertificateGenerationData(
    employeeId: number,
    formatKey: string,
    contractId: number,
    variant = 'GENERAL',
    supplied: { fondo_solidaridad?: string; retencion_fuente?: string; fecha_inicio_labores?: string } | undefined = undefined,
  ): Observable<Record<string, unknown>> {
    if (variant !== 'GENERAL') {
      return this.http.post<ApiResponse<Record<string, unknown>>>(
        `${this.url}/employees/${employeeId}/certificates/${formatKey}/generation-data`,
        { id_empleado_contrato: contractId, variante: variant, ...supplied },
      ).pipe(map((response) => response.data));
    }
    const params = new HttpParams().set('id_empleado_contrato', String(contractId));
    return this.http
      .get<ApiResponse<Record<string, unknown>>>(
        `${this.url}/employees/${employeeId}/certificates/${formatKey}/generation-data`,
        { params },
      )
      .pipe(map((response) => response.data));
  }

  downloadCertificate(
    employeeId: number,
    formatKey: string,
    contractId: number,
    variant = 'GENERAL',
    supplied: { fondo_solidaridad?: string; retencion_fuente?: string; fecha_inicio_labores?: string } | undefined = undefined,
  ): Observable<Blob> {
    if (variant !== 'GENERAL') {
      return this.http.post(`${this.url}/employees/${employeeId}/certificates/${formatKey}/download`,
        { id_empleado_contrato: contractId, variante: variant, ...supplied }, { responseType: 'blob' });
    }
    const params = new HttpParams().set('id_empleado_contrato', String(contractId));
    return this.http.get(
      `${this.url}/employees/${employeeId}/certificates/${formatKey}/download`,
      { params, responseType: 'blob' },
    );
  }

  getRetirementCertificateGenerationData(
    employeeId: number,
    retirementId: number | null,
    supplied: { fondo_solidaridad: string; retencion_fuente: string; auxilio_transporte: string },
  ): Observable<Record<string, unknown>> {
    return this.http.post<ApiResponse<Record<string, unknown>>>(
      `${this.url}/employees/${employeeId}/certificates/retirement/generation-data`,
      { id_retiro: retirementId, ...supplied },
    ).pipe(map((response) => response.data));
  }

  downloadRetirementCertificate(
    employeeId: number,
    retirementId: number | null,
    supplied: { fondo_solidaridad: string; retencion_fuente: string; auxilio_transporte: string },
  ): Observable<Blob> {
    return this.http.post(
      `${this.url}/employees/${employeeId}/certificates/retirement/download`,
      { id_retiro: retirementId, ...supplied },
      { responseType: 'blob' },
    );
  }

  getChecklistCertificates(employeeId: number): Observable<Record<string, unknown>[]> {
    return this.http
      .get<ApiResponse<Record<string, unknown>[]>>(`${this.url}/employees/${employeeId}/certificates/checklist`)
      .pipe(map((response) => response.data ?? []));
  }

  getChecklistGenerationData(employeeId: number, retirementId: number | null): Observable<Record<string, unknown>> {
    return this.http.post<ApiResponse<Record<string, unknown>>>(
      `${this.url}/employees/${employeeId}/certificates/checklist/generation-data`,
      { id_retiro: retirementId },
    ).pipe(map((response) => response.data));
  }

  downloadChecklist(employeeId: number, retirementId: number | null): Observable<Blob> {
    return this.http.post(
      `${this.url}/employees/${employeeId}/certificates/checklist/download`,
      { id_retiro: retirementId },
      { responseType: 'blob' },
    );
  }

  getAcceptanceCertificates(employeeId: number): Observable<Record<string, unknown>[]> {
    return this.http
      .get<ApiResponse<Record<string, unknown>[]>>(`${this.url}/employees/${employeeId}/certificates/acceptance`)
      .pipe(map((response) => response.data ?? []));
  }

  getAcceptanceGenerationData(
    employeeId: number,
    retirementId: number | null,
    supplied: { fecha_presentacion_renuncia: string },
  ): Observable<Record<string, unknown>> {
    return this.http.post<ApiResponse<Record<string, unknown>>>(
      `${this.url}/employees/${employeeId}/certificates/acceptance/generation-data`,
      { id_retiro: retirementId, ...supplied },
    ).pipe(map((response) => response.data));
  }

  downloadAcceptance(
    employeeId: number,
    retirementId: number | null,
    supplied: { fecha_presentacion_renuncia: string },
  ): Observable<Blob> {
    return this.http.post(
      `${this.url}/employees/${employeeId}/certificates/acceptance/download`,
      { id_retiro: retirementId, ...supplied },
      { responseType: 'blob' },
    );
  }

  getCesantiasCertificates(employeeId: number): Observable<Record<string, unknown>[]> {
    return this.http
      .get<ApiResponse<Record<string, unknown>[]>>(`${this.url}/employees/${employeeId}/certificates/cesantias`)
      .pipe(map((response) => response.data ?? []));
  }

  getCesantiasGenerationData(
    employeeId: number,
    supplied: { modalidad: string; concepto_retiro: string; monto_retiro: string },
  ): Observable<Record<string, unknown>> {
    return this.http.post<ApiResponse<Record<string, unknown>>>(
      `${this.url}/employees/${employeeId}/certificates/cesantias/generation-data`,
      supplied,
    ).pipe(map((response) => response.data));
  }

  downloadCesantias(
    employeeId: number,
    supplied: { modalidad: string; concepto_retiro: string; monto_retiro: string },
  ): Observable<Blob> {
    return this.http.post(
      `${this.url}/employees/${employeeId}/certificates/cesantias/download`,
      supplied,
      { responseType: 'blob' },
    );
  }

  getCesantiasTerminationCertificates(employeeId: number): Observable<Record<string, unknown>[]> {
    return this.http
      .get<ApiResponse<Record<string, unknown>[]>>(`${this.url}/employees/${employeeId}/certificates/cesantias-fin-contrato`)
      .pipe(map((response) => response.data ?? []));
  }

  getCesantiasTerminationGenerationData(
    employeeId: number,
    supplied: { fecha_desde: string; fecha_hasta: string; nit_empresa: string; correo_contacto: string; telefono_contacto: string },
  ): Observable<Record<string, unknown>> {
    return this.http.post<ApiResponse<Record<string, unknown>>>(
      `${this.url}/employees/${employeeId}/certificates/cesantias-fin-contrato/generation-data`,
      supplied,
    ).pipe(map((response) => response.data));
  }

  downloadCesantiasTermination(
    employeeId: number,
    supplied: { fecha_desde: string; fecha_hasta: string; nit_empresa: string; correo_contacto: string; telefono_contacto: string },
  ): Observable<Blob> {
    return this.http.post(
      `${this.url}/employees/${employeeId}/certificates/cesantias-fin-contrato/download`,
      supplied,
      { responseType: 'blob' },
    );
  }

  getNonRenewalCertificates(employeeId: number): Observable<Record<string, unknown>[]> {
    return this.http
      .get<ApiResponse<Record<string, unknown>[]>>(`${this.url}/employees/${employeeId}/certificates/non-renewal`)
      .pipe(map((response) => response.data ?? []));
  }

  getNonRenewalGenerationData(
    employeeId: number,
    contractId: number,
    supplied: { nit_empresa: string },
  ): Observable<Record<string, unknown>> {
    return this.http.post<ApiResponse<Record<string, unknown>>>(
      `${this.url}/employees/${employeeId}/certificates/non-renewal/generation-data`,
      { id_empleado_contrato: contractId, ...supplied },
    ).pipe(map((response) => response.data));
  }

  downloadNonRenewal(
    employeeId: number,
    contractId: number,
    supplied: { nit_empresa: string },
  ): Observable<Blob> {
    return this.http.post(
      `${this.url}/employees/${employeeId}/certificates/non-renewal/download`,
      { id_empleado_contrato: contractId, ...supplied },
      { responseType: 'blob' },
    );
  }

  saveProfile(
    employeeId: number,
    payload: SaveContractingProfileRequest,
  ): Observable<ContractingProfile> {
    return this.http
      .post<ApiResponse<ContractingProfile>>(`${this.url}/employees/${employeeId}/profile`, payload)
      .pipe(map((response) => response.data));
  }

  getContractTemplates(filters: ContractTemplateFilters = {}): Observable<ContractTemplate[]> {
    let params = new HttpParams();
    if (filters.id_tipo_contrato)
      params = params.set('id_tipo_contrato', String(filters.id_tipo_contrato));
    if (filters.solo_activas !== undefined && filters.solo_activas !== null)
      params = params.set('solo_activas', String(filters.solo_activas));

    return this.http
      .get<ApiResponse<ContractTemplate[]>>(`${this.url}/contract-templates`, { params })
      .pipe(map((response) => response.data ?? []));
  }

  getMinimumSalary(date: string): Observable<CurrentSystemParameter> {
    const params = new HttpParams().set('fecha', date);
    return this.http
      .get<ApiResponse<CurrentSystemParameter>>(`${this.url}/parameters/minimum-salary`, { params })
      .pipe(map((response) => response.data));
  }

  getContracts(employeeId: number): Observable<EmployeeContract[]> {
    return this.http
      .get<ApiResponse<EmployeeContract[]>>(`${this.url}/employees/${employeeId}/contracts`)
      .pipe(map((response) => response.data ?? []));
  }

  getEmployeeContracts(employeeId: number): Observable<EmployeeContract[]> {
    return this.getContracts(employeeId);
  }

  createContract(
    employeeId: number,
    payload: CreateEmployeeContractRequest,
  ): Observable<EmployeeContract> {
    return this.http
      .post<ApiResponse<EmployeeContract>>(`${this.url}/employees/${employeeId}/contracts`, payload)
      .pipe(map((response) => response.data));
  }

  createEmployeeContract(
    employeeId: number,
    payload: CreateEmployeeContractRequest,
  ): Observable<EmployeeContract> {
    return this.createContract(employeeId, payload);
  }

  updateEmployeeContract(employeeId: number, employeeContractId: number, payload: CreateEmployeeContractRequest): Observable<EmployeeContract> {
    return this.http.put<ApiResponse<EmployeeContract>>(`${this.url}/employees/${employeeId}/contracts/${employeeContractId}`, payload)
      .pipe(map((response) => response.data));
  }

  deleteEmployeeContract(employeeId: number, employeeContractId: number): Observable<void> {
    return this.http
      .delete<ApiResponse<unknown>>(`${this.url}/employees/${employeeId}/contracts/${employeeContractId}`)
      .pipe(map(() => undefined));
  }

  signContract(
    employeeContractId: number,
    payload: SignEmployeeContractRequest,
  ): Observable<SignedEmployeeContract> {
    const formData = new FormData();
    formData.append('fecha_firma', payload.fecha_firma);
    formData.append('origen', payload.origen);

    if (payload.origen === 'ARCHIVO' && payload.archivo) {
      formData.append('archivo', payload.archivo, payload.archivo.name);
    }
    if (payload.origen === 'URL' && payload.url?.trim()) {
      formData.append('url', payload.url.trim());
    }
    if (payload.nombre_archivo?.trim()) {
      formData.append('nombre_archivo', payload.nombre_archivo.trim());
    }
    if (payload.observaciones?.trim()) {
      formData.append('observaciones', payload.observaciones.trim());
    }

    return this.http
      .post<
        ApiResponse<SignedEmployeeContract>
      >(`${this.url}/contracts/${employeeContractId}/sign`, formData)
      .pipe(map((response) => response.data));
  }

  getContractGenerationData(employeeContractId: number): Observable<ContractGenerationData> {
    return this.http
      .get<
        ApiResponse<ContractGenerationData>
      >(`${this.url}/contracts/${employeeContractId}/generation-data`)
      .pipe(map((response) => response.data));
  }

  getSocialSecurity(employeeId: number): Observable<EmployeeSocialSecurity | null> {
    return this.http
      .get<
        ApiResponse<EmployeeSocialSecurity | null>
      >(`${this.url}/employees/${employeeId}/social-security`)
      .pipe(map((response) => response.data ?? null));
  }

  saveSocialSecurity(
    employeeId: number,
    payload: SaveSocialSecurityRequest,
  ): Observable<EmployeeSocialSecurity> {
    return this.http
      .post<
        ApiResponse<EmployeeSocialSecurity>
      >(`${this.url}/employees/${employeeId}/social-security`, payload)
      .pipe(map((response) => response.data));
  }

  getMedicalExams(employeeId: number): Observable<EmployeeMedicalExam[]> {
    return this.http
      .get<ApiResponse<EmployeeMedicalExam[]>>(`${this.url}/employees/${employeeId}/medical-exams`)
      .pipe(map((response) => response.data ?? []));
  }

  createMedicalExam(
    employeeId: number,
    payload: CreateMedicalExamRequest | FormData,
  ): Observable<EmployeeMedicalExam> {
    return this.http
      .post<
        ApiResponse<EmployeeMedicalExam>
      >(`${this.url}/employees/${employeeId}/medical-exams`, payload)
      .pipe(map((response) => response.data));
  }

  updateMedicalExam(employeeId: number, examId: number, payload: CreateMedicalExamRequest | FormData): Observable<EmployeeMedicalExam> {
    return this.http.post<ApiResponse<EmployeeMedicalExam>>(
      `${this.url}/employees/${employeeId}/medical-exams/${examId}`,
      payload,
    ).pipe(map((response) => response.data));
  }

  deleteMedicalExam(employeeId: number, examId: number): Observable<void> {
    return this.http.delete<ApiResponse<unknown>>(
      `${this.url}/employees/${employeeId}/medical-exams/${examId}`,
    ).pipe(map(() => undefined));
  }

  getDocuments(employeeId: number): Observable<EmployeeLaborDocument[]> {
    return this.http
      .get<ApiResponse<EmployeeLaborDocument[]>>(`${this.url}/employees/${employeeId}/documents`)
      .pipe(map((response) => response.data ?? []));
  }

  registerDocument(
    employeeId: number,
    payload: RegisterEmployeeDocumentRequest | FormData,
  ): Observable<EmployeeLaborDocument> {
    return this.http
      .post<
        ApiResponse<EmployeeLaborDocument>
      >(`${this.url}/employees/${employeeId}/documents`, payload)
      .pipe(map((response) => response.data));
  }

  updateDocument(employeeId: number, documentId: number, payload: RegisterEmployeeDocumentRequest | FormData): Observable<EmployeeLaborDocument> {
    return this.http.post<ApiResponse<EmployeeLaborDocument>>(
      `${this.url}/employees/${employeeId}/documents/${documentId}`,
      payload,
    ).pipe(map((response) => response.data));
  }

  deleteDocument(employeeId: number, documentId: number): Observable<void> {
    return this.http.delete<ApiResponse<unknown>>(
      `${this.url}/employees/${employeeId}/documents/${documentId}`,
    ).pipe(map(() => undefined));
  }

  downloadDocument(employeeId: number, documentId: number): Observable<Blob> {
    return this.http.get(`${this.url}/employees/${employeeId}/documents/${documentId}/file`, {
      responseType: 'blob',
    });
  }

  getContractAlerts(diasAntes?: number | null): Observable<ContractingAlert[]> {
    const params =
      diasAntes != null ? new HttpParams().set('dias_antes', String(diasAntes)) : undefined;
    return this.http
      .get<ApiResponse<ContractingAlert[]>>(`${this.url}/alerts`, { params })
      .pipe(map((response) => response.data ?? []));
  }

}
