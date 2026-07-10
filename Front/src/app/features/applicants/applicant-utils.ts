import { Applicant, ApplicantDocumentStatus, ApplicantStatus } from '../../core/models/api.models';

export const APPLICANT_STATUSES: ApplicantStatus[] = [
  'REGISTRADO',
  'EN_REVISION',
  'APROBADO_CONTRATACION',
  'RECHAZADO',
  'CONVERTIDO_EMPLEADO',
  'CANCELADO',
];

export const MANUAL_APPLICANT_STATUSES: ApplicantStatus[] = [
  'REGISTRADO',
  'EN_REVISION',
  'APROBADO_CONTRATACION',
  'RECHAZADO',
  'CANCELADO',
];

export const APPLICANT_DOCUMENT_STATUSES: ApplicantDocumentStatus[] = [
  'PENDIENTE',
  'CARGADO',
  'VALIDADO',
  'RECHAZADO',
  'VENCIDO',
];

export function applicantName(applicant: Pick<Applicant, 'nombres' | 'apellidos' | 'nombre_completo'> | null | undefined): string {
  return applicant?.nombre_completo || `${applicant?.nombres ?? ''} ${applicant?.apellidos ?? ''}`.trim() || 'Aspirante';
}

export function applicantStatusClass(status: ApplicantStatus | string | null | undefined): string {
  if (status === 'APROBADO_CONTRATACION') return 'success';
  if (status === 'CONVERTIDO_EMPLEADO') return 'neutral';
  if (status === 'RECHAZADO') return 'danger';
  if (status === 'CANCELADO') return 'neutral';
  if (status === 'EN_REVISION') return 'warning';
  return 'info';
}

export function canApproveApplicant(applicant: Applicant): boolean {
  return applicant.estado_aspirante === 'REGISTRADO' || applicant.estado_aspirante === 'EN_REVISION';
}

export function canConvertApplicant(applicant: Applicant): boolean {
  return applicant.estado_aspirante === 'APROBADO_CONTRATACION' && !applicant.id_empleado_generado;
}

export function blankToNull(value: unknown): string | null {
  const text = String(value ?? '').trim();
  return text === '' ? null : text;
}

export function toNullableNumber(value: unknown): number | null {
  if (value === '' || value == null) return null;
  const numberValue = Number(value);
  return Number.isFinite(numberValue) && numberValue > 0 ? numberValue : null;
}
