import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable, map } from 'rxjs';
import { environment } from '../../../environments/environment';
import {
  ApiResponse,
  Area,
  Position,
  ContractType,
  DocumentType,
  LaborDocumentType,
  MedicalExamType,
  DotationArticle,
  SocialSecurityType,
  ParametersSocialSecurityEntity,
  SaveSocialSecurityEntityPayload,
  UniformItemFamily,
  SaveDotationArticleRequest,
  SystemParameter,
  SaveSystemParameterPayload,
} from '../models/api.models';

@Injectable({ providedIn: 'root' })
export class ParametersService {
  private readonly http = inject(HttpClient);
  private readonly base = `${environment.apiUrl}/parameters`;

  listAreas(): Observable<Area[]> {
    return this.http.get<ApiResponse<Area[]>>(`${this.base}/areas`).pipe(map((r) => r.data ?? []));
  }

  createArea(payload: { nombre: string; descripcion?: string | null }): Observable<Area> {
    return this.http.post<ApiResponse<Area>>(`${this.base}/areas`, payload).pipe(map((r) => r.data));
  }

  updateArea(id: number, payload: { nombre: string; descripcion?: string | null; activo?: boolean }): Observable<Area> {
    return this.http.put<ApiResponse<Area>>(`${this.base}/areas/${id}`, payload).pipe(map((r) => r.data));
  }

  listPositions(): Observable<Position[]> {
    return this.http.get<ApiResponse<Position[]>>(`${this.base}/positions`).pipe(map((r) => r.data ?? []));
  }

  createPosition(payload: { nombre: string; descripcion?: string | null }): Observable<Position> {
    return this.http.post<ApiResponse<Position>>(`${this.base}/positions`, payload).pipe(map((r) => r.data));
  }

  updatePosition(id: number, payload: { nombre: string; descripcion?: string | null; activo?: boolean }): Observable<Position> {
    return this.http.put<ApiResponse<Position>>(`${this.base}/positions/${id}`, payload).pipe(map((r) => r.data));
  }

  getUniformItemFamilies(): Observable<UniformItemFamily[]> {
    return this.http.get<ApiResponse<UniformItemFamily[]>>(`${this.base}/uniform-item-families`).pipe(map((r) => r.data ?? []));
  }

  /* Contract types */
  listContractTypes(): Observable<ContractType[]> {
    return this.http.get<ApiResponse<ContractType[]>>(`${this.base}/contract-types`).pipe(map((r) => r.data ?? []));
  }

  createContractType(payload: { nombre: string; descripcion?: string | null }): Observable<ContractType> {
    return this.http.post<ApiResponse<ContractType>>(`${this.base}/contract-types`, payload).pipe(map((r) => r.data));
  }

  updateContractType(id: number, payload: { nombre: string; descripcion?: string | null; activo?: boolean }): Observable<ContractType> {
    return this.http.put<ApiResponse<ContractType>>(`${this.base}/contract-types/${id}`, payload).pipe(map((r) => r.data));
  }

  /* Document types */
  listDocumentTypes(): Observable<DocumentType[]> {
    return this.http.get<ApiResponse<DocumentType[]>>(`${this.base}/document-types`).pipe(map((r) => r.data ?? []));
  }

  createDocumentType(payload: { nombre: string; descripcion?: string | null }): Observable<DocumentType> {
    return this.http.post<ApiResponse<DocumentType>>(`${this.base}/document-types`, payload).pipe(map((r) => r.data));
  }

  updateDocumentType(id: number, payload: { nombre: string; descripcion?: string | null; activo?: boolean }): Observable<DocumentType> {
    return this.http.put<ApiResponse<DocumentType>>(`${this.base}/document-types/${id}`, payload).pipe(map((r) => r.data));
  }

  /* Labor document types */
  listLaborDocumentTypes(): Observable<LaborDocumentType[]> {
    return this.http.get<ApiResponse<LaborDocumentType[]>>(`${this.base}/labor-document-types`).pipe(map((r) => r.data ?? []));
  }

  createLaborDocument(payload: Partial<LaborDocumentType> & { nombre: string }): Observable<LaborDocumentType> {
    return this.http.post<ApiResponse<LaborDocumentType>>(`${this.base}/labor-document-types`, payload).pipe(map((r) => r.data));
  }

  updateLaborDocument(id: number, payload: Partial<LaborDocumentType> & { nombre: string }): Observable<LaborDocumentType> {
    return this.http.put<ApiResponse<LaborDocumentType>>(`${this.base}/labor-document-types/${id}`, payload).pipe(map((r) => r.data));
  }

  /* Social security entities */
  listSocialSecurityEntities(type?: SocialSecurityType): Observable<ParametersSocialSecurityEntity[]> {
    const params = type ? new HttpParams().set('type', type) : undefined;
    return this.http.get<ApiResponse<ParametersSocialSecurityEntity[]>>(`${this.base}/social-security-entities`, { params }).pipe(map((r) => r.data ?? []));
  }

  createSocialSecurityEntity(payload: SaveSocialSecurityEntityPayload): Observable<ParametersSocialSecurityEntity> {
    return this.http.post<ApiResponse<ParametersSocialSecurityEntity>>(`${this.base}/social-security-entities`, payload).pipe(map((r) => r.data));
  }

  updateSocialSecurityEntity(id: number, payload: SaveSocialSecurityEntityPayload): Observable<ParametersSocialSecurityEntity> {
    return this.http.put<ApiResponse<ParametersSocialSecurityEntity>>(`${this.base}/social-security-entities/${id}`, payload).pipe(map((r) => r.data));
  }

  /* Medical exam types */
  listMedicalExamTypes(): Observable<any[]> {
    return this.http.get<ApiResponse<any[]>>(`${this.base}/medical-exam-types`).pipe(map((r) => r.data ?? []));
  }

  createMedicalExamType(payload: { nombre: string; descripcion?: string | null }): Observable<any> {
    return this.http.post<ApiResponse<any>>(`${this.base}/medical-exam-types`, payload).pipe(map((r) => r.data));
  }

  updateMedicalExamType(id: number, payload: { nombre: string; descripcion?: string | null; activo?: boolean }): Observable<any> {
    return this.http.put<ApiResponse<any>>(`${this.base}/medical-exam-types/${id}`, payload).pipe(map((r) => r.data));
  }

  /* Uniform items */
  listUniformItems(): Observable<DotationArticle[]> {
    return this.http.get<ApiResponse<DotationArticle[]>>(`${this.base}/uniform-items`).pipe(map((r) => r.data ?? []));
  }

  createUniformItem(payload: SaveDotationArticleRequest): Observable<DotationArticle> {
    return this.http.post<ApiResponse<DotationArticle>>(`${this.base}/uniform-items`, payload).pipe(map((r) => r.data));
  }

  updateUniformItem(id: number, payload: SaveDotationArticleRequest): Observable<DotationArticle> {
    return this.http.put<ApiResponse<DotationArticle>>(`${this.base}/uniform-items/${id}`, payload).pipe(map((r) => r.data));
  }

  /* System parameters */
  listSystemParameters(): Observable<SystemParameter[]> {
    return this.http.get<ApiResponse<SystemParameter[]>>(`${this.base}/system`).pipe(map((r) => r.data ?? []));
  }

  createSystemParameter(payload: SaveSystemParameterPayload): Observable<SystemParameter> {
    return this.http.post<ApiResponse<SystemParameter>>(`${this.base}/system`, payload).pipe(map((r) => r.data));
  }

  updateSystemParameter(id: number, payload: SaveSystemParameterPayload): Observable<SystemParameter> {
    return this.http.put<ApiResponse<SystemParameter>>(`${this.base}/system/${id}`, payload).pipe(map((r) => r.data));
  }
}
