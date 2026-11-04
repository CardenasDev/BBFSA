export interface IsoWeekInfo {
  year: number;
  week: number;
}

function toDate(value: string | Date | number | null | undefined): Date {
  if (value instanceof Date) {
    return new Date(value.getTime());
  }

  if (typeof value === 'number') {
    return new Date(value);
  }

  const text = String(value ?? '').trim();
  if (!text) {
    return new Date();
  }

  const isoMatch = text.match(/^(\d{4})-(\d{2})-(\d{2})$/);
  if (isoMatch) {
    const year = Number(isoMatch[1]);
    const month = Number(isoMatch[2]) - 1;
    const day = Number(isoMatch[3]);
    return new Date(year, month, day);
  }

  const parsed = new Date(text);
  return Number.isNaN(parsed.getTime()) ? new Date() : parsed;
}

function pad(value: number): string {
  return String(value).padStart(2, '0');
}

export function toIsoDate(value: string | Date | number | null | undefined): string {
  const date = toDate(value);
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}`;
}

export function parseEvaluationDate(value: string | Date | number | null | undefined): Date {
  return toDate(value);
}

export function addDays(value: string | Date | number | null | undefined, days: number): string {
  const date = toDate(value);
  date.setDate(date.getDate() + days);
  return toIsoDate(date);
}

export function getIsoWeek(value: string | Date | number | null | undefined): IsoWeekInfo {
  const date = toDate(value);
  const utcDate = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()));
  const dayNumber = utcDate.getUTCDay() || 7;
  utcDate.setUTCDate(utcDate.getUTCDate() + 4 - dayNumber);

  const isoYear = utcDate.getUTCFullYear();
  const yearStart = new Date(Date.UTC(isoYear, 0, 1));
  const week = Math.ceil((((utcDate.getTime() - yearStart.getTime()) / 86400000) + 1) / 7);

  return { year: isoYear, week };
}

export function getIsoWeekNumber(value: string | Date | number | null | undefined): number {
  return getIsoWeek(value).week;
}

export function getIsoWeekYear(value: string | Date | number | null | undefined): number {
  return getIsoWeek(value).year;
}

export function calculateFechaFin(fechaInicio: string | Date | number | null | undefined): string {
  return addDays(fechaInicio, 6);
}

export function calculateAnio(fechaInicio: string | Date | number | null | undefined): number {
  return getIsoWeekYear(fechaInicio);
}

export function calculateNumeroSemana(fechaInicio: string | Date | number | null | undefined): number {
  return getIsoWeekNumber(fechaInicio);
}

export function calculateEvaluationWeek(fechaInicio: string | Date | number | null | undefined): {
  anio: number;
  numero_semana: number;
  nombre_semana: string;
  fecha_fin: string;
} {
  const week = getIsoWeek(fechaInicio);
  return {
    anio: week.year,
    numero_semana: week.week,
    nombre_semana: `Semana ${week.week}`,
    fecha_fin: calculateFechaFin(fechaInicio),
  };
}

// Aliases for common naming conventions.
export const getISOWeek = getIsoWeek;
export const getISOWeekNumber = getIsoWeekNumber;
export const getISOWeekYear = getIsoWeekYear;
export const getIsoWeekInfo = getIsoWeek;
export const calculateIsoWeek = calculateEvaluationWeek;
export const calculateWeekRange = calculateEvaluationWeek;
export const calculateWeek = calculateEvaluationWeek;
export const isoWeek = getIsoWeek;
export const weekRange = calculateEvaluationWeek;

export * from './evaluation-status.util';