import { HttpClient, HttpResponse } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { map, Observable } from 'rxjs';
import { environment } from '../../../environments/environment';
import { ApiResponse } from '../models/api.models';
import { KpiData } from '../models/kpi.models';

@Injectable({ providedIn: 'root' })
export class KpiService {
  private readonly http = inject(HttpClient);
  private readonly url = `${environment.apiUrl}/kpi`;

  getRotationAndDemographics(): Observable<KpiData> {
    return this.http
      .get<ApiResponse<KpiData>>(`${this.url}/rotation-demographics`)
      .pipe(map((r) => r.data));
  }

  export(): Observable<HttpResponse<Blob>> {
    return this.http.get(`${this.url}/export`, {
      responseType: 'blob',
      observe: 'response',
    });
  }
}