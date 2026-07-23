import { parseContractFunctions, validateWorkContractData } from './contract-work-validation.util';
import { ContractGenerationData } from './models/contract-generation.models';

function buildWorkData(overrides: Partial<ContractGenerationData>): ContractGenerationData {
  return {
    empresa: {},
    empleado: {},
    contrato: {
      id_tipo_contrato: 4,
      objeto_obra_labor: 'Corte y clasificación de flor',
      clausula_funciones: '1. Realizar corte seguro de flor\n2. Clasificar por calidad',
    },
    firmas: {},
    parametros: {
      plantilla: { id_tipo_contrato: 4 },
      reemplazos: {},
    },
    ...overrides,
  };
}

describe('contract work validation', () => {
  it('parses numbered function lists', () => {
    const parsed = parseContractFunctions('1. Función uno\n2) Función dos');
    expect(parsed).toEqual(['Función uno', 'Función dos']);
  });

  it('rejects work contracts when functions are missing', () => {
    const data = buildWorkData({
      contrato: {
        id_tipo_contrato: 4,
        objeto_obra_labor: 'Cosecha operativa',
        clausula_funciones: 'funciones',
      },
    });

    expect(validateWorkContractData(data)).toContain('configurar las funciones');
  });

  it('rejects work contracts when labor object is missing', () => {
    const data = buildWorkData({
      contrato: {
        id_tipo_contrato: 4,
        objeto_obra_labor: '',
        clausula_funciones: 'Empacar flor exportación',
      },
    });

    expect(validateWorkContractData(data)).toContain('descripcion de la obra o labor');
  });
});
