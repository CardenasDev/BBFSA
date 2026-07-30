import { HttpClient, HttpResponse } from '@angular/common/http';
import { inject, Injectable } from '@angular/core';
import { map, Observable } from 'rxjs';
import { environment } from '../../../environments/environment';
import { ApiResponse } from '../models/api.models';

export interface BulkLoadError {
  row: number;
  field: string;
  message: string;
}

export interface BulkLoadValidation {
  total: number;
  valid: number;
  invalid: number;
  warnings: BulkLoadError[];
  errors: BulkLoadError[];
}

export interface BulkLoadImportResult {
  created: number;
  total: number;
}

@Injectable({ providedIn: 'root' })
export class BulkLoadService {
  private readonly http = inject(HttpClient);
  private readonly url = `${environment.apiUrl}/bulk-load/employees`;

  downloadEmployeeTemplate(): Observable<HttpResponse<Blob>> {
    return this.http.get(`${this.url}/template`, { observe: 'response', responseType: 'blob' });
  }

  validateEmployees(file: File): Observable<BulkLoadValidation> {
    return this.http.post<ApiResponse<BulkLoadValidation>>(`${this.url}/validate`, this.form(file)).pipe(map((response) => response.data));
  }

  importEmployees(file: File): Observable<BulkLoadImportResult> {
    return this.http.post<ApiResponse<BulkLoadImportResult>>(`${this.url}/import`, this.form(file)).pipe(map((response) => response.data));
  }

  private form(file: File): FormData {
    const form = new FormData();
    form.append('file', file, file.name);
    return form;
  }
}
