import { Component, input } from '@angular/core';
import { ContractGenerationData } from '../models/contract-generation.models';

@Component({
  selector: 'app-base-contract',
  standalone: true,
  template: `
    <section class="panel">
      <p class="eyebrow">{{ title() }}</p>
      <h2>{{ subtitle() }}</h2>
      <p class="muted">{{ description() }}</p>

      <div class="employee-summary">
        <div><small>Empleado</small><span>{{ data().empleado.nombre_completo || 'Sin nombre' }}</span></div>
        <div><small>Documento</small><span>{{ data().empleado.numero_documento || 'Sin documento' }}</span></div>
        <div><small>Tipo contrato</small><span>{{ data().contrato.tipo_contrato || data().contrato.nombre_tipo_contrato || 'Sin tipo' }}</span></div>
        <div><small>Numero contrato</small><span>{{ data().contrato.numero_contrato || 'Sin numero' }}</span></div>
      </div>

      <ng-content></ng-content>
    </section>
  `,
})
export class BaseContractComponent {
  readonly data = input.required<ContractGenerationData>();
  readonly title = input<string>('Contrato');
  readonly subtitle = input<string>('Vista base del contrato');
  readonly description = input<string>('Componente base reutilizable para los tipos de contrato.');
}
