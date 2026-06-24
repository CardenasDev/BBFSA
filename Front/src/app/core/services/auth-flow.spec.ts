import { provideHttpClient, withInterceptors } from '@angular/common/http';
import { HttpTestingController, provideHttpClientTesting } from '@angular/common/http/testing';
import { TestBed } from '@angular/core/testing';
import { ActivatedRouteSnapshot, Router, RouterStateSnapshot, UrlTree, provideRouter } from '@angular/router';
import { environment } from '../../../environments/environment';
import { LoginResponse } from '../models/api.models';
import { authInterceptor } from '../interceptors/auth.interceptor';
import { passwordChangeGuard } from '../guards/auth.guards';
import { AuthService } from './auth.service';
import { RoleService } from './catalog.service';
import { UserService } from './user.service';

describe('flujo de autenticación', () => {
  let auth: AuthService;
  let users: UserService;
  let roles: RoleService;
  let http: HttpTestingController;

  const loginData: LoginResponse = {
    access_token: 'access-token-test',
    refresh_token: 'refresh-token-test',
    expires_in: 3600,
    usuario: {
      id_usuario: 1,
      nombre_usuario: 'admin',
      correo: 'tester@example.com',
      tipo_usuario: 'ADMIN',
      tipo_autenticacion: 'LOCAL',
      estado: 'ACTIVO',
      requiere_cambio_password: true,
    },
    roles: [{ id_rol: 1, nombre: 'SUPER_ADMIN', activo: 1 }],
    permisos: [{ id_permiso: 1, codigo: 'USUARIOS_CREAR', nombre: 'Crear usuarios', modulo: 'USUARIOS', activo: 1 }],
    requiere_cambio_password: true,
  };

  beforeEach(() => {
    localStorage.clear();
    TestBed.configureTestingModule({
      providers: [
        provideRouter([]),
        provideHttpClient(withInterceptors([authInterceptor])),
        provideHttpClientTesting(),
      ],
    });
    auth = TestBed.inject(AuthService);
    users = TestBed.inject(UserService);
    roles = TestBed.inject(RoleService);
    http = TestBed.inject(HttpTestingController);
  });

  afterEach(() => {
    http.verify();
    localStorage.clear();
  });

  it('guarda la sesión, actualiza la identidad y autoriza la creación de usuarios', () => {
    auth.login(loginData.usuario.correo, 'clave-no-persistida').subscribe();
    const login = http.expectOne(`${environment.apiUrl}/auth/login`);
    expect(login.request.headers.has('Authorization')).toBe(false);
    login.flush({ success: true, message: 'OK', data: loginData });

    expect(localStorage.getItem('access_token')).toBe(loginData.access_token);
    expect(localStorage.getItem('refresh_token')).toBe(loginData.refresh_token);
    expect(JSON.parse(localStorage.getItem('auth_user') ?? '{}').correo).toBe(loginData.usuario.correo);
    expect(JSON.parse(localStorage.getItem('roles') ?? '[]')[0].nombre).toBe('SUPER_ADMIN');
    expect(JSON.parse(localStorage.getItem('permissions') ?? '[]')[0].codigo).toBe('USUARIOS_CREAR');
    const persisted = ['access_token', 'refresh_token', 'auth_user', 'roles', 'permissions']
      .map((key) => localStorage.getItem(key)).join('');
    expect(persisted).not.toContain('clave-no-persistida');

    const router = TestBed.inject(Router);
    const dashboardRoute = { routeConfig: { path: 'dashboard' } } as ActivatedRouteSnapshot;
    const state = {} as RouterStateSnapshot;
    const pendingDecision = TestBed.runInInjectionContext(() => passwordChangeGuard(dashboardRoute, state));
    expect(router.serializeUrl(pendingDecision as UrlTree)).toBe('/admin/change-password');

    users.createUser({
      nombre_usuario: 'prueba', correo: 'prueba@example.com', password: 'Temporal123',
      tipo_usuario: 'ADMIN', tipo_autenticacion: 'LOCAL',
      requiere_cambio_password: true, correo_verificado: true,
    }).subscribe();
    const create = http.expectOne(`${environment.apiUrl}/users`);
    expect(create.request.headers.get('Authorization')).toBe(`Bearer ${loginData.access_token}`);
    create.flush({ success: true, message: 'Creado', data: { ...loginData.usuario, id_usuario: 2 } });

    users.getUserRoles(2).subscribe();
    const currentRoles = http.expectOne(`${environment.apiUrl}/users/2/roles`);
    expect(currentRoles.request.headers.get('Authorization')).toBe(`Bearer ${loginData.access_token}`);
    currentRoles.flush({ success: true, message: 'OK', data: [] });

    roles.listRoles().subscribe();
    const availableRoles = http.expectOne(`${environment.apiUrl}/roles`);
    expect(availableRoles.request.headers.get('Authorization')).toBe(`Bearer ${loginData.access_token}`);
    availableRoles.flush({ success: true, message: 'OK', data: loginData.roles });

    users.assignRole(2, 1).subscribe();
    const assign = http.expectOne(`${environment.apiUrl}/users/2/roles`);
    expect(assign.request.method).toBe('POST');
    expect(assign.request.body).toEqual({ id_rol: 1 });
    expect(assign.request.headers.get('Authorization')).toBe(`Bearer ${loginData.access_token}`);
    assign.flush({ success: true, message: 'Asignado', data: loginData.roles });

    users.getUserPermissions(2).subscribe();
    const permissions = http.expectOne(`${environment.apiUrl}/users/2/permissions`);
    expect(permissions.request.headers.get('Authorization')).toBe(`Bearer ${loginData.access_token}`);
    permissions.flush({ success: true, message: 'OK', data: loginData.permisos });

    users.removeRole(2, 1).subscribe();
    const remove = http.expectOne(`${environment.apiUrl}/users/2/roles/1`);
    expect(remove.request.method).toBe('DELETE');
    expect(remove.request.headers.get('Authorization')).toBe(`Bearer ${loginData.access_token}`);
    remove.flush({ success: true, message: 'Retirado', data: [] });

    auth.changePassword({
      current_password: 'clave-no-persistida', password: 'NuevaClave1', password_confirmation: 'NuevaClave1',
    }).subscribe();
    const change = http.expectOne(`${environment.apiUrl}/auth/change-password`);
    expect(change.request.headers.get('Authorization')).toBe(`Bearer ${loginData.access_token}`);
    change.flush({ success: true, message: 'Actualizada', data: null });

    const me = http.expectOne(`${environment.apiUrl}/auth/me`);
    me.flush({
      success: true,
      message: 'OK',
      data: { ...loginData, usuario: { ...loginData.usuario, requiere_cambio_password: false } },
    });
    expect(auth.getCurrentUser()?.requiere_cambio_password).toBe(false);
    expect(TestBed.runInInjectionContext(() => passwordChangeGuard(dashboardRoute, state))).toBe(true);
  });
});
