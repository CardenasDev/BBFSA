export interface GenderBreakdown {
  genero: string;
  total_activos: number;
}

export interface KpiData {
  tasa_rotacion_3m: number;
  salidas_ultimos_3m: number;
  promedio_activos_3m: number;
  ventana_inicio: string;
  ventana_fin: string;
  metodo_calculo: string;
  desglose_genero: GenderBreakdown[];
  fecha_calculo: string;
}