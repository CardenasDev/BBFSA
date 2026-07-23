import { ContractGenerationData } from './models/contract-generation.models';

export function parseContractFunctions(rawValue: unknown): string[] {
  if (rawValue === null || rawValue === undefined) {
    return [];
  }

  const source = String(rawValue).trim();
  if (!source || /^sin dato$/i.test(source) || /^funciones\.?$/i.test(source)) {
    return [];
  }

  const sanitized = source
    .replace(/<br\s*\/?>/gi, '\n')
    .replace(/<\/p>/gi, '\n')
    .replace(/<\/li>/gi, '\n')
    .replace(/<li[^>]*>/gi, '\n- ')
    .replace(/<[^>]+>/g, ' ')
    .replace(/&nbsp;/gi, ' ')
    .replace(/\r/g, '')
    .replace(/\s+(\d{1,2}[.)])/g, '\n$1')
    .replace(/\s+([a-zA-Z][)])/g, '\n$1');

  const lines = sanitized
    .split(/\n+/)
    .map((line) => line.replace(/^(?:\d{1,2}[.)]|[a-zA-Z][)]|[-*•])\s*/u, '').replace(/\s+/g, ' ').trim())
    .filter((line) => line.length > 0 && !/^funciones\.?$/i.test(line));

  if (lines.length > 1) {
    return lines;
  }

  return sanitized
    .split(/;+/)
    .map((line) => line.replace(/\s+/g, ' ').trim())
    .filter((line) => line.length > 0 && !/^funciones\.?$/i.test(line));
}

export function validateWorkContractData(data: ContractGenerationData): string {
  const replacementFunctions = data.parametros.reemplazos.CLAUSULA_FUNCIONES;
  const contractFunctions = data.contrato.clausula_funciones;
  const functions = parseContractFunctions(replacementFunctions ?? contractFunctions);
  if (functions.length === 0) {
    return 'No es posible generar el contrato por obra o labor: debes configurar las funciones de la labor contratada.';
  }

  const workObject = String(data.parametros.reemplazos.OBJETO_OBRA_LABOR ?? data.contrato.objeto_obra_labor ?? '').trim();
  if (!workObject) {
    return 'No es posible generar el contrato por obra o labor: falta la descripcion de la obra o labor contratada.';
  }

  return '';
}
