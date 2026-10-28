export type EvaluationStatus = 'BORRADOR' | 'EN_PROCESO' | 'COMPLETADA' | 'CERRADA';

export interface EvaluationList {
  id_evaluacion: number;
  anio: number;
  numero_semana: number;
  nombre_semana?: string | null;
  fecha_inicio: string;
  fecha_fin?: string | null;
  estado: EvaluationStatus;
  observaciones?: string | null;
  id_usuario_crea?: number;
  created_at?: string;
}

export interface EvaluationLabor {
  id_evaluacion_labor: number;
  codigo: string;
  nombre: string;
  descripcion?: string | null;
  ponderacion_maxima_default?: number;
  ponderacion_maxima?: number;
  orden?: number;
  activo?: boolean;
}

export interface EvaluationScore {
  id_evaluacion_detalle?: number;
  id_evaluacion_empleado?: number;
  id_empleado?: number;
  id_evaluacion_labor: number;
  valor_obtenido: number;
  valor_maximo?: number | null;
  observaciones?: string | null;
  codigo?: string;
  nombre?: string;
  labor?: string;
  codigo_labor?: string;
}

export interface EvaluationEmployee {
  id_evaluacion_empleado: number;
  id_evaluacion?: number;
  id_empleado: number;
  estado_evaluacion: string;
  observaciones?: string | null;
  numero_documento?: string;
  nombres?: string;
  apellidos?: string;
  empleado?: string;
  estado_empleado?: string;
  detalles?: EvaluationScore[];
  total_semana?: number;
}

export interface EvaluationDetail {
  evaluation: EvaluationList;
  employees: EvaluationEmployee[];
}

export interface EvaluationLaborDetail {
  id_evaluacion_labor: number;
  codigo: string;
  nombre: string;
  ponderacion_maxima: number;
  camas_ejecutadas: number;
  meta_camas: number;
  porcentaje_avance: number | null;
  camas_pendientes: number;
  estado_labor: 'Iniciado' | 'En Proceso' | 'Completado';
  total_empleados: number;
}

export interface EvaluationManagementSummary {
  total_camas_ejecutadas: number;
  total_meta_camas: number;
  porcentaje_cobertura_global: number | null;
  estado_consolidado?: string;
  total_empleados: number;
}

export interface EvaluationManagementPanel {
  evaluation: EvaluationList;
  labores: EvaluationLaborDetail[];
  resumen: EvaluationManagementSummary;
}

export interface EvaluationScoreInput {
  id_empleado: number;
  id_evaluacion_labor: number;
  valor_obtenido: number;
  valor_maximo?: number | null;
  observaciones?: string | null;
}
