import { Component, ViewEncapsulation, input } from '@angular/core';

@Component({
  selector: 'app-contract-work-document-header',
  standalone: true,
  encapsulation: ViewEncapsulation.None,
  template: `
    <table class="fixed-header-table">
      <tbody>
        <tr>
          <td class="fixed-header-logo" rowspan="4">
            <img src="assets/icon/logo.png" alt="Barro Blanco Farms" />
          </td>
          <td class="fixed-header-process" rowspan="2">
            PROCESO GESTIÓN DE TALENTO HUMANO<br>
            SUBPROCESO: ADMINISTRACIÓN DE CONTRATOS LABORALES
          </td>
          <td class="fixed-header-meta">Código: {{ code() }}</td>
        </tr>
        <tr><td class="fixed-header-meta">Versión: {{ version() }}</td></tr>
        <tr>
          <td class="fixed-header-title" rowspan="2">CONTRATO POR OBRA O LABOR DETERMINADA<br>OPERATIVA</td>
          <td class="fixed-header-meta">Vigente a partir de:<br>{{ validityDate() }}</td>
        </tr>
        <tr><td class="fixed-header-meta">Página {{ pageNumber() }} de {{ pageCount() }}</td></tr>
      </tbody>
    </table>
  `,
})
export class ContractWorkDocumentHeaderComponent {
  readonly code = input.required<string>();
  readonly version = input.required<string>();
  readonly validityDate = input.required<string>();
  readonly pageNumber = input.required<number>();
  readonly pageCount = input<number>(5);
}
