-- Habilitación de BBTH-F-004 Check list de retiro entregado a excolaborador
-- Ejecutar SOLO en DEV después de verificar la BD destino
-- Este script es idempotente y no destruye datos existentes
-- No modifica otros formatos. No ejecutar automáticamente.

-- 1. Actualizar el registro existente de BBTH-F-004
-- Copia los firmantes institucionales de BBTH-F-002 (ya operativos).
UPDATE bbf_documento_formatos
SET CLAVE_RENDERIZADOR = 'constancia-entrega-retiro',
    HABILITADO_GENERACION = 1,
    FIRMANTES_JSON = (
        SELECT F2.FIRMANTES_JSON
        FROM (SELECT FIRMANTES_JSON FROM bbf_documento_formatos
              WHERE CODIGO_FORMATO = 'BBTH-F-002' AND VARIANTE = 'GENERAL'
              LIMIT 1) F2
    ),
    CONTROL_DOCUMENTAL_JSON = JSON_OBJECT(
        'estado_validacion', 'APROBADO',
        'fuente', '00. Definiciones/Certificados/BBTH-F-004 CHECK LIST DE RETIRO ENTREGADO A EXCOLABORADOR.docx',
        'vigencia_fuente', 'Versión 01 del encabezado; tabla de revisión indica 02, pendiente de confirmación institucional',
        'observaciones', 'Checklist de entrega documental. Solo lectura: no registra entregas ni altera el retiro o el estado del empleado.'
    )
WHERE CLAVE_FORMATO = 'CONSTANCIA_ENTREGA_RETIRO'
  AND CODIGO_FORMATO = 'BBTH-F-004'
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
WHERE CLAVE_FORMATO = 'CONSTANCIA_ENTREGA_RETIRO'
  AND CODIGO_FORMATO = 'BBTH-F-004';

-- 3. Verificar que los SP lo retornan (solo lectura)
CALL SP_BBF_DOCUMENTO_FORMATOS_LISTAR(NULL, DATE(CONVERT_TZ(UTC_TIMESTAMP(), '+00:00', '-05:00')));
