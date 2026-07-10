import { Component, OnInit, inject, signal } from '@angular/core';
import { NgClass } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { finalize, forkJoin } from 'rxjs';
import { Applicant, ApplicantStatus, Area, Position } from '../../core/models/api.models';
import { ApplicantService } from '../../core/services/applicant.service';
import { AuthService } from '../../core/services/auth.service';
import { CatalogService } from '../../core/services/catalog.service';
import { apiErrorMessage } from '../../shared/api-error';
import {
  APPLICANT_STATUSES,
  MANUAL_APPLICANT_STATUSES,
  applicantName,
  applicantStatusClass,
  blankToNull,
  canApproveApplicant,
  canConvertApplicant,
  toNullableNumber,
} from './applicant-utils';

@Component({
  standalone: true,
  imports: [FormsModule, NgClass, RouterLink],
  template: `
    <div class="page-heading">
      <div>
        <p class="eyebrow">Recursos humanos</p>
        <h1>Aspirantes</h1>
        <p class="muted">Inicio del proceso de contratacion antes de crear el empleado.</p>
      </div>
      @if (auth.hasPermission('ASPIRANTES_CREAR')) {
        <a class="btn primary" routerLink="/admin/applicants/create">Registrar aspirante</a>
      }
    </div>

    <section class="panel">
      <form class="filters applicants-filters" (ngSubmit)="load()">
        <label>Buscar
          <input name="search" [(ngModel)]="search" placeholder="Documento, nombre, correo, area o cargo" />
        </label>
        <label>Estado
          <select name="status" [(ngModel)]="status">
            <option value="">Todos</option>
            @for (item of statuses; track item) { <option [value]="item">{{ item }}</option> }
          </select>
        </label>
        <label>Area
          <select name="area" [(ngModel)]="areaId">
            <option [ngValue]="null">Todas</option>
            @for (area of areas(); track area.id_area) { <option [ngValue]="area.id_area">{{ area.nombre }}</option> }
          </select>
        </label>
        <label>Cargo
          <select name="position" [(ngModel)]="positionId">
            <option [ngValue]="null">Todos</option>
            @for (position of positions(); track position.id_cargo) { <option [ngValue]="position.id_cargo">{{ position.nombre }}</option> }
          </select>
        </label>
        <button class="btn secondary" type="submit" [disabled]="loading()">Filtrar</button>
      </form>

      @if (success()) { <div class="alert success">{{ success() }}</div> }
      @if (error()) { <div class="alert error">{{ error() }} <button class="btn small ghost" type="button" (click)="load()" [disabled]="loading()">Reintentar</button></div> }

      <div class="table-wrap">
        <table>
          <thead>
            <tr>
              <th>Documento</th>
              <th>Nombre completo</th>
              <th>Correo</th>
              <th>Telefono</th>
              <th>Area aspirada</th>
              <th>Cargo aspirado</th>
              <th>Estado</th>
              <th>Documentos</th>
              <th>Fecha registro</th>
              <th>Acciones</th>
            </tr>
          </thead>
          <tbody>
            @for (applicant of applicants(); track applicant.id_aspirante) {
              <tr>
                <td><strong>{{ applicant.numero_documento }}</strong><small class="muted">{{ applicant.tipo_documento || displayId(applicant.id_tipo_documento) }}</small></td>
                <td>{{ name(applicant) }}</td>
                <td>{{ applicant.correo || 'Sin correo' }}</td>
                <td>{{ applicant.telefono || 'Sin telefono' }}</td>
                <td>{{ applicant.area_aspira || displayId(applicant.id_area_aspira) }}</td>
                <td>{{ applicant.cargo_aspira || displayId(applicant.id_cargo_aspira) }}</td>
                <td><span class="badge" [ngClass]="statusClass(applicant.estado_aspirante)">{{ applicant.estado_aspirante }}</span></td>
                <td>
                  <strong>{{ applicant.total_documentos ?? 0 }}</strong>
                  <small class="muted">Pendientes {{ applicant.documentos_pendientes ?? 0 }}</small>
                </td>
                <td>{{ applicant.created_at || 'Sin fecha' }}</td>
                <td>
                  <div class="row-actions">
                    @if (auth.hasPermission('ASPIRANTES_VER')) { <a class="btn small ghost" [routerLink]="['/admin/applicants', applicant.id_aspirante]">Ver</a> }
                    @if (auth.hasPermission('ASPIRANTES_EDITAR')) { <a class="btn small secondary" [routerLink]="['/admin/applicants', applicant.id_aspirante, 'edit']">Editar</a> }
                    @if (auth.hasPermission('ASPIRANTES_DOCUMENTOS_VER')) { <a class="btn small ghost" [routerLink]="['/admin/applicants', applicant.id_aspirante, 'documents']">Documentos</a> }
                    @if (auth.hasPermission('ASPIRANTES_VER')) { <a class="btn small ghost" [routerLink]="['/admin/applicants', applicant.id_aspirante, 'history']">Historial</a> }
                    @if (auth.hasPermission('ASPIRANTES_CAMBIAR_ESTADO')) { <button class="btn small tertiary" type="button" (click)="openStatus(applicant)">Estado</button> }
                    @if (auth.hasPermission('ASPIRANTES_APROBAR_CONTRATACION') && canApprove(applicant)) {
                      <button class="btn small secondary" type="button" (click)="openApprove(applicant)">Aprobar</button>
                    }
                    @if (auth.hasPermission('ASPIRANTES_CONVERTIR_EMPLEADO') && canConvert(applicant)) {
                      <a class="btn small primary" [routerLink]="['/admin/applicants', applicant.id_aspirante, 'convert']">Convertir</a>
                    }
                  </div>
                </td>
              </tr>
            } @empty {
              <tr><td colspan="10" class="empty">{{ loading() ? 'Cargando aspirantes...' : 'No se encontraron aspirantes.' }}</td></tr>
            }
          </tbody>
        </table>
      </div>
    </section>

    @if (statusApplicant(); as applicant) {
      <button class="drawer-backdrop" type="button" aria-label="Cerrar cambio de estado" (click)="closeStatus()"></button>
      <aside class="role-drawer" aria-label="Cambiar estado del aspirante" aria-modal="true">
        <header class="drawer-header">
          <div><p class="eyebrow">Estado aspirante</p><h2>Cambiar estado</h2></div>
          <button class="icon-btn close-btn" type="button" (click)="closeStatus()" aria-label="Cerrar">x</button>
        </header>
        <div class="drawer-user">
          <div class="avatar large">{{ initials(applicant) }}</div>
          <div><strong>{{ name(applicant) }}</strong><small>{{ applicant.numero_documento }}</small><span class="badge" [ngClass]="statusClass(applicant.estado_aspirante)">{{ applicant.estado_aspirante }}</span></div>
        </div>
        @if (statusError()) { <div class="alert error">{{ statusError() }}</div> }
        <form class="narrow-form" (ngSubmit)="saveStatus()">
          <label>Nuevo estado
            <select name="estado_aspirante" [(ngModel)]="statusForm.estado_aspirante">
              @for (item of manualStatuses; track item) { <option [value]="item">{{ item }}</option> }
            </select>
          </label>
          <label>Observaciones<textarea rows="4" name="observaciones" [(ngModel)]="statusForm.observaciones"></textarea></label>
          <div class="form-actions">
            <button class="btn secondary" type="button" (click)="closeStatus()" [disabled]="savingStatus()">Cancelar</button>
            <button class="btn primary" type="submit" [disabled]="savingStatus()">{{ savingStatus() ? 'Guardando...' : 'Actualizar estado' }}</button>
          </div>
        </form>
      </aside>
    }

    @if (approveApplicant(); as applicant) {
      <button class="drawer-backdrop" type="button" aria-label="Cerrar aprobacion" (click)="closeApprove()"></button>
      <aside class="role-drawer" aria-label="Aprobar aspirante" aria-modal="true">
        <header class="drawer-header">
          <div><p class="eyebrow">Aprobacion</p><h2>Aprobar para contratacion</h2></div>
          <button class="icon-btn close-btn" type="button" (click)="closeApprove()" aria-label="Cerrar">x</button>
        </header>
        <p><strong>Deseas aprobar este aspirante para iniciar el proceso de contratacion?</strong></p>
        <p class="muted">{{ name(applicant) }} - {{ applicant.numero_documento }}</p>
        @if (approveError()) { <div class="alert error">{{ approveError() }}</div> }
        <form class="narrow-form" (ngSubmit)="approve()">
          <label>Observaciones<textarea rows="4" name="approve_observaciones" [(ngModel)]="approveObservations"></textarea></label>
          <div class="form-actions">
            <button class="btn secondary" type="button" (click)="closeApprove()" [disabled]="approving()">Cancelar</button>
            <button class="btn primary" type="submit" [disabled]="approving()">{{ approving() ? 'Aprobando...' : 'Aprobar' }}</button>
          </div>
        </form>
      </aside>
    }
  `,
})
export class ApplicantsListComponent implements OnInit {
  readonly auth = inject(AuthService);
  private readonly service = inject(ApplicantService);
  private readonly catalogs = inject(CatalogService);
  readonly applicants = signal<Applicant[]>([]);
  readonly areas = signal<Area[]>([]);
  readonly positions = signal<Position[]>([]);
  readonly loading = signal(false);
  readonly error = signal('');
  readonly success = signal('');
  readonly statusApplicant = signal<Applicant | null>(null);
  readonly approveApplicant = signal<Applicant | null>(null);
  readonly savingStatus = signal(false);
  readonly approving = signal(false);
  readonly statusError = signal('');
  readonly approveError = signal('');
  readonly statuses = APPLICANT_STATUSES;
  readonly manualStatuses = MANUAL_APPLICANT_STATUSES;
  search = '';
  status: ApplicantStatus | '' = '';
  areaId: number | null = null;
  positionId: number | null = null;
  approveObservations = 'Aprobado por RRHH para iniciar contratacion';
  statusForm: { estado_aspirante: ApplicantStatus; observaciones: string | null } = { estado_aspirante: 'EN_REVISION', observaciones: null };

  ngOnInit(): void {
    this.loadCatalogs();
    this.load();
  }

  load(): void {
    this.loading.set(true);
    this.error.set('');
    this.service.getApplicants({
      search: this.search.trim(),
      status: this.status,
      area_id: toNullableNumber(this.areaId),
      position_id: toNullableNumber(this.positionId),
    }).pipe(finalize(() => this.loading.set(false))).subscribe({
      next: (applicants) => this.applicants.set(applicants ?? []),
      error: (error) => this.error.set(apiErrorMessage(error, 'No fue posible cargar los aspirantes.')),
    });
  }

  loadCatalogs(): void {
    forkJoin({ areas: this.catalogs.getAreas(), positions: this.catalogs.getPositions() }).subscribe({
      next: ({ areas, positions }) => {
        this.areas.set(areas);
        this.positions.set(positions);
      },
      error: () => {
        this.areas.set([]);
        this.positions.set([]);
      },
    });
  }

  openStatus(applicant: Applicant): void {
    this.statusError.set('');
    this.statusApplicant.set(applicant);
    this.statusForm = {
      estado_aspirante: applicant.estado_aspirante === 'CONVERTIDO_EMPLEADO' ? 'EN_REVISION' : applicant.estado_aspirante,
      observaciones: null,
    };
  }

  closeStatus(): void {
    if (this.savingStatus()) return;
    this.statusApplicant.set(null);
  }

  saveStatus(): void {
    const applicant = this.statusApplicant();
    if (!applicant) return;
    this.savingStatus.set(true);
    this.statusError.set('');
    this.success.set('');
    this.service.changeStatus(applicant.id_aspirante, {
      estado_aspirante: this.statusForm.estado_aspirante,
      observaciones: blankToNull(this.statusForm.observaciones),
    }).pipe(finalize(() => this.savingStatus.set(false))).subscribe({
      next: () => {
        this.success.set('Estado del aspirante actualizado correctamente.');
        this.closeStatus();
        this.load();
      },
      error: (error) => this.statusError.set(apiErrorMessage(error, 'No fue posible cambiar el estado.')),
    });
  }

  openApprove(applicant: Applicant): void {
    this.approveError.set('');
    this.approveApplicant.set(applicant);
    this.approveObservations = 'Aprobado por RRHH para iniciar contratacion';
  }

  closeApprove(): void {
    if (this.approving()) return;
    this.approveApplicant.set(null);
  }

  approve(): void {
    const applicant = this.approveApplicant();
    if (!applicant) return;
    this.approving.set(true);
    this.approveError.set('');
    this.success.set('');
    this.service.approveForContracting(applicant.id_aspirante, blankToNull(this.approveObservations) ?? undefined)
      .pipe(finalize(() => this.approving.set(false))).subscribe({
        next: () => {
          this.success.set('Aspirante aprobado para contratacion correctamente.');
          this.closeApprove();
          this.load();
        },
        error: (error) => this.approveError.set(apiErrorMessage(error, 'No fue posible aprobar para contratacion.')),
      });
  }

  name(applicant: Applicant): string {
    return applicantName(applicant);
  }

  initials(applicant: Applicant): string {
    return this.name(applicant).split(/\s+/).slice(0, 2).map((part) => part[0]).join('').toUpperCase();
  }

  statusClass(status: ApplicantStatus): string {
    return applicantStatusClass(status);
  }

  canApprove(applicant: Applicant): boolean {
    return canApproveApplicant(applicant);
  }

  canConvert(applicant: Applicant): boolean {
    return canConvertApplicant(applicant);
  }

  displayId(value?: number | null): string {
    return value ? `ID ${value}` : 'Sin dato';
  }
}
