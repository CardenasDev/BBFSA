import { Component, ViewEncapsulation, input } from '@angular/core';

@Component({
  selector: 'app-contract-document-control',
  standalone: true,
  encapsulation: ViewEncapsulation.None,
  template: `
    <table class="doc-footer-table contract-table">
      <thead>
        <tr>
          <th>Versión</th>
          <th>Fecha</th>
          <th>Motivo de la Revisión</th>
          <th>Modificación</th>
          <th>Elaboró</th>
          <th>Revisó</th>
          <th>Aprobó</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td>{{ version() }}</td>
          <td>{{ validityDate() }}</td>
          <td>Cambio de normativa legal colombiana</td>
          <td></td>
          <td>Oscar Villarraga</td>
          <td>Yuliana Villarraga<br>Gerente</td>
          <td>Yuliana Villarraga<br>Gerente</td>
        </tr>
      </tbody>
    </table>

    <p class="doc-control-note">Documento controlado. Prohibida su reproducción parcial o total sin autorización de BARRO BLANCO FARMS S.A.S</p>
  `,
})
export class ContractDocumentControlComponent {
  readonly version = input.required<string>();
  readonly validityDate = input.required<string>();
}