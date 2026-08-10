import { CommonModule } from '@angular/common';
import { Component, OnInit, inject, signal } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { finalize } from 'rxjs';
import { TrainingCommitment } from '../../core/models/training.models';
import { TrainingService } from '../../core/services/training.service';
import { apiErrorMessage } from '../../shared/api-error';

@Component({
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="print-view">
      <div class="print-toolbar">
        <button class="btn primary" type="button" (click)="print()">
          Imprimir / Guardar como PDF
        </button>
        <button class="btn" type="button" (click)="goBack()">Volver</button>
      </div>

      @if (error()) {
        <div class="message error">{{ error() }}</div>
      }
      @if (loading()) {
        <div class="message">Cargando carta de compromiso...</div>
      }
      @if (!loading() && commitment(); as data) {
        <article class="commitment-sheet" aria-label="Carta de compromiso evaluativo">
          <table class="document-header" aria-label="Control del formato BBTH-F-013">
            <tbody>
              <tr>
                <td class="logo-cell" rowspan="4">
                  <img src="assets/icon/logo.png" alt="Barro Blanco Farms S.A.S." />
                </td>
                <th class="header-title" rowspan="2">PROCESO DE TALENTO HUMANO</th>
                <td class="header-meta">Código: BBTH – F-013</td>
              </tr>
              <tr>
                <td class="header-meta">Versión: 01</td>
              </tr>
              <tr>
                <th class="header-title" rowspan="2">CARTAS DE COMPROMISO EVALUATIVO</th>
                <td class="header-meta validity">Vigente a partir de:<br />18/06/2026</td>
              </tr>
              <tr>
                <td class="header-meta">Página 1 de 1</td>
              </tr>
            </tbody>
          </table>

          <main class="letter-body">
            <img class="watermark" src="assets/icon/logo.png" alt="" aria-hidden="true" />
            <p>Gachancipá, {{ dateText(data.fecha_compromiso) }}</p>

            <div class="recipient">
              <p>Señor (a).</p>
              <p>
                <strong>{{ data.empleado || data.nombre_completo }}</strong>
              </p>
              <p>{{ data.cargo || 'Trabajador(a)' }}</p>
            </div>

            <h1>REF: Carta de compromiso laboral</h1>

            <p class="justify">
              Por medio de la presente, queremos expresar nuestra preocupación con respecto al
              resultado obtenido en la capacitación <strong>{{ data.capacitacion }}</strong
              >. De acuerdo con la evaluación realizada, el resultado fue
              <strong>{{ resultLabel(data.resultado) }}</strong>
              @if (data.puntaje_final != null) {
                con un puntaje de <strong>{{ data.puntaje_final }}</strong>
              }
              @if (data.puntaje_minimo_aplicado != null) {
                frente a un mínimo requerido de
                <strong>{{ data.puntaje_minimo_aplicado }}</strong>
              }
              .
            </p>

            <p class="justify">
              Dado que valoramos su talento y compromiso con la empresa, queremos brindarle la
              oportunidad de mejorar. Para ello hemos establecido las siguientes medidas correctivas
              y objetivos a cumplir
              @if (data.fecha_limite) {
                hasta el <strong>{{ dateText(data.fecha_limite) }}</strong>
              } @else {
                dentro del plazo definido para las próximas evaluaciones
              }
              .
            </p>

            <ol class="commitment-list">
              @for (line of commitmentLines(data); track $index) {
                <li>{{ line }}</li>
              }
            </ol>

            <p class="justify">
              Nos comprometemos a brindarle el apoyo y las herramientas necesarias para que pueda
              alcanzar estos objetivos, incluyendo capacitaciones, reuniones de seguimiento,
              acompañamiento o las que usted considere necesarias para lograrlo.
            </p>

            <p class="justify">
              Este compromiso tiene como propósito ayudar a mejorar y garantizar un desempeño óptimo
              en la empresa. Sin embargo, si no se evidencia una mejoría en el plazo establecido,
              será necesario adoptar medidas adicionales conforme a la normativa interna y la
              legislación laboral vigente.
            </p>

            <p class="justify">
              Agradecemos su disposición para asumir este compromiso y esperamos ver una mejoría
              significativa en su desempeño. Solicitamos que firme la carta como muestra de acuerdo
              con lo aquí estipulado.
            </p>

            <p>Atentamente,</p>

            <div class="signatures">
              <div>
                <span class="signature-line"></span><strong>Yeisson Prieto</strong><br />Supervisor
                General
              </div>
              <div>
                <span class="signature-line"></span><strong>Firma del trabajador</strong><br />{{
                  data.empleado || data.nombre_completo
                }}
              </div>
            </div>
          </main>

          <footer>
            <table>
              <thead>
                <tr>
                  <th>Versión</th>
                  <th>Fecha</th>
                  <th>Motivo de la revisión</th>
                  <th>Modificación</th>
                  <th>Elaboró</th>
                  <th>Revisó</th>
                  <th>Aprobó</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td>01</td>
                  <td>18/06/2026</td>
                  <td>Creación de formato</td>
                  <td></td>
                  <td>Dayana Santafé</td>
                  <td>Yeisson Prieto<br />Supervisor General</td>
                  <td>Yuliana Villarraga<br />Gerente</td>
                </tr>
              </tbody>
            </table>
          </footer>
        </article>
      }
    </div>
  `,
  styleUrl: './training-commitment-print.component.css',
})
export class TrainingCommitmentPrintComponent implements OnInit {
  private readonly route = inject(ActivatedRoute);
  private readonly api = inject(TrainingService);

  readonly loading = signal(false);
  readonly error = signal('');
  readonly commitment = signal<TrainingCommitment | null>(null);

  ngOnInit(): void {
    const id = Number(this.route.snapshot.paramMap.get('commitmentId'));
    if (!id || Number.isNaN(id)) {
      this.error.set('El identificador del compromiso no es válido.');
      return;
    }
    this.loading.set(true);
    this.api
      .commitment(id)
      .pipe(finalize(() => this.loading.set(false)))
      .subscribe({
        next: (data) => this.commitment.set(data),
        error: (error) =>
          this.error.set(apiErrorMessage(error, 'No fue posible cargar la carta de compromiso.')),
      });
  }

  print(): void {
    window.print();
  }

  goBack(): void {
    window.history.back();
  }

  dateText(value?: string | null): string {
    if (!value) return 'fecha no definida';
    const date = new Date(`${value.slice(0, 10)}T12:00:00`);
    return new Intl.DateTimeFormat('es-CO', {
      day: '2-digit',
      month: 'long',
      year: 'numeric',
    }).format(date);
  }

  resultLabel(value?: string | null): string {
    return (value || 'NO APROBADO').replaceAll('_', ' ');
  }

  commitmentLines(data: TrainingCommitment): string[] {
    const source = data.compromisos_empleado?.trim() || data.motivo?.trim();
    if (!source) return ['Cumplir las medidas y actividades definidas para la próxima evaluación.'];
    return source
      .split(/\r?\n|;/)
      .map((line) => line.replace(/^[-•\d.)\s]+/, '').trim())
      .filter(Boolean);
  }
}
