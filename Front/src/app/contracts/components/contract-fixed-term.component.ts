import { Component, input } from '@angular/core';
import { BaseContractComponent } from './base-contract.component';
import { ContractGenerationData } from '../models/contract-generation.models';

@Component({
  selector: 'app-contract-fixed-term',
  standalone: true,
  imports: [BaseContractComponent],
  template: `
    <app-base-contract
      [data]="data()"
      title="Contrato"
      subtitle="Contrato a termino fijo"
      description="Estructura preparada para renderizar contratos a termino fijo."
    >
      <div class="alert success">Componente preparado: pendiente maquetacion final del contrato a termino fijo.</div>
    </app-base-contract>
  `,
})
export class ContractFixedTermComponent {
  readonly data = input.required<ContractGenerationData>();
}
