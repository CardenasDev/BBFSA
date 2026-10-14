-- Habilitación de BBTH-F-012 Carta de retiro de cesantías por finalización de contrato
-- Ejecutar SOLO en DEV después de verificar la BD destino
-- Este script es idempotente y no destruye datos existentes
-- No modifica otros formatos. No ejecutar automáticamente.

-- 1. Actualizar el registro existente de BBTH-F-012
-- Copia los firmantes institucionales de BBTH-F-002 (ya operativos).
UPDATE bbf_documento_formatos
SET CLAVE_RENDERIZADOR = 'carta-retiro-cesantias-fin-contrato',
    HABILITADO_GENERACION = 1,
    FIRMANTES_JSON = (
        SELECT F2.FIRMANTES_JSON
        FROM (SELECT FIRMANTES_JSON FROM bbf_documento_formatos
              WHERE CODIGO_FORMATO = 'BBTH-F-002' AND VARIANTE = 'GENERAL'
              LIMIT 1) F2
    ),
    CONTROL_DOCUMENTAL_JSON = JSON_OBJECT(
        'estado_validacion', 'APROBADO',
        'fuente', '00. Definiciones/Certificados/BBTH-F-012  FORMATO DE RETIRO DE CESANTIAS.docx',
        'vigencia_fuente', 'Versión 01 del encabezado',
        'observaciones', 'Sin sello: sección de firmas (empleador + trabajador). Periodo, NIT y contacto suministrados por el usuario. No modifica registros.'
    )
WHERE CLAVE_FORMATO = 'CESANTIAS_FIN_CONTRATO'
  AND CODIGO_FORMATO = 'BBTH-F-012'
  AND VARIANTE = 'GENERAL';

-- 2. Verificar que el registro quedó habilitado
SELECT
    ID_DOCUMENTO_FORMATO,
    CLAVE_FORMATO,
    CODIGO_FORMATO,
    NOMBRE,
    VARIANTE,
    VERSION_FORMATO,
    CLAVE_RENDERIZADOR,
    FIRMANTES_JSON,
    HABILITADO_GENERACION,
    ACTIVO
FROM bbf_documento_formatos
WHERE CLAVE_FORMATO = 'CESANTIAS_FIN_CONTRATO'
  AND CODIGO_FORMATO = 'BBTH-F-012';

-- 3. Verificar que los SP lo retornan (solo lectura)
CALL SP_BBF_DOCUMENTO_FORMATOS_LISTAR(NULL, DATE(CONVERT_TZ(UTC_TIMESTAMP(), '+00:00', '-05:00')));
