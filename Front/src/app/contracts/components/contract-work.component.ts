import { Component, ViewEncapsulation, input } from '@angular/core';
import { ContractGenerationData } from '../models/contract-generation.models';
import { ContractDocumentControlComponent } from './contract-document-control.component';
import { ContractWorkDocumentHeaderComponent } from './contract-work-document-header.component';

@Component({
  selector: 'app-contract-work',
  standalone: true,
  imports: [ContractDocumentControlComponent, ContractWorkDocumentHeaderComponent],
  encapsulation: ViewEncapsulation.None,
  styleUrl: './contract-work.component.css',
  template: `
    <article class="fixed-contract-doc work-contract-doc" aria-label="Contrato por obra o labor determinada operativa">
      <section class="fixed-contract-page work-contract-page">
        <app-contract-work-document-header class="work-contract-page__header" [code]="headerCode()" [version]="templateVersion()" [validityDate]="templateValidityDate()" [pageNumber]="1" [pageCount]="5" />
        <main class="fixed-contract-page__content work-contract-page__content contract-body">
          <table class="fixed-data-table fixed-employer-table">
            <tbody>
              <tr><th colspan="2">EMPLEADOR</th></tr>
              <tr><td>Razón Social</td><td>{{ companyName() }}</td></tr>
              <tr><td>Identificación</td><td>{{ companyNitLabel() }}</td></tr>
              <tr><td>Domicilio del empleador</td><td>{{ companyAddress() }}</td></tr>
              <tr><td>Correo Electrónico Empleador:</td><td class="fixed-uppercase">{{ companyEmail() }}</td></tr>
            </tbody>
          </table>

          <table class="fixed-data-table fixed-worker-table">
            <tbody>
              <tr><th colspan="2">TRABAJADOR</th></tr>
              <tr><td>Nombre trabajador(a):</td><td>{{ employeeFullName() }}</td></tr>
              <tr><td>Tipo de Numero de identificación:</td><td>{{ employeeDocumentType() }} {{ employeeDocumentNumber() }}</td></tr>
              <tr><td>Dirección Del Trabajador(a)</td><td>{{ employeeAddress() }}</td></tr>
              <tr><td>Lugar, Fecha De Nacimiento Y Nacionalidad.</td><td>{{ employeeBirthPlace() }}, {{ employeeBirthDateText() }}, {{ employeeNationality() }}</td></tr>
              <tr><td>Oficio Que Desempeñará El Trabajador(a)</td><td>{{ contractCargo() }}</td></tr>
              <tr><td>Salario ordinario</td><td>{{ salaryText() }}</td></tr>
              <tr><td>Auxilio de Transporte</td><td>{{ transportAidText() }}</td></tr>
              <tr><td>Pagadero Por Periodos</td><td>{{ paymentPeriod() }}</td></tr>
              <tr><td>Fecha De Iniciación De Labores</td><td>{{ contractStartDateText() }}</td></tr>
              <tr><td>Lugar Donde Se Desempeñarán Las Labores</td><td>{{ contractWorkplace() }}</td></tr>
              <tr><td>Término de la obra o labor</td><td>{{ workObject() }}</td></tr>
              <tr><td>Vence El Día</td><td>{{ contractEndDateText() }}</td></tr>
            </tbody>
          </table>

          <p class="fixed-clause">Entre el empleador y el(la) trabajador(a), de las condiciones ya dichas identificados como aparece al pie de sus correspondientes firmas se ha celebrado el presente <strong>CONTRATO DE TRABAJO POR OBRA Y LABOR</strong>, regido además por las siguientes:</p>
          <h1 class="fixed-clauses-title">CLÁUSULAS</h1>
          <p class="fixed-clause fixed-clause--spaced"><strong>PRIMERO: el empleador contrata los servicios.</strong> El(la) Trabajador(a) se obliga a prestar servicios personales para el Empleador, desempeñándose como trabajador en MISION, de acuerdo con las instrucciones que le sean impartidas por este, para lo cual se obliga a:</p>
        </main>
        <app-contract-document-control class="fixed-contract-page__footer work-contract-page__footer" [version]="templateVersion()" [validityDate]="templateValidityDate()" />
      </section>

      <section class="fixed-contract-page work-contract-page">
        <app-contract-work-document-header class="work-contract-page__header" [code]="headerCode()" [version]="templateVersion()" [validityDate]="templateValidityDate()" [pageNumber]="2" [pageCount]="5" />
        <main class="fixed-contract-page__content work-contract-page__content work-contract-page__content--page-2 fixed-contract-legal contract-body contract-body--legal">
          <div class="fixed-literal-list">
            <p><span class="fixed-literal-marker">a)</span><span>Poner al servicio del EMPLEADOR toda su capacidad normal de trabajo, en forma exclusiva en el desempeño de las funciones propias del oficio mencionado y en las labores anexas y complementarias del mismo, de conformidad con las ordenes e instrucciones que le imparta par EL EMPLEADOR o sus representantes, y</span></p>
            <p><span class="fixed-literal-marker">b)</span><span>A no prestar la labor requerida por la empresa.</span></p>
          </div>
          <p>La obra o labor se prestará en el municipio de Gachancipa.</p>
          <p><strong>SEGUNDA. FUNCIONES.</strong> En el ejercicio del cargo, el Trabajador deberá desarrollar todas y cada una de las labores o iniciativas que sean inherentes o estén relacionadas con dicha labor y que sean necesarias de acuerdo con la labor contratada, tales como:</p>
          <ol class="fixed-number-list">
            <li>Realizar la labor a que se refiere el presente contrato.</li>
            <li>Realizar las labores acordadas con el empleador.</li>
            <li>Realizar labores netamente en lo que tiene que ver con la floricultura.</li>
          </ol>
          <p><strong>TERCERA: JORNADA DE TRABAJO.</strong> La jornada de trabajo a cumplir por el Trabajador tendrá una duración de 44 horas semanales efectivas de labor, distribuidas de conformidad con la reforma laboral y la Ley 2101 del 2021 y la Ley 2466 del 2025.</p>
          <p><strong>CUARTA: REMUNERACIÓN.</strong> El empleador pagará al trabajador por la prestación de sus servicios el salario indicado, pagadero en las oportunidades también ya señaladas.</p>
          <p><strong>PARAGRAFO UNICO.</strong> El trabajador autoriza expresamente al empleador para que le descuente de su salario mensual y de su liquidación final de acreencias laborales y de cualquier otra suma que por cualquier concepto le adeude las sumas de dinero que deba pagar por concepto de las pérdidas o daños causados a los bienes del empleador recibidos por inventario ya sea por sí o por qué los se los facilitó a alguien estando bajo su responsabilidad</p>
          <p><strong>PARAGRAFO:</strong> La obra y labor objeto del presente contrato se podrá prorrogar {{ extensionDaysValue() }} Días</p>
          <p><strong>QUINTA. AUXILIO DE TRANSPORTE.</strong> El trabajador tendrá derecho al pago de Auxilio de transporte de conformidad con lo señalado en el Código Sustantivo de trabajo y la seguridad social. </p>
          <p><strong>SEXTA.</strong> Todo trabajo suplementario o en horas extras y todo trabajo en domingo o festivo en los que legalmente debe concederse el descanso, se remunerará conforme a la Ley, así como los correspondientes recargos nocturnos. Para el reconocimiento y pago del trabajo suplementario, dominical o festivo el empleador o sus representantes deben autorizarlo previamente por escrito. Cuando la necesidad de este trabajo se presente de manera imprevista o inaplazable, deberá ejecutarse y darse cuenta de él por escrito, a la mayor brevedad, al empleador o sus representantes. </p>
        </main>
        <app-contract-document-control class="fixed-contract-page__footer work-contract-page__footer" [version]="templateVersion()" [validityDate]="templateValidityDate()" />
      </section>

      <section class="fixed-contract-page work-contract-page">
        <app-contract-work-document-header class="work-contract-page__header" [code]="headerCode()" [version]="templateVersion()" [validityDate]="templateValidityDate()" [pageNumber]="3" [pageCount]="5" />
        <main class="fixed-contract-page__content work-contract-page__content fixed-contract-legal contract-body contract-body--legal">
          <p>El empleador, en consecuencia, no reconocerá ningún trabajo suplementario o en días de descanso legalmente obligatorio que no haya sido autorizado previamente o avisado inmediatamente, como queda dicho. </p>
          <p><strong>SEPTIMA.</strong> El trabajador se obliga a laborar la jornada ordinaria en los turnos y dentro de las horas señaladas por el empleador, pudiendo hacer éste ajustes o cambios de horario cuando lo estime conveniente. Por el acuerdo expreso o tácito de las partes, podrán repartirse las horas jornada ordinaria de la forma prevista en el numeral 2 artículo 6 de la Ley 2466 del 2025. Código Sustantivo del Trabajo.</p>
          <p><strong>OCTAVA.</strong> Son justas causas para dar por terminado unilateralmente este contrato por cualquiera de las partes, las enumeradas en el Código Sustantivo del Trabajo; y, además, por parte del empleado, las faltas que para el efecto se califiquen como graves en el reglamento Interno. </p>
          <p><strong>PARAGRAFO PRIMERO.</strong> Debido a que el empleador desarrolla actividades que suponen un alto riesgo de accidentes, y que la labor para la cual ha sido contratado el trabajador implica un alto grado de responsabilidad en la prevención de los mismos, y, en el seguimiento riguroso de las instrucciones para el desempeño de su labor, el trabajador no podrá presentarse a laborar habiendo consumido o bajo los efectos del alcohol, o, de cualquier sustancia psicoactiva, que afecte sus sentidos, sus reflejos, o la atención en el trabajo.</p>
          <p>La contravención a la anterior prohibición, aún por la primera vez, se considera como falta grave, y por lo tanto justa causa para dar por terminado unilateralmente el contrato de trabajo por parte del empleado.</p>
        </main>
        <app-contract-document-control class="fixed-contract-page__footer work-contract-page__footer" [version]="templateVersion()" [validityDate]="templateValidityDate()" />
      </section>

      <section class="fixed-contract-page work-contract-page">
        <app-contract-work-document-header class="work-contract-page__header" [code]="headerCode()" [version]="templateVersion()" [validityDate]="templateValidityDate()" [pageNumber]="4" [pageCount]="5" />
        <main class="fixed-contract-page__content work-contract-page__content fixed-contract-legal contract-body contract-body--legal">
          <p><strong>PARAGRAFO SEGUNDO.</strong> EL EMPLEADOR, podrá practicar a EL TRABAJADOR, en cualquier momento, antes, durante, o después de la jornada de trabajo, exámenes de alcoholemia o cualquier otro tipo de prueba para detectar la presencia de sustancias psicoactivas que alteren los sentidos los reflejos o las condiciones de atención que debe mantener el trabajador durante el desempeño de sus labores; el trabajador entiende y acepta que la práctica esos exámenes y prueba tiene como finalidad preservar su estado de salud e integridad física, motivo por el cual, autoriza la práctica de los exámenes, y manifiesta que acudirá a la práctica de los mismos, cuando el empleador lo solicite. La negativa del trabajador aún por la primera vez a permitir al empleador, o, sus delegados, para la práctica de los exámenes o pruebas anteriormente mencionados se considera como falta grave y por lo tanto justa causa para dar por terminado unilateralmente el contrato de trabajo por parte del empleador. </p>
          <p>Se entiende que el trabajador ha consumido se encuentra bajo los efectos de cualquier sustancia psicoactiva que afecte sus reflejos sus sentidos o la atención en el trabajo cuando una prueba para detectar la presencia de esas sustancias en el organismo entre el trabajador arroja como resultados una cifra superior a 0.0. </p>
          <p><strong>NOVENA.</strong> Las partes podrán convenir que el trabajo se preste en lugar distinto al inicialmente contratado, siempre que tales traslados no desmejoren las condiciones laborales o de remuneración del trabajador, o impliquen perjuicios para él. Los gastos que se originen con el traslado serán cubiertos por el empleador de conformidad con el Código Sustantivo del Trabajo. </p>
          <p><strong>DECIMA.</strong> Este contrato ha sido redactado estrictamente de acuerdo con la ley y la jurisprudencia y será interpretado de buena fe y en consonancia con el Código Sustantivo del Trabajo cuyo objeto, definido en su artículo 6 de la Ley 2466 del 2025º, es lograr la justicia en las relaciones entre empleadores y trabajadores dentro de un espíritu de coordinación económica y equilibrio social. </p>
          <p><strong>DECIMO PRIMERA.</strong> El presente contrato reemplaza en su integridad y deja sin efecto alguno cualquiera otro contrato verbal o escrito celebrado por las partes con anterioridad. Las modificaciones que se acuerden al presente contrato se anotarán a continuación de su texto.</p>
          <p><strong>DECIMO SEGUNDA.</strong> El trabajador para todos los efectos legales y en especial para la aplicación del artículo 6 de la ley 2466 del 25 de junio del 2025., teniéndose como suya la última dirección registrada en la hoja de vida.</p>
        </main>
        <app-contract-document-control class="fixed-contract-page__footer work-contract-page__footer" [version]="templateVersion()" [validityDate]="templateValidityDate()" />
      </section>

      <section class="fixed-contract-page work-contract-page">
        <app-contract-work-document-header class="work-contract-page__header" [code]="headerCode()" [version]="templateVersion()" [validityDate]="templateValidityDate()" [pageNumber]="5" [pageCount]="5" />
        <main class="fixed-contract-page__content work-contract-page__content fixed-contract-legal contract-body contract-body--legal">
          <h2 class="fixed-signatures-title work-signatures-title">FIRMAS</h2>
          <table class="fixed-signatures-table">
            <tbody>
              <tr><th>EL EMPLEADOR</th><th>EL(LA) TRABAJADOR(A)</th></tr>
              <tr class="fixed-sign-row"><td>(Firme aquí)</td><td>(Firme aquí)</td></tr>
              <tr><td><strong>{{ companyName() }}</strong></td><td><strong>{{ employeeFullName() }}</strong></td></tr>
              <tr><td>{{ companyNitLabel() }}</td><td>{{ employeeDocumentType() }} {{ employeeDocumentNumber() }}</td></tr>
              <tr><td><strong>Dirección:</strong> {{ companyAddress() }}</td><td><strong>Dirección:</strong> {{ employeeAddress() }}</td></tr>
              <tr><td><strong>Correo Electrónico:</strong> {{ companyEmail() }}</td><td><strong>Correo Electrónico:</strong> {{ employeeEmail() }}</td></tr>
            </tbody>
          </table>
          <p class="fixed-signature-caption">Para constancia se firma en:</p>
          <table class="fixed-signature-location">
            <tbody>
              <tr><th>Ciudad:</th><td>{{ signatureCity() }}</td></tr>
              <tr><th>Fecha:</th><td>{{ signatureDateText() }}</td></tr>
              <tr><th>Número de contrato</th><td>{{ contractNumber() }}</td></tr>
            </tbody>
          </table>
        </main>
        <app-contract-document-control class="fixed-contract-page__footer work-contract-page__footer" [version]="templateVersion()" [validityDate]="templateValidityDate()" />
      </section>
    </article>
  `,
})
export class ContractWorkComponent {
  readonly data = input.required<ContractGenerationData>();

  headerCode(): string { return this.value(this.data().parametros.reemplazos.CODIGO_FORMATO ?? this.data().parametros.plantilla.codigo_formato, 'BBTH-F-014'); }
  templateVersion(): string { return this.value(this.data().parametros.reemplazos.VERSION_FORMATO ?? this.data().parametros.plantilla.version_formato, '02'); }
  templateValidityDate(): string { return this.documentDate(this.data().parametros.plantilla.fecha_vigencia ?? this.data().parametros.reemplazos.FECHA_VIGENCIA ?? this.data().parametros.reemplazos.FECHA_VIGENCIA_TEXTO, '18/06/2026'); }
  companyName(): string { return this.value(this.data().empresa.razonSocial, 'BARRO BLANCO FARMS S.A.S'); }
  companyNitLabel(): string { return `NIT No ${this.value(this.data().empresa.nit, '900747203-1')}`; }
  companyAddress(): string { return this.value(this.data().empresa.domicilio, 'VEREDA SAN JOSE FINCA BARRO BLANCO'); }
  companyEmail(): string { return this.value(this.data().empresa.correo, 'barroblancofarms@gmail.com'); }
  employeeFullName(): string { return this.value(this.data().parametros.reemplazos.NOMBRE_COMPLETO ?? this.data().empleado.nombre_completo); }
  employeeDocumentType(): string { return this.value(this.data().parametros.reemplazos.TIPO_DOCUMENTO ?? this.data().empleado.tipo_documento); }
  employeeDocumentNumber(): string { return this.value(this.data().parametros.reemplazos.NUMERO_DOCUMENTO ?? this.data().empleado.numero_documento); }
  employeeAddress(): string { return this.value(this.data().parametros.reemplazos.DIRECCION_RESIDENCIA ?? this.data().empleado.direccion_residencia); }
  employeeBirthPlace(): string { return this.value(this.data().parametros.reemplazos.LUGAR_NACIMIENTO ?? this.data().empleado.lugar_nacimiento); }
  employeeBirthDateText(): string { return this.value(this.data().parametros.reemplazos.FECHA_NACIMIENTO_TEXTO ?? this.data().empleado.fecha_nacimiento); }
  employeeNationality(): string { return this.value(this.data().parametros.reemplazos.NACIONALIDAD ?? this.data().empleado.nacionalidad); }
  employeeEmail(): string { return this.value(this.data().parametros.reemplazos.CORREO_PERSONAL ?? this.data().empleado.correo_personal ?? this.data().empleado.correo); }
  contractCargo(): string { return this.value(this.data().parametros.reemplazos.CARGO ?? this.data().contrato.cargo ?? this.data().contrato.nombre_cargo); }
  salaryText(): string { return this.value(this.data().parametros.reemplazos.SALARIO_TEXTO ?? this.data().parametros.reemplazos.SALARIO_BASE ?? this.data().contrato.salario_base); }
  transportAidText(): string { return this.value(this.data().parametros.reemplazos.AUXILIO_TRANSPORTE_TEXTO, 'SI'); }
  paymentPeriod(): string { return this.value(this.data().parametros.reemplazos.PERIODO_PAGO ?? this.data().contrato.periodo_pago); }
  contractStartDateText(): string { return this.value(this.data().parametros.reemplazos.FECHA_INICIO_TEXTO ?? this.data().contrato.fecha_inicio); }
  contractEndDateText(): string { return this.value(this.data().parametros.reemplazos.FECHA_FIN_TEXTO ?? this.data().contrato.fecha_fin, 'No aplica'); }
  contractWorkplace(): string { return this.value(this.data().parametros.reemplazos.LUGAR_LABORES ?? this.data().contrato.lugar_labores); }
  workObject(): string { return this.value(this.data().parametros.reemplazos.OBJETO_OBRA_LABOR ?? this.data().contrato.objeto_obra_labor); }
  signatureCity(): string { return this.value(this.data().firmas.ciudad_firma ?? this.data().parametros.reemplazos.CIUDAD_FIRMA); }
  signatureDateText(): string { return this.value(this.data().firmas.fecha_firma_texto ?? this.data().parametros.reemplazos.FECHA_FIRMA_TEXTO); }
  contractNumber(): string { return this.value(this.data().parametros.reemplazos.NUMERO_CONTRATO ?? this.data().contrato.numero_contrato); }

  extensionDaysValue(): string {
    const value = this.data().parametros.reemplazos.PRORROGA_DIAS ?? this.data().contrato.prorroga_dias;
    const days = Number(value);
    if (!Number.isFinite(days) || days < 0) {
      return '0';
    }

    return String(days);
  }

  private value(value: unknown, fallback = 'Sin dato'): string {
    if (value === null || value === undefined || String(value).trim() === '') return fallback;
    return String(value).trim();
  }

  private documentDate(value: unknown, fallback: string): string {
    if (value === null || value === undefined) {
      return fallback;
    }

    const text = String(value).trim();
    if (text === '') {
      return fallback;
    }

    const match = text.match(/^(\d{4})-(\d{2})-(\d{2})$/);
    if (!match) {
      return text;
    }

    return `${match[3]}/${match[2]}/${match[1]}`;
  }
}
