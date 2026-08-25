export interface RetirementReason{id_motivo_retiro:number;codigo:string;nombre:string;descripcion?:string;requiere_renuncia:boolean|number}
export interface RetirementRow{id_retiro:number;id_empleado:number;numero_documento:string;empleado:string;motivo_retiro:string;fecha_inicio_proceso:string;fecha_retiro:string;estado:string;actividades_pendientes:number}
export interface RetirementActivity{id_retiro_actividad:number;codigo:string;nombre:string;descripcion?:string;obligatoria:boolean|number;requiere_documento:boolean|number;cantidad_documentos:number;estado:string;observaciones?:string}
export interface RetirementDocument{id_empleado_documento:number;nombre_archivo:string;nombre_original?:string;tipo_documento:string;periodo_documento?:string;archivo_url_publica?:string;fecha_carga:string}
export interface RetirementDetail{retirement:any;activities:RetirementActivity[];documents:RetirementDocument[];interview:any|null}
export interface RetirementDocumentType{id_tipo_documento_laboral:number;nombre:string;descripcion?:string;obligatorio:boolean|number}
