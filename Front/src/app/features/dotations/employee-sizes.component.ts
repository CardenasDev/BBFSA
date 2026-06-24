import { Component, OnInit, inject, signal } from '@angular/core';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { finalize } from 'rxjs';
import { EmployeeDotationSize } from '../../core/models/api.models';
import { DotationService } from '../../core/services/dotation.service';
import { apiErrorMessage } from '../../shared/api-error';

@Component({
  standalone: true,
  imports: [RouterLink],
  template: `
    <div class="page-heading">
      <div>
        <p class="eyebrow">Dotaciones</p>
        <h1>Tallas de empleado</h1>
        <p class="muted">{{ employeeName() || 'Consulta solo lectura de tallas registradas.' }}</p>
      </div>
      <a class="btn ghost" routerLink="/admin/dotations/employees">Volver</a>
    </div>

    <section class="panel">
      @if (error()) { <div class="alert error">{{ error() }} <button class="btn small ghost" type="button" (click)="load()" [disabled]="loading()">Reintentar</button></div> }
      <div class="table-wrap">
        <table>
          <thead><tr><th>Documento</th><th>Nombre completo</th><th>Tipo dotacion</th><th>Talla</th><th>Observaciones</th><th>Ultima actualizacion</th></tr></thead>
          <tbody>
            @for (size of sizes(); track size.id_tipo_dotacion) {
              <tr>
                <td><strong>{{ size.numero_documento }}</strong></td>
                <td>{{ size.nombre_completo }}</td>
                <td>{{ size.tipo_dotacion }}</td>
                <td>{{ size.talla || 'Sin talla' }}</td>
                <td>{{ size.observaciones || 'Sin observaciones' }}</td>
                <td>{{ size.updated_at || size.created_at || 'Sin fecha' }}</td>
              </tr>
            } @empty {
              <tr><td colspan="6" class="empty">{{ loading() ? 'Cargando tallas...' : 'No se encontraron tallas para este empleado.' }}</td></tr>
            }
          </tbody>
        </table>
      </div>
    </section>
  `,
})
export class EmployeeDotationSizesComponent implements OnInit {
  private readonly route = inject(ActivatedRoute);
  private readonly service = inject(DotationService);
  readonly sizes = signal<EmployeeDotationSize[]>([]);
  readonly loading = signal(false);
  readonly error = signal('');
  private employeeId = 0;

  ngOnInit(): void {
    this.employeeId = Number(this.route.snapshot.paramMap.get('employeeId'));
    this.load();
  }

  employeeName(): string {
    return this.sizes()[0]?.nombre_completo ?? '';
  }

  load(): void {
    if (!this.employeeId) {
      this.error.set('Empleado no valido.');
      return;
    }
    this.loading.set(true);
    this.error.set('');
    this.service.getEmployeeSizes(this.employeeId).pipe(finalize(() => this.loading.set(false))).subscribe({
      next: (sizes) => this.sizes.set(sizes),
      error: (error) => this.error.set(apiErrorMessage(error, 'No fue posible cargar las tallas del empleado.')),
    });
  }
}
