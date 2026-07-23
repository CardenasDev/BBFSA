import { TestBed } from '@angular/core/testing';
import { ContractWorkComponent } from './contract-work.component';
import { ContractGenerationData } from '../models/contract-generation.models';

function buildData(): ContractGenerationData {
  return {
    empresa: {
      razonSocial: 'BARRO BLANCO FARMS S.A.S',
      nit: '900747203-1',
      domicilio: 'VEREDA SAN JOSE FINCA BARRO BLANCO',
      correo: 'barroblancofarms@gmail.com',
    },
    empleado: {
      nombre_completo: 'Juan Perez',
      tipo_documento: 'Cédula de ciudadanía',
      numero_documento: '123456789',
      direccion_residencia: 'Calle 10 # 10 - 10',
      lugar_nacimiento: 'Gachancipá',
      nacionalidad: 'Colombiana',
      correo_personal: 'juan@example.com',
    },
    contrato: {
      id_tipo_contrato: 4,
      cargo: 'Operario',
      salario_base: 1423500,
      periodo_pago: 'QUINCENAL',
      fecha_inicio: '2026-07-23',
      fecha_fin: '2026-12-23',
      lugar_labores: 'Gachancipá, Cundinamarca',
      objeto_obra_labor: 'Corte y clasificación de flor',
      prorroga_dias: 15,
      clausula_funciones: '1. Corte técnico\n2. Clasificación por calidad\n3. Empaque final',
      numero_contrato: 'CT-2026-014',
    },
    firmas: {
      ciudad_firma: 'Gachancipá',
      fecha_firma_texto: '23 de julio de 2026',
    },
    parametros: {
      plantilla: {
        id_tipo_contrato: 4,
        codigo_formato: 'BBTH-F-014',
        version_formato: '02',
        fecha_vigencia: '2026-06-18',
      },
      reemplazos: {
        CODIGO_FORMATO: 'BBTH-F-014',
        VERSION_FORMATO: '02',
        FECHA_VIGENCIA_TEXTO: '18/06/2026',
      },
    },
  };
}

describe('ContractWorkComponent', () => {
  it('renders five useful pages and final signature section', async () => {
    await TestBed.configureTestingModule({
      imports: [ContractWorkComponent],
    }).compileComponents();

    const fixture = TestBed.createComponent(ContractWorkComponent);
    fixture.componentRef.setInput('data', buildData());
    fixture.detectChanges();

    const element = fixture.nativeElement as HTMLElement;
    const pages = element.querySelectorAll('.work-contract-page');
    expect(pages.length).toBe(5);
    expect(element.textContent).toContain('Página 5 de 5');
    expect(element.textContent).toContain('FIRMAS');
  });

  it('does not render null or undefined placeholders', async () => {
    await TestBed.configureTestingModule({
      imports: [ContractWorkComponent],
    }).compileComponents();

    const fixture = TestBed.createComponent(ContractWorkComponent);
    fixture.componentRef.setInput('data', buildData());
    fixture.detectChanges();

    const text = (fixture.nativeElement as HTMLElement).textContent ?? '';
    expect(text).not.toContain('undefined');
    expect(text).not.toContain('null');
  });

  it('renders the literal BBTH-F-014 body without reused or dynamic clauses', async () => {
    await TestBed.configureTestingModule({
      imports: [ContractWorkComponent],
    }).compileComponents();

    const fixture = TestBed.createComponent(ContractWorkComponent);
    fixture.componentRef.setInput('data', buildData());
    fixture.detectChanges();

    const element = fixture.nativeElement as HTMLElement;
    const text = element.textContent ?? '';
    const functions = Array.from(element.querySelectorAll('.fixed-number-list li'))
      .map((item) => item.textContent?.trim());
    expect(text).toContain('PRIMERO: el empleador contrata los servicios.');
    expect(text).toContain('desempeñándose como trabajador en MISION, de acuerdo con las instrucciones');
    expect(text).toContain('b)A no prestar la labor requerida por la empresa.');
    expect(text).toContain('La obra o labor se prestará en el municipio de Gachancipa.');
    expect(functions).toEqual([
      'Realizar la labor a que se refiere el presente contrato.',
      'Realizar las labores acordadas con el empleador.',
      'Realizar labores netamente en lo que tiene que ver con la floricultura.',
    ]);
    expect(text).toContain('arroja como resultados una cifra superior a 0.0.');
    expect(text).toContain('Las modificaciones que se acuerden al presente contrato se anotarán a continuación de su texto.');
    expect(text).not.toContain('Funciones dt');
    expect(text).not.toContain('Corte técnico');
    expect(text).not.toContain('ejecutando la obra o labor contratada');
    expect(text).not.toContain('A no prestar directa ni indirectamente');
    expect(text).not.toContain('Los servicios se prestarán');
    expect(text).not.toContain('municipio de VEREDA SAN JOSE');
  });
});
