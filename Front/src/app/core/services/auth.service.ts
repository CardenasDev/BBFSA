import { HttpClient } from '@angular/common/http';
import { Injectable, computed, inject, signal } from '@angular/core';
import { Observable, catchError, map, switchMap, tap, throwError } from 'rxjs';
import { environment } from '../../../environments/environment';
import {
  ApiResponse, AuthUser, ChangePasswordRequest, LoginResponse, MeResponse,
  Permission, Role, TokenResponse,
} from '../models/api.models';

const KEYS = {
  access: 'access_token', refresh: 'refresh_token', user: 'auth_user',
  roles: 'roles', permissions: 'permissions',
} as const;

@Injectable({ providedIn: 'root' })
export class AuthService {
  private readonly http = inject(HttpClient);
  private readonly userState = signal<AuthUser | null>(this.read<AuthUser>(KEYS.user));
  private readonly roleState = signal<Role[]>(this.read<Role[]>(KEYS.roles) ?? []);
  private readonly permissionState = signal<Permission[]>(this.read<Permission[]>(KEYS.permissions) ?? []);

  readonly currentUser = this.userState.asReadonly();
  readonly roles = this.roleState.asReadonly();
  readonly permissions = this.permissionState.asReadonly();
  readonly authenticated = computed(() => !!this.getAccessToken() && !!this.userState());

  login(usuario: string, password: string): Observable<LoginResponse> {
    return this.http.post<ApiResponse<LoginResponse>>(`${environment.apiUrl}/auth/login`, { usuario, password })
      .pipe(map((response) => response.data), tap((data) => this.storeLogin(data)));
  }

  logout(): Observable<void> {
    return this.http.post<ApiResponse<null>>(`${environment.apiUrl}/auth/logout`, {}).pipe(
      map(() => undefined), catchError((error) => { this.clearSession(); return throwError(() => error); }),
      tap(() => this.clearSession()),
    );
  }

  logoutAll(): Observable<void> {
    return this.http.post<ApiResponse<null>>(`${environment.apiUrl}/auth/logout-all`, {}).pipe(
      map(() => undefined), tap(() => this.clearSession()),
    );
  }

  refreshToken(): Observable<TokenResponse> {
    const refresh_token = this.getRefreshToken();
    if (!refresh_token) return throwError(() => new Error('No hay refresh token.'));
    return this.http.post<ApiResponse<TokenResponse>>(`${environment.apiUrl}/auth/refresh`, { refresh_token }).pipe(
      map((response) => response.data), tap((tokens) => this.storeTokens(tokens)),
    );
  }

  me(): Observable<MeResponse> {
    return this.http.get<ApiResponse<MeResponse>>(`${environment.apiUrl}/auth/me`).pipe(
      map((response) => response.data), tap((data) => this.storeIdentity(data)),
    );
  }

  changePassword(payload: ChangePasswordRequest): Observable<MeResponse> {
    return this.http.post<ApiResponse<null>>(`${environment.apiUrl}/auth/change-password`, payload)
      .pipe(switchMap(() => this.me()));
  }

  isAuthenticated(): boolean { return this.authenticated(); }
  hasPermission(code: string): boolean { return this.permissionState().some((p) => p.codigo === code); }
  hasAnyPermission(codes: string[]): boolean { return codes.some((code) => this.hasPermission(code)); }
  hasRole(name: string): boolean { return this.roleState().some((role) => role.nombre === name); }
  getCurrentUser(): AuthUser | null { return this.userState(); }
  getPermissions(): Permission[] { return this.permissionState(); }
  getRoles(): Role[] { return this.roleState(); }
  getAccessToken(): string | null { return localStorage.getItem(KEYS.access); }
  getRefreshToken(): string | null { return localStorage.getItem(KEYS.refresh); }

  clearSession(): void {
    Object.values(KEYS).forEach((key) => localStorage.removeItem(key));
    this.userState.set(null); this.roleState.set([]); this.permissionState.set([]);
  }

  private storeLogin(data: LoginResponse): void {
    this.storeTokens(data); this.storeIdentity(data);
  }

  private storeTokens(data: TokenResponse): void {
    localStorage.setItem(KEYS.access, data.access_token);
    localStorage.setItem(KEYS.refresh, data.refresh_token);
  }

  private storeIdentity(data: MeResponse): void {
    localStorage.setItem(KEYS.user, JSON.stringify(data.usuario));
    localStorage.setItem(KEYS.roles, JSON.stringify(data.roles));
    localStorage.setItem(KEYS.permissions, JSON.stringify(data.permisos));
    this.userState.set(data.usuario); this.roleState.set(data.roles); this.permissionState.set(data.permisos);
  }

  private read<T>(key: string): T | null {
    try { const value = localStorage.getItem(key); return value ? JSON.parse(value) as T : null; }
    catch { localStorage.removeItem(key); return null; }
  }
}
