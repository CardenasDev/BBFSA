export type TrainingType = 'CAPACITACION' | 'INDUCCION' | 'REINDUCCION' | 'EVALUACION_REINDUCCION';
export type TrainingSessionStatus =
  | 'BORRADOR'
  | 'PROGRAMADA'
  | 'EN_EJECUCION'
  | 'CERRADA'
  | 'ANULADA';
export type AttendanceStatus =
  | 'PENDIENTE'
  | 'ASISTIO'
  | 'NO_ASISTIO'
  | 'JUSTIFICADO'
  | 'INCAPACITADO';
export type TrainingResultStatus =
  | 'PENDIENTE'
  | 'APROBADO'
  | 'NO_APROBADO'
  | 'REQUIERE_REINDUCCION';
export type CommitmentStatus =
  | 'BORRADOR'
  | 'PENDIENTE_FIRMA'
  | 'FIRMADO'
  | 'CUMPLIDO'
  | 'INCUMPLIDO'
  | 'ANULADO';

export interface TrainingTask {
  id_capacitacion_labor: number;
  codigo: string;
  nombre: string;
  descripcion?: string | null;
  orden?: number;
  activo: boolean;
  puntaje_minimo_labor?: number | null;
  puntaje_maximo_labor?: number | null;
}
export interface Training {
  id_capacitacion: number;
  codigo: string;
  nombre: string;
  descripcion?: string | null;
  tipo: TrainingType;
  requiere_evaluacion: boolean;
  requiere_confirmacion: boolean;
  puntaje_minimo?: number | null;
  puntaje_maximo?: number | null;
  regla_calculo?: string | null;
  generar_compromiso_no_aprobado: boolean;
  dias_para_evaluar?: number | null;
  activo: boolean;
}
export interface TrainingSession {
  id_capacitacion_sesion: number;
  id_capacitacion: number;
  capacitacion?: string | null;
  nombre_capacitacion?: string;
  codigo?: string;
  fecha_inicio: string;
  fecha_fin: string;
  anio?: number;
  numero_semana?: number;
  semana?: number;
  estado: TrainingSessionStatus;
  instructor?: string | null;
  instructor_externo?: string | null;
  lugar?: string | null;
  observaciones?: string | null;
  total_participantes?: number;
}
export interface TrainingParticipant {
  id_capacitacion_participante: number;
  id_empleado: number;
  empleado?: string;
  nombre_completo?: string;
  numero_documento?: string;
  estado_asistencia?: AttendanceStatus;
  confirmo_recibido?: boolean;
  fecha_confirmacion?: string | null;
  puntaje_final?: number | null;
  puntaje_minimo?: number | null;
  resultado?: TrainingResultStatus | null;
  id_capacitacion_resultado?: number | null;
  id_capacitacion_compromiso?: number | null;
  estado_compromiso?: CommitmentStatus | null;
  observaciones?: string | null;
}
export interface TrainingEvaluation {
  id_capacitacion_evaluacion?: number;
  id_capacitacion_participante: number;
  id_capacitacion_labor: number;
  fecha_evaluacion: string;
  valor_obtenido: number;
  valor_maximo?: number | null;
  requiere_atencion?: boolean;
  observaciones?: string | null;
}
export interface TrainingSessionDetail {
  session: TrainingSession;
  participants: TrainingParticipant[];
  evaluations: TrainingEvaluation[];
}
export interface TrainingAlert {
  id_empleado?: number;
  empleado?: string;
  nombre_completo?: string;
  tipo_alerta?: string;
  mensaje?: string;
  capacitacion?: string;
  fecha?: string;
  resultado?: TrainingResultStatus;
  id_capacitacion_resultado?: number | null;
  requiere_compromiso?: boolean;
  id_capacitacion_compromiso?: number | null;
  [key: string]: unknown;
}
export interface TrainingCommitment {
  id_capacitacion_compromiso: number;
  id_capacitacion_resultado: number;
  id_empleado?: number;
  empleado?: string;
  nombre_completo?: string;
  capacitacion?: string;
  fecha_compromiso?: string;
  fecha_limite?: string | null;
  motivo: string;
  compromisos_empleado?: string | null;
  estado: CommitmentStatus;
  documento_url?: string | null;
  documento_ruta?: string | null;
  firma_url?: string | null;
  observaciones?: string | null;
  cargo?: string | null;
  area?: string | null;
  numero_documento?: string | null;
  resultado?: TrainingResultStatus;
  puntaje_final?: number | null;
  puntaje_minimo_aplicado?: number | null;
  fecha_resultado?: string | null;
  tipo_capacitacion?: TrainingType;
  fecha_inicio?: string | null;
  fecha_fin?: string | null;
  numero_semana?: number | null;
  lugar?: string | null;
  creado_por?: string | null;
}
export interface TrainingImportResult {
  importacion?: {
    estado?: string;
    total_registros?: number;
    registros_validos?: number;
    resumen?: string;
  };
  errores: Array<{
    hoja?: string;
    celda?: string;
    fila?: number;
    empleado?: string;
    labor?: string;
    mensaje: string;
  }>;
  aplicados: number;
}
