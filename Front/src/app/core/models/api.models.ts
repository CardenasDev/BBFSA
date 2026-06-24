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
export type EmployeeStatus = 'ACTIVO' | 'RETIRADO' | 'SUSPENDIDO' | 'INCAPACITADO' | 'EN_PROCESO_RETIRO';
export type ContractChargeType = 'ADMINISTRATIVO' | 'OPERATIVO' | 'OTRO';

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

export interface MyDotationSize {
  id_tipo_dotacion: number;
  tipo_dotacion: string;
  tipo_dotacion_descripcion?: string | null;
  requiere_talla: boolean;
  id_empleado_dotacion_talla?: number | null;
  id_empleado?: number | null;
  id_talla_dotacion?: number | null;
  talla?: string | null;
  talla_descripcion?: string | null;
  observaciones?: string | null;
  created_at?: string | null;
  updated_at?: string | null;
}

export interface SaveMyDotationSizeRequest {
  id_tipo_dotacion: number;
  id_talla_dotacion?: number | null;
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

export interface EmployeeDotationHistory {
  id_dotacion_entrega: number;
  id_empleado: number;
  numero_documento: string;
  nombre_completo: string;
  area?: string | null;
  cargo?: string | null;
  fecha_entrega: string;
  fecha_confirmacion?: string | null;
  estado: string;
  observaciones_entrega?: string | null;
  observacion_confirmacion?: string | null;
  firma_url?: string | null;
  id_registrado_por?: number | null;
  registrado_por?: string | null;
  id_confirmado_por?: number | null;
  confirmado_por?: string | null;
  id_dotacion_entrega_detalle: number;
  id_tipo_dotacion: number;
  tipo_dotacion: string;
  id_talla_dotacion?: number | null;
  talla?: string | null;
  cantidad: number;
  observaciones_detalle?: string | null;
  created_at?: string | null;
  updated_at?: string | null;
}

export interface DotationDelivery {
  id_dotacion_entrega: number;
  id_empleado: number;
  numero_documento: string;
  nombre_completo: string;
  fecha_entrega: string;
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

export interface MyDotationDelivery {
  id_dotacion_entrega: number;
  id_empleado: number;
  numero_documento: string;
  nombre_completo: string;
  fecha_entrega: string;
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

export interface DotationDeliveryDetail {
  id_dotacion_entrega_detalle: number;
  id_dotacion_entrega: number;
  id_tipo_dotacion: number;
  tipo_dotacion: string;
  id_talla_dotacion?: number | null;
  talla?: string | null;
  cantidad: number;
  observaciones?: string | null;
  created_at?: string | null;
}

export interface CreateDotationDeliveryRequest {
  id_empleado: number;
  fecha_entrega: string;
  observaciones?: string | null;
  detalles: {
    id_tipo_dotacion: number;
    id_talla_dotacion?: number | null;
    cantidad: number;
    observaciones?: string | null;
  }[];
}

export interface DotationEmployeeFilters {
  texto_busqueda?: string;
  id_area?: number | null;
  id_cargo?: number | null;
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
  lugar_nacimiento?: string | null;
  departamento_nacimiento?: string | null;
  ciudad_residencia?: string | null;
  departamento_residencia?: string | null;
  direccion_residencia?: string | null;
  telefono_alterno?: string | null;
  correo_personal?: string | null;
  estado_civil?: string | null;
  nivel_educativo?: string | null;
  personas_a_cargo?: number | null;
  numero_hijos?: number | null;
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
  lugar_nacimiento?: string | null;
  departamento_nacimiento?: string | null;
  ciudad_residencia?: string | null;
  departamento_residencia?: string | null;
  direccion_residencia?: string | null;
  telefono_alterno?: string | null;
  correo_personal?: string | null;
  estado_civil?: string | null;
  nivel_educativo?: string | null;
  personas_a_cargo?: number | null;
  numero_hijos?: number | null;
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

export interface EmployeeContract {
  id_empleado_contrato?: number | null;
  id_contrato_empleado?: number | null;
  id_empleado: number;
  id_tipo_contrato?: number | null;
  tipo_contrato?: string | null;
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
  registrado_por?: string | null;
  created_at?: string | null;
}

export interface CreateEmployeeContractRequest {
  id_tipo_contrato?: number | null;
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

export interface ContractingAlert {
  tipo_alerta: string;
  id_empleado: number;
  numero_documento?: string | null;
  nombre_completo: string;
  area?: string | null;
  cargo?: string | null;
  id_referencia?: number | null;
  fecha_alerta?: string | null;
  dias_restantes?: number | null;
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
