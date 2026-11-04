export function calculateEmployeeTotalStatus(total: number): string | number {
  const value = Number(total) || 0;

  if (value === 0) {
    return '';
  }
  if (value >= 500) {
    return 'EXCELENTE';
  }
  if (value > 400) {
    return 100;
  }
  if (value <= 250) {
    return 'LLAMADO DE ATENCION';
  }
  return 'FALTA';
}