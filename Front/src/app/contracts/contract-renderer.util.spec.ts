import { resolveContractRenderer } from './contract-renderer.util';
import { ContractGenerationData } from './models/contract-generation.models';

function baseData(): ContractGenerationData {
  return {
    empresa: {},
    empleado: {},
    contrato: {},
    firmas: {},
    parametros: {
      plantilla: {},
      reemplazos: {},
    },
  };
}

describe('resolveContractRenderer', () => {
  it('selects work renderer for contract type id 4', () => {
    const data = baseData();
    data.contrato.id_tipo_contrato = 4;
    data.contrato.tipo_contrato = 'Otro';

    expect(resolveContractRenderer(data)).toBe('work');
  });

  it('keeps indefinite renderer for contract type id 2', () => {
    const data = baseData();
    data.contrato.id_tipo_contrato = 2;
    data.contrato.tipo_contrato = 'Indefinido';

    expect(resolveContractRenderer(data)).toBe('indefinite');
  });

  it('keeps fixed-term renderer for contract type id 3', () => {
    const data = baseData();
    data.contrato.id_tipo_contrato = 3;
    data.contrato.tipo_contrato = 'Fijo';

    expect(resolveContractRenderer(data)).toBe('fixed-term');
  });
});
