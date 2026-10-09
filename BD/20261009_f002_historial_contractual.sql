-- Ejecutar solo tras seleccionar y verificar explícitamente la BD destino.
-- No ejecutado por la aplicación. No altera GENERAL ni SALARIO_AFILIACIONES ni inventa firmantes.
-- Copia metadatos institucionales de una única configuración GENERAL vigente
-- previamente verificada; si no existe o es ambigua, no registra ninguna fila.
-- La nueva variante queda deshabilitada hasta aprobación institucional.
INSERT INTO bbf_documento_formatos
 (CLAVE_FORMATO, CODIGO_FORMATO, NOMBRE, VARIANTE, VERSION_FORMATO, PROCESO,
  TITULO, CONTEXTO_ORIGEN, VIGENCIA_DESDE, VIGENCIA_HASTA, CLAVE_RENDERIZADOR,
  CONTROL_DOCUMENTAL_JSON, FIRMANTES_JSON, CONFIG_CAMPOS_JSON, ACTIVO, HABILITADO_GENERACION)
SELECT G.CLAVE_FORMATO, G.CODIGO_FORMATO,
 'Certificado laboral activo con historial contractual', 'HISTORIAL_CONTRACTUAL',
 G.VERSION_FORMATO, G.PROCESO, G.TITULO, G.CONTEXTO_ORIGEN,
 G.VIGENCIA_DESDE, G.VIGENCIA_HASTA, 'certificado-laboral-activo-historial-contractual',
 G.CONTROL_DOCUMENTAL_JSON, G.FIRMANTES_JSON,
 '{"campos_declarados":["fecha_inicio_labores"]}', 1, 0
FROM bbf_documento_formatos G
WHERE G.CLAVE_FORMATO = 'CERTIFICADO_LABORAL_ACTIVO' AND G.VARIANTE = 'GENERAL'
 AND G.ACTIVO = 1 AND G.HABILITADO_GENERACION = 1 AND G.CONTEXTO_ORIGEN = 'EMPLEADO'
 AND G.CODIGO_FORMATO = 'BBTH-F-002'
 AND G.CLAVE_RENDERIZADOR = 'certificado-laboral-activo-funciones'
 AND G.VIGENCIA_DESDE <= DATE(CONVERT_TZ(UTC_TIMESTAMP(), '+00:00', '-05:00'))
 AND (G.VIGENCIA_HASTA IS NULL OR G.VIGENCIA_HASTA >= DATE(CONVERT_TZ(UTC_TIMESTAMP(), '+00:00', '-05:00')))
 AND JSON_VALID(G.FIRMANTES_JSON) AND JSON_TYPE(G.FIRMANTES_JSON) = 'ARRAY' AND JSON_LENGTH(G.FIRMANTES_JSON) > 0
 AND (SELECT COUNT(*) FROM bbf_documento_formatos X
      WHERE X.CLAVE_FORMATO = G.CLAVE_FORMATO AND X.VARIANTE = 'GENERAL'
       AND X.ACTIVO = 1 AND X.HABILITADO_GENERACION = 1
       AND X.VIGENCIA_DESDE <= DATE(CONVERT_TZ(UTC_TIMESTAMP(), '+00:00', '-05:00'))
       AND (X.VIGENCIA_HASTA IS NULL OR X.VIGENCIA_HASTA >= DATE(CONVERT_TZ(UTC_TIMESTAMP(), '+00:00', '-05:00')))) = 1
 AND NOT EXISTS (SELECT 1 FROM bbf_documento_formatos H
                 WHERE H.CLAVE_FORMATO = G.CLAVE_FORMATO AND H.VARIANTE = 'HISTORIAL_CONTRACTUAL');

-- Inspeccionar la fila y validar los parámetros referenciados antes de habilitarla.
SELECT * FROM bbf_documento_formatos
WHERE CLAVE_FORMATO = 'CERTIFICADO_LABORAL_ACTIVO' AND VARIANTE = 'HISTORIAL_CONTRACTUAL';
