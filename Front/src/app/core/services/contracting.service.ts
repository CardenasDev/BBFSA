import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable, map } from 'rxjs';
import { environment } from '../../../environments/environment';
import {
  ApiResponse,
  ContractChargeType,
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
  GenerateContractDocxResponse,
  GenerateContractPdfResponse,
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
  tipo_cargo_contrato?: ContractChargeType | string | null;
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
    if (filters.tipo_cargo_contrato?.trim())
      params = params.set('tipo_cargo_contrato', filters.tipo_cargo_contrato.trim());
    if (filters.solo_activas !== undefined && filters.solo_activas !== null)
      params = params.set('solo_activas', String(filters.solo_activas));

    return this.http
      .get<ApiResponse<ContractTemplate[]>>(`${this.url}/contract-templates`, { params })
      .pipe(map((response) => response.data ?? []));
  }

  getContractTemplate(templateId: number): Observable<ContractTemplate> {
    return this.http
      .get<ApiResponse<ContractTemplate>>(`${this.url}/contract-templates/${templateId}`)
      .pipe(map((response) => response.data));
  }

  getContractTemplateByType(
    idTipoContrato: number,
    tipoCargoContrato?: ContractChargeType | string | null,
  ): Observable<ContractTemplate | null> {
    let params = new HttpParams().set('id_tipo_contrato', String(idTipoContrato));
    if (tipoCargoContrato?.trim())
      params = params.set('tipo_cargo_contrato', tipoCargoContrato.trim());

    return this.http
      .get<
        ApiResponse<ContractTemplate | null>
      >(`${this.url}/contract-templates/by-type`, { params })
      .pipe(map((response) => response.data ?? null));
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

  generateContractDocx(employeeContractId: number): Observable<GenerateContractDocxResponse> {
    return this.http
      .post<
        ApiResponse<GenerateContractDocxResponse>
      >(`${this.url}/contracts/${employeeContractId}/generate-docx`, {})
      .pipe(map((response) => response.data));
  }

  generateContractPdf(employeeContractId: number): Observable<GenerateContractPdfResponse> {
    return this.http
      .post<
        ApiResponse<GenerateContractPdfResponse>
      >(`${this.url}/contracts/${employeeContractId}/generate-pdf`, {})
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
    payload: CreateMedicalExamRequest,
  ): Observable<EmployeeMedicalExam> {
    return this.http
      .post<
        ApiResponse<EmployeeMedicalExam>
      >(`${this.url}/employees/${employeeId}/medical-exams`, payload)
      .pipe(map((response) => response.data));
  }

  getDocuments(employeeId: number): Observable<EmployeeLaborDocument[]> {
    return this.http
      .get<ApiResponse<EmployeeLaborDocument[]>>(`${this.url}/employees/${employeeId}/documents`)
      .pipe(map((response) => response.data ?? []));
  }

  registerDocument(
    employeeId: number,
    payload: RegisterEmployeeDocumentRequest,
  ): Observable<EmployeeLaborDocument> {
    return this.http
      .post<
        ApiResponse<EmployeeLaborDocument>
      >(`${this.url}/employees/${employeeId}/documents`, payload)
      .pipe(map((response) => response.data));
  }

  getContractAlerts(diasAntes?: number | null): Observable<ContractingAlert[]> {
    const params =
      diasAntes != null ? new HttpParams().set('dias_antes', String(diasAntes)) : undefined;
    return this.http
      .get<ApiResponse<ContractingAlert[]>>(`${this.url}/alerts`, { params })
      .pipe(map((response) => response.data ?? []));
  }

  getAlerts(days?: number | null): Observable<ContractingAlert[]> {
    return this.getContractAlerts(days);
  }
}
