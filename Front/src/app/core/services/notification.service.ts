import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { map } from 'rxjs';
import { environment } from '../../../environments/environment';
import { ApiResponse } from '../models/api.models';
import { AppNotification, NotificationSummary } from '../models/notification.models';

@Injectable({ providedIn: 'root' })
export class NotificationService {
  private readonly http = inject(HttpClient);
  private readonly url = `${environment.apiUrl}/notifications`;

  list(unreadOnly = false, limit = 50) {
    const params = new HttpParams().set('unread_only', String(unreadOnly)).set('limit', String(limit));
    return this.http.get<ApiResponse<AppNotification[]>>(this.url, { params }).pipe(map((response) => response.data));
  }

  summary() {
    return this.http.get<ApiResponse<NotificationSummary>>(`${this.url}/summary`).pipe(map((response) => response.data));
  }

  markRead(id: number, read: boolean) {
    return this.http.patch<ApiResponse<unknown>>(`${this.url}/${id}/read`, { read }).pipe(map((response) => response.data));
  }

  archive(id: number) {
    return this.http.patch<ApiResponse<null>>(`${this.url}/${id}/archive`, {}).pipe(map((response) => response.data));
  }

  resolve(id: number) {
    return this.http.patch<ApiResponse<unknown>>(`${this.url}/${id}/resolve`, {}).pipe(map((response) => response.data));
  }

}
