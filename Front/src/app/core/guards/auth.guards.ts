import { inject } from '@angular/core';
import { ActivatedRouteSnapshot, CanActivateChildFn, CanActivateFn, Router } from '@angular/router';
import { AuthService } from '../services/auth.service';

export const authGuard: CanActivateFn = (_route, state) => {
  const auth = inject(AuthService); const router = inject(Router);
  return auth.isAuthenticated() ? true : router.createUrlTree(['/login'], { queryParams: { returnUrl: state.url } });
};

export const guestGuard: CanActivateFn = () => {
  const auth = inject(AuthService); const router = inject(Router);
  return auth.isAuthenticated() ? router.createUrlTree(['/admin/dashboard']) : true;
};

export const permissionGuard: CanActivateFn = (route: ActivatedRouteSnapshot) => {
  const auth = inject(AuthService); const router = inject(Router);
  const permissions = route.data['permissions'] as string[] | undefined;
  return !permissions?.length || auth.hasAnyPermission(permissions) ? true : router.createUrlTree(['/admin/unauthorized']);
};

export const passwordChangeGuard: CanActivateChildFn = (route) => {
  const auth = inject(AuthService); const router = inject(Router);
  const changePending = Boolean(auth.getCurrentUser()?.requiere_cambio_password);
  return !changePending || route.routeConfig?.path === 'change-password'
    ? true
    : router.createUrlTree(['/admin/change-password']);
};
