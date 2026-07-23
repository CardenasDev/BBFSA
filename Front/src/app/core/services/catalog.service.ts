import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable, map } from 'rxjs';
import { environment } from '../../../environments/environment';
import { ApiResponse, Area, ContractType, DocumentType, Domain, HealthStatus, LaborDocumentType, Permission, Position, Role } from '../models/api.models';

@Injectable({ providedIn: 'root' })
export class RoleService {
  private readonly http = inject(HttpClient);

  listRoles(): Observable<Role[]> {
    return this.http.get<ApiResponse<Role[]>>(`${environment.apiUrl}/roles`).pipe(map((r) => r.data));
  }

  createRole(payload: { nombre: string; descripcion?: string | null }): Observable<Role> {
    return this.http.post<ApiResponse<Role>>(`${environment.apiUrl}/roles`, payload).pipe(map((r) => r.data));
  }

  changeRoleState(roleId: number, estado: 'ACTIVO' | 'INACTIVO'): Observable<Role> {
    return this.http.patch<ApiResponse<Role>>(`${environment.apiUrl}/roles/${roleId}/estado`, { activo: estado === 'ACTIVO' }).pipe(map((r) => r.data));
  }

  deleteRole(roleId: number): Observable<{ id_rol: number; eliminado: boolean }> {
    return this.http.delete<ApiResponse<{ id_rol: number; eliminado: boolean }>>(`${environment.apiUrl}/roles/${roleId}`).pipe(map((r) => r.data));
  }

  getRolePermissions(roleId: number): Observable<Permission[]> {
    return this.http.get<ApiResponse<Permission[]>>(`${environment.apiUrl}/roles/${roleId}/permissions`).pipe(map((r) => r.data));
  }

  assignRolePermission(roleId: number, permissionId: number): Observable<Permission[]> {
    return this.http.post<ApiResponse<Permission[]>>(`${environment.apiUrl}/roles/${roleId}/permissions`, { id_permiso: permissionId }).pipe(map((r) => r.data));
  }

  removeRolePermission(roleId: number, permissionId: number): Observable<Permission[]> {
    return this.http.delete<ApiResponse<Permission[]>>(`${environment.apiUrl}/roles/${roleId}/permissions/${permissionId}`).pipe(map((r) => r.data));
  }
}

@Injectable({ providedIn: 'root' })
export class DomainService {
  private readonly http = inject(HttpClient);

  listDomains(): Observable<Domain[]> {
    return this.http.get<ApiResponse<Domain[]>>(`${environment.apiUrl}/domains`).pipe(map((r) => r.data));
  }

  createDomain(payload: { dominio: string }): Observable<Domain> {
    return this.http.post<ApiResponse<Domain>>(`${environment.apiUrl}/domains`, payload).pipe(map((r) => r.data));
  }

  changeDomainState(domainId: number, estado: 'ACTIVO' | 'INACTIVO'): Observable<Domain> {
    return this.http.patch<ApiResponse<Domain>>(`${environment.apiUrl}/domains/${domainId}/estado`, { activo: estado === 'ACTIVO' }).pipe(map((r) => r.data));
  }
}

@Injectable({ providedIn: 'root' })
export class PermissionService {
  private readonly http = inject(HttpClient);
  listPermissions(module = ''): Observable<Permission[]> {
    const params = module ? new HttpParams().set('modulo', module) : undefined;
    return this.http.get<ApiResponse<Permission[]>>(`${environment.apiUrl}/permissions`, { params }).pipe(map((r) => r.data));
  }
}

@Injectable({ providedIn: 'root' })
export class CatalogService {
  private readonly http = inject(HttpClient);

  getDocumentTypes(soloActivos = true): Observable<DocumentType[]> {
    const params = new HttpParams().set('solo_activos', String(soloActivos));
    return this.http.get<ApiResponse<DocumentType[]>>(`${environment.apiUrl}/catalogs/document-types`, { params }).pipe(
      map((response) => response.data ?? []),
    );
  }

  getAreas(soloActivos = true): Observable<Area[]> {
    const params = new HttpParams().set('solo_activos', String(soloActivos));
    return this.http.get<ApiResponse<Area[]>>(`${environment.apiUrl}/catalogs/areas`, { params }).pipe(
      map((response) => response.data ?? []),
    );
  }

  getPositions(soloActivos = true): Observable<Position[]> {
    const params = new HttpParams().set('solo_activos', String(soloActivos));
    return this.http.get<ApiResponse<Position[]>>(`${environment.apiUrl}/catalogs/positions`, { params }).pipe(
      map((response) => response.data ?? []),
    );
  }

  getContractTypes(soloActivos = true): Observable<ContractType[]> {
    const params = new HttpParams().set('solo_activos', String(soloActivos));
    return this.http.get<ApiResponse<ContractType[]>>(`${environment.apiUrl}/catalogs/contract-types`, { params }).pipe(
      map((response) => response.data ?? []),
    );
  }

  getLaborDocumentTypesForApplicants(): Observable<LaborDocumentType[]> {
    const params = new HttpParams()
      .set('active', '1')
      .set('applies_applicant', '1');

    return this.http.get<ApiResponse<LaborDocumentType[]>>(`${environment.apiUrl}/catalogs/labor-document-types`, { params }).pipe(
      map((response) => response.data ?? []),
    );
  }

  getLaborDocumentTypesForContracting(): Observable<LaborDocumentType[]> {
    const params = new HttpParams()
      .set('active', '1')
      .set('applies_contracting', '1');

    return this.http.get<ApiResponse<LaborDocumentType[]>>(`${environment.apiUrl}/catalogs/labor-document-types`, { params }).pipe(
      map((response) => response.data ?? []),
    );
  }
}

@Injectable({ providedIn: 'root' })
export class HealthService {
  private readonly http = inject(HttpClient);
  check(): Observable<HealthStatus> { return this.http.get<ApiResponse<HealthStatus>>(`${environment.apiUrl}/health`).pipe(map((r) => r.data)); }
}
