export interface ApiResponse<T> {
  success: boolean;
  message: string;
  data: T;
  errors?: Record<string, string[]>;
}

export interface LoginRequest {
  usuario: string;
  password: string;
}

export interface AuthUser {
  id_usuario: number;
  id_empleado?: number | null;
  nombre_usuario: string;
  correo: string;
  tipo_usuario: string;
  tipo_autenticacion: string;
  estado: UserStatus;
  requiere_cambio_password?: boolean | number;
  correo_verificado?: boolean | number;
}

export interface Role {
  id_rol: number;
  nombre: string;
  descripcion?: string | null;
  activo: boolean | number;
}

export interface Permission {
  id_permiso: number;
  codigo: string;
  nombre: string;
  modulo: string;
  descripcion?: string | null;
  activo: boolean | number;
}

export interface Domain {
  id_dominio: number;
  dominio: string;
  activo: boolean | number;
}

export interface DocumentType {
  id_tipo_documento: number;
  nombre: string;
  activo: boolean;
}

export interface Area {
  id_area: number;
  nombre: string;
  descripcion?: string | null;
  activo: boolean;
}

export interface Position {
  id_cargo: number;
  nombre: string;
  descripcion?: string | null;
  activo: boolean;
}

export interface ContractType {
  id_tipo_contrato: number;
  nombre: string;
  descripcion?: string | null;
  activo: boolean;
}

export interface Department {
  id_departamento: number;
  codigo_dane: string;
  nombre: string;
}

export interface Municipality {
  id_municipio: number;
  id_departamento: number;
  codigo_dane: string;
  nombre: string;
}

export interface LaborDocumentType {
  id_tipo_documento_laboral: number;
  nombre: string;
  descripcion?: string | null;
  obligatorio?: boolean | number | null;
  requiere_vencimiento?: boolean | number | null;
  aplica_aspirante?: boolean | number | null;
  aplica_contratacion?: boolean | number | null;
  aplica_retiro?: boolean | number | null;
  activo?: boolean | number | null;
}

export interface LoginResponse {
  access_token: string;
  refresh_token: string;
  expires_in: number;
  usuario: AuthUser;
  roles: Role[];
  permisos: Permission[];
  requiere_cambio_password: boolean;
}

export type UserStatus = 'ACTIVO' | 'INACTIVO' | 'BLOQUEADO' | 'ELIMINADO';
export type UserType = 'EMPLEADO' | 'PERSONAL_AUTORIZADO' | 'ADMIN';
export type AuthenticationType = 'LOCAL' | 'DOMINIO_EMPRESA';
export type EmployeeStatus =
  | 'ACTIVO'
  | 'RETIRADO'
  | 'SUSPENDIDO'
  | 'INCAPACITADO'
  | 'EN_PROCESO_RETIRO';
export type ContractChargeType = 'ADMINISTRATIVO' | 'OPERATIVO' | 'OTRO';
export type ContractOutputFormat = 'DOCX' | 'PDF' | 'AMBOS';
export type ApplicantCivilState =
  | 'SOLTERO'
  | 'CASADO'
  | 'UNION_LIBRE'
  | 'SEPARADO'
  | 'DIVORCIADO'
  | 'VIUDO'
  | 'OTRO';
export type ApplicantEducationLevel =
  | 'PRIMARIA'
  | 'BACHILLER'
  | 'TECNICO'
  | 'TECNOLOGO'
  | 'PROFESIONAL'
  | 'POSGRADO'
  | 'NINGUNO'
  | 'OTRO';

export interface User extends AuthUser {
  fecha_creacion?: string;
  ultimo_acceso?: string | null;
}

export interface CreateUserRequest {
  numero_documento_empleado?: string;
  nombre_usuario: string;
  correo: string;
  password: string;
  tipo_usuario: UserType;
  tipo_autenticacion: AuthenticationType;
  requiere_cambio_password: boolean;
  correo_verificado: boolean;
}

export interface ChangePasswordRequest {
  current_password: string;
  password: string;
  password_confirmation: string;
}

export interface UserFilters {
  estado?: UserStatus | '';
  tipo_usuario?: UserType | '';
  buscar?: string;
}

export interface Employee {
  id_empleado: number;
  id_tipo_documento?: number | null;
  tipo_documento?: string | null;
  numero_documento: string;
  nombres: string;
  apellidos: string;
  nombre_completo?: string | null;
  correo?: string | null;
  telefono?: string | null;
  foto_url?: string | null;
  id_area?: number | null;
  area?: string | null;
  id_cargo?: number | null;
  cargo?: string | null;
  id_tipo_contrato?: number | null;
  tipo_contrato?: string | null;
  fecha_ingreso?: string | null;
  fecha_retiro?: string | null;
  estado_empleado: EmployeeStatus;
  observaciones?: string | null;
  created_at?: string;
  updated_at?: string | null;
}

export interface EmployeePayload {
  id_tipo_documento?: number | null;
  numero_documento: string;
  nombres: string;
  apellidos: string;
  correo?: string | null;
  telefono?: string | null;
  foto_url?: string | null;
  id_area?: number | null;
  id_cargo?: number | null;
  id_tipo_contrato?: number | null;
  fecha_ingreso?: string | null;
  fecha_retiro?: string | null;
  estado_empleado: EmployeeStatus;
  observaciones?: string | null;
}

export interface EmployeeFilters {
  estado_empleado?: EmployeeStatus | '';
  id_area?: number | null;
  id_cargo?: number | null;
  texto_busqueda?: string;
}

export interface ChangeEmployeeStatusPayload {
  estado_empleado: EmployeeStatus;
  fecha_retiro?: string | null;
}

export interface Tool {
  id_herramienta: number;
  nombre: string;
  descripcion?: string | null;
  activo?: boolean | number;
  created_at?: string | null;
  updated_at?: string | null;
}

export interface ToolPayload {
  nombre: string;
  descripcion?: string | null;
}

export interface ToolDeliveryDetail {
  id_detalle?: number | null;
  id_herramienta: number;
  herramienta?: string | null;
  cantidad: number;
  observaciones?: string | null;
}

export interface ToolDeliveryEvidence {
  id_evidencia?: number | null;
  nombre_archivo?: string | null;
  nombre_original?: string | null;
  archivo_url?: string | null;
  archivo_ruta?: string | null;
  mime_type?: string | null;
  peso_bytes?: number | null;
  created_at?: string | null;
}

export interface ToolDelivery {
  id_entrega: number;
  id_empleado?: number;
  empleado?: string | null;
  nombres?: string | null;
  apellidos?: string | null;
  numero_documento?: string | null;
  fecha_entrega: string;
  estado?: 'pendiente' | 'confirmada' | string | null;
  observaciones?: string | null;
  fecha_confirmacion?: string | null;
  total_herramientas?: number;
  herramientas?: ToolDeliveryDetail[];
  evidencias?: ToolDeliveryEvidence[];
}

export interface ToolDeliveryFilters {
  id_empleado?: number | null;
  estado?: 'pendiente' | 'confirmada' | null;
}

export interface CreateToolDeliveryRequest {
  id_empleado: number;
  fecha_entrega: string;
  observaciones?: string | null;
  herramientas: Array<{
    id_herramienta: number;
    cantidad: number;
    observaciones?: string | null;
  }>;
  evidencias: File[];
}

export interface DotationType {
  id_tipo_dotacion: number;
  nombre: string;
  descripcion?: string | null;
  requiere_talla: boolean;
  activo: boolean;
}

export interface DotationSize {
  id_talla_dotacion: number;
  id_tipo_dotacion: number;
  talla: string;
  descripcion?: string | null;
  orden?: number;
  activo: boolean;
}

export type DotationArticleGender = 'HOMBRE' | 'MUJER' | 'UNISEX' | 'NO_APLICA';
export type DotationArticleUnit = 'UNIDAD' | 'PAR' | 'JUEGO';

export interface DotationArticle {
  id_dotacion_articulo: number;
  codigo: string;
  articulo: string;
  descripcion?: string | null;
  genero: DotationArticleGender;
  unidad_medida: DotationArticleUnit;
  id_tipo_dotacion: number;
  tipo_dotacion: string;
  requiere_talla: boolean;
  activo: boolean;
}

export type DotationDeliveryType = 'ORDINARIA' | 'EXTRAORDINARIA';
export type DotationEvidenceOrigin = 'ARCHIVO' | 'URL';
export type DotationDeliveryStatus = 'POR_COMPRAR' | 'REGISTRADA' | 'ENTREGADA' | 'ANULADA';

export interface DotationEvidence {
  evidencia_nombre_archivo?: string | null;
  evidencia_nombre_original?: string | null;
  evidencia_url?: string | null;
  evidencia_ruta?: string | null;
  evidencia_url_publica?: string | null;
  evidencia_mime_type?: string | null;
  evidencia_peso_bytes?: number | null;
  evidencia_fecha_carga?: string | null;
}

export interface UpdateDotationEvidenceRequest {
  origen_evidencia: DotationEvidenceOrigin;
  evidencia_nombre_archivo?: string | null;
  evidencia_archivo?: File | null;
  evidencia_url?: string | null;
}

export interface DotationCombination {
  id_dotacion_combinacion: number;
  codigo: string;
  nombre: string;
  descripcion?: string | null;
  activo: boolean;
}

export interface DotationCombinationDetail {
  id_dotacion_combinacion_detalle: number;
  id_dotacion_combinacion: number;
  codigo_combinacion: string;
  combinacion: string;
  id_tipo_dotacion: number;
  tipo_dotacion: string;
  requiere_talla: boolean;
  cantidad: number;
  orden: number;
  activo: boolean;
}

export interface MyDotationSize {
  id_dotacion_articulo: number;
  codigo_articulo: string;
  articulo: string;
  articulo_descripcion?: string | null;
  genero: string;
  unidad_medida: string;
  id_tipo_dotacion: number;
  tipo_dotacion: string;
  tipo_dotacion_descripcion?: string | null;
  requiere_talla: boolean;
  id_empleado_dotacion_articulo_talla?: number | null;
  id_talla_familia_legacy?: number | null;
  id_empleado?: number | null;
  id_talla_dotacion?: number | null;
  talla?: string | null;
  talla_descripcion?: string | null;
  origen_talla: 'ESPECIFICA' | 'HEREDADA_FAMILIA' | 'SIN_REGISTRAR';
  requiere_confirmacion: boolean;
  observaciones?: string | null;
  created_at?: string | null;
  updated_at?: string | null;
}

export interface SaveMyDotationSizeRequest {
  id_dotacion_articulo: number;
  id_talla_dotacion: number;
  observaciones?: string | null;
}

export interface DotationEmployeeSummary {
  id_empleado: number;
  numero_documento: string;
  nombre_completo: string;
  correo?: string | null;
  telefono?: string | null;
  id_area?: number | null;
  area?: string | null;
  id_cargo?: number | null;
  cargo?: string | null;
  estado_empleado: string;
  resumen_tallas?: string | null;
  total_entregas?: number | null;
  entregas_pendientes_confirmacion?: number | null;
  ultima_fecha_entrega?: string | null;
}

export interface EmployeeDotationSize {
  id_empleado: number;
  numero_documento: string;
  nombre_completo: string;
  id_tipo_dotacion: number;
  tipo_dotacion: string;
  id_empleado_dotacion_talla?: number | null;
  id_talla_dotacion?: number | null;
  talla?: string | null;
  observaciones?: string | null;
  created_at?: string | null;
  updated_at?: string | null;
}

export interface EmployeeDotationArticleSize {
  id_empleado: number;
  numero_documento: string;
  nombre_completo: string;
  id_dotacion_articulo: number;
  codigo_articulo: string;
  articulo: string;
  genero?: string | null;
  unidad_medida?: string | null;
  id_tipo_dotacion: number;
  tipo_dotacion: string;
  requiere_talla: boolean;
  id_empleado_dotacion_articulo_talla?: number | null;
  id_talla_dotacion?: number | null;
  talla?: string | null;
  observaciones?: string | null;
  created_at?: string | null;
  updated_at?: string | null;
}

export interface SaveEmployeeDotationArticleSizeRequest {
  id_talla_dotacion: number;
  observaciones?: string | null;
}

export interface EmployeeDotationHistory extends DotationEvidence {
  id_dotacion_entrega: number;
  id_empleado: number;
  numero_documento: string;
  nombre_completo: string;
  area?: string | null;
  cargo?: string | null;
  fecha_entrega: string;
  tipo_entrega: DotationDeliveryType;
  id_dotacion_combinacion?: number | null;
  codigo_combinacion?: string | null;
  nombre_combinacion?: string | null;
  fecha_confirmacion?: string | null;
  estado: DotationDeliveryStatus;
  observaciones_entrega?: string | null;
  observacion_confirmacion?: string | null;
  firma_url?: string | null;
  id_registrado_por?: number | null;
  registrado_por?: string | null;
  id_confirmado_por?: number | null;
  confirmado_por?: string | null;
  id_dotacion_entrega_detalle: number;
  id_dotacion_articulo?: number | null;
  codigo_articulo?: string | null;
  articulo: string;
  genero?: DotationArticleGender | null;
  unidad_medida?: DotationArticleUnit | null;
  id_tipo_dotacion: number;
  tipo_dotacion: string;
  id_talla_dotacion?: number | null;
  talla?: string | null;
  cantidad: number;
  observaciones_detalle?: string | null;
  created_at?: string | null;
  updated_at?: string | null;
}

export interface DotationDelivery extends DotationEvidence {
  id_dotacion_entrega: number;
  id_empleado: number;
  numero_documento: string;
  nombre_completo: string;
  fecha_entrega: string;
  tipo_entrega: DotationDeliveryType;
  id_dotacion_combinacion?: number | null;
  codigo_combinacion?: string | null;
  nombre_combinacion?: string | null;
  fecha_confirmacion?: string | null;
  estado: DotationDeliveryStatus;
  observaciones?: string | null;
  observacion_confirmacion?: string | null;
  firma_url?: string | null;
  id_registrado_por?: number | null;
  registrado_por?: string | null;
  id_confirmado_por?: number | null;
  confirmado_por?: string | null;
  created_at?: string | null;
  updated_at?: string | null;
}

export interface MyDotationDelivery extends DotationEvidence {
  id_dotacion_entrega: number;
  id_empleado: number;
  numero_documento: string;
  nombre_completo: string;
  fecha_entrega: string;
  tipo_entrega: DotationDeliveryType;
  id_dotacion_combinacion?: number | null;
  codigo_combinacion?: string | null;
  nombre_combinacion?: string | null;
  fecha_confirmacion?: string | null;
  estado: string;
  observaciones?: string | null;
  observacion_confirmacion?: string | null;
  firma_url?: string | null;
  id_registrado_por?: number | null;
  registrado_por?: string | null;
  id_confirmado_por?: number | null;
  confirmado_por?: string | null;
  created_at?: string | null;
  updated_at?: string | null;
}

export interface ConfirmDotationDeliveryRequest {
  observacion_confirmacion?: string | null;
  firma_url?: string | null;
}

export interface ConfirmedDotationDelivery {
  id_dotacion_entrega: number;
  id_empleado: number;
  fecha_entrega: string;
  fecha_confirmacion: string;
  estado: string;
  observaciones?: string | null;
  observacion_confirmacion?: string | null;
  firma_url?: string | null;
  id_confirmado_por?: number | null;
}

export interface DeleteDotationDeliveryResponse {
  id_dotacion_entrega: number;
  eliminado: boolean;
  estado: string;
  fecha_eliminacion: string;
}

export interface DotationDeliveryDetail extends DotationEvidence {
  id_dotacion_entrega_detalle: number;
  id_dotacion_entrega: number;
  id_empleado?: number | null;
  fecha_entrega?: string | null;
  tipo_entrega: DotationDeliveryType;
  id_dotacion_combinacion?: number | null;
  codigo_combinacion?: string | null;
  nombre_combinacion?: string | null;
  estado?: string | null;
  observaciones_entrega?: string | null;
  fecha_confirmacion?: string | null;
  id_dotacion_articulo?: number | null;
  codigo_articulo?: string | null;
  articulo: string;
  genero?: DotationArticleGender | null;
  unidad_medida?: DotationArticleUnit | null;
  id_tipo_dotacion: number;
  tipo_dotacion: string;
  requiere_talla?: boolean;
  id_talla_dotacion?: number | null;
  talla?: string | null;
  cantidad: number;
  observaciones?: string | null;
  created_at?: string | null;
}

export interface CreateDotationDeliveryRequest {
  id_empleado: number;
  fecha_entrega: string;
  tipo_entrega: DotationDeliveryType;
  estado_inicial: 'POR_COMPRAR' | 'REGISTRADA';
  id_dotacion_combinacion: number | null;
  origen_evidencia?: DotationEvidenceOrigin | null;
  evidencia_archivo?: File | null;
  evidencia_url?: string | null;
  evidencia_nombre_archivo?: string | null;
  observaciones?: string | null;
  detalles: {
    id_dotacion_articulo: number;
    id_tipo_dotacion: number;
    id_talla_dotacion?: number | null;
    cantidad: number;
    observaciones?: string | null;
  }[];
}

export interface PrepareDotationDeliveryRequest {
  fecha_entrega: string;
  origen_evidencia: DotationEvidenceOrigin;
  evidencia_archivo?: File | null;
  evidencia_url?: string | null;
  evidencia_nombre_archivo?: string | null;
}

export interface CreatedDotationDelivery extends DotationEvidence {
  id_dotacion_entrega: number;
  id_empleado?: number;
  fecha_entrega?: string;
  tipo_entrega?: DotationDeliveryType;
  id_dotacion_combinacion?: number | null;
  estado?: string;
}

export interface DotationEmployeeFilters {
  texto_busqueda?: string;
  id_area?: number | null;
  id_cargo?: number | null;
}

export interface DotationQuotationFilters {
  id_area?: number | null;
  id_cargo?: number | null;
  id_empleado?: number | null;
}

export interface DotationDeliveryFilters {
  id_empleado?: number | null;
  fecha_inicio?: string | null;
  fecha_fin?: string | null;
}

export interface ContractingEmployee {
  id_empleado: number;
  numero_documento: string;
  nombres?: string | null;
  apellidos?: string | null;
  nombre_completo: string;
  correo?: string | null;
  telefono?: string | null;
  id_area?: number | null;
  area?: string | null;
  id_cargo?: number | null;
  cargo?: string | null;
  id_tipo_contrato?: number | null;
  tipo_contrato?: string | null;
  fecha_ingreso?: string | null;
  fecha_retiro?: string | null;
  estado_empleado?: string | null;
  id_ficha_ingreso?: number | null;
  estado_ficha?: string | null;
  id_ultimo_contrato?: number | null;
  fecha_inicio_contrato?: string | null;
  fecha_fin_contrato?: string | null;
  estado_contrato?: string | null;
  auxilio_transporte?: boolean | number | null;
  periodo_pago?: string | null;
  lugar_labores?: string | null;
  numero_contrato?: string | null;
  tipo_cargo_contrato?: ContractChargeType | null;
  prorroga_dias?: number | null;
  ficha_pendiente?: boolean | number | null;
  contrato_proximo_vencer?: boolean | number | null;
  contrato_vencido?: boolean | number | null;
}

export interface ContractingProfile {
  id_empleado: number;
  id_aspirante_origen?: number | null;
  numero_documento?: string | null;
  nombre_completo?: string | null;
  correo?: string | null;
  telefono?: string | null;
  fecha_ingreso?: string | null;
  estado_empleado?: string | null;
  area?: string | null;
  cargo?: string | null;
  tipo_contrato?: string | null;
  id_ficha_ingreso?: number | null;
  numero_carpeta?: string | null;
  genero?: string | null;
  fecha_expedicion_documento?: string | null;
  lugar_expedicion_documento?: string | null;
  fecha_nacimiento?: string | null;
  id_departamento_nacimiento?: number | null;
  id_municipio_nacimiento?: number | null;
  lugar_nacimiento?: string | null;
  nacionalidad?: string | null;
  departamento_nacimiento?: string | null;
  id_departamento_residencia?: number | null;
  id_municipio_residencia?: number | null;
  ciudad_residencia?: string | null;
  departamento_residencia?: string | null;
  direccion_residencia?: string | null;
  telefono_alterno?: string | null;
  correo_personal?: string | null;
  estado_civil?: string | null;
  nivel_educativo?: string | null;
  personas_a_cargo?: number | null;
  numero_hijos?: number | null;
  personas_vivienda?: number | null;
  menores_estudian?: boolean | number | null;
  estado_ficha?: string | null;
  observaciones?: string | null;
  id_contacto_emergencia?: number | null;
  contacto_nombre_completo?: string | null;
  contacto_parentesco?: string | null;
  contacto_telefono?: string | null;
  contacto_telefono_alterno?: string | null;
  contacto_direccion?: string | null;
  contacto_observaciones?: string | null;
}

export interface SaveContractingProfileRequest {
  numero_carpeta?: string | null;
  genero?: string | null;
  fecha_expedicion_documento?: string | null;
  lugar_expedicion_documento?: string | null;
  fecha_nacimiento?: string | null;
  id_departamento_nacimiento?: number | null;
  id_municipio_nacimiento?: number | null;
  nacionalidad?: string | null;
  id_departamento_residencia?: number | null;
  id_municipio_residencia?: number | null;
  direccion_residencia?: string | null;
  telefono_alterno?: string | null;
  correo_personal?: string | null;
  estado_civil?: string | null;
  nivel_educativo?: string | null;
  personas_a_cargo?: number | null;
  numero_hijos?: number | null;
  personas_vivienda?: number | null;
  menores_estudian?: boolean | null;
  observaciones?: string | null;
  contacto_emergencia?: {
    nombre_completo?: string | null;
    parentesco?: string | null;
    telefono?: string | null;
    telefono_alterno?: string | null;
    direccion?: string | null;
    observaciones?: string | null;
  };
}

export interface ContractTemplateFieldConfig {
  requiere_fecha_fin?: boolean;
  requiere_duracion_meses?: boolean;
  requiere_prorroga_dias?: boolean;
  requiere_objeto_obra_labor?: boolean;
  requiere_periodo_prueba_dias?: boolean;
  requiere_clausula_funciones?: boolean;
  campos_visibles?: string[];
  campos_ocultos?: string[];
}

export interface ContractTemplateDefaultValues {
  auxilio_transporte?: boolean;
  periodo_pago?: string;
  lugar_labores?: string;
  tipo_cargo_contrato?: ContractChargeType;
  duracion_meses?: number;
  jornada_laboral?: string;
  periodo_prueba_dias?: number;
  termino_inicial_contrato?: string;
  salario_texto_default?: string;
  objeto_obra_labor?: string;
  prorroga_dias?: number;
}

export interface ContractTemplate {
  id_plantilla_contrato: number;
  id_tipo_contrato: number;
  tipo_contrato?: string | null;
  nombre_plantilla: string;
  codigo_formato: string;
  version_formato: string;
  fecha_vigencia?: string | null;
  tipo_cargo_contrato?: ContractChargeType | null;
  descripcion?: string | null;
  archivo_plantilla_url?: string | null;
  archivo_plantilla_ruta?: string | null;
  formato_salida_default?: ContractOutputFormat | null;
  config_campos?: ContractTemplateFieldConfig | null;
  valores_default?: ContractTemplateDefaultValues | null;
  activo?: boolean | number;
  created_at?: string | null;
  updated_at?: string | null;
}

export interface EmployeeContract {
  id_empleado_contrato?: number | null;
  id_contrato_empleado?: number | null;
  id_empleado: number;
  id_tipo_contrato?: number | null;
  tipo_contrato?: string | null;
  id_plantilla_contrato?: number | null;
  nombre_plantilla?: string | null;
  codigo_formato?: string | null;
  version_formato?: string | null;
  fecha_vigencia?: string | null;
  archivo_plantilla_url?: string | null;
  archivo_plantilla_ruta?: string | null;
  formato_salida_default?: ContractOutputFormat | string | null;
  config_campos?: ContractTemplateFieldConfig | null;
  valores_default?: ContractTemplateDefaultValues | null;
  id_area?: number | null;
  area?: string | null;
  id_cargo?: number | null;
  cargo?: string | null;
  fecha_inicio: string;
  fecha_fin?: string | null;
  duracion_meses?: number | null;
  salario_base?: number | string | null;
  auxilio_transporte?: boolean | number | null;
  periodo_pago?: string | null;
  lugar_labores?: string | null;
  numero_contrato?: string | null;
  tipo_cargo_contrato?: ContractChargeType | null;
  objeto_obra_labor?: string | null;
  prorroga_dias?: number | null;
  clausula_funciones?: string | null;
  jornada_laboral?: string | null;
  periodo_prueba_dias?: number | null;
  estado_contrato?: string | null;
  archivo_contrato_url?: string | null;
  observaciones?: string | null;
  fecha_firma?: string | null;
  contrato_firmado?: boolean | number | string | null;
  dias_para_vencer?: number | null;
  estado_vencimiento?: string | null;
  registrado_por?: string | null;
  created_at?: string | null;
}

export interface GenerateContractDocxResponse {
  id_empleado_contrato: number;
  archivo_generado_url: string;
  archivo_contrato_url?: string | null;
  formato: 'DOCX';
}

export interface GenerateContractPdfResponse {
  id_empleado_contrato: number;
  archivo_generado_url: string;
  archivo_contrato_url?: string | null;
  formato: 'PDF';
}

export interface CreateEmployeeContractRequest {
  id_tipo_contrato: number | null;
  id_plantilla_contrato?: number | null;
  id_area?: number | null;
  id_cargo?: number | null;
  fecha_inicio: string;
  fecha_fin?: string | null;
  duracion_meses?: number | null;
  salario_base?: number | null;
  auxilio_transporte?: boolean | null;
  periodo_pago?: string | null;
  lugar_labores?: string | null;
  numero_contrato?: string | null;
  tipo_cargo_contrato?: ContractChargeType | null;
  objeto_obra_labor?: string | null;
  prorroga_dias?: number | null;
  clausula_funciones?: string | null;
  jornada_laboral?: string | null;
  periodo_prueba_dias?: number | null;
  estado_contrato?: string | null;
  archivo_contrato_url?: string | null;
  observaciones?: string | null;
}

export interface ContractGenerationData {
  contract?: Partial<EmployeeContract> & Record<string, unknown>;
  employee?: Record<string, unknown>;
  template?: Partial<ContractTemplate> & Record<string, unknown>;
  generation?: {
    fecha_generacion?: string | null;
    formato_salida_default?: ContractOutputFormat | string | null;
  };
  raw?: Record<string, unknown>;
  [key: string]: unknown;
}

export interface EmployeeSocialSecurity {
  id_seguridad_social?: number | null;
  id_empleado: number;
  id_eps?: number | null;
  eps?: string | null;
  id_arl?: number | null;
  arl?: string | null;
  id_fondo_pension?: number | null;
  fondo_pension?: string | null;
  id_fondo_cesantias?: number | null;
  fondo_cesantias?: string | null;
  id_caja_compensacion?: number | null;
  caja_compensacion?: string | null;
  fecha_afiliacion_eps?: string | null;
  fecha_afiliacion_arl?: string | null;
  fecha_afiliacion_pension?: string | null;
  fecha_afiliacion_cesantias?: string | null;
  fecha_afiliacion_caja?: string | null;
  observaciones?: string | null;
}

export interface SaveSocialSecurityRequest {
  id_eps?: number | null;
  id_arl?: number | null;
  id_fondo_pension?: number | null;
  id_fondo_cesantias?: number | null;
  id_caja_compensacion?: number | null;
  fecha_afiliacion_eps?: string | null;
  fecha_afiliacion_arl?: string | null;
  fecha_afiliacion_pension?: string | null;
  fecha_afiliacion_cesantias?: string | null;
  fecha_afiliacion_caja?: string | null;
  observaciones?: string | null;
}

export type SignedContractOrigin = 'ARCHIVO' | 'URL';

export interface SignEmployeeContractRequest {
  fecha_firma: string;
  origen: SignedContractOrigin;
  archivo?: File | null;
  url?: string | null;
  nombre_archivo?: string | null;
  observaciones?: string | null;
}

export interface SignedEmployeeContract {
  id_empleado_contrato: number;
  id_empleado: number;
  numero_contrato?: string | null;
  fecha_firma: string;
  id_empleado_documento: number;
  nombre_archivo: string;
  nombre_original?: string | null;
  archivo_url?: string | null;
  archivo_ruta?: string | null;
  estado_documento: string;
  observaciones?: string | null;
  estado_firma: string;
}

export type SocialSecurityType = 'EPS' | 'ARL' | 'PENSION' | 'CESANTIAS' | 'CAJA_COMPENSACION';

export interface SocialSecurityEntity {
  id_entidad_seguridad_social: number;
  tipo: string;
  nombre: string;
  codigo?: string | null;
}

export interface ParametersSocialSecurityEntity {
  id_entidad: number;
  tipo: SocialSecurityType;
  nombre: string;
  nit?: string | null;
  activo: boolean;
}

export interface SaveSocialSecurityEntityPayload {
  tipo_entidad: SocialSecurityType;
  nombre: string;
  nit?: string | null;
  activo?: boolean;
}

export interface UniformItemFamily {
  id_tipo_dotacion: number;
  nombre: string;
  descripcion?: string | null;
  requiere_talla: boolean;
}

export interface SaveDotationArticleRequest {
  id_tipo_dotacion: number;
  nombre: string;
  descripcion?: string | null;
  genero?: DotationArticleGender | null;
  unidad_medida?: DotationArticleUnit | null;
  requiere_talla?: boolean;
  activo?: boolean;
}

export type SystemParameterDataType = 'TEXTO' | 'NUMERICO' | 'FECHA' | 'BOOLEANO' | 'JSON';

export interface SystemParameter {
  id_parametro: number;
  codigo: string;
  nombre: string;
  grupo?: string | null;
  descripcion?: string | null;
  tipo_dato: SystemParameterDataType;
  valor?: string | null;
  unidad_medida?: string | null;
  vigencia_desde?: string | null;
  vigencia_hasta?: string | null;
  activo: boolean;
  editable: boolean;
}

export interface SaveSystemParameterPayload {
  codigo: string;
  nombre: string;
  grupo?: string | null;
  descripcion?: string | null;
  tipo_dato: SystemParameterDataType;
  valor?: string | null;
  unidad_medida?: string | null;
  vigencia_desde?: string | null;
  vigencia_hasta?: string | null;
  activo?: boolean;
  editable?: boolean;
}

export interface EmployeeMedicalExam {
  id_examen_medico?: number | null;
  id_empleado: number;
  id_tipo_examen_medico?: number | null;
  tipo_examen_medico?: string | null;
  fecha_examen: string;
  entidad_realiza?: string | null;
  resultado_general?: string | null;
  fecha_vencimiento?: string | null;
  archivo_url?: string | null;
  observaciones?: string | null;
  vencido?: boolean | number | null;
  proximo_vencer?: boolean | number | null;
}

export interface MedicalExamType {
  id_tipo_examen_medico: number;
  nombre: string;
}

export interface NoveltyTypeParameter {
  id_tipo_novedad: number;
  codigo: string;
  nombre: string;
  descripcion?: string | null;
  requiere_fecha_fin: boolean;
  requiere_soporte: boolean;
  es_incapacidad: boolean;
  activo: boolean;
  total_novedades: number;
  novedades_activas: number;
}

export interface DepartmentParameter { id_departamento:number; codigo_dane:string; nombre:string; activo:boolean; total_municipios:number; municipios_activos:number; }
export interface MunicipalityParameter { id_municipio:number; id_departamento:number; codigo_departamento:string; departamento:string; codigo_dane:string; nombre:string; activo:boolean; }

export type SaveNoveltyTypePayload = Omit<NoveltyTypeParameter,
  'id_tipo_novedad' | 'codigo' | 'total_novedades' | 'novedades_activas'>;

export interface CreateMedicalExamRequest {
  id_tipo_examen_medico?: number | null;
  fecha_examen: string;
  entidad_realiza?: string | null;
  resultado_general?: string | null;
  fecha_vencimiento?: string | null;
  archivo_url?: string | null;
  observaciones?: string | null;
}

export interface EmployeeLaborDocument {
  id_empleado_documento?: number | null;
  id_empleado_documento_laboral?: number | null;
  id_empleado: number;
  id_tipo_documento_laboral?: number | null;
  tipo_documento_laboral?: string | null;
  obligatorio?: boolean | number | null;
  requiere_vencimiento?: boolean | number | null;
  nombre_archivo?: string | null;
  archivo_url?: string | null;
  mime_type?: string | null;
  peso_bytes?: number | null;
  fecha_carga?: string | null;
  fecha_vencimiento?: string | null;
  estado_documento?: string | null;
  observaciones?: string | null;
  cargado_por?: string | null;
  validado_por?: string | null;
  fecha_validacion?: string | null;
  vencido?: boolean | number | null;
  proximo_vencer?: boolean | number | null;
}

export interface RegisterEmployeeDocumentRequest {
  id_tipo_documento_laboral?: number | null;
  nombre_archivo: string;
  archivo_url: string;
  mime_type?: string | null;
  peso_bytes?: number | null;
  fecha_vencimiento?: string | null;
  estado_documento?: string | null;
  observaciones?: string | null;
}

export type ApplicantStatus =
  | 'REGISTRADO'
  | 'EN_REVISION'
  | 'APROBADO_CONTRATACION'
  | 'RECHAZADO'
  | 'CONVERTIDO_EMPLEADO'
  | 'CANCELADO';

export type ApplicantDocumentStatus =
  | 'PENDIENTE'
  | 'CARGADO'
  | 'VALIDADO'
  | 'RECHAZADO'
  | 'VENCIDO';
export type ApplicantDocumentOrigin = 'PENDIENTE' | 'URL_EXTERNA' | 'ARCHIVO_FISICO';

export interface Applicant {
  id_aspirante: number;
  id_tipo_documento?: number | null;
  tipo_documento?: string | null;
  numero_documento: string;
  nombres: string;
  apellidos: string;
  nombre_completo?: string | null;
  correo?: string | null;
  telefono?: string | null;
  direccion?: string | null;
  fecha_nacimiento?: string | null;
  id_departamento_nacimiento?: number | null;
  id_municipio_nacimiento?: number | null;
  lugar_nacimiento?: string | null;
  departamento_nacimiento?: string | null;
  nacionalidad?: string | null;
  id_departamento_residencia?: number | null;
  id_municipio_residencia?: number | null;
  ciudad_residencia?: string | null;
  departamento_residencia?: string | null;
  estado_civil?: ApplicantCivilState | null;
  nivel_educativo?: ApplicantEducationLevel | null;
  personas_a_cargo?: number | null;
  numero_hijos?: number | null;
  id_area_aspira?: number | null;
  area_aspira?: string | null;
  id_cargo_aspira?: number | null;
  cargo_aspira?: string | null;
  estado_aspirante: ApplicantStatus;
  observaciones?: string | null;
  id_empleado_generado?: number | null;
  total_documentos?: number | null;
  documentos_pendientes?: number | null;
  created_at?: string | null;
  updated_at?: string | null;
}

export interface ApplicantDetail extends Applicant {}

export interface ApplicantFilters {
  search?: string;
  status?: ApplicantStatus | '';
  area_id?: number | null;
  position_id?: number | null;
}

export interface CreateApplicantRequest {
  id_tipo_documento?: number | null;
  numero_documento: string;
  nombres: string;
  apellidos: string;
  correo?: string | null;
  telefono?: string | null;
  direccion?: string | null;
  fecha_nacimiento?: string | null;
  id_departamento_nacimiento?: number | null;
  id_municipio_nacimiento?: number | null;
  nacionalidad?: string | null;
  id_departamento_residencia?: number | null;
  id_municipio_residencia?: number | null;
  estado_civil?: ApplicantCivilState | null;
  nivel_educativo?: ApplicantEducationLevel | null;
  personas_a_cargo?: number | null;
  numero_hijos?: number | null;
  id_area_aspira?: number | null;
  id_cargo_aspira?: number | null;
  observaciones?: string | null;
}

export interface UpdateApplicantRequest extends CreateApplicantRequest {}

export interface CreateApplicantResponse {
  id_aspirante: number;
  estado_aspirante: ApplicantStatus;
}

export interface ChangeApplicantStatusRequest {
  estado_aspirante: ApplicantStatus;
  observaciones?: string | null;
}

export interface ApplicantDocument {
  id_aspirante_documento: number;
  id_aspirante: number;
  id_tipo_documento_laboral: number;
  tipo_documento_laboral?: string | null;
  obligatorio?: boolean | number | null;
  requiere_vencimiento?: boolean | number | null;
  aplica_aspirante?: boolean | number | null;
  nombre_archivo?: string | null;
  archivo_url?: string | null;
  archivo_ruta?: string | null;
  nombre_original?: string | null;
  mime_type?: string | null;
  peso_bytes?: number | null;
  tipo_origen_archivo?: 'FISICO' | 'URL' | 'SIN_ARCHIVO' | null;
  estado_documento?: ApplicantDocumentStatus | null;
  observaciones?: string | null;
  id_cargado_por?: number | null;
  cargado_por?: string | null;
  created_at?: string | null;
  updated_at?: string | null;
}

export interface RegisterApplicantDocumentRequest {
  id_tipo_documento_laboral: number;
  nombre_archivo?: string | null;
  archivo_url?: string | null;
  estado_documento?: ApplicantDocumentStatus | null;
  observaciones?: string | null;
}

export interface ApplicantStatusHistory {
  id_historial: number;
  id_aspirante: number;
  estado_anterior?: ApplicantStatus | null;
  estado_nuevo: ApplicantStatus;
  observaciones?: string | null;
  id_usuario_cambio?: number | null;
  usuario_cambio?: string | null;
  created_at?: string | null;
}

export interface ConvertApplicantToEmployeeRequest {
  id_tipo_contrato?: number | null;
  fecha_ingreso?: string | null;
  observaciones?: string | null;
}

export interface ConvertApplicantToEmployeeResponse {
  id_aspirante: number;
  id_empleado: number;
  estado_aspirante: ApplicantStatus;
  estado_ficha?: string | null;
}

export interface ContractingAlert {
  tipo_alerta: string;
  id_empleado: number;
  id_empleado_contrato?: number | null;
  numero_documento?: string | null;
  nombre_completo: string;
  correo?: string | null;
  telefono?: string | null;
  tipo_contrato?: string | null;
  nombre_plantilla?: string | null;
  numero_contrato?: string | null;
  fecha_inicio?: string | null;
  fecha_fin?: string | null;
  estado_contrato?: string | null;
  area?: string | null;
  cargo?: string | null;
  id_referencia?: number | null;
  fecha_alerta?: string | null;
  dias_restantes?: number | null;
  dias_para_vencer?: number | null;
  descripcion?: string | null;
}

export interface MeResponse {
  usuario: AuthUser;
  roles: Role[];
  permisos: Permission[];
}

export interface TokenResponse {
  access_token: string;
  refresh_token: string;
  expires_in: number;
}

export interface HealthStatus {
  app: string;
  status: string;
}
// Devoluciones unificadas de dotaciones y herramientas.
export type ReturnType = 'DOTACION' | 'HERRAMIENTA';
export type ReturnStatus = 'REGISTRADA' | 'CONFIRMADA' | 'ANULADA';
export type ReturnItemCondition =
  | 'BUENO'
  | 'USADO'
  | 'DETERIORADO'
  | 'DANADO'
  | 'INCOMPLETO'
  | 'NO_FUNCIONAL';

export interface AvailableReturnItem {
  tipo_devolucion: ReturnType;
  id_entrega: number;
  id_detalle: number;
  id_empleado: number;
  fecha_entrega: string;
  id_dotacion_articulo?: number | null;
  codigo_articulo?: string | null;
  elemento: string;
  tipo_dotacion?: string | null;
  talla?: string | null;
  cantidad_entregada: number;
  cantidad_devuelta: number;
  cantidad_disponible: number;
}

export interface AvailableReturnDelivery {
  tipo_devolucion: ReturnType;
  id_entrega: number;
  id_empleado: number;
  fecha_entrega: string;
  items: AvailableReturnItem[];
}

export interface ReturnListItem {
  id_devolucion: number;
  tipo_devolucion: ReturnType;
  id_empleado: number;
  id_entrega: number;
  fecha_devolucion: string;
  numero_documento?: string | null;
  empleado?: string | null;
  nombre_completo?: string | null;
  total_elementos?: number;
  total_unidades?: number;
  total_evidencias?: number;
  estado: ReturnStatus;
}

export interface ReturnDetail {
  id_detalle?: number;
  id_devolucion_detalle?: number;
  id_dotacion_articulo?: number | null;
  codigo_articulo?: string | null;
  elemento: string;
  tipo_dotacion?: string | null;
  talla?: string | null;
  cantidad?: number;
  cantidad_devuelta?: number;
  estado_elemento: ReturnItemCondition;
  observaciones?: string | null;
}

export interface ReturnEvidence {
  id_evidencia?: number;
  nombre_archivo?: string | null;
  nombre_original?: string | null;
  mime_type?: string | null;
  peso_bytes?: number | null;
  fecha_carga?: string | null;
  archivo_url?: string | null;
  archivo_ruta?: string | null;
}

export interface ReturnRecord extends ReturnListItem {
  motivo?: string | null;
  observaciones?: string | null;
  fecha_registro?: string | null;
  fecha_confirmacion?: string | null;
  fecha_anulacion?: string | null;
  motivo_anulacion?: string | null;
  registrado_por?: string | null;
  confirmado_por?: string | null;
  anulado_por?: string | null;
}

export interface ReturnRecordResponse {
  return: ReturnRecord;
  details: ReturnDetail[];
  evidence: ReturnEvidence[];
}

export interface ReturnFilters {
  type?: ReturnType | '';
  employee_id?: number | null;
  status?: ReturnStatus | '';
  date_from?: string;
  date_to?: string;
}

export interface CreateReturnDetail {
  id_detalle: number;
  cantidad: number;
  estado_elemento: ReturnItemCondition;
  observaciones?: string | null;
}

export interface CreateReturnPayload {
  type: ReturnType;
  employee_id: number;
  delivery_id: number;
  return_date: string;
  reason: string;
  observations?: string | null;
  details: CreateReturnDetail[];
  evidence: File[];
}
