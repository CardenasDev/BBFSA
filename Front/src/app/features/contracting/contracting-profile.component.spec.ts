import { describe, expect, it } from 'vitest';
import { contractingNullableInteger, contractingStudyStatus } from './contracting-profile.component';

describe('ContractingProfileComponent mappings', () => {
  it('preserves the three menores_estudian states returned by the API', () => {
    expect(contractingStudyStatus(1)).toBe(true);
    expect(contractingStudyStatus(0)).toBe(false);
    expect(contractingStudyStatus(null)).toBeNull();
  });

  it('preserves boolean menores_estudian values sent by the form', () => {
    expect(contractingStudyStatus(true)).toBe(true);
    expect(contractingStudyStatus(false)).toBe(false);
    expect(contractingStudyStatus(undefined)).toBeNull();
  });

  it('accepts only nullable integers for personas_vivienda', () => {
    expect(contractingNullableInteger('4')).toBe(4);
    expect(contractingNullableInteger(0)).toBe(0);
    expect(contractingNullableInteger('')).toBeNull();
    expect(contractingNullableInteger(-1.5)).toBeNull();
  });
});
