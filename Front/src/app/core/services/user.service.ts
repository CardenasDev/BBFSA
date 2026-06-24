import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable, map } from 'rxjs';
import { environment } from '../../../environments/environment';
import { ApiResponse, CreateUserRequest, Permission, Role, User, UserFilters, UserStatus } from '../models/api.models';

@Injectable({ providedIn: 'root' })
export class UserService {
  private readonly http = inject(HttpClient);
  private readonly url = `${environment.apiUrl}/users`;

  listUsers(filters: UserFilters = {}): Observable<User[]> {
    let params = new HttpParams();
    Object.entries(filters).forEach(([key, value]) => { if (value !== '' && value != null) params = params.set(key, String(value)); });
    return this.http.get<ApiResponse<User[]>>(this.url, { params }).pipe(map((r) => r.data));
  }
  getUserById(id: number): Observable<User> { return this.http.get<ApiResponse<User>>(`${this.url}/${id}`).pipe(map((r) => r.data)); }
  createUser(payload: CreateUserRequest): Observable<User> { return this.http.post<ApiResponse<User>>(this.url, payload).pipe(map((r) => r.data)); }
  updateUser(id: number, payload: Partial<User>): Observable<User> { return this.http.patch<ApiResponse<User>>(`${this.url}/${id}`, payload).pipe(map((r) => r.data)); }
  changeUserStatus(id: number, estado: UserStatus): Observable<User> { return this.http.patch<ApiResponse<User>>(`${this.url}/${id}/estado`, { estado }).pipe(map((r) => r.data)); }
  getUserRoles(id: number): Observable<Role[]> { return this.http.get<ApiResponse<Role[]>>(`${this.url}/${id}/roles`).pipe(map((r) => r.data)); }
  getUserPermissions(id: number): Observable<Permission[]> { return this.http.get<ApiResponse<Permission[]>>(`${this.url}/${id}/permissions`).pipe(map((r) => r.data)); }
  assignRole(userId: number, roleId: number): Observable<Role[]> { return this.http.post<ApiResponse<Role[]>>(`${this.url}/${userId}/roles`, { id_rol: roleId }).pipe(map((r) => r.data)); }
  removeRole(userId: number, roleId: number): Observable<Role[]> { return this.http.delete<ApiResponse<Role[]>>(`${this.url}/${userId}/roles/${roleId}`).pipe(map((r) => r.data)); }
}
