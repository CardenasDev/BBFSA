export type NoveltyStatus='REGISTRADA'|'VALIDADA'|'CERRADA'|'ANULADA';
export interface NoveltyType { id_tipo_novedad:number; codigo:string; nombre:string; descripcion?:string; requiere_fecha_fin:number|boolean; requiere_soporte:number|boolean; es_incapacidad:number|boolean; activo:number|boolean; }
export interface Novelty { id_novedad:number; id_empleado:number; numero_documento:string; nombre_completo:string; tipo_novedad:string; codigo_tipo_novedad:string; es_incapacidad:number|boolean; fecha_inicio:string; fecha_fin?:string|null; numero_dias:number; motivo?:string|null; observaciones?:string|null; estado:NoveltyStatus; id_incapacidad?:number|null; eps?:string|null; diagnostico?:string|null; codigo_cie10?:string|null; origen_incapacidad?:string|null; numero_certificado?:string|null; numero_radicado?:string|null; entidad_emisora?:string|null; es_prorroga?:number|boolean; id_incapacidad_origen?:number|null; fecha_radicacion?:string|null; total_evidencias?:number; }
export interface NoveltyEvidence { id_novedad_evidencia:number; tipo_evidencia:string; nombre_archivo:string; nombre_original?:string|null; archivo_url?:string|null; archivo_ruta?:string|null; archivo_url_publica?:string|null; mime_type?:string|null; peso_bytes?:number|null; observaciones?:string|null; created_at:string; }
export interface NoveltyHistory { id_novedad_historial:number; accion:string; estado_anterior?:string|null; estado_nuevo?:string|null; detalle?:string|null; nombre_usuario:string; created_at:string; }
export interface NoveltyDetail { novelty:Novelty; evidence:NoveltyEvidence[]; history:NoveltyHistory[]; }
export interface NoveltyFilters { employee_id?:number|null; type?:string; status?:string; date_from?:string; date_to?:string; }
export interface NoveltyPayload { employee_id?:number; type?:string; start_date:string; end_date?:string|null; reason?:string|null; observations?:string|null; }
export interface DisabilityPayload extends NoveltyPayload { end_date:string; diagnosis?:string|null; cie10_code?:string|null; eps_id?:number|null; origin:string; certificate_number?:string|null; filing_number?:string|null; issuer?:string|null; is_extension?:boolean; source_disability_id?:number|null; filing_date?:string|null; }
export type DisabilityTrackingStatus='PENDIENTE'|'EN_TRAMITE'|'CERRADO'|'CANCELADO';
export interface DisabilityTracking {
 id_novedad:number; id_incapacidad:number; id_incapacidad_seguimiento:number;
 id_entidad_responsable?:number|null; entidad_responsable?:string|null; tipo_entidad?:string|null;
 dias_pagados_empresa:number; dias_pagar_entidad:number;
 estado_transcripcion:'NO_REQUIERE'|'PENDIENTE'|'TRANSCRITA'|'RECHAZADA'; canal_transcripcion?:string|null; fecha_transcripcion?:string|null;
 estado_solicitud_pago:'NO_REQUIERE'|'PENDIENTE'|'RADICADA'|'EN_ESTUDIO'|'APROBADA'|'RECHAZADA'|'PAGADA_PARCIAL'|'PAGADA'; fecha_solicitud_pago?:string|null;
 valor_incapacidad:number; valor_recibido_entidad:number; valor_pagado_empresa_trabajador:number; valor_pagado_trabajador:number; valor_adeudado_entidad:number;
 fecha_ultimo_pago?:string|null; estado_seguimiento:DisabilityTrackingStatus; observaciones_seguimiento?:string|null;
 numero_documento?:string; apellido_y_nombre_completo?:string; fecha_inicio?:string; fecha_fin?:string; dias_incapacidad?:number; diagnostico?:string; numero_incapacidad?:string; estado_trabajador?:string;
}
export interface DisabilityTrackingPayload {
 responsible_entity_id?:number|null; days_paid_company:number; days_payable_entity:number;
 transcription_status:string; transcription_channel?:string|null; transcription_date?:string|null;
 payment_request_status:string; payment_request_date?:string|null;
 disability_value:number; entity_received_value:number; company_paid_worker_value:number; worker_paid_value:number;
 last_payment_date?:string|null; tracking_status:DisabilityTrackingStatus; tracking_observations?:string|null;
}
export interface DisabilityTrackingFilters { employee_id?:number|null; responsible_entity_id?:number|null; tracking_status?:string; date_from?:string; date_to?:string; }
