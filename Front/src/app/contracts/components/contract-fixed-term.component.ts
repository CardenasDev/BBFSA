import { Component, ViewEncapsulation, input } from '@angular/core';
import { ContractGenerationData } from '../models/contract-generation.models';
import { ContractDocumentControlComponent } from './contract-document-control.component';
import { ContractFixedDocumentHeaderComponent } from './contract-fixed-document-header.component';

@Component({
  selector: 'app-contract-fixed-term',
  standalone: true,
  imports: [ContractDocumentControlComponent, ContractFixedDocumentHeaderComponent],
  encapsulation: ViewEncapsulation.None,
  styleUrl: './contract-fixed-term.component.css',
  template: `
    <article class="fixed-contract-doc" aria-label="Contrato de trabajo a término fijo inferior a un año">
      <section class="fixed-contract-page fixed-contract-page--1">
        <app-contract-fixed-document-header class="fixed-contract-page__header" [code]="headerCode()" [version]="templateVersion()" [validityDate]="templateValidityDate()" [pageNumber]="1" />
        <main class="fixed-contract-page__content">
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
              <tr><td>Término Inicial Del Contrato</td><td>{{ initialContractTerm() }}</td></tr>
              <tr><td>Vence El Día</td><td>{{ contractEndDateText() }}</td></tr>
            </tbody>
          </table>

          <p class="fixed-clause">Entre el empleador y el(la) trabajador(a), de las condiciones ya dichas identificados como aparece al pie de sus correspondientes firmas se ha celebrado el presente <strong>CONTRATO INDIVIDUAL DE TRABAJO DE TERMINO FIJO</strong>, regido además por las siguientes:</p>
          <h1 class="fixed-clauses-title">CLÁUSULAS</h1>
          <ol class="fixed-alpha-list"><li>Poner al servicio del EMPLEADOR toda su capacidad normal de trabajo, en forma exclusiva en el desempeño de las funciones propias del oficio mencionado y en las labores anexas y complementarias del mismo, de conformidad con las ordenes e instrucciones que le imparta EL EMPLEADOR o sus representantes, y</li></ol>
        </main>
        <app-contract-document-control class="fixed-contract-page__footer" [version]="templateVersion()" [validityDate]="templateValidityDate()" />
      </section>

      <section class="fixed-contract-page fixed-contract-page--2">
        <app-contract-fixed-document-header class="fixed-contract-page__header" [code]="headerCode()" [version]="templateVersion()" [validityDate]="templateValidityDate()" [pageNumber]="2" />
        <main class="fixed-contract-page__content fixed-contract-legal">
          <ol class="fixed-alpha-list" start="2"><li>A no prestar directa ni indirectamente servicios laborales a otros EMPLEADORES, ni a trabajar por cuenta propia en el mismo oficio, durante la vigencia de este contrato.</li></ol>
          <p><strong>SEGUNDA. FUNCIONES.</strong> En el ejercicio del cargo, el Trabajador deberá desarrollar todas y cada una de las labores o iniciativas que sean inherentes o estén relacionadas con dicho cargo y que sean necesarias para el mejor y más adecuado desarrollo de sus funciones, tales como:</p>
          <p>{{ contractFunctions() }}</p>
          <p>Lo anterior, sin perjuicio de la facultad del Empleador de alterar la naturaleza de los servicios, o el sitio o recinto en que ellos han de prestarse, con la sola limitación de que se trate de labores similares y que el nuevo sitio o recinto quede dentro del mismo lugar o ciudad, sin que ello importe menoscabo para el Trabajador.</p>
          <p><strong>CUARTA: REMUNERACIÓN.</strong> El empleador pagará al trabajador por la prestación de sus servicios el salario indicado, pagadero en las oportunidades también ya señaladas.</p>
          <p><strong>PARAGRAFO UNICO.</strong> El trabajador autoriza expresamente al empleador para que le descuente de su salario mensual y de su liquidación final de acreencias laborales y de cualquier otra suma que por cualquier concepto le adeude las sumas de dinero que deba pagar por concepto de las pérdidas o daños causados a los bienes del empleador recibidos por inventario ya sea por sí o por qué los se los facilitó a alguien estando bajo su responsabilidad</p>
          <p><strong>QUINTA. AUXILIO DE TRANSPORTE.</strong> El trabajador tendrá derecho al pago de Auxilio de transporte de conformidad con lo señalado en el Código Sustantivo de trabajo y la seguridad social.</p>
          <p><strong>SEXTA.</strong> Todo trabajo suplementario o en horas extras y todo trabajo en domingo o festivo en los que legalmente debe concederse el descanso, se remunerará conforme a la Ley, así como los correspondientes recargos nocturnos. Para el reconocimiento y pago del trabajo suplementario, dominical o festivo el empleador o sus representantes deben autorizarlo previamente por escrito. Cuando la necesidad de este trabajo se presente de manera imprevista o inaplazable, deberá ejecutarse y darse cuenta de él por escrito, a la mayor brevedad, al empleador o sus representantes.</p>
        </main>
        <app-contract-document-control class="fixed-contract-page__footer" [version]="templateVersion()" [validityDate]="templateValidityDate()" />
      </section>

      <section class="fixed-contract-page fixed-contract-page--3">
        <app-contract-fixed-document-header class="fixed-contract-page__header" [code]="headerCode()" [version]="templateVersion()" [validityDate]="templateValidityDate()" [pageNumber]="3" />
        <main class="fixed-contract-page__content fixed-contract-legal">
          <p>El empleador, en consecuencia, no reconocerá ningún trabajo suplementario o en días de descanso legalmente obligatorio que no haya sido autorizado previamente o avisado inmediatamente, como queda dicho.</p>
          <p><strong>SEPTIMA.</strong> El trabajador se obliga a laborar la jornada ordinaria en los turnos y dentro de las horas señaladas por el empleador, pudiendo hacer éste ajustes o cambios de horario cuando lo estime conveniente. Por el acuerdo expreso o tácito de las partes, podrán repartirse las horas jornada ordinaria de la forma prevista en la ley 2466 del 2025, teniendo en cuenta que los tiempos de descanso entre las secciones de la jornada no se computan dentro de la misma, según el artículo 167 ibidem.</p>
          <p><strong>OCTAVA.</strong> Son justas causas para dar por terminado unilateralmente este contrato por cualquiera de las partes, Código Sustantivo del Trabajo; y, además, por parte del empleado, las faltas que para el efecto se califiquen como graves en el reglamento Interno.</p>
          <p><strong>PARAGRAFO PRIMERO.</strong> Debido a que el empleador desarrolla actividades que suponen un alto riesgo de accidentes, y que la labor para la cual ha sido contratado el trabajador implica un alto grado de responsabilidad en la prevención de los mismos, y, en el seguimiento riguroso de las instrucciones para el desempeño de su labor, el trabajador no podrá presentarse a laborar habiendo consumido o bajo los efectos del alcohol, o, de cualquier sustancia psicoactiva, que afecte sus sentidos, sus reflejos, o la atención en el trabajo.</p>
          <p>La contravención a la anterior prohibición, aún por la primera vez, se considera como falta grave, y por lo tanto justa causa para dar por terminado unilateralmente el contrato de trabajo por parte del empleado.</p>
          <p><strong>PARAGRAFO SEGUNDO.</strong> EL Empleador, podrá practicar a EL TRABAJADOR, en cualquier momento, antes, durante, o después de la jornada de trabajo, exámenes de alcoholemia o cualquier otro tipo de prueba para detectar la presencia de sustancias psicoactivas que alteren los sentidos los reflejos o las condiciones de atención que debe mantener el trabajador durante el desempeño de sus labores; el trabajador entiende y acepta que la práctica esos exámenes y prueba tiene como finalidad preservar su estado de salud e integridad física, motivo por el cual, autoriza la práctica de los exámenes, y manifiesta que acudirá a la práctica de los mismos, cuando el empleador lo solicite. La negativa del trabajador aún por la primera vez a permitir al empleador, o, sus delegados, para la práctica de los exámenes o pruebas anteriormente mencionados se considera como falta grave y por lo tanto justa causa para dar por terminado unilateralmente el contrato de trabajo por parte del empleador.</p>
        </main>
        <app-contract-document-control class="fixed-contract-page__footer" [version]="templateVersion()" [validityDate]="templateValidityDate()" />
      </section>

      <section class="fixed-contract-page fixed-contract-page--4">
        <app-contract-fixed-document-header class="fixed-contract-page__header" [code]="headerCode()" [version]="templateVersion()" [validityDate]="templateValidityDate()" [pageNumber]="4" />
        <main class="fixed-contract-page__content fixed-contract-legal">
          <p>Se entiende que el trabajador ha consumido se encuentra bajo los efectos de cualquier sustancia psicoactiva que afecte sus reflejos sus sentidos o la atención en el trabajo cuando una prueba para detectar la presencia de esas sustancias en el organismo entre el trabajador arroja como resultados una cifra superior a 0.0.</p>
          <p><strong>NOVENA.</strong> Las partes podrán convenir que el trabajo se preste en lugar distinto al inicialmente contratado, siempre que tales traslados no desmejoren las condiciones laborales o de remuneración del trabajador, o impliquen perjuicios para él. Los gastos que se originen con el traslado serán cubiertos por el empleador de conformidad con la ley 2466 del 2025. El trabajador se obliga a aceptar los cambios de oficio que decida el empleador dentro de su poder subordinante, siempre que se respeten las condiciones laborales del trabajador y no se le causen perjuicios. Todo ello sin que se afecte el honor, la dignidad y los derechos mínimos del trabajador, de conformidad Código Sustantivo del Trabajo y la ley 2466 de 2025.</p>
          <p><strong>DECIMA.</strong> Este contrato ha sido redactado estrictamente de acuerdo con la ley y la jurisprudencia y será interpretado de buena fe y en consonancia con el Código Sustantivo del Trabajo cuyo objeto, es lograr la justicia en las relaciones entre empleadores y trabajadores dentro de un espíritu de coordinación económica y equilibrio social.</p>
          <p><strong>DECIMO PRIMERA.</strong> El presente contrato reemplaza en su integridad y deja sin efecto alguno cualquiera otro contrato verbal o escrito celebrado por las partes con anterioridad. Las modificaciones que se acuerden al presente contrato se anotarán a continuación de su texto.</p>
        </main>
        <app-contract-document-control class="fixed-contract-page__footer" [version]="templateVersion()" [validityDate]="templateValidityDate()" />
      </section>

      <section class="fixed-contract-page fixed-contract-page--5">
        <app-contract-fixed-document-header class="fixed-contract-page__header" [code]="headerCode()" [version]="templateVersion()" [validityDate]="templateValidityDate()" [pageNumber]="5" />
        <main class="fixed-contract-page__content fixed-contract-legal">
          <p><strong>DECIMO SEGUNDA.</strong> El trabajador para todos los efectos legales y en especial para la aplicación de parágrafo 1 de artículo 6 de la ley 2466 del 25de junio del 2025, inciso 1, se compromete a informar por escrito y de manera inmediata al empleador, cualquier cambio de direcciones de residencia, teniéndose como suya la última dirección registrada en la hoja de vida.</p>
          <p><strong>SEPTIMA– CLAUSULA DE CONFIENZALIDAD</strong> El trabajador manifiesta la responsabilidad de no reproducir, hacer pública o divulgar a terceros la información objeto del presente contrato y cumplir con las medidas de seguridad adecuadas al tipo de documento con el que se trabaje en lo que se tiene que ver con todo el sistema financiero que tiene acceso en la compañía mientras exista y divulgación de información del personal.</p>
          <h2 class="fixed-signatures-title">FIRMAS</h2>
          <table class="fixed-signatures-table">
            <tbody>
              <tr><th>EL EMPLEADOR</th><th>EL(LA) TRABAJADOR(A)</th></tr>
              <tr class="fixed-sign-row"><td>(Firme aquí)</td><td>(Firme aquí)</td></tr>
              <tr><td><strong>{{ companyName() }}</strong></td><td><strong>{{ employeeFullName() }}</strong></td></tr>
              <tr><td>{{ companyNitLabel() }}</td><td>{{ employeeDocumentType() }} {{ employeeDocumentNumber() }}</td></tr>
              <tr><td></td><td><strong>Dirección:</strong> {{ employeeAddress() }}</td></tr>
              <tr><td></td><td><strong>Correo Electrónico:</strong> {{ employeeEmail() }}</td></tr>
            </tbody>
          </table>
          <p class="fixed-signature-caption">Para constancia se firma en:</p>
          <table class="fixed-signature-location">
            <tbody>
              <tr><th>Ciudad:</th><td>{{ signatureCity() }}</td></tr>
              <tr><th>Fecha:</th><td>{{ signatureDateText() }}</td></tr>
              <tr><th>Numero de contrato</th><td>{{ contractNumber() }}</td></tr>
            </tbody>
          </table>
        </main>
        <app-contract-document-control class="fixed-contract-page__footer" [version]="templateVersion()" [validityDate]="templateValidityDate()" />
      </section>

      <!-- Página 6 conservada intencionalmente porque existe en las fuentes PDF y DOCX. -->
      <section class="fixed-contract-page fixed-contract-page--6">
        <app-contract-fixed-document-header class="fixed-contract-page__header" [code]="headerCode()" [version]="templateVersion()" [validityDate]="templateValidityDate()" [pageNumber]="6" />
        <main class="fixed-contract-page__content" aria-label="Página institucional sin contenido contractual"></main>
        <app-contract-document-control class="fixed-contract-page__footer" [version]="templateVersion()" [validityDate]="templateValidityDate()" />
      </section>
    </article>
  `,
})
export class ContractFixedTermComponent {
  readonly data = input.required<ContractGenerationData>();

  headerCode(): string { return this.value(this.data().parametros.reemplazos.CODIGO_FORMATO ?? this.data().parametros.plantilla.codigo_formato, 'BBTH-F-015'); }
  templateVersion(): string { return this.value(this.data().parametros.reemplazos.VERSION_FORMATO ?? this.data().parametros.plantilla.version_formato, '02'); }
  templateValidityDate(): string { return this.value(this.data().parametros.reemplazos.FECHA_VIGENCIA_TEXTO ?? this.data().parametros.plantilla.fecha_vigencia, '18/06/2026'); }
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
  transportAidText(): string { return this.value(this.data().parametros.reemplazos.AUXILIO_TRANSPORTE_TEXTO); }
  paymentPeriod(): string { return this.value(this.data().parametros.reemplazos.PERIODO_PAGO ?? this.data().contrato.periodo_pago); }
  contractStartDateText(): string { return this.value(this.data().parametros.reemplazos.FECHA_INICIO_TEXTO ?? this.data().contrato.fecha_inicio); }
  contractEndDateText(): string { return this.value(this.data().parametros.reemplazos.FECHA_FIN_TEXTO ?? this.data().contrato.fecha_fin); }
  contractWorkplace(): string { return this.value(this.data().parametros.reemplazos.LUGAR_LABORES ?? this.data().contrato.lugar_labores); }
  initialContractTerm(): string { return this.value(this.data().parametros.reemplazos.TERMINO_INICIAL_CONTRATO ?? this.data().contrato.duracion_meses); }
  contractFunctions(): string { return this.value(this.data().parametros.reemplazos.CLAUSULA_FUNCIONES ?? this.data().contrato.clausula_funciones); }
  signatureCity(): string { return this.value(this.data().firmas.ciudad_firma ?? this.data().parametros.reemplazos.CIUDAD_FIRMA); }
  signatureDateText(): string { return this.value(this.data().firmas.fecha_firma_texto ?? this.data().parametros.reemplazos.FECHA_FIRMA_TEXTO); }
  contractNumber(): string { return this.value(this.data().parametros.reemplazos.NUMERO_CONTRATO ?? this.data().contrato.numero_contrato); }

  private value(value: unknown, fallback = 'Sin dato'): string {
    if (value === null || value === undefined || String(value).trim() === '') return fallback;
    return String(value).trim();
  }
}
