import { ContractGenerationData, ContractRendererType } from './models/contract-generation.models';

export function resolveContractRenderer(data: ContractGenerationData): ContractRendererType {
  const contractTypeId = Number(data.contrato.id_tipo_contrato ?? data.parametros.plantilla.id_tipo_contrato ?? 0);

  if (contractTypeId === 4) {
    return 'work';
  }

  if (contractTypeId === 3) {
    return 'fixed-term';
  }

  if (contractTypeId === 2) {
    return 'indefinite';
  }

  const type = (
    data.contrato.tipo_contrato
    || data.contrato.nombre_tipo_contrato
    || data.parametros.plantilla.tipo_contrato
    || ''
  ).toUpperCase();

  if (type.includes('OBRA') || type.includes('LABOR')) {
    return 'work';
  }

  if (type.includes('FIJO')) {
    return 'fixed-term';
  }

  if (type.includes('INDEFIN')) {
    return 'indefinite';
  }

  return 'base';
}
