export interface CompanyContractData {
  razonSocial?: string;
  nit?: string;
  domicilio?: string;
  correo?: string;
}

export interface EmployeeContractData {
  id_empleado?: number;
  id_tipo_documento?: number;
  tipo_documento?: string;
  numero_documento?: string;
  nombres?: string;
  apellidos?: string;
  nombre_completo?: string;
  correo?: string;
  telefono?: string;
  fecha_ingreso?: string;
  estado_empleado?: string;
  fecha_nacimiento?: string;
  lugar_nacimiento?: string;
  departamento_nacimiento?: string;
  nacionalidad?: string;
  ciudad_residencia?: string;
  departamento_residencia?: string;
  direccion_residencia?: string;
  telefono_alterno?: string;
  correo_personal?: string;
  estado_civil?: string;
  nivel_educativo?: string;
  personas_a_cargo?: number;
  numero_hijos?: number;
}

export interface ContractData {
  id_empleado_contrato?: number;
  id_contrato_empleado?: number;
  id_empleado?: number;
  id_tipo_contrato?: number;
  id_plantilla_contrato?: number;
  id_area?: number;
  id_cargo?: number;
  fecha_inicio?: string;
  fecha_fin?: string;
  duracion_meses?: number;
  salario_base?: number | string;
  auxilio_transporte?: boolean | number | string;
  periodo_pago?: string;
  lugar_labores?: string;
  numero_contrato?: string;
  tipo_cargo_contrato?: string;
  objeto_obra_labor?: string;
  prorroga_dias?: number;
  clausula_funciones?: string;
  jornada_laboral?: string;
  periodo_prueba_dias?: number;
  estado_contrato?: string;
  archivo_contrato_url?: string;
  observaciones?: string;
  tipo_contrato?: string;
  nombre_tipo_contrato?: string;
  cargo?: string;
  nombre_cargo?: string;
  area?: string;
  nombre_area?: string;
}

export interface ContractSignatureData {
  ciudad_firma?: string;
  fecha_firma?: string;
  fecha_firma_texto?: string;
  nombre_representante_legal?: string;
  cargo_representante_legal?: string;
}

export interface ContractTemplateData {
  id_plantilla_contrato?: number;
  id_tipo_contrato?: number;
  tipo_contrato?: string;
  nombre_plantilla?: string;
  codigo_formato?: string;
  version_formato?: string;
  fecha_vigencia?: string;
  tipo_cargo_contrato?: string;
  descripcion?: string;
  archivo_plantilla_url?: string;
  formato_salida_default?: string;
  config_campos?: {
    requiere_fecha_fin?: boolean;
    requiere_duracion_meses?: boolean;
    requiere_prorroga_dias?: boolean;
    requiere_objeto_obra_labor?: boolean;
    requiere_periodo_prueba_dias?: boolean;
    requiere_clausula_funciones?: boolean;
    campos_visibles?: string[];
    campos_ocultos?: string[];
  };
  valores_default?: {
    auxilio_transporte?: boolean;
    periodo_pago?: string;
    lugar_labores?: string;
    tipo_cargo_contrato?: string;
    duracion_meses?: number;
    jornada_laboral?: string;
    periodo_prueba_dias?: number;
    termino_inicial_contrato?: string;
    salario_texto_default?: string;
    objeto_obra_labor?: string;
    prorroga_dias?: number;
    salario_texto?: string;
    ciudad_firma?: string;
    fecha_firma?: string;
  };
  activo?: boolean | number;
  created_at?: string;
  updated_at?: string;
}

export interface ContractReplacementData {
  NOMBRE_COMPLETO?: string;
  TIPO_DOCUMENTO?: string;
  NUMERO_DOCUMENTO?: string;
  CORREO_PERSONAL?: string;
  CORREO?: string;
  TELEFONO?: string;
  TELEFONO_ALTERNO?: string;
  DIRECCION_RESIDENCIA?: string;
  LUGAR_NACIMIENTO?: string;
  FECHA_NACIMIENTO_TEXTO?: string;
  NACIONALIDAD?: string;
  CARGO?: string;
  SALARIO_TEXTO?: string;
  SALARIO_BASE?: string;
  AUXILIO_TRANSPORTE_TEXTO?: string;
  PERIODO_PAGO?: string;
  FECHA_INICIO_TEXTO?: string;
  FECHA_FIN_TEXTO?: string;
  LUGAR_LABORES?: string;
  TERMINO_INICIAL_CONTRATO?: string;
  NUMERO_CONTRATO?: string;
  CIUDAD_FIRMA?: string;
  FECHA_FIRMA_TEXTO?: string;
  JORNADA_LABORAL?: string;
  PERIODO_PRUEBA_DIAS?: string;
  OBJETO_OBRA_LABOR?: string;
  PRORROGA_DIAS?: string;
  CLAUSULA_FUNCIONES?: string;
  NOMBRE_PLANTILLA?: string;
  CODIGO_FORMATO?: string;
  VERSION_FORMATO?: string;
  FECHA_VIGENCIA?: string;
  AREA?: string;
  TIPO_CONTRATO?: string;
  FECHA_VIGENCIA_TEXTO?: string;
}

export interface ContractParametersData {
  plantilla: ContractTemplateData;
  fecha_generacion?: string;
  reemplazos: ContractReplacementData;
}

export interface ContractGenerationData {
  empresa: CompanyContractData;
  empleado: EmployeeContractData;
  contrato: ContractData;
  firmas: ContractSignatureData;
  parametros: ContractParametersData;
}

export interface ContractGenerationResponse {
  success: boolean;
  message: string;
  data: ContractGenerationData;
}

export type ContractRendererType = 'base' | 'indefinite' | 'fixed-term' | 'work';
