import { CommonModule } from '@angular/common';
import { Component, inject, signal } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { EvaluationManagementPanel } from '../../core/models/evaluation.models';
import { EvaluationService } from '../../core/services/evaluation.service';

@Component({
  standalone: true,
  imports: [CommonModule],
  template: `
    @if (panel(); as p) {
      <header class="page-header">
        <div>
          <h1>Panel gerencial de labores agrícolas</h1>
          <p>Evaluación semana {{ p.evaluation.numero_semana }} · {{ p.evaluation.anio }}</p>
          <span class="badge" [class]="statusClass(p.resumen.estado_consolidado || '')">{{ p.resumen.estado_consolidado || 'En Ejecución' }}</span>
        </div>
        <button class="btn" (click)="back()">Volver a captura</button>
      </header>

      <section class="metrics">
        <article class="metric">
          <span>Total labores ejecutadas</span>
          <strong>{{ p.resumen.total_camas_ejecutadas }}</strong>
        </article>
        <article class="metric">
          <span>Meta total finca</span>
          <strong>{{ p.resumen.total_meta_camas }}</strong>
        </article>
        <article class="metric">
          <span>% Cobertura global</span>
          <strong>{{ p.resumen.porcentaje_cobertura_global ?? 0 }}%</strong>
        </article>
      </section>

      <section class="card">
        <table>
          <thead>
            <tr>
              <th>Labor agrícola</th>
              <th>Camas ejecutadas</th>
              <th>Meta (camas)</th>
              <th>% Avance</th>
              <th>Camas pendientes</th>
              <th>Estado</th>
            </tr>
          </thead>
          <tbody>
            @for (labor of p.labores; track labor.id_evaluacion_labor) {
              <tr>
                <td>{{ labor.nombre }}</td>
                <td>{{ labor.camas_ejecutadas }}</td>
                <td>{{ labor.meta_camas }}</td>
                <td>{{ labor.porcentaje_avance ?? 0 }}%</td>
                <td>{{ labor.camas_pendientes }}</td>
                <td><span class="badge" [class]="statusClass(labor.estado_labor)">{{ labor.estado_labor }}</span></td>
              </tr>
            } @empty {
              <tr><td colspan="6">Sin datos.</td></tr>
            }
          </tbody>
        </table>
      </section>
    } @else if (loading()) {
      <p>Cargando panel gerencial...</p>
    } @else if (error()) {
      <div class="notice bad">{{ error() }}</div>
    }
  `,
  styles: [`
    :host { display:block; }
    .page-header { display:flex; justify-content:space-between; align-items:center; margin-bottom:16px; }
    .metrics { display:grid; grid-template-columns:repeat(3,1fr); gap:12px; margin-bottom:16px; }
    .metric { background:#fff; border:1px solid #dce5e1; border-radius:14px; padding:16px; display:grid; gap:6px; }
    .metric span { color:#607068; }
    .metric strong { font-size:1.6rem; color:#183e34; }
    .card { background:#fff; border:1px solid #dce5e1; border-radius:14px; padding:16px; }
    table { width:100%; border-collapse:collapse; }
    th,td { padding:10px; border-bottom:1px solid #e4ebe7; text-align:left; }
    .btn { padding:8px 12px; border:1px solid #cbd8d2; border-radius:8px; background:#fff; cursor:pointer; }
    .badge { padding:4px 10px; border-radius:999px; font-size:.8rem; font-weight:700; }
    .badge.iniciado { background:#eef2ff; color:#334; }
    .badge.proceso { background:#fff7e6; color:#8a5a00; }
    .badge.completado { background:#e7f7ef; color:#08745b; }
    .badge.sin-iniciar { background:#f1f1f1; color:#607068; }
    .notice { padding:10px; margin:10px 0; border-radius:8px; }
    .notice.bad { background:#fff0f0; color:#a11; }
  `],
})
export class EvaluationManagementPanelComponent {
  private readonly api = inject(EvaluationService);
  private readonly route = inject(ActivatedRoute);
  private readonly router = inject(Router);

  id = Number(this.route.snapshot.paramMap.get('id'));
  panel = signal<EvaluationManagementPanel | null>(null);
  loading = signal(false);
  error = signal('');

  constructor() {
    this.load();
  }

  load(): void {
    this.loading.set(true);
    this.error.set('');
    this.api.getManagementPanel(this.id).subscribe({
      next: (p) => {
        this.panel.set(p);
        this.loading.set(false);
      },
      error: (e) => {
        this.loading.set(false);
        this.error.set(e?.error?.message || 'No fue posible consultar el panel gerencial.');
      },
    });
  }

  back(): void {
    this.router.navigate(['/admin/evaluations', this.id]);
  }

  statusClass(status: string): string {
    const normalized = (status || '').toLowerCase();
    if (normalized.includes('complet') || normalized.includes('cumplida')) return 'completado';
    if (normalized.includes('proceso') || normalized.includes('ejecución') || normalized.includes('ejecucion')) return 'proceso';
    if (normalized.includes('iniciado')) return 'iniciado';
    return 'sin-iniciar';
  }
}
