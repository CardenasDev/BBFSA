import { Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { AuthService } from '../../../core/services/auth.service';
import { KpiService } from '../../../core/services/kpi.service';
import { KpiData, GenderBreakdown } from '../../../core/models/kpi.models';

@Component({
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="page-heading">
      <div>
        <p class="eyebrow">Talento humano</p>
        <h1>KPI — Rotación y Demografía</h1>
        <p class="muted">Indicadores clave de desempeño del personal activo.</p>
      </div>
      <div class="heading-actions">
        @if (auth.hasPermission('EMPLEADOS_KPI_EXPORTAR')) {
          <button class="btn secondary" (click)="exportKpi()" [disabled]="exporting()">
            {{ exporting() ? 'Exportando...' : 'Exportar XLS' }}
          </button>
        }
        <button class="btn primary" (click)="refresh()" [disabled]="loading()">
          {{ loading() ? 'Actualizando...' : 'Actualizar' }}
        </button>
      </div>
    </div>

    @if (error()) {
      <div class="alert error" role="alert">{{ error() }}</div>
    }

    @if (kpi(); as data) {
      <!-- Tarjetas resumen -->
      <section class="kpi-grid">
        <article class="kpi-card primary">
          <div class="kpi-icon">🔄</div>
          <div class="kpi-value">{{ data.tasa_rotacion_3m.toFixed(2) }}%</div>
          <div class="kpi-label">Tasa de Rotación (3m)</div>
          <div class="kpi-detail">
            <span>{{ data.salidas_ultimos_3m }} salidas</span>
            <span>·</span>
            <span>{{ data.promedio_activos_3m.toFixed(1) }} prom. activos</span>
          </div>
        </article>

        <article class="kpi-card secondary">
          <div class="kpi-icon">👥</div>
          <div class="kpi-value">{{ totalActivos() }}</div>
          <div class="kpi-label">Total Activos Hoy</div>
          <div class="kpi-detail">Calculado al {{ data.fecha_calculo }}</div>
        </article>
      </section>

      <!-- Desglose por Género -->
      <section class="panel">
        <h2>Desglose Demográfico (Activos por Género)</h2>
        <div class="table-wrap">
          <table>
            <thead>
              <tr>
                <th>Género</th>
                <th>Total Activos</th>
                <th>Porcentaje</th>
              </tr>
            </thead>
            <tbody>
              @for (g of data.desglose_genero; track g.genero) {
                <tr>
                  <td><strong>{{ g.genero }}</strong></td>
                  <td>{{ g.total_activos }}</td>
                  <td>
                    <div class="progress-bar">
                      <div class="progress-fill" [style.width.%]="genderPct(g.total_activos)"></div>
                    </div>
                    <small>{{ genderPct(g.total_activos).toFixed(1) }}%</small>
                  </td>
                </tr>
              } @empty {
                <tr><td colspan="3" class="empty">Sin datos de género registrados.</td></tr>
              }
            </tbody>
          </table>
        </div>
        <p class="hint">Basado en empleados con ESTADO_EMPLEADO = 'ACTIVO'. Género normalizado desde ficha de ingreso.</p>
      </section>

      <!-- Metadatos -->
      <details class="meta">
        <summary>Detalles técnicos</summary>
        <ul>
          <li>Método: {{ data.metodo_calculo }}</li>
          <li>Fecha de cálculo: {{ data.fecha_calculo }}</li>
          <li>Ventana: últimos 3 meses (rolling)</li>
          <li>Periodo: {{ data.ventana_inicio }} a {{ data.ventana_fin }}</li>
        </ul>
      </details>
    } @else {
      <div class="empty-state">Cargando indicadores...</div>
    }
  `,
  styles: [`
    .heading-actions {
      display: flex;
      flex-wrap: wrap;
      justify-content: flex-end;
      gap: .75rem;
      margin-top: 8px;
    }
    @media (max-width: 640px) {
      .heading-actions {
        width: 100%;
        justify-content: flex-start;
      }
    }
    .kpi-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
      gap: 16px;
      margin: 16px 0;
    }
    .kpi-card {
      background: #fff;
      border: 1px solid #dce5e1;
      border-radius: 14px;
      padding: 20px;
      display: grid;
      gap: 8px;
    }
    .kpi-card.primary {
      border-left: 4px solid #08745b;
    }
    .kpi-card.secondary {
      border-left: 4px solid #3b82f6;
    }
    .kpi-icon {
      font-size: 1.8rem;
    }
    .kpi-value {
      font-size: 2.2rem;
      font-weight: 800;
      color: #183e34;
      line-height: 1;
    }
    .kpi-label {
      color: #607068;
      font-weight: 600;
    }
    .kpi-detail {
      display: flex;
      gap: 8px;
      color: #607068;
      font-size: 0.85rem;
    }
    .progress-bar {
      height: 8px;
      background: #e4ebe7;
      border-radius: 4px;
      overflow: hidden;
      width: 100%;
      max-width: 200px;
    }
    .progress-fill {
      height: 100%;
      background: #08745b;
      border-radius: 4px;
      transition: width 0.3s;
    }
    .meta {
      margin-top: 16px;
      padding: 12px;
      background: #f8faf9;
      border: 1px solid #dce5e1;
      border-radius: 8px;
      font-size: 0.85rem;
      color: #607068;
    }
    .meta summary {
      cursor: pointer;
      font-weight: 600;
      color: #183e34;
    }
    .meta ul {
      margin: 8px 0 0 0;
      padding-left: 20px;
    }
    .meta li {
      margin: 4px 0;
    }
    .empty-state {
      padding: 40px;
      text-align: center;
      color: #607068;
    }
    .hint {
      color: #607068;
      font-size: 0.85rem;
      margin-top: 8px;
    }
  `],
})
export class KpiComponent implements OnInit {
  readonly auth = inject(AuthService);
  private readonly kpiService = inject(KpiService);

  readonly kpi = signal<KpiData | null>(null);
  readonly loading = signal(false);
  readonly exporting = signal(false);
  readonly error = signal('');

  ngOnInit(): void {
    this.load();
  }

  load(): void {
    this.loading.set(true);
    this.error.set('');
    this.kpiService.getRotationAndDemographics().subscribe({
      next: (data) => {
        this.kpi.set(data);
        this.loading.set(false);
      },
      error: (e) => {
        this.error.set(e?.error?.message || 'No fue posible cargar los KPI.');
        this.loading.set(false);
      },
    });
  }

  refresh(): void {
    this.load();
  }

  exportKpi(): void {
    this.exporting.set(true);
    this.kpiService.export().subscribe({
      next: (response) => {
        this.exporting.set(false);
        const blob = response.body;
        if (!blob) return;
        const disposition = response.headers.get('Content-Disposition');
        let filename = 'kpi_rotacion_demografia_' + new Date().toISOString().slice(0,10) + '.xlsx';
        if (disposition) {
          const match = disposition.match(/filename\*=UTF-8''([^;]+)|filename="?([^";]+)"?/i);
          if (match) filename = match[1] || match[2] || filename;
        }
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = filename;
        a.click();
        window.URL.revokeObjectURL(url);
      },
      error: () => {
        this.exporting.set(false);
      },
    });
  }

  totalActivos(): number {
    return this.kpi()?.desglose_genero.reduce((sum, g) => sum + g.total_activos, 0) ?? 0;
  }

  genderPct(value: number): number {
    const total = this.totalActivos();
    return total > 0 ? (value / total) * 100 : 0;
  }
}