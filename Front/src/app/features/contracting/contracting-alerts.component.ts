import { Component, OnInit, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { finalize } from 'rxjs';
import { ContractingAlert } from '../../core/models/api.models';
import { ContractingService } from '../../core/services/contracting.service';
import { apiErrorMessage } from '../../shared/api-error';

@Component({
  standalone: true,
  imports: [FormsModule, RouterLink],
  template: `
    <div class="page-heading">
      <div><p class="eyebrow">Contratacion</p><h1>Alertas de contratacion</h1><p class="muted">Contratos, documentos y examenes que requieren atencion.</p></div>
      <a class="btn ghost" routerLink="/admin/contracting">Volver a contratacion</a>
    </div>

    <section class="panel">
      <form class="filters compact" (ngSubmit)="load()">
        <label>Dias antes<input type="number" min="1" max="365" name="days" [(ngModel)]="days" /></label>
        <button class="btn secondary" type="submit" [disabled]="loading()">Consultar</button>
      </form>

      @if (error()) { <div class="alert error">{{ error() }} <button class="btn small ghost" type="button" (click)="load()" [disabled]="loading()">Reintentar</button></div> }

      <div class="table-wrap">
        <table>
          <thead><tr><th>Tipo</th><th>Empleado</th><th>Documento</th><th>Detalle</th><th>Plantilla</th><th>Inicio</th><th>Fin</th><th>Dias</th><th>Area</th><th>Cargo</th><th>Accion</th></tr></thead>
          <tbody>
            @for (alert of alerts(); track alert.tipo_alerta + '-' + alert.id_empleado + '-' + alert.id_referencia) {
              <tr>
                <td>
                  <span class="badge"
                        [class.danger]="isDanger(alert)"
                        [class.warning]="isWarning(alert)"
                        [class.success]="isInfo(alert)">
                    {{ label(alert.tipo_alerta) }}
                  </span>
                </td>
                <td>{{ alert.nombre_completo }}</td>
                <td>{{ alert.numero_documento || 'Sin dato' }}</td>
                <td>
                  @if (isExamAlert(alert)) {
                    <strong>{{ alert.tipo_examen_medico || 'Examen médico' }}</strong>
                    <small class="muted">{{ alert.entidad_realiza || 'Sin entidad' }}</small>
                  } @else {
                    <strong>{{ alert.numero_contrato || 'Sin número' }}</strong>
                    <small class="muted">{{ alert.tipo_contrato || 'Sin tipo' }}</small>
                  }
                </td>
                <td>
                  @if (isExamAlert(alert)) {
                    {{ alert.fecha_examen || '—' }}
                  } @else {
                    {{ alert.nombre_plantilla || 'Sin plantilla' }}
                  }
                </td>
                <td>
                  @if (isExamAlert(alert)) {
                    {{ alert.fecha_vencimiento_examen || 'Sin fecha' }}
                  } @else {
                    {{ alert.fecha_fin || 'Sin fecha' }}
                  }
                </td>
                <td>{{ alert.dias_para_vencer ?? alert.dias_restantes ?? 'Sin dato' }}</td>
                <td>{{ alert.area || 'Sin área' }}</td>
                <td>{{ alert.cargo || 'Sin cargo' }}</td>
                <td><a class="btn small ghost" [routerLink]="['/admin/contracting/employees', alert.id_empleado, routeFor(alert)]">Ver</a></td>
              </tr>
            } @empty {
              <tr><td colspan="11" class="empty">{{ loading() ? 'Cargando alertas...' : 'No hay registros para mostrar.' }}</td></tr>
            }
          </tbody>
        </table>
      </div>
    </section>
  `,
  styles: [`
    .badge.warning {
      background: #f59e0b;
      color: #fff;
    }
  `]
})
export class ContractingAlertsComponent implements OnInit {
  private readonly service = inject(ContractingService);
  readonly alerts = signal<ContractingAlert[]>([]);
  readonly loading = signal(false);
  readonly error = signal('');
  days = 30;

  ngOnInit(): void {
    this.load();
  }

  load(): void {
    const validation = this.validateDays();
    if (validation) {
      this.error.set(validation);
      return;
    }
    this.loading.set(true);
    this.error.set('');
    this.service.getContractAlerts(this.days).pipe(finalize(() => this.loading.set(false))).subscribe({
      next: (alerts) => this.alerts.set(alerts),
      error: (error) => this.error.set(apiErrorMessage(error, 'No fue posible cargar la informacion de contratacion.')),
    });
  }

  label(type: string): string {
    const labels: Record<string, string> = {
      'CONTRATO_VENCIDO': 'Contrato Vencido',
      'CONTRATO_PROXIMO_VENCER': 'Contrato Próximo a Vencer',
      'CONTRATO_VIGENTE': 'Contrato Vigente',
      'EXAMEN_MEDICO_VENCIDO': 'Examen Médico Vencido',
      'EXAMEN_MEDICO_PROXIMO_VENCER': 'Examen Médico Próximo a Vencer',
      'DOCUMENTO_PENDIENTE': 'Documento Pendiente',
    };
    return labels[type] ?? type.replaceAll('_', ' ');
  }

  isDanger(alert: ContractingAlert): boolean {
    return alert.tipo_alerta === 'CONTRATO_VENCIDO' || alert.tipo_alerta === 'EXAMEN_MEDICO_VENCIDO';
  }

  isWarning(alert: ContractingAlert): boolean {
    return alert.tipo_alerta === 'CONTRATO_PROXIMO_VENCER' || alert.tipo_alerta === 'EXAMEN_MEDICO_PROXIMO_VENCER';
  }

  isInfo(alert: ContractingAlert): boolean {
    return alert.tipo_alerta === 'DOCUMENTO_PENDIENTE';
  }

  isExamAlert(alert: ContractingAlert): boolean {
    return alert.tipo_alerta.startsWith('EXAMEN_MEDICO');
  }

  routeFor(alert: ContractingAlert): string {
    if (alert.tipo_alerta.includes('EXAMEN')) return 'medical-exams';
    if (alert.tipo_alerta.includes('DOCUMENTO')) return 'documents';
    return 'contracts';
  }

  private validateDays(): string {
    const value = Number(this.days);
    if (!Number.isInteger(value) || value < 1 || value > 365) return 'Los dias antes deben estar entre 1 y 365.';
    return '';
  }
}
