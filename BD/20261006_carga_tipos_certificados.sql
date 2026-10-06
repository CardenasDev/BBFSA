-- Carga inicial de los ocho tipos documentales, sin habilitar su generacion.
-- Ejecutar despues de 20261006_base_documental.sql, en la BD LOCAL indicada.
-- No usar en otro entorno sin revisar expresamente el USE.
-- Nombres y metadatos tomados de 00. Definiciones/Certificados.
-- No carga datos personales de ejemplo, firmantes ni archivos emitidos.
-- Reejecutable: no modifica ninguna variante GENERAL ya registrada,
-- aunque su vigencia/version haya sido ajustada posteriormente.
-- Una fila GENERAL por tipo es una entrada de catalogo inicial;
-- NO define como oficial una variante de cuerpo ni reemplaza sus reglas.
-- La fecha 18/06/2026 se extrajo de los encabezados de los ocho DOCX.
-- Sigue pendiente de validacion junto con los demas metadatos.

USE `bbf_administrativo`;
SET NAMES utf8mb4;

INSERT INTO `bbf_documento_formatos` (
    `CLAVE_FORMATO`, `CODIGO_FORMATO`, `NOMBRE`, `VARIANTE`,
    `VERSION_FORMATO`, `PROCESO`, `TITULO`, `CONTEXTO_ORIGEN`,
    `VIGENCIA_DESDE`, `VIGENCIA_HASTA`, `CLAVE_RENDERIZADOR`,
    `CONTROL_DOCUMENTAL_JSON`, `FIRMANTES_JSON`, `CONFIG_CAMPOS_JSON`,
    `ACTIVO`, `HABILITADO_GENERACION`
)
SELECT
    S.CLAVE_FORMATO, S.CODIGO_FORMATO, S.NOMBRE, 'GENERAL',
    S.VERSION_FORMATO, 'GESTIÓN DE TALENTO HUMANO', S.NOMBRE, S.CONTEXTO_ORIGEN,
    '2026-06-18', NULL, NULL,
    JSON_OBJECT(
        'estado_validacion', 'PENDIENTE',
        'fuente', '00. Definiciones/Certificados',
        'vigencia_fuente', 'Encabezado del DOCX: 18/06/2026; pendiente de validacion',
        'observaciones', S.OBSERVACIONES
    ),
    NULL, NULL, 1, 0
FROM (
    SELECT 'CERTIFICADO_LABORAL_ACTIVO' AS CLAVE_FORMATO,
           'BBTH-F-002' AS CODIGO_FORMATO,
           'Certificado laboral a colaborador activo' AS NOMBRE,
           '01' AS VERSION_FORMATO, 'EMPLEADO' AS CONTEXTO_ORIGEN,
           'El DOCX contiene tres textos: funciones, salario/afiliaciones e historia contractual. Variantes pendientes de confirmar.' AS OBSERVACIONES
    UNION ALL
    SELECT 'CERTIFICADO_LABORAL_RETIRO', 'BBTH-F-003',
           'Certificado laboral de retiro a colaborador', '02', 'RETIRO',
           'Version del encabezado. Pendientes los campos sin fuente automatica demostrada y la regla de consecutivo.'
    UNION ALL
    SELECT 'CONSTANCIA_ENTREGA_RETIRO', 'BBTH-F-004',
           'Check list de retiro entregado a excolaborador', '01', 'RETIRO',
           'Version 01 del encabezado; tabla de revision indica 02. Confirmar version oficial y evidencia de entrega.'
    UNION ALL
    SELECT 'ACEPTACION_RENUNCIA', 'BBTH-F-005',
           'Carta de aceptación de renuncia', '01', 'RETIRO',
           'Requiere renuncia y decision de aceptacion; emitir la carta no ejecuta la decision ni cambia estado del empleado.'
    UNION ALL
    SELECT 'CESANTIAS_VIVIENDA', 'BBTH-F-011',
           'Carta de retiro de cesantías para vivienda', '01', 'SOLICITUD_CESANTIAS',
           'Retiro de dinero, no retiro laboral. El asunto dice total y el cuerpo parcial: confirmar modalidad y texto.'
    UNION ALL
    SELECT 'CESANTIAS_FIN_CONTRATO', 'BBTH-F-012',
           'Carta de retiro de cesantías por finalización de contrato', '01', 'RETIRO',
           'Requiere fondo y periodo laboral. No exigir monto por analogia con cesantias para vivienda.'
    UNION ALL
    SELECT 'COMPROMISO_EVALUATIVO', 'BBTH-F-013',
           'Carta de compromiso evaluativo', '01', 'COMPROMISO',
           'Existe impresion ligada a capacitacion; confirmar aplicabilidad del ejemplo de desempeno semanal antes de habilitar.'
    UNION ALL
    SELECT 'NO_RENOVACION_CONTRATO', 'BBTH-F-015',
           'Carta de notificación de no renovación de contrato', '01', 'CONTRATO',
           'El codigo F-015 tambien figura en plantillas contractuales. Esta clave funcional independiente evita mezclarlas.'
) S
WHERE NOT EXISTS (
    SELECT 1 FROM `bbf_documento_formatos` F
    WHERE F.CLAVE_FORMATO = S.CLAVE_FORMATO AND F.VARIANTE = 'GENERAL'
)
-- Protege una colision concurrente de la clave unica sin cambiar metadatos.
ON DUPLICATE KEY UPDATE `ID_DOCUMENTO_FORMATO` = `bbf_documento_formatos`.`ID_DOCUMENTO_FORMATO`;

-- El cliente puede contar filas encontradas en la rama de conflicto concurrente.
-- Este contador no sustituye la verificacion del catalogo que sigue.
SELECT ROW_COUNT() AS FILAS_AFECTADAS_REPORTADAS;

-- Verificar los tipos cargados, incluso deshabilitados para generacion.
SELECT `CLAVE_FORMATO`, `CODIGO_FORMATO`, `NOMBRE`, `VARIANTE`,
       `VERSION_FORMATO`, `CONTEXTO_ORIGEN`, `VIGENCIA_DESDE`,
       `ACTIVO`, `HABILITADO_GENERACION`
FROM `bbf_documento_formatos`
WHERE `CLAVE_FORMATO` IN (
    'CERTIFICADO_LABORAL_ACTIVO', 'CERTIFICADO_LABORAL_RETIRO',
    'CONSTANCIA_ENTREGA_RETIRO', 'ACEPTACION_RENUNCIA',
    'CESANTIAS_VIVIENDA', 'CESANTIAS_FIN_CONTRATO',
    'COMPROMISO_EVALUATIVO', 'NO_RENOVACION_CONTRATO'
) AND `VARIANTE` = 'GENERAL'
ORDER BY `CODIGO_FORMATO`;

-- IMPORTANTE: SP_BBF_DOCUMENTO_FORMATOS_LISTAR solo muestra habilitados.
-- Estos ocho nombres existen en la tabla, pero ese SP seguira sin ofrecer
-- las filas nuevas hasta implementar/validar cada formato y habilitarlo.
