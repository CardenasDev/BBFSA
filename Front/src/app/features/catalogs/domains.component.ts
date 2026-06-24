import { Component, OnInit, computed, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { finalize } from 'rxjs/operators';
import { AuthService } from '../../core/services/auth.service';
import { DomainService } from '../../core/services/catalog.service';
import { apiErrorMessage } from '../../shared/api-error';
import { Domain } from '../../core/models/api.models';

@Component({
  standalone: true,
  imports: [FormsModule],
  template: `
    <div class="page-heading">
      <div>
        <p class="eyebrow">Control de acceso</p>
        <h1>Dominios autorizados</h1>
        <p class="muted">Administra los dominios permitidos para autenticación corporativa.</p>
      </div>
      @if (auth.hasPermission('DOMINIOS_CREAR')) {
        <button class="btn primary" type="button" (click)="openCreate()">Agregar dominio</button>
      }
    </div>

    <section class="panel">
      @if (error()) { <div class="alert error">{{ error() }}</div> }
      <div class="table-wrap">
        <table>
          <thead>
            <tr><th>Dominio</th><th>Estado</th><th>Acciones</th></tr>
          </thead>
          <tbody>
            @for (domain of domains(); track domain.id_dominio) {
              <tr>
                <td><strong>{{ domain.dominio }}</strong></td>
                <td><span class="badge" [class.success]="domain.activo">{{ domain.activo ? 'ACTIVO' : 'INACTIVO' }}</span></td>
                <td>
                  @if (auth.hasPermission('DOMINIOS_EDITAR')) {
                    <button class="btn small secondary" type="button" (click)="toggleState(domain)" [disabled]="loading()">{{ domain.activo ? 'Inactivar' : 'Activar' }}</button>
                  }
                </td>
              </tr>
            } @empty {
              <tr><td colspan="3" class="empty">Cargando dominios…</td></tr>
            }
          </tbody>
        </table>
      </div>
    </section>

    @if (createOpen()) {
      <section class="panel modal">
        <div class="modal-content">
          <header>
            <h2>Agregar dominio autorizado</h2>
            <button class="icon-btn" type="button" (click)="closeCreate()" aria-label="Cerrar">×</button>
          </header>
          <form (ngSubmit)="createDomain()">
            <label>Dominio
              <input type="text" [(ngModel)]="createForm.dominio" name="dominio" required maxlength="255" />
            </label>
            @if (formError()) { <div class="alert error">{{ formError() }}</div> }
            <div class="modal-actions">
              <button class="btn secondary" type="button" (click)="closeCreate()">Cancelar</button>
              <button class="btn primary" type="submit" [disabled]="loading()">Crear</button>
            </div>
          </form>
        </div>
      </section>
    }
  `,
})
export class DomainsComponent implements OnInit {
  private readonly service = inject(DomainService);
  readonly auth = inject(AuthService);

  readonly domains = signal<Domain[]>([]);
  readonly error = signal('');
  readonly formError = signal('');
  readonly loading = signal(false);
  readonly createOpen = signal(false);
  createForm = { dominio: '' };

  ngOnInit(): void {
    this.loadDomains();
  }

  loadDomains(): void {
    this.error.set('');
    this.service.listDomains().subscribe({
      next: (domains) => this.domains.set(domains),
      error: (error) => this.error.set(apiErrorMessage(error, 'No fue posible cargar los dominios autorizados.')),
    });
  }

  openCreate(): void {
    this.formError.set('');
    this.createForm = { dominio: '' };
    this.createOpen.set(true);
  }

  closeCreate(): void {
    this.createOpen.set(false);
  }

  createDomain(): void {
    const dominio = this.createForm.dominio.trim().toLowerCase().replace(/^@+/, '');
    if (! dominio) {
      this.formError.set('El dominio es obligatorio.');
      return;
    }

    this.loading.set(true);
    this.formError.set('');
    this.service.createDomain({ dominio }).pipe(finalize(() => this.loading.set(false))).subscribe({
      next: () => {
        this.closeCreate();
        this.loadDomains();
      },
      error: (error) => this.formError.set(apiErrorMessage(error, 'No fue posible crear el dominio autorizado.')),
    });
  }

  toggleState(domain: Domain): void {
    const nextState = domain.activo ? 'INACTIVO' : 'ACTIVO';
    if (domain.activo && !confirm(`¿Seguro que deseas inactivar el dominio ${domain.dominio}?`)) {
      return;
    }

    this.loading.set(true);
    this.service.changeDomainState(domain.id_dominio, nextState).pipe(finalize(() => this.loading.set(false))).subscribe({
      next: () => this.loadDomains(),
      error: (error) => this.error.set(apiErrorMessage(error, 'No fue posible cambiar el estado del dominio.')),
    });
  }
}
