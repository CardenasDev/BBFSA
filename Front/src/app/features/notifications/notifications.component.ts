import { Component, OnInit, inject, signal } from '@angular/core';
import { Router } from '@angular/router';
import { finalize } from 'rxjs';
import { AppNotification } from '../../core/models/notification.models';
import { AuthService } from '../../core/services/auth.service';
import { NotificationService } from '../../core/services/notification.service';
import { apiErrorMessage } from '../../shared/api-error';

@Component({
  standalone: true,
  template: `
    <div class="page-heading">
      <div><p class="eyebrow">Seguimiento laboral</p><h1>Notificaciones</h1><p class="muted">Alertas destinadas a tu rol y responsabilidades.</p></div>
      <label class="inline-check"><input type="checkbox" [checked]="unreadOnly()" (change)="toggleUnread($event)"> Solo no leídas</label>
    </div>
    @if (error()) { <div class="alert error">{{ error() }}</div> }
    <section class="stats-grid">
      <article class="stat-card"><span>Activas</span><strong>{{ summary()?.total_activas ?? 0 }}</strong><small>Alertas vigentes</small></article>
      <article class="stat-card"><span>No leídas</span><strong>{{ summary()?.total_no_leidas ?? 0 }}</strong><small>Pendientes de revisión</small></article>
      <article class="stat-card"><span>Críticas</span><strong>{{ summary()?.total_criticas ?? 0 }}</strong><small>Requieren atención prioritaria</small></article>
    </section>
    <section class="panel">
      @if (loading()) { <p class="empty">Cargando notificaciones...</p> }
      @for (item of notifications(); track item.id_notificacion) {
        <article class="notification-row" [class.unread]="!asBool(item.leida)">
          <div class="priority" [attr.data-priority]="item.prioridad"></div>
          <div class="notification-copy">
            <div class="notification-title"><strong>{{ item.titulo }}</strong><span class="badge" [class.danger]="item.prioridad === 'CRITICA'" [class.warning]="item.prioridad === 'ALTA'">{{ item.prioridad }}</span></div>
            <p>{{ item.mensaje }}</p>
            <small>{{ item.modulo }} · {{ item.fecha_vencimiento ? 'Vence ' + item.fecha_vencimiento : 'Generada ' + item.created_at }}</small>
          </div>
          <div class="row-actions">
            @if (item.url_accion) { <button class="btn ghost" (click)="open(item)">Atender</button> }
            <button class="btn ghost" (click)="markRead(item)">{{ asBool(item.leida) ? 'No leída' : 'Leída' }}</button>
            <button class="btn ghost" (click)="archive(item)">Archivar</button>
            @if (auth.hasPermission('NOTIFICACIONES_GESTIONAR')) { <button class="btn" (click)="resolve(item)">Resolver</button> }
          </div>
        </article>
      } @empty { @if (!loading()) { <p class="empty">No tienes notificaciones activas con este filtro.</p> } }
    </section>
  `,
  styles: [`
    .inline-check{display:flex;align-items:center;gap:.5rem}.notification-row{display:grid;grid-template-columns:5px minmax(0,1fr) auto;gap:1rem;align-items:center;padding:1rem 0;border-bottom:1px solid #edf0ee}.notification-row:last-child{border-bottom:0}.notification-row.unread{background:#f7fbf9;margin-inline:-.65rem;padding-inline:.65rem;border-radius:10px}.priority{height:100%;min-height:55px;border-radius:999px;background:#9aa59f}.priority[data-priority='MEDIA']{background:#d39c31}.priority[data-priority='ALTA']{background:#d56d2c}.priority[data-priority='CRITICA']{background:#b93636}.notification-copy p{margin:.35rem 0}.notification-copy small{color:var(--muted)}.notification-title{display:flex;align-items:center;gap:.55rem}.row-actions{flex-wrap:wrap;justify-content:flex-end}@media(max-width:850px){.notification-row{grid-template-columns:5px 1fr}.notification-row .row-actions{grid-column:2;justify-content:flex-start}}
  `],
})
export class NotificationsComponent implements OnInit {
  readonly auth = inject(AuthService);
  private readonly service = inject(NotificationService);
  private readonly router = inject(Router);
  readonly notifications = signal<AppNotification[]>([]);
  readonly summary = signal<import('../../core/models/notification.models').NotificationSummary | null>(null);
  readonly unreadOnly = signal(false);
  readonly loading = signal(false);
  readonly error = signal('');

  ngOnInit(): void { this.load(); }
  asBool(value: boolean | number): boolean { return value === true || value === 1; }
  toggleUnread(event: Event): void { this.unreadOnly.set((event.target as HTMLInputElement).checked); this.load(); }
  open(item: AppNotification): void { if (item.url_accion) { void this.router.navigateByUrl(item.url_accion); if (!this.asBool(item.leida)) this.service.markRead(item.id_notificacion, true).subscribe(); } }
  markRead(item: AppNotification): void { this.service.markRead(item.id_notificacion, !this.asBool(item.leida)).subscribe({ next: () => this.load(), error: (error) => this.error.set(apiErrorMessage(error)) }); }
  archive(item: AppNotification): void { this.service.archive(item.id_notificacion).subscribe({ next: () => this.load(), error: (error) => this.error.set(apiErrorMessage(error)) }); }
  resolve(item: AppNotification): void { this.service.resolve(item.id_notificacion).subscribe({ next: () => this.load(), error: (error) => this.error.set(apiErrorMessage(error)) }); }
  load(): void { this.loading.set(true); this.error.set(''); this.service.list(this.unreadOnly(), 100).pipe(finalize(() => this.loading.set(false))).subscribe({ next: (items) => this.notifications.set(items), error: (error) => this.error.set(apiErrorMessage(error)) }); this.service.summary().subscribe({ next: (summary) => this.summary.set(summary), error: (error) => this.error.set(apiErrorMessage(error)) }); }
}
