import { Component, ViewEncapsulation, input } from '@angular/core';
import { ContractGenerationData } from '../models/contract-generation.models';
import { ContractDocumentHeaderComponent } from './contract-document-header.component';
import { ContractDocumentControlComponent } from './contract-document-control.component';

@Component({
  selector: 'app-contract-indefinite',
  standalone: true,
  imports: [ContractDocumentHeaderComponent, ContractDocumentControlComponent],
  encapsulation: ViewEncapsulation.None,
  styleUrl: './contract-indefinite.component.css',
  template: `
    <article class="indefinite-contract-doc" aria-label="Contrato de trabajo a termino indefinido">
      <section class="contract-sheet contract-page contract-sheet--page-1">
        <app-contract-document-header
          [code]="headerCode()"
          [version]="templateVersion()"
          [validityDate]="templateValidityDate()"
          [pageNumber]="1"
        ></app-contract-document-header>

        <h1 class="doc-main-title">CONTRATO INDIVIDUAL DE TRABAJO A TÉRMINO INDEFINIDO</h1>

        <table class="doc-table section-table contract-data-table employer-table contract-table">
          <tbody>
            <tr><th class="table-title" colspan="2">EMPLEADOR</th></tr>
            <tr>
              <td class="label-cell">Razón Social</td>
              <td class="value-cell">{{ companyName() }}</td>
            </tr>
            <tr>
              <td class="label-cell">Identificación</td>
              <td class="value-cell">{{ companyNitLabel() }}</td>
            </tr>
            <tr>
              <td class="label-cell">Domicilio del empleador</td>
              <td class="value-cell">{{ companyAddress() }}</td>
            </tr>
            <tr>
              <td class="label-cell">Correo Electrónico Empleador:</td>
              <td class="value-cell uppercase">{{ companyEmail() }}</td>
            </tr>
          </tbody>
        </table>

        <table class="doc-table section-table contract-data-table worker-table contract-table">
          <tbody>
            <tr><th class="table-title" colspan="2">TRABAJADOR</th></tr>
            <tr>
              <td class="label-cell">Nombre trabajador(a):</td>
              <td class="value-cell">{{ employeeFullName() }}</td>
            </tr>
            <tr>
              <td class="label-cell">Tipo de Numero de identificación:</td>
              <td class="value-cell">{{ employeeDocumentType() }}<br>{{ employeeDocumentNumber() }}</td>
            </tr>
            <tr>
              <td class="label-cell">Dirección Del Trabajador(a)</td>
              <td class="value-cell">{{ employeeAddress() }}</td>
            </tr>
            <tr>
              <td class="label-cell">Lugar, Fecha De Nacimiento Y Nacionalidad.</td>
              <td class="value-cell">{{ employeeBirthPlace() }},<br>{{ employeeBirthDateText() }},<br>{{ employeeNationality() }}</td>
            </tr>
            <tr>
              <td class="label-cell">Oficio Que Desempeñará El Trabajador(a)</td>
              <td class="value-cell">{{ contractCargo() }}</td>
            </tr>
            <tr>
              <td class="label-cell">Salario ordinario</td>
              <td class="value-cell">{{ salaryText() }}</td>
            </tr>
            <tr>
              <td class="label-cell">Auxilio de Transporte</td>
              <td class="value-cell">{{ transportAidText() }}</td>
            </tr>
            <tr>
              <td class="label-cell">Pagadero Por Periodos</td>
              <td class="value-cell">{{ paymentPeriod() }}</td>
            </tr>
            <tr>
              <td class="label-cell">Fecha De Iniciación De Labores</td>
              <td class="value-cell">{{ contractStartDateText() }}</td>
            </tr>
            <tr>
              <td class="label-cell">Lugar Donde Se Desempeñarán Las Labores</td>
              <td class="value-cell">{{ contractWorkplace() }}</td>
            </tr>
            <tr>
              <td class="label-cell">Término Inicial Del Contrato</td>
              <td class="value-cell">{{ initialContractTerm() }}</td>
            </tr>
          </tbody>
        </table>

        <p class="doc-clause-text">
          Entre el empleador y el trabajador, se celebra el presente contrato individual de trabajo, regido además por las siguientes cláusulas:
          <strong>PRIMERA – OBLIGACIONES:</strong>
          El empleador contrata los servicios personales del trabajador y éste se obliga: a) A poner al servicio del empleador toda su capacidad normal de trabajo,
          en forma exclusiva en el desempeño de las funciones propias del oficio mencionado y en las labores anexas y complementarias del mismo, de conformidad con
          las órdenes e instrucciones que le imparta el empleador o sus representantes, y b) A no prestar directa ni indirectamente servicios laborales a otros
          empleadores, ni a trabajar por cuenta propia en el mismo oficio, durante la vigencia de este contrato.
          <strong>SEGUNDA. -SALARIO.</strong>
          El empleador pagará al trabajador por la prestación de sus servicios el salario indicado, según los términos descritos. Dentro de este pago se encuentra
          incluida la remuneración de los descansos dominicales y festivos de que tratan los capítulos I y II del título VII del Código Sustantivo del Trabajo.
          Se aclara y se conviene que en los casos en los que el
        </p>

        <app-contract-document-control
          [version]="templateVersion()"
          [validityDate]="templateValidityDate()"
        ></app-contract-document-control>
      </section>

      <section class="contract-sheet contract-page contract-sheet--page-2">
        <app-contract-document-header
          [code]="headerCode()"
          [version]="templateVersion()"
          [validityDate]="templateValidityDate()"
          [pageNumber]="2"
        ></app-contract-document-header>

        <p class="doc-clause-text doc-clause-text--page-2">
          trabajador devengue comisiones o cualquiera otra modalidad de salario variable, el 82.5% de dichos ingresos, constituye remuneración ordinaria, y el 17.5% restante está destinado a remunerar el descanso en los días dominicales y festivos de que tratan los capítulos I y II del título VIII del Código Sustantivo del Trabajo.
          <strong>TERCERA. - EXTRAS.</strong>
          Todo trabajo suplementario o en horas extras y todo trabajo en domingo o festivo, se remunerará conforme a la ley, así como los correspondientes recargos nocturnos. Para el reconocimiento y pago del trabajo suplementario, dominical o festivo el empleador o sus representantes deben autorizarlo previamente por escrito. Cuando la necesidad de este trabajo se presente de manera imprevista o inaplazable, deberá ejecutarse y darse cuenta de él por escrito, a la mayor brevedad, al empleador o a sus representantes.
        </p>

        <p class="doc-clause-text doc-clause-text--page-2 doc-clause-text--page-2-gap">
          En consecuencia, el empleador no reconocerá ningún trabajo suplementario o en días de descanso legalmente obligatorio que no haya sido autorizado previamente o avisado inmediatamente, como queda dicho.
          <strong>CUARTA. - OBLIGACIONES.</strong>
          El trabajador se obliga a laborar la jornada ordinaria en los turnos y dentro de las horas señaladas por el empleador, pudiendo hacer éste ajustes o cambios de horario cuando lo estime conveniente. Por el acuerdo expreso o tácito de las partes, podrán repartirse las horas de la jornada ordinaria en la forma prevista en el artículo 164 del Código Sustantivo del Trabajo, modificado por el artículo 23 de la Ley 50 de 1990, teniendo en cuenta que los tiempos de descanso entre las secciones de la jornada no se computan dentro de la misma, según el artículo 167.
          <strong>QUINTA. -PERIODO DE PRUEBA:</strong>
          Los primeros {{ periodOfTrialDaysPageText() }} días del presente contrato se consideran como período de prueba y, por consiguiente, cualquiera de las partes podrá terminar el contrato unilateralmente, en cualquier momento durante dicho período. Vencido éste, la duración del contrato será indefinida, mientras subsistan las causas que le dieron origen y la materia del trabajo; no obstante, el trabajador podrá dar por terminado este contrato mediante aviso escrito al empleador con antelación no inferior a treinta (30) días. En caso de no dar el trabajador el aviso, o darlo tardíamente, deberá al empleador una indemnización equivalente a treinta (30) días de salario o proporcional al tiempo faltante, deducible de sus prestaciones sociales; este descuento se depositará a órdenes del juez, todo de conformidad con el numeral 5º del artículo 6º de la Ley 50 de 1990, que modificó el artículo 64 del Código Sustantivo del Trabajo.
          <strong>SEXTA. - TERMINACIÓN ANTICIPADA.</strong>
          Son justas causas para dar por terminado unilateralmente este contrato por cualquiera de las partes, las enumeradas en el artículo 7º del Decreto 2351 de 1965; y, además, por parte del empleador, las faltas que para el efecto se califiquen como graves en el espacio reservado para cláusulas adicionales en el presente contrato.
          <strong>SÉPTIMA. – TRASLADOS:</strong>
          Las partes podrán convenir que el trabajo se preste en lugar distinto del inicialmente contratado, siempre que tales traslados no desmejoren las condiciones laborales o de remuneración del trabajador, o impliquen perjuicios para él. Los gastos que se originen con el traslado serán cubiertos por el empleador de conformidad con el numeral 8º del artículo 57 del Código Sustantivo del Trabajo. El trabajador se obliga a aceptar los cambios de oficio que decida el empleador dentro de su poder subordinante, siempre que se respeten las
        </p>

        <app-contract-document-control
          [version]="templateVersion()"
          [validityDate]="templateValidityDate()"
        ></app-contract-document-control>
      </section>

      <section class="contract-sheet contract-page contract-sheet--page-3">
        <app-contract-document-header
          [code]="headerCode()"
          [version]="templateVersion()"
          [validityDate]="templateValidityDate()"
          [pageNumber]="3"
        ></app-contract-document-header>

        <p class="doc-clause-text doc-clause-text--page-3">
          condiciones laborales del trabajador y no se le causen perjuicios. Todo ello sin que se afecte el honor, la dignidad y los derechos mínimos del trabajador, de conformidad con el artículo 23 del Código Sustantivo del Trabajo, modificado por el artículo 1º de la Ley 50 de 1990.
          <strong>OCTAVA. -DERECHOS DE AUTOR:</strong>
          Las invenciones o descubrimientos realizados por el trabajador contratado para investigar pertenecen al empleador, de conformidad con el artículo 539 del Código de Comercio, así como el artículo 20 y concordantes de la Ley 23 de 1982 sobre derechos de autor. En cualquier otro caso el invento pertenece al trabajador, salvo cuando éste no haya sido contratado para investigar y realice la invención mediante datos o medios conocidos o utilizados debido a la labor desempeñada, evento en el cual el trabajador, tendrá derecho a una compensación que se fijará de acuerdo con el monto del salario, la importancia del invento o descubrimiento, el beneficio que reporte al empleador u otros factores similares.
          <strong>NOVENA. – FORMALIDAD:</strong>
          El presente contrato reemplaza en su integridad y deja sin efecto alguno cualquiera otro contrato verbal o escrito celebrado entre las partes con anterioridad. Las modificaciones que se acuerden al presente contrato se anotarán a continuación de su texto. Para constancia se firma en dos o más ejemplares del mismo tenor y valor, ante testigos en la ciudad y fecha que se indican a continuación:
        </p>

        <app-contract-document-control
          [version]="templateVersion()"
          [validityDate]="templateValidityDate()"
        ></app-contract-document-control>
      </section>

      <section class="contract-sheet contract-page contract-sheet--page-4">
        <app-contract-document-header
          [code]="headerCode()"
          [version]="templateVersion()"
          [validityDate]="templateValidityDate()"
          [pageNumber]="4"
        ></app-contract-document-header>

        <section class="signatures-block section-table--worker">
          <h2 class="signatures-title">FIRMAS</h2>

          <table class="signatures-table contract-table">
            <tbody>
              <tr>
                <th>EL EMPLEADOR</th>
                <th>EL(LA) TRABAJADOR(A)</th>
              </tr>
              <tr class="sign-row">
                <td><span>(Firme aquí)</span></td>
                <td><span>(Firme aquí)</span></td>
              </tr>
              <tr class="sign-name-row">
                <td>{{ companyName() }}</td>
                <td>{{ employeeFullName() }}</td>
              </tr>
              <tr>
                <td>{{ companyNitLabel() }}</td>
                <td>{{ employeeDocumentType() }}<br>{{ employeeDocumentNumber() }}</td>
              </tr>
              <tr>
                <td></td>
                <td><strong>Dirección:</strong> {{ employeeAddress() }}</td>
              </tr>
              <tr>
                <td></td>
                <td><strong>Correo Electrónico:</strong><br>{{ employeeEmail() }}</td>
              </tr>
            </tbody>
          </table>
        </section>

        <section class="signature-location-block">
          <p class="signature-location-title">Para constancia se firma en:</p>
          <table class="signature-location-table contract-table">
            <tbody>
              <tr>
                <td class="label">Ciudad:</td>
                <td class="value">{{ signatureCity() }}</td>
              </tr>
              <tr>
                <td class="label">Fecha:</td>
                <td class="value">{{ signatureDateText() }}</td>
              </tr>
            </tbody>
          </table>
        </section>

        <app-contract-document-control
          [version]="templateVersion()"
          [validityDate]="templateValidityDate()"
        ></app-contract-document-control>
      </section>
    </article>
  `,
})
export class ContractIndefiniteComponent {
  readonly data = input.required<ContractGenerationData>();

  contract(): ContractGenerationData['contrato'] {
    return this.data().contrato;
  }

  companyName(): string {
    return this.text(this.data().empresa.razonSocial);
  }

  companyNit(): string {
    return this.text(this.data().empresa.nit);
  }

  companyNitLabel(): string {
    return `NIT No ${this.companyNit()}`;
  }

  headerCode(): string {
    return this.text(this.data().parametros.reemplazos.CODIGO_FORMATO ?? 'BBTH - 7');
  }

  companyAddress(): string {
    return this.text(this.data().empresa.domicilio);
  }

  companyEmail(): string {
    return this.text(this.data().empresa.correo);
  }

  companyPhone(): string {
    return this.text(null);
  }

  employeeFullName(): string {
    return this.text(this.data().empleado.nombre_completo ?? [this.data().empleado.nombres, this.data().empleado.apellidos].filter(Boolean).join(' '));
  }

  employeeDocumentLabel(): string {
    const type = this.text(this.data().empleado.tipo_documento);
    const number = this.text(this.data().empleado.numero_documento);
    return [type, number].filter(Boolean).join(' ');
  }

  employeeDocumentType(): string {
    return this.text(this.data().parametros.reemplazos.TIPO_DOCUMENTO ?? this.data().empleado.tipo_documento);
  }

  employeeDocumentNumber(): string {
    return this.text(this.data().parametros.reemplazos.NUMERO_DOCUMENTO ?? this.data().empleado.numero_documento);
  }

  employeeAddress(): string {
    return this.text(this.data().empleado.direccion_residencia ?? 'Sin dato');
  }

  employeeEmail(): string {
    return this.text(this.data().empleado.correo_personal ?? this.data().empleado.correo ?? 'Sin dato');
  }

  employeeCorporateEmail(): string {
    return this.text(this.data().empleado.correo ?? 'Sin dato');
  }

  employeePhone(): string {
    return this.text(this.data().empleado.telefono ?? 'Sin dato');
  }

  employeeAlternatePhone(): string {
    return this.text(this.data().empleado.telefono_alterno ?? this.data().empleado.telefono ?? 'Sin dato');
  }

  employeeBirthDate(): string {
    return this.formatDate(this.data().empleado.fecha_nacimiento);
  }

  employeeBirthDateText(): string {
    return this.text(this.data().parametros.reemplazos.FECHA_NACIMIENTO_TEXTO ?? this.employeeBirthDate());
  }

  employeeBirthPlace(): string {
    return this.text(this.data().empleado.lugar_nacimiento ?? 'Sin dato');
  }

  employeeNationality(): string {
    return this.text(this.data().empleado.nacionalidad ?? 'Sin dato');
  }

  contractTypeLabel(): string {
    return this.text(this.data().contrato.tipo_contrato ?? this.data().contrato.nombre_tipo_contrato ?? 'TERMINO INDEFINIDO');
  }

  contractChargeType(): string {
    return this.text(this.data().contrato.tipo_cargo_contrato ?? this.data().parametros.plantilla.tipo_cargo_contrato ?? 'Sin dato');
  }

  contractCargo(): string {
    return this.text(this.data().contrato.cargo ?? this.data().contrato.nombre_cargo ?? 'Sin dato');
  }

  contractArea(): string {
    return this.text(this.data().contrato.area ?? this.data().contrato.nombre_area ?? 'Sin dato');
  }

  contractWorkplace(): string {
    return this.text(this.data().contrato.lugar_labores ?? this.data().parametros.plantilla.valores_default?.lugar_labores ?? 'Sin dato');
  }

  contractWorkday(): string {
    return this.text(this.data().contrato.jornada_laboral ?? this.data().parametros.plantilla.valores_default?.jornada_laboral ?? 'Sin dato');
  }

  contractStartDate(): string {
    return this.formatDate(this.data().contrato.fecha_inicio);
  }

  contractEndDate(): string {
    return this.formatDate(this.data().contrato.fecha_fin);
  }

  salaryValue(): string {
    return this.formatCurrency(this.data().contrato.salario_base);
  }

  salaryText(): string {
    return this.text(this.data().parametros.reemplazos.SALARIO_TEXTO ?? this.data().parametros.plantilla.valores_default?.salario_texto_default ?? this.salaryValue());
  }

  transportAidText(): string {
    return this.text(this.data().parametros.reemplazos.AUXILIO_TRANSPORTE_TEXTO ?? this.yesNo(this.contract().auxilio_transporte));
  }

  paymentPeriod(): string {
    return this.text(this.data().contrato.periodo_pago ?? this.data().parametros.plantilla.valores_default?.periodo_pago ?? 'Sin dato');
  }

  contractStartDateText(): string {
    return this.text(this.data().parametros.reemplazos.FECHA_INICIO_TEXTO ?? this.contractStartDate());
  }

  initialContractTerm(): string {
    return this.text(this.data().parametros.reemplazos.TERMINO_INICIAL_CONTRATO ?? this.data().parametros.plantilla.valores_default?.termino_inicial_contrato ?? 'Sin dato');
  }

  periodOfTrialDaysPageText(): string {
    return this.text(this.data().parametros.reemplazos.PERIODO_PRUEBA_DIAS ?? this.periodOfTrialDays());
  }

  periodOfTrialDays(): string {
    return this.text(this.data().contrato.periodo_prueba_dias ?? this.data().parametros.plantilla.valores_default?.periodo_prueba_dias ?? 'Sin dato');
  }

  clauseFunctions(): string {
    return this.text(this.data().contrato.clausula_funciones ?? 'Sin dato');
  }

  signatureCity(): string {
    return this.text(this.data().firmas.ciudad_firma ?? this.data().parametros.reemplazos.CIUDAD_FIRMA ?? 'Sin dato');
  }

  signatureDateText(): string {
    return this.text(this.data().firmas.fecha_firma_texto ?? this.data().parametros.reemplazos.FECHA_FIRMA_TEXTO ?? 'Sin dato');
  }

  templateCode(): string {
    return this.text(this.data().parametros.plantilla.codigo_formato ?? 'BBTH-F-016');
  }

  templateVersion(): string {
    return this.text(this.data().parametros.plantilla.version_formato ?? '02');
  }

  templateValidityDate(): string {
    return this.formatDate(this.data().parametros.plantilla.fecha_vigencia);
  }

  yesNo(value: unknown): string {
    if (value === true || value === 1 || value === '1' || value === 'true') {
      return 'SI';
    }

    if (value === false || value === 0 || value === '0' || value === 'false') {
      return 'NO';
    }

    return 'Sin dato';
  }

  private text(value: unknown): string {
    return value === null || value === undefined ? '—' : String(value).trim() || '—';
  }

  private formatDate(value?: string | null): string {
    if (!value) {
      return 'Sin dato';
    }

    const parsed = new Date(value);
    if (Number.isNaN(parsed.getTime())) {
      return this.text(value);
    }

    const day = String(parsed.getDate()).padStart(2, '0');
    const month = String(parsed.getMonth() + 1).padStart(2, '0');
    const year = parsed.getFullYear();

    return `${day}/${month}/${year}`;
  }

  private formatCurrency(value: number | string | null | undefined): string {
    if (value === null || value === undefined || value === '') {
      return 'Sin dato';
    }

    const numeric = typeof value === 'string' ? Number(value) : value;
    if (!Number.isFinite(numeric)) {
      return String(value);
    }

    return new Intl.NumberFormat('es-CO', { style: 'currency', currency: 'COP', maximumFractionDigits: 0 }).format(numeric);
  }
}
