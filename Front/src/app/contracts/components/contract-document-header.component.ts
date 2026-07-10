import { Component, ViewEncapsulation, input } from '@angular/core';

@Component({
  selector: 'app-contract-document-header',
  standalone: true,
  encapsulation: ViewEncapsulation.None,
  template: `
    <table class="doc-header-table contract-table">
      <tbody>
        <tr>
          <td class="doc-header-logo logo-cell" rowspan="4">
            <img
              src="assets/icon/logo.png"
              alt="Barro Blanco Farms"
              class="contract-logo"
            />
          </td>
          <td class="doc-header-title-top">FORMATO AREA DE TALENTO HUMANO</td>
          <td class="doc-header-meta">Código: {{ code() }}</td>
        </tr>
        <tr>
          <td class="doc-header-title-spacer"></td>
          <td class="doc-header-meta">Versión: {{ version() }}</td>
        </tr>
        <tr>
          <td class="doc-header-title-bottom">CONTRATO DE TRABAJO A TERMINO INDEFINIDO</td>
          <td class="doc-header-meta">Vigente a partir de:<br>{{ validityDate() }}</td>
        </tr>
        <tr>
          <td class="doc-header-title-spacer"></td>
          <td class="doc-header-meta">Página {{ pageNumber() }} de {{ pageCount() }}</td>
        </tr>
      </tbody>
    </table>
  `,
})
export class ContractDocumentHeaderComponent {
  readonly code = input.required<string>();
  readonly version = input.required<string>();
  readonly validityDate = input.required<string>();
  readonly pageNumber = input.required<number>();
  readonly pageCount = input<number>(4);
}