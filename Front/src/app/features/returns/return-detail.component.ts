import { Component, OnInit, inject, signal } from '@angular/core';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { finalize } from 'rxjs';
import { ReturnEvidence, ReturnItemCondition, ReturnRecordResponse, ReturnStatus, ReturnType } from '../../core/models/api.models';
import { AuthService } from '../../core/services/auth.service';
import { resolveReturnEvidenceUrl, ReturnService } from '../../core/services/return.service';
import { apiErrorMessage } from '../../shared/api-error';

@Component({
  standalone: true,
  imports: [RouterLink],
  template: `
    <section class="page-header"><div><p class="eyebrow">Devoluciones</p><h1>Detalle de devolución</h1><p class="muted">Consulta de cabecera, elementos y evidencias.</p></div><a class="btn ghost" routerLink="/admin/returns">Volver al historial</a></section>
    @if (error()) { <div class="alert error" role="alert">{{ error() }}</div> }
    @if (success()) { <div class="alert success" role="status">{{ success() }}</div> }
    @if (loading()) { <section class="panel empty" aria-live="polite">Cargando detalle...</section> }
    @else if (record(); as data) {
      <section class="panel">
        <div class="section-title">
          <div><h2>Devolución #{{ data.return.id_devolucion }}</h2><span class="badge" [class.success]="data.return.estado === 'CONFIRMADA'" [class.danger]="data.return.estado === 'ANULADA'" [class.warning]="data.return.estado === 'REGISTRADA'">{{ statusLabel(data.return.estado) }}</span></div>
          <div class="row-actions">
            @if (canConfirm()) { <button class="btn secondary" type="button" [disabled]="confirming() || cancelling()" (click)="confirmReturn()">{{ confirming() ? 'Confirmando...' : 'Confirmar devolución' }}</button> }
            @if (canCancel()) { <button class="btn danger-outline" type="button" [disabled]="confirming() || cancelling()" (click)="cancelReturn()">{{ cancelling() ? 'Anulando...' : 'Anular devolución' }}</button> }
          </div>
        </div>
        <dl class="detail-list">
          <dt>Tipo</dt><dd>{{ typeLabel(data.return.tipo_devolucion) }}</dd>
          <dt>Empleado</dt><dd>{{ data.return.empleado || data.return.nombre_completo || 'Empleado #' + data.return.id_empleado }}</dd>
          <dt>Documento</dt><dd>{{ data.return.numero_documento || '—' }}</dd>
          <dt>Fecha devolución</dt><dd>{{ data.return.fecha_devolucion }}</dd>
          <dt>Entrega original</dt><dd>#{{ data.return.id_entrega }}</dd>
          <dt>Motivo</dt><dd>{{ data.return.motivo || '—' }}</dd>
          <dt>Observaciones</dt><dd>{{ data.return.observaciones || '—' }}</dd>
          <dt>Fecha de registro</dt><dd>{{ data.return.fecha_registro || '—' }}</dd>
          <dt>Fecha de confirmación</dt><dd>{{ data.return.fecha_confirmacion || '—' }}</dd>
          @if (data.return.estado === 'ANULADA') {
            <dt>Fecha de anulación</dt><dd>{{ data.return.fecha_anulacion || '—' }}</dd>
            <dt>Motivo de anulación</dt><dd>{{ data.return.motivo_anulacion || '—' }}</dd>
          }
        </dl>
      </section>

      <section class="panel"><div class="section-title"><h2>Elementos devueltos</h2></div><div class="table-wrap"><table>
        <thead><tr><th>Elemento</th><th>Talla</th><th>Cantidad</th><th>Estado físico</th><th>Observaciones</th></tr></thead>
        <tbody>@for (detail of data.details; track detail.id_devolucion_detalle || detail.id_detalle) {
          <tr><td>{{ detail.elemento }}</td><td>{{ detail.talla || '—' }}</td><td>{{ detail.cantidad_devuelta ?? detail.cantidad ?? '—' }}</td><td>{{ conditionLabel(detail.estado_elemento) }}</td><td>{{ detail.observaciones || '—' }}</td></tr>
        } @empty { <tr><td colspan="5" class="empty">No hay detalles registrados.</td></tr> }</tbody>
      </table></div></section>

      <section class="panel"><div class="section-title"><h2>Evidencias</h2></div><div class="evidence-grid">
        @for (evidence of data.evidence; track evidence.id_evidencia || evidence.nombre_archivo) {
          <article class="evidence-card">
            @if (isImage(evidence) && evidenceUrl(evidence); as url) { <img [src]="url" [alt]="'Evidencia ' + evidenceName(evidence)" /> }
            <div><strong>{{ evidenceName(evidence) }}</strong><small>{{ evidence.mime_type || 'Tipo no informado' }} · {{ fileSize(evidence.peso_bytes) }}</small><small>{{ evidence.fecha_carga || '' }}</small></div>
            @if (evidenceUrl(evidence); as url) { <a class="btn small ghost" [href]="url" target="_blank" rel="noopener noreferrer">Abrir</a> }
          </article>
        } @empty { <p class="empty">No hay evidencias registradas.</p> }
      </div></section>
    }
  `,
  styles: [`
    .detail-list{display:grid;grid-template-columns:minmax(140px,220px) 1fr;gap:.65rem 1rem}.detail-list dt{font-weight:700;color:var(--muted)}.detail-list dd{margin:0}
    .evidence-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(260px,1fr));gap:.75rem}.evidence-card{display:grid;grid-template-columns:72px 1fr auto;align-items:center;gap:.75rem;border:1px solid var(--line);border-radius:12px;padding:.75rem}.evidence-card img{width:72px;height:72px;object-fit:cover;border-radius:8px}.evidence-card small{display:block;color:var(--muted);margin-top:.2rem}
    @media(max-width:700px){.detail-list{grid-template-columns:1fr}.detail-list dd{margin-bottom:.5rem}}
  `],
})
export class ReturnDetailComponent implements OnInit {
  readonly auth = inject(AuthService);
  private readonly service = inject(ReturnService);
  private readonly route = inject(ActivatedRoute);
  readonly record = signal<ReturnRecordResponse | null>(null);
  readonly loading = signal(false);
  readonly confirming = signal(false);
  readonly cancelling = signal(false);
  readonly error = signal('');
  readonly success = signal('');
  private returnId = 0;

  ngOnInit(): void {
    this.returnId = Number(this.route.snapshot.paramMap.get('id'));
    this.success.set(history.state?.message ?? '');
    this.load();
  }

  load(): void {
    this.loading.set(true); this.error.set('');
    this.service.getReturnById(this.returnId).pipe(finalize(() => this.loading.set(false))).subscribe({
      next: (record) => this.record.set(record),
      error: (error) => this.error.set(apiErrorMessage(error, 'No fue posible consultar la devolución.')),
    });
  }

  canConfirm(): boolean { return this.record()?.return.estado === 'REGISTRADA' && this.auth.hasPermission('DEVOLUCIONES_CONFIRMAR'); }
  canCancel(): boolean { return this.record()?.return.estado !== 'ANULADA' && this.auth.hasPermission('DEVOLUCIONES_ANULAR'); }

  confirmReturn(): void {
    if (!this.canConfirm() || !window.confirm('¿Confirmas la recepción de esta devolución?\\n\\nUna vez confirmada, la devolución quedará registrada como recibida.')) return;
    this.confirming.set(true); this.error.set(''); this.success.set('');
    this.service.confirmReturn(this.returnId).pipe(finalize(() => this.confirming.set(false))).subscribe({
      next: () => { this.updateStatus('CONFIRMADA'); this.success.set('Devolución confirmada correctamente.'); },
      error: (error) => this.error.set(apiErrorMessage(error, 'No fue posible confirmar la devolución.')),
    });
  }

  cancelReturn(): void {
    if (!this.canCancel()) return;
    const reason = window.prompt('La devolución será anulada, pero su información y evidencias se conservarán.\\n\\nIndica el motivo de anulación:')?.trim() ?? '';
    if (!reason) { this.error.set('El motivo de anulación es obligatorio.'); return; }
    if (reason.length > 500) { this.error.set('El motivo de anulación no puede superar 500 caracteres.'); return; }
    this.cancelling.set(true); this.error.set(''); this.success.set('');
    this.service.cancelReturn(this.returnId, reason).pipe(finalize(() => this.cancelling.set(false))).subscribe({
      next: () => {
        this.record.update((current) => current ? { ...current, return: { ...current.return, estado: 'ANULADA', motivo_anulacion: reason } } : current);
        this.success.set('Devolución anulada correctamente.');
      },
      error: (error) => this.error.set(apiErrorMessage(error, 'No fue posible anular la devolución.')),
    });
  }

  evidenceUrl(evidence: ReturnEvidence): string | null { return resolveReturnEvidenceUrl(evidence); }
  evidenceName(evidence: ReturnEvidence): string { return evidence.nombre_original || evidence.nombre_archivo || 'Evidencia'; }
  isImage(evidence: ReturnEvidence): boolean { return evidence.mime_type?.startsWith('image/') ?? false; }
  fileSize(bytes?: number | null): string { if (!bytes) return 'Tamaño no informado'; return bytes < 1048576 ? `${Math.max(1, Math.round(bytes / 1024))} KB` : `${(bytes / 1048576).toFixed(1)} MB`; }
  typeLabel(type: ReturnType): string { return type === 'DOTACION' ? 'Dotación' : 'Herramienta'; }
  statusLabel(status: ReturnStatus): string { return ({ REGISTRADA: 'Registrada', CONFIRMADA: 'Confirmada', ANULADA: 'Anulada' })[status]; }
  conditionLabel(condition: ReturnItemCondition): string { return ({ BUENO: 'Bueno', USADO: 'Usado', DETERIORADO: 'Deteriorado', DANADO: 'Dañado', INCOMPLETO: 'Incompleto', NO_FUNCIONAL: 'No funcional' })[condition]; }

  private updateStatus(status: ReturnStatus): void {
    this.record.update((current) => current ? { ...current, return: { ...current.return, estado: status } } : current);
  }
}
