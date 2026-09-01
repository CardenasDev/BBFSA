export type NotificationPriority = 'BAJA' | 'MEDIA' | 'ALTA' | 'CRITICA';

export interface AppNotification {
  id_notificacion: number;
  tipo_codigo: string;
  tipo_notificacion: string;
  modulo: string;
  id_empleado?: number | null;
  titulo: string;
  mensaje: string;
  prioridad: NotificationPriority;
  fecha_evento?: string | null;
  fecha_vencimiento?: string | null;
  estado: string;
  url_accion?: string | null;
  datos_json?: string | null;
  leida: boolean | number;
  fecha_lectura?: string | null;
  archivada: boolean | number;
  created_at: string;
  dias_restantes?: number | null;
}

export interface NotificationSummary {
  total_activas: number;
  total_no_leidas: number;
  total_criticas: number;
  total_contratacion: number;
  total_capacitaciones: number;
  total_novedades: number;
}
