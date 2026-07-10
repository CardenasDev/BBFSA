import { Component, OnInit, inject, signal } from '@angular/core';
import { NgClass } from '@angular/common';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { finalize, forkJoin } from 'rxjs';
import { ApplicantDetail, ApplicantStatusHistory } from '../../core/models/api.models';
import { ApplicantService } from '../../core/services/applicant.service';
import { apiErrorMessage } from '../../shared/api-error';
import { applicantName, applicantStatusClass } from './applicant-utils';

@Component({
  standalone: true,
  imports: [NgClass, RouterLink],
  template: `
    <div class="page-heading">
      <div><p class="eyebrow">Aspirantes</p><h1>Historial de estados</h1><p class="muted">Trazabilidad de cambios del aspirante.</p></div>
      <a class="btn ghost" [routerLink]="['/admin/applicants', applicantId]">Volver</a>
    </div>

    @if (applicant(); as current) {
      <section class="panel profile-summary">
        <div class="avatar large">{{ initials(current) }}</div>
        <div>
          <h2>{{ name(current) }}</h2>
          <p class="muted">Documento {{ current.numero_documento }}</p>
        </div>
        <span class="badge" [ngClass]="statusClass(current.estado_aspirante)">{{ current.estado_aspirante }}</span>
      </section>
    }

    <section class="panel">
      <div class="row-actions" style="margin-bottom:1rem">
        <a class="btn small ghost" [routerLink]="['/admin/applicants', applicantId]">Detalle</a>
        <a class="btn small ghost" [routerLink]="['/admin/applicants', applicantId, 'documents']">Documentos</a>
        <a class="btn small secondary" [routerLink]="['/admin/applicants', applicantId, 'history']">Historial</a>
      </div>

      @if (error()) { <div class="alert error">{{ error() }} <button class="btn small ghost" type="button" (click)="load()" [disabled]="loading()">Reintentar</button></div> }

      <div class="table-wrap">
        <table>
          <thead><tr><th>Fecha</th><th>Estado anterior</th><th>Estado nuevo</th><th>Usuario cambio</th><th>Observaciones</th></tr></thead>
          <tbody>
            @for (item of history(); track item.id_historial) {
              <tr>
                <td>{{ item.created_at || 'Sin fecha' }}</td>
                <td><span class="badge" [ngClass]="statusClass(item.estado_anterior)">{{ item.estado_anterior || 'Inicio' }}</span></td>
                <td><span class="badge" [ngClass]="statusClass(item.estado_nuevo)">{{ item.estado_nuevo }}</span></td>
                <td>{{ item.usuario_cambio || displayId(item.id_usuario_cambio) }}</td>
                <td>{{ item.observaciones || 'Sin observaciones' }}</td>
              </tr>
            } @empty {
              <tr><td colspan="5" class="empty">{{ loading() ? 'Cargando historial...' : 'No hay historial de estados.' }}</td></tr>
            }
          </tbody>
        </table>
      </div>
    </section>
  `,
})
export class ApplicantHistoryComponent implements OnInit {
  private readonly route = inject(ActivatedRoute);
  private readonly service = inject(ApplicantService);
  readonly applicant = signal<ApplicantDetail | null>(null);
  readonly history = signal<ApplicantStatusHistory[]>([]);
  readonly loading = signal(false);
  readonly error = signal('');
  applicantId = 0;

  ngOnInit(): void {
    this.applicantId = Number(this.route.snapshot.paramMap.get('applicantId'));
    this.load();
  }

  load(): void {
    this.loading.set(true);
    this.error.set('');
    forkJoin({
      applicant: this.service.getApplicant(this.applicantId),
      history: this.service.getStatusHistory(this.applicantId),
    }).pipe(finalize(() => this.loading.set(false))).subscribe({
      next: ({ applicant, history }) => {
        this.applicant.set(applicant);
        this.history.set(history ?? []);
      },
      error: (error) => this.error.set(apiErrorMessage(error, 'No fue posible cargar el historial.')),
    });
  }

  name(applicant: ApplicantDetail): string {
    return applicantName(applicant);
  }

  initials(applicant: ApplicantDetail): string {
    return this.name(applicant).split(/\s+/).slice(0, 2).map((part) => part[0]).join('').toUpperCase();
  }

  statusClass(status: string | null | undefined): string {
    return applicantStatusClass(status);
  }

  displayId(value?: number | null): string {
    return value ? `ID ${value}` : 'Sin dato';
  }
}
