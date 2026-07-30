import { Component, DestroyRef, HostListener, inject, signal } from '@angular/core';
import { NavigationEnd, Router, RouterLink, RouterLinkActive, RouterOutlet } from '@angular/router';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { filter } from 'rxjs';
import { finalize } from 'rxjs';
import { AuthService } from '../core/services/auth.service';

interface MenuItem {
  label: string;
  icon: string;
  route: string;
  menuKey?: string;
  permissions?: string[];
  children?: MenuItem[];
}

@Component({
  standalone: true,
  imports: [RouterOutlet, RouterLink, RouterLinkActive],
  template: `
    <div class="admin-shell" [class.sidebar-open]="menuOpen()">
      <aside class="sidebar">
        <div class="sidebar-brand"><span class="brand-mark small">BBF</span><div><strong>Barro Blanco</strong><small>Sistema Administrativo</small></div></div>
        <nav>
          @for (item of visibleItems(); track item.route) {
            @if (item.children?.length && item.menuKey) {
              <button
                type="button"
                class="menu-parent"
                (click)="toggleMenu(item.menuKey)"
                [attr.aria-expanded]="isMenuOpen(item.menuKey)"
              >
                <span class="menu-icon">{{ item.icon }}</span>
                <span class="menu-label">{{ item.label }}</span>
                <span class="menu-chevron" aria-hidden="true">{{ isMenuOpen(item.menuKey) ? '⌄' : '›' }}</span>
              </button>
            } @else {
              <a [routerLink]="item.route" routerLinkActive="active" (click)="menuOpen.set(false)"><span>{{ item.icon }}</span>{{ item.label }}</a>
            }
            @if (item.children?.length && item.menuKey && isMenuOpen(item.menuKey)) {
              <div class="submenu" role="group">
                @for (child of item.children; track child.route) {
                  <a [routerLink]="child.route" routerLinkActive="active" (click)="menuOpen.set(false)"><span>{{ child.icon }}</span>{{ child.label }}</a>
                }
              </div>
            }
          }
        </nav>
        <div class="sidebar-footer"><span class="status-dot"></span> Sesion protegida</div>
      </aside>
      <div class="page-shell">
        <header class="topbar">
          <button class="icon-btn menu-toggle" (click)="menuOpen.set(!menuOpen())" aria-label="Abrir menu">☰</button>
          <div class="topbar-title"><strong>Sistema Administrativo</strong><small>Barro Blanco Farms</small></div>
          <div class="user-menu"><div class="avatar">{{ initials() }}</div><div class="user-copy"><strong>{{ auth.currentUser()?.nombre_usuario }}</strong><small>{{ auth.currentUser()?.tipo_usuario }}</small></div><button class="btn ghost" (click)="logout()" [disabled]="loggingOut()">Salir</button></div>
        </header>
        <main class="content"><router-outlet /></main>
      </div>
      @if (menuOpen()) { <button class="overlay" (click)="menuOpen.set(false)" aria-label="Cerrar menu"></button> }
    </div>`,
})
export class AdminLayoutComponent {
  readonly auth = inject(AuthService);
  private readonly router = inject(Router);
  private readonly destroyRef = inject(DestroyRef);
  readonly menuOpen = signal(false);
  readonly openMenu = signal<string | null>(null);
  readonly loggingOut = signal(false);
  private readonly items: MenuItem[] = [
    { label: 'Dashboard', icon: '⌂', route: '/admin/dashboard', permissions: ['DASHBOARD_VER'] },
    { label: 'Aspirantes', icon: 'A', route: '/admin/applicants', permissions: ['ASPIRANTES_VER'] },
    { label: 'Empleados', icon: 'E', route: '/admin/employees', permissions: ['EMPLEADOS_VER'] },
    {
      label: 'Herramientas',
      icon: 'H',
      route: '/admin/tools',
      menuKey: 'tools',
      permissions: ['HERRAMIENTAS_LISTAR', 'HERRAMIENTAS_CREAR', 'HERRAMIENTAS_EDITAR', 'HERRAMIENTAS_ENTREGAR', 'HERRAMIENTAS_ELIMINAR'],
      children: [
        { label: 'Catálogo', icon: 'C', route: '/admin/tools', permissions: ['HERRAMIENTAS_LISTAR'] },
        { label: 'Entregas', icon: 'E', route: '/admin/tool-deliveries', permissions: ['HERRAMIENTAS_LISTAR'] },
        { label: 'Registrar entrega', icon: '+', route: '/admin/tool-deliveries/create', permissions: ['HERRAMIENTAS_ENTREGAR'] },
      ],
    },
    {
      label: 'Dotaciones',
      icon: 'D',
      route: '/admin/dotations/my-sizes',
      menuKey: 'dotations',
      permissions: ['DOTACIONES_VER', 'HERRAMIENTAS_MIS_ENTREGAS_VER', 'DEVOLUCIONES_VER'],
      children: [
        { label: 'Mis tallas', icon: 'M', route: '/admin/dotations/my-sizes', permissions: ['DOTACIONES_MIS_TALLAS_VER'] },
        { label: 'Mis dotaciones', icon: 'D', route: '/admin/dotations/my-deliveries', permissions: ['DOTACIONES_MIS_ENTREGAS_VER'] },
        { label: 'Mis herramientas', icon: 'H', route: '/admin/my-tool-deliveries', permissions: ['HERRAMIENTAS_MIS_ENTREGAS_VER'] },
        { label: 'Control de dotaciones', icon: 'C', route: '/admin/dotations/employees', permissions: ['DOTACIONES_ADMIN_VER'] },
        { label: 'Devoluciones', icon: 'R', route: '/admin/returns', permissions: ['DEVOLUCIONES_VER'] },
      ],
    },
    {
      label: 'Contratacion',
      icon: 'C',
      route: '/admin/contracting',
      menuKey: 'contracting',
      permissions: ['CONTRATACION_VER'],
      children: [
        { label: 'Ficha de ingreso', icon: 'F', route: '/admin/contracting', permissions: ['CONTRATACION_VER'] },
        { label: 'Alertas', icon: 'A', route: '/admin/contracting/alerts', permissions: ['CONTRATACION_ALERTAS_VER'] },
      ],
    },
    { label: 'Usuarios', icon: 'U', route: '/admin/users', permissions: ['USUARIOS_LISTAR', 'USUARIOS_VER'] },
    { label: 'Roles', icon: 'R', route: '/admin/roles', permissions: ['ROLES_LISTAR', 'ROLES_VER'] },
    { label: 'Dominios', icon: 'D', route: '/admin/domains', permissions: ['DOMINIOS_LISTAR'] },
    { label: 'Permisos', icon: 'P', route: '/admin/permissions', permissions: ['PERMISOS_LISTAR', 'PERMISOS_VER'] },
    { label: 'Mi perfil', icon: 'M', route: '/admin/profile', permissions: ['MI_PERFIL_VER'] },
  ];

  constructor() {
    this.updateOpenMenuFromUrl(this.router.url);
    this.router.events
      .pipe(
        filter((event): event is NavigationEnd => event instanceof NavigationEnd),
        takeUntilDestroyed(this.destroyRef),
      )
      .subscribe((event) => this.updateOpenMenuFromUrl(event.urlAfterRedirects));
  }

  visibleItems(): MenuItem[] {
    const visibleItems = this.items
      .filter((item) => !item.permissions || this.auth.hasAnyPermission(item.permissions))
      .map((item) => {
        const children = item.children
          ?.filter((child) => !child.permissions || this.auth.hasAnyPermission(child.permissions))
          .sort((left, right) => this.compareLabels(left, right));
        return { ...item, route: children?.[0]?.route ?? item.route, children };
      })
      .filter((item) => !item.menuKey || !!item.children?.length);

    return visibleItems.sort((left, right) => {
      if (left.route === '/admin/dashboard') return -1;
      if (right.route === '/admin/dashboard') return 1;
      return this.compareLabels(left, right);
    });
  }

  private compareLabels(left: MenuItem, right: MenuItem): number {
    return left.label.localeCompare(right.label, 'es', { sensitivity: 'base' });
  }

  toggleMenu(menu: string): void {
    this.openMenu.update((current) => current === menu ? null : menu);
  }

  isMenuOpen(menu: string): boolean {
    return this.openMenu() === menu;
  }

  private updateOpenMenuFromUrl(url: string): void {
    const path = url.split(/[?#]/, 1)[0];

    if (path === '/admin/tools' || path.startsWith('/admin/tool-deliveries')) {
      this.openMenu.set('tools');
      return;
    }

    if (path.startsWith('/admin/dotations') || path.startsWith('/admin/my-tool-deliveries')) {
      this.openMenu.set('dotations');
      return;
    }

    if (path.startsWith('/admin/contracting')) {
      this.openMenu.set('contracting');
      return;
    }

    this.openMenu.set(null);
  }

  initials(): string {
    return (this.auth.currentUser()?.nombre_usuario ?? 'U').split(/\s+/).slice(0, 2).map((part) => part[0]).join('').toUpperCase();
  }

  logout(): void {
    this.loggingOut.set(true);
    this.auth.logout().pipe(finalize(() => this.loggingOut.set(false))).subscribe({
      next: () => void this.router.navigate(['/login']),
      error: () => void this.router.navigate(['/login']),
    });
  }

  @HostListener('window:resize') onResize(): void {
    if (window.innerWidth > 900) this.menuOpen.set(false);
  }
}
