import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable, map } from 'rxjs';
import { environment } from '../../../environments/environment';
import {
  ApiResponse,
  ChangeEmployeeStatusPayload,
  Employee,
  EmployeeFilters,
  EmployeePayload,
} from '../models/api.models';

@Injectable({ providedIn: 'root' })
export class EmployeeService {
  private readonly http = inject(HttpClient);
  private readonly url = `${environment.apiUrl}/employees`;

  listEmployees(filters: EmployeeFilters = {}): Observable<Employee[]> {
    let params = new HttpParams();
    Object.entries(filters).forEach(([key, value]) => {
      if (value !== '' && value != null) {
        params = params.set(key, String(value));
      }
    });
    return this.http.get<ApiResponse<Employee[]>>(this.url, { params }).pipe(map((response) => response.data));
  }

  getEmployee(id: number): Observable<Employee> {
    return this.http.get<ApiResponse<Employee>>(`${this.url}/${id}`).pipe(map((response) => response.data));
  }

  getEmployeeByDocument(document: string): Observable<Employee> {
    return this.http.get<ApiResponse<Employee>>(`${this.url}/by-document/${encodeURIComponent(document)}`).pipe(map((response) => response.data));
  }

  createEmployee(payload: EmployeePayload): Observable<Employee> {
    return this.http.post<ApiResponse<Employee>>(this.url, payload).pipe(map((response) => response.data));
  }

  updateEmployee(id: number, payload: EmployeePayload): Observable<Employee> {
    return this.http.patch<ApiResponse<Employee>>(`${this.url}/${id}`, payload).pipe(map((response) => response.data));
  }

  uploadPhoto(employeeId: number, file: File): Observable<{ id_empleado: number; foto_url: string }> {
    const formData = new FormData();
    formData.append('photo', file);

    return this.http.post<ApiResponse<{ id_empleado: number; foto_url: string }>>(`${this.url}/${employeeId}/photo`, formData)
      .pipe(map((response) => response.data));
  }

  changeEmployeeStatus(id: number, payload: ChangeEmployeeStatusPayload): Observable<Employee> {
    return this.http.patch<ApiResponse<Employee>>(`${this.url}/${id}/estado`, payload).pipe(map((response) => response.data));
  }

  deleteEmployee(id: number): Observable<{ id_empleado: number; eliminado: boolean }> {
    return this.http.delete<ApiResponse<{ id_empleado: number; eliminado: boolean }>>(`${this.url}/${id}`).pipe(map((response) => response.data));
  }
}
