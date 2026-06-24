import { HttpContextToken, HttpErrorResponse, HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { Router } from '@angular/router';
import { BehaviorSubject, catchError, filter, finalize, switchMap, take, throwError } from 'rxjs';
import { environment } from '../../../environments/environment';
import { AuthService } from '../services/auth.service';

let refreshing = false;
const refreshedToken$ = new BehaviorSubject<string | null>(null);
const IS_RETRY = new HttpContextToken(() => false);

export const authInterceptor: HttpInterceptorFn = (request, next) => {
  const auth = inject(AuthService);
  const router = inject(Router);
  const isApi = request.url.startsWith(environment.apiUrl);
  const isPublicAuth = request.url.endsWith('/auth/login') || request.url.endsWith('/auth/refresh');
  const token = auth.getAccessToken();
  const authorized = isApi && !isPublicAuth && token
    ? request.clone({ setHeaders: { Authorization: `Bearer ${token}` } }) : request;

  return next(authorized).pipe(catchError((error: HttpErrorResponse) => {
    if (error.status !== 401 || !isApi || isPublicAuth || request.context.get(IS_RETRY)) return throwError(() => error);
    if (!refreshing) {
      refreshing = true; refreshedToken$.next(null);
      return auth.refreshToken().pipe(
        switchMap((tokens) => { refreshedToken$.next(tokens.access_token); return next(request.clone({ context: request.context.set(IS_RETRY, true), setHeaders: { Authorization: `Bearer ${tokens.access_token}` } })); }),
        catchError((refreshError) => { auth.clearSession(); void router.navigate(['/login']); return throwError(() => refreshError); }),
        finalize(() => { refreshing = false; }),
      );
    }
    return refreshedToken$.pipe(filter((value): value is string => !!value), take(1), switchMap((newToken) => next(request.clone({ context: request.context.set(IS_RETRY, true), setHeaders: { Authorization: `Bearer ${newToken}` } }))));
  }));
};
