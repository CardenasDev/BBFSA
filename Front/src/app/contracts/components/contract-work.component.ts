import { Component, input } from '@angular/core';
import { BaseContractComponent } from './base-contract.component';
import { ContractGenerationData } from '../models/contract-generation.models';

@Component({
  selector: 'app-contract-work',
  standalone: true,
  imports: [BaseContractComponent],
  template: `
    <app-base-contract
      [data]="data()"
      title="Contrato"
      subtitle="Contrato por obra o labor"
      description="Estructura preparada para renderizar contratos por obra o labor."
    >
      <div class="alert success">Componente preparado: pendiente maquetacion final del contrato por obra o labor.</div>
    </app-base-contract>
  `,
})
export class ContractWorkComponent {
  readonly data = input.required<ContractGenerationData>();
}
