-- ============================================================
-- Migracion delta QA: 2026-10-23
-- Destino: base de datos cWeb (QA).
-- Restriccion: NO incluye DROP TABLE, TRUNCATE ni eliminacion de datos.
-- Idempotente: usa DROP PROCEDURE IF EXISTS, CREATE TABLE IF NOT EXISTS, INSERT IGNORE, UPDATE condicionales.
-- ============================================================

SET NAMES utf8mb4;

-- ============================================================
-- 1. ALERTAS Y CONTRATACION
-- ============================================================
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_CONTRATACION_ALERTAS_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_CONTRATACION_ALERTAS_LISTAR`(
    IN P_DIAS_ANTES INT
)
BEGIN
    DECLARE V_DIAS_ANTES INT DEFAULT 30;
    SET V_DIAS_ANTES = IFNULL(P_DIAS_ANTES, 30);

    /* 1. ALERTAS DE CONTRATOS */
    SELECT
        EC.ID_EMPLEADO_CONTRATO             AS id_referencia,
        EC.ID_EMPLEADO,
        CONCAT(E.NOMBRES, ' ', E.APELLIDOS) AS nombre_completo,
        E.NUMERO_DOCUMENTO                  AS numero_documento,
        E.CORREO,
        E.TELEFONO,
        TC.NOMBRE                           AS tipo_contrato,
        CP.NOMBRE_PLANTILLA                 AS nombre_plantilla,
        EC.NUMERO_CONTRATO                  AS numero_contrato,
        EC.FECHA_INICIO                     AS fecha_inicio,
        EC.FECHA_FIN                        AS fecha_fin,
        EC.ESTADO_CONTRATO                  AS estado_contrato,
        A.NOMBRE                            AS area,
        C.NOMBRE                            AS cargo,
        DATEDIFF(EC.FECHA_FIN, CURRENT_DATE()) AS dias_para_vencer,
        CASE
            WHEN EC.FECHA_FIN < CURRENT_DATE() THEN 'CONTRATO_VENCIDO'
            WHEN DATEDIFF(EC.FECHA_FIN, CURRENT_DATE()) <= V_DIAS_ANTES THEN 'CONTRATO_PROXIMO_VENCER'
            ELSE 'CONTRATO_VIGENTE'
        END                                 AS tipo_alerta,
        NULL                                AS id_tipo_examen_medico,
        NULL                                AS tipo_examen_medico,
        NULL                                AS fecha_examen,
        NULL                                AS entidad_realiza,
        NULL                                AS resultado_general,
        NULL                                AS fecha_vencimiento_examen
    FROM bbf_empleado_contratos EC
    INNER JOIN bbf_empleados E ON E.ID_EMPLEADO = EC.ID_EMPLEADO AND IFNULL(E.ELIMINADO, 0) = 0
    LEFT JOIN bbf_tipos_contrato TC ON TC.ID_TIPO_CONTRATO = EC.ID_TIPO_CONTRATO
    LEFT JOIN bbf_contrato_plantillas CP ON CP.ID_PLANTILLA_CONTRATO = EC.ID_PLANTILLA_CONTRATO
    LEFT JOIN bbf_areas A ON A.ID_AREA = EC.ID_AREA
    LEFT JOIN bbf_cargos C ON C.ID_CARGO = EC.ID_CARGO
    WHERE IFNULL(EC.ELIMINADO, 0) = 0
      AND EC.FECHA_FIN IS NOT NULL
      AND EC.ESTADO_CONTRATO = 'ACTIVO'
      AND EC.FECHA_FIN <= DATE_ADD(CURRENT_DATE(), INTERVAL V_DIAS_ANTES DAY)

    UNION ALL

    /* 2. EXÁMENES MÉDICOS VENCIDOS */
    SELECT
        EM.ID_EXAMEN_MEDICO                 AS id_referencia,
        EM.ID_EMPLEADO,
        CONCAT(E.NOMBRES, ' ', E.APELLIDOS) AS nombre_completo,
        E.NUMERO_DOCUMENTO                  AS numero_documento,
        E.CORREO,
        E.TELEFONO,
        NULL                                AS tipo_contrato,
        NULL                                AS nombre_plantilla,
        NULL                                AS numero_contrato,
        NULL                                AS fecha_inicio,
        NULL                                AS fecha_fin,
        NULL                                AS estado_contrato,
        A.NOMBRE                            AS area,
        C.NOMBRE                            AS cargo,
        DATEDIFF(CURRENT_DATE(), EM.FECHA_VENCIMIENTO) AS dias_para_vencer,
        'EXAMEN_MEDICO_VENCIDO'             AS tipo_alerta,
        TEM.ID_TIPO_EXAMEN_MEDICO           AS id_tipo_examen_medico,
        TEM.NOMBRE                          AS tipo_examen_medico,
        EM.FECHA_EXAMEN                     AS fecha_examen,
        EM.ENTIDAD_REALIZA                  AS entidad_realiza,
        EM.RESULTADO_GENERAL                AS resultado_general,
        EM.FECHA_VENCIMIENTO                AS fecha_vencimiento_examen
    FROM bbf_empleado_examenes_medicos EM
    INNER JOIN bbf_tipos_examen_medico TEM ON TEM.ID_TIPO_EXAMEN_MEDICO = EM.ID_TIPO_EXAMEN_MEDICO
    INNER JOIN bbf_empleados E ON E.ID_EMPLEADO = EM.ID_EMPLEADO AND IFNULL(E.ELIMINADO, 0) = 0
    LEFT JOIN bbf_areas A ON A.ID_AREA = E.ID_AREA
    LEFT JOIN bbf_cargos C ON C.ID_CARGO = E.ID_CARGO
    WHERE IFNULL(EM.ELIMINADO, 0) = 0
      AND EM.FECHA_VENCIMIENTO IS NOT NULL
      AND EM.FECHA_VENCIMIENTO < CURRENT_DATE()

    UNION ALL

    /* 3. EXÁMENES MÉDICOS PRÓXIMOS A VENCER */
    SELECT
        EM.ID_EXAMEN_MEDICO                 AS id_referencia,
        EM.ID_EMPLEADO,
        CONCAT(E.NOMBRES, ' ', E.APELLIDOS) AS nombre_completo,
        E.NUMERO_DOCUMENTO                  AS numero_documento,
        E.CORREO,
        E.TELEFONO,
        NULL                                AS tipo_contrato,
        NULL                                AS nombre_plantilla,
        NULL                                AS numero_contrato,
        NULL                                AS fecha_inicio,
        NULL                                AS fecha_fin,
        NULL                                AS estado_contrato,
        A.NOMBRE                            AS area,
        C.NOMBRE                            AS cargo,
        DATEDIFF(EM.FECHA_VENCIMIENTO, CURRENT_DATE()) AS dias_para_vencer,
        'EXAMEN_MEDICO_PROXIMO_VENCER'      AS tipo_alerta,
        TEM.ID_TIPO_EXAMEN_MEDICO           AS id_tipo_examen_medico,
        TEM.NOMBRE                          AS tipo_examen_medico,
        EM.FECHA_EXAMEN                     AS fecha_examen,
        EM.ENTIDAD_REALIZA                  AS entidad_realiza,
        EM.RESULTADO_GENERAL                AS resultado_general,
        EM.FECHA_VENCIMIENTO                AS fecha_vencimiento_examen
    FROM bbf_empleado_examenes_medicos EM
    INNER JOIN bbf_tipos_examen_medico TEM ON TEM.ID_TIPO_EXAMEN_MEDICO = EM.ID_TIPO_EXAMEN_MEDICO
    INNER JOIN bbf_empleados E ON E.ID_EMPLEADO = EM.ID_EMPLEADO AND IFNULL(E.ELIMINADO, 0) = 0
    LEFT JOIN bbf_areas A ON A.ID_AREA = E.ID_AREA
    LEFT JOIN bbf_cargos C ON C.ID_CARGO = E.ID_CARGO
    WHERE IFNULL(EM.ELIMINADO, 0) = 0
      AND EM.FECHA_VENCIMIENTO IS NOT NULL
      AND EM.FECHA_VENCIMIENTO BETWEEN CURRENT_DATE() AND DATE_ADD(CURRENT_DATE(), INTERVAL V_DIAS_ANTES DAY)

    ORDER BY
        CASE tipo_alerta
            WHEN 'CONTRATO_VENCIDO'             THEN 1
            WHEN 'EXAMEN_MEDICO_VENCIDO'        THEN 2
            WHEN 'CONTRATO_PROXIMO_VENCER'      THEN 3
            WHEN 'EXAMEN_MEDICO_PROXIMO_VENCER' THEN 4
            ELSE 5
        END,
        dias_para_vencer ASC,
        nombre_completo ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_CONTRATO_PLANTILLAS_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_CONTRATO_PLANTILLAS_LISTAR`(
    IN P_ID_TIPO_CONTRATO INT,
    IN P_SOLO_ACTIVAS TINYINT
)
BEGIN
    SELECT
        P.ID_PLANTILLA_CONTRATO,
        P.ID_TIPO_CONTRATO,
        TC.NOMBRE AS TIPO_CONTRATO,
        P.NOMBRE_PLANTILLA,
        P.CODIGO_FORMATO,
        P.VERSION_FORMATO,
        P.FECHA_VIGENCIA,
        P.TIPO_CARGO_CONTRATO,
        P.DESCRIPCION,
        P.ARCHIVO_PLANTILLA_URL,
        P.ARCHIVO_PLANTILLA_RUTA,
        P.FORMATO_SALIDA_DEFAULT,
        P.CONFIG_CAMPOS_JSON,
        P.VALORES_DEFAULT_JSON,
        P.ACTIVO,
        P.CREATED_AT,
        P.UPDATED_AT
    FROM bbf_contrato_plantillas P
    INNER JOIN bbf_tipos_contrato TC
        ON TC.ID_TIPO_CONTRATO = P.ID_TIPO_CONTRATO
    WHERE IFNULL(P.ELIMINADO, 0) = 0
      AND (P_ID_TIPO_CONTRATO IS NULL OR P.ID_TIPO_CONTRATO = P_ID_TIPO_CONTRATO)
      AND (IFNULL(P_SOLO_ACTIVAS, 1) = 0 OR P.ACTIVO = 1)
    ORDER BY TC.NOMBRE, P.NOMBRE_PLANTILLA;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

-- ============================================================
-- 2. KPIS
-- ============================================================
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_KPI_ROTACION_Y_DEMOGRAFIA` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_KPI_ROTACION_Y_DEMOGRAFIA`()
BEGIN
    /* 
       RETORNA 2 RESULTSETS:
       1) Metricas principales: tasa_rotacion, salidas, promedio_activos
       2) Desglose por genero: genero, total_activos
    */

    -- 1) PARAMETROS DE VENTANA (ultimos 3 meses rolling)
    SET @fecha_fin   := CURRENT_DATE();
    SET @fecha_inicio := DATE_SUB(@fecha_fin, INTERVAL 3 MONTH);

    -- 2) SALIDAS EN VENTANA (empleados con FECHA_RETIRO en los ultimos 3m)
    SELECT COUNT(*) INTO @salidas_3m
    FROM `bbf_empleados`
    WHERE `ESTADO_EMPLEADO` = 'RETIRADO'
      AND `FECHA_RETIRO` >= @fecha_inicio
      AND `FECHA_RETIRO` <= @fecha_fin
      AND `ELIMINADO` = 0;

    -- 3) PROMEDIO DE ACTIVOS EN VENTANA (metodo: promedio de puntas de mes)
    --    Promedio = (Headcount al inicio del periodo + Headcount al final) / 2
    -- Headcount al inicio (hace 3 meses)
    SELECT COUNT(*) INTO @hc_inicio
    FROM `bbf_empleados`
    WHERE `FECHA_INGRESO` <= @fecha_inicio
      AND (`FECHA_RETIRO` IS NULL OR `FECHA_RETIRO` > @fecha_inicio)
      AND `ESTADO_EMPLEADO` = 'ACTIVO'
      AND `ELIMINADO` = 0;

    -- Headcount al final (hoy)
    SELECT COUNT(*) INTO @hc_fin
    FROM `bbf_empleados`
    WHERE `FECHA_INGRESO` <= @fecha_fin
      AND (`FECHA_RETIRO` IS NULL OR `FECHA_RETIRO` > @fecha_fin)
      AND `ESTADO_EMPLEADO` = 'ACTIVO'
      AND `ELIMINADO` = 0;

    SET @promedio_activos := ROUND((@hc_inicio + @hc_fin) / 2.0, 2);

    -- 4) TASA DE ROTACION
    SET @tasa_rotacion := CASE 
        WHEN @promedio_activos > 0 THEN ROUND((@salidas_3m / @promedio_activos) * 100, 2)
        ELSE 0 
    END;

    -- 5) RESULTSET 1: METRICAS PRINCIPALES
    SELECT 
        @tasa_rotacion      AS `tasa_rotacion`,
        @salidas_3m         AS `salidas`,
        @promedio_activos   AS `promedio_activos`,
        @fecha_inicio       AS `ventana_inicio`,
        @fecha_fin          AS `ventana_fin`,
        'promedio_puntas_mes' AS `metodo_calculo`;

    -- 6) RESULTSET 2: DESGLOSE DEMOGRAFICO (ACTIVOS HOY POR GENERO)
    --    Genero viene de bbf_empleado_ficha_ingreso.GENERO (free-text -> normalizado)
    SELECT 
        CASE 
            WHEN UPPER(TRIM(`fi`.`GENERO`)) IN ('M','MASCULINO','MALE','HOMBRE') THEN 'MASCULINO'
            WHEN UPPER(TRIM(`fi`.`GENERO`)) IN ('F','FEMENINO','FEMALE','MUJER') THEN 'FEMENINO'
            ELSE 'NO_ESPECIFICADO'
        END AS `genero`,
        COUNT(DISTINCT `e`.`ID_EMPLEADO`) AS `total_activos`
    FROM `bbf_empleados` `e`
    LEFT JOIN `bbf_empleado_ficha_ingreso` `fi` 
        ON `fi`.`ID_EMPLEADO` = `e`.`ID_EMPLEADO`
    WHERE `e`.`FECHA_INGRESO` <= @fecha_fin
      AND (`e`.`FECHA_RETIRO` IS NULL OR `e`.`FECHA_RETIRO` > @fecha_fin)
      AND `e`.`ESTADO_EMPLEADO` = 'ACTIVO'
      AND `e`.`ELIMINADO` = 0
    GROUP BY `genero`
    ORDER BY `total_activos` DESC;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

-- ============================================================
-- 3. PERMISOS
-- ============================================================
INSERT IGNORE INTO `bbf_permisos` (`CODIGO`, `NOMBRE`, `DESCRIPCION`, `MODULO`, `ACTIVO`)
VALUES
  ('DOMINIOS_VER', 'Ver dominios autorizados', 'Ver dominios autorizados', 'DOMINIOS', 1),
  ('EMPLEADOS_KPI_VER', 'Ver KPI Empleados', 'Ver KPI Empleados', 'EMPLEADOS', 1),
  ('EMPLEADOS_KPI_GESTIONAR', 'Gestionar KPI Empleados', 'Gestionar KPI Empleados', 'EMPLEADOS', 1),
  ('EMPLEADOS_KPI_EXPORTAR', 'Exportar KPI Empleados', 'Exportar KPI Empleados', 'EMPLEADOS', 1);

INSERT IGNORE INTO `bbf_rol_permisos` (`ID_ROL`, `ID_PERMISO`)
SELECT r.`ID_ROL`, p.`ID_PERMISO`
FROM `bbf_roles` r
JOIN `bbf_permisos` p
  ON p.`CODIGO` IN ('DOMINIOS_VER','EMPLEADOS_KPI_VER','EMPLEADOS_KPI_GESTIONAR','EMPLEADOS_KPI_EXPORTAR')
WHERE r.`NOMBRE` = 'SUPER_ADMIN';

-- ============================================================
-- 4. CERTIFICADOS / BASE DOCUMENTAL
-- ============================================================
CREATE TABLE IF NOT EXISTS `bbf_documento_formatos` (
  `ID_DOCUMENTO_FORMATO` int(11) NOT NULL AUTO_INCREMENT,
  `CLAVE_FORMATO` varchar(100) NOT NULL COMMENT 'Identidad funcional; no es el codigo impreso',
  `CODIGO_FORMATO` varchar(50) NOT NULL,
  `NOMBRE` varchar(200) NOT NULL,
  `VARIANTE` varchar(50) NOT NULL DEFAULT 'GENERAL',
  `VERSION_FORMATO` varchar(20) NOT NULL,
  `PROCESO` varchar(200) NOT NULL,
  `TITULO` varchar(250) NOT NULL,
  `CONTEXTO_ORIGEN` varchar(50) NOT NULL COMMENT 'EMPLEADO, RETIRO, CONTRATO, COMPROMISO, SOLICITUD_CESANTIAS',
  `VIGENCIA_DESDE` date NOT NULL,
  `VIGENCIA_HASTA` date DEFAULT NULL,
  `CLAVE_RENDERIZADOR` varchar(100) DEFAULT NULL COMMENT 'Clave permitida en codigo; no codigo ejecutable',
  `CONTROL_DOCUMENTAL_JSON` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `FIRMANTES_JSON` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Referencias a parametros y funciones, no nombres duplicados',
  `CONFIG_CAMPOS_JSON` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `ACTIVO` tinyint(1) NOT NULL DEFAULT 1,
  `HABILITADO_GENERACION` tinyint(1) NOT NULL DEFAULT 0,
  `CREATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  `UPDATED_AT` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`ID_DOCUMENTO_FORMATO`),
  UNIQUE KEY `UQ_BBF_DOC_FORMATO_VARIANTE_DESDE` (`CLAVE_FORMATO`,`VARIANTE`,`VIGENCIA_DESDE`),
  KEY `IDX_BBF_DOC_FORMATO_CONTEXTO` (`CONTEXTO_ORIGEN`,`ACTIVO`,`HABILITADO_GENERACION`,`VIGENCIA_DESDE`),
  CONSTRAINT `CK_BBF_DOC_FORMATO_VIGENCIA` CHECK (`VIGENCIA_HASTA` is null or `VIGENCIA_HASTA` >= `VIGENCIA_DESDE`),
  CONSTRAINT `CK_BBF_DOC_FORMATO_IDENTIDAD` CHECK (char_length(trim(`CLAVE_FORMATO`)) > 0 and char_length(trim(`VARIANTE`)) > 0 and octet_length(`CLAVE_FORMATO`) = octet_length(trim(`CLAVE_FORMATO`)) and octet_length(`VARIANTE`) = octet_length(trim(`VARIANTE`))),
  CONSTRAINT `CK_BBF_DOC_FORMATO_METADATOS` CHECK (char_length(trim(`CODIGO_FORMATO`)) > 0 and char_length(trim(`NOMBRE`)) > 0 and char_length(trim(`VERSION_FORMATO`)) > 0 and char_length(trim(`PROCESO`)) > 0 and char_length(trim(`TITULO`)) > 0),
  CONSTRAINT `CK_BBF_DOC_FORMATO_CONTEXTO` CHECK (`CONTEXTO_ORIGEN` in ('EMPLEADO','RETIRO','CONTRATO','COMPROMISO','SOLICITUD_CESANTIAS')),
  CONSTRAINT `CK_BBF_DOC_FORMATO_CONTROL_JSON` CHECK (`CONTROL_DOCUMENTAL_JSON` is null or json_valid(`CONTROL_DOCUMENTAL_JSON`)),
  CONSTRAINT `CK_BBF_DOC_FORMATO_FIRMANTES_JSON` CHECK (`FIRMANTES_JSON` is null or json_valid(`FIRMANTES_JSON`)),
  CONSTRAINT `CK_BBF_DOC_FORMATO_CAMPOS_JSON` CHECK (`CONFIG_CAMPOS_JSON` is null or json_valid(`CONFIG_CAMPOS_JSON`)),
  CONSTRAINT `CK_BBF_DOC_FORMATO_FLAGS` CHECK (`ACTIVO` in (0,1) and `HABILITADO_GENERACION` in (0,1)),
  CONSTRAINT `CK_BBF_DOC_FORMATO_RENDER` CHECK (`HABILITADO_GENERACION` = 0 or `CLAVE_RENDERIZADOR` is not null and char_length(trim(`CLAVE_RENDERIZADOR`)) > 0)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_DOCUMENTO_FORMATOS_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_DOCUMENTO_FORMATOS_LISTAR`(
    IN P_CONTEXTO VARCHAR(50),
    IN P_FECHA DATE
)
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
BEGIN
    DECLARE V_CONTEXTO VARCHAR(50);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        DROP TEMPORARY TABLE IF EXISTS `tmp_bbf_doc_formatos_lista`;
        RESIGNAL;
    END;
    SET V_CONTEXTO = NULLIF(UPPER(TRIM(P_CONTEXTO)), '');
    IF P_FECHA IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Indique la fecha de consulta del catalogo documental.';
    END IF;
    IF V_CONTEXTO IS NOT NULL AND V_CONTEXTO NOT IN ('EMPLEADO','RETIRO','CONTRATO','COMPROMISO','SOLICITUD_CESANTIAS') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Contexto documental no valido.';
    END IF;
    -- Una sola lectura de la tabla permanente: validar y devolver la misma copia.
    -- Tabla temporal privada de esta conexion; no registra emisiones.
    DROP TEMPORARY TABLE IF EXISTS `tmp_bbf_doc_formatos_lista`;
    CREATE TEMPORARY TABLE `tmp_bbf_doc_formatos_lista` AS
        SELECT F.* FROM `bbf_documento_formatos` F
        WHERE F.ACTIVO = 1 AND F.HABILITADO_GENERACION = 1
          AND (V_CONTEXTO IS NULL OR F.CONTEXTO_ORIGEN = V_CONTEXTO)
          AND F.VIGENCIA_DESDE <= P_FECHA
          AND (F.VIGENCIA_HASTA IS NULL OR F.VIGENCIA_HASTA >= P_FECHA);
    IF EXISTS (
        SELECT 1 FROM `tmp_bbf_doc_formatos_lista` F
        GROUP BY F.CLAVE_FORMATO, F.VARIANTE
        HAVING COUNT(*) > 1
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Hay variantes documentales con vigencias superpuestas.';
    END IF;
    SELECT F.* FROM `tmp_bbf_doc_formatos_lista` F
    ORDER BY F.CONTEXTO_ORIGEN, F.CODIGO_FORMATO, F.CLAVE_FORMATO, F.VARIANTE;
    DROP TEMPORARY TABLE `tmp_bbf_doc_formatos_lista`;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_DOCUMENTO_FORMATO_OBTENER` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_DOCUMENTO_FORMATO_OBTENER`(
    IN P_CLAVE VARCHAR(100),
    IN P_VARIANTE VARCHAR(50),
    IN P_FECHA DATE
)
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
BEGIN
    DECLARE V_CLAVE VARCHAR(100);
    DECLARE V_VARIANTE VARCHAR(50);
    DECLARE V_CANTIDAD INT DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        DROP TEMPORARY TABLE IF EXISTS `tmp_bbf_doc_formato_detalle`;
        RESIGNAL;
    END;
    SET V_CLAVE = NULLIF(UPPER(TRIM(P_CLAVE)), '');
    SET V_VARIANTE = NULLIF(UPPER(TRIM(P_VARIANTE)), '');
    IF V_CLAVE IS NULL OR V_VARIANTE IS NULL OR P_FECHA IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Indique clave, variante y fecha del formato documental.';
    END IF;
    DROP TEMPORARY TABLE IF EXISTS `tmp_bbf_doc_formato_detalle`;
    CREATE TEMPORARY TABLE `tmp_bbf_doc_formato_detalle` AS
    SELECT F.* FROM `bbf_documento_formatos` F
    WHERE F.CLAVE_FORMATO = V_CLAVE AND F.VARIANTE = V_VARIANTE
      AND F.ACTIVO = 1 AND F.HABILITADO_GENERACION = 1
      AND F.VIGENCIA_DESDE <= P_FECHA
      AND (F.VIGENCIA_HASTA IS NULL OR F.VIGENCIA_HASTA >= P_FECHA);
    SELECT COUNT(*) INTO V_CANTIDAD FROM `tmp_bbf_doc_formato_detalle`;
    IF V_CANTIDAD = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Formato no encontrado, no vigente o no habilitado para generacion.';
    END IF;
    IF V_CANTIDAD > 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La variante documental tiene vigencias superpuestas.';
    END IF;
    SELECT F.* FROM `tmp_bbf_doc_formato_detalle` F;
    DROP TEMPORARY TABLE `tmp_bbf_doc_formato_detalle`;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

-- Carga inicial de tipos documentales (idempotente)
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


-- Variantes F-002 (idempotentes, no modifican GENERAL)
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


-- Ejecutar solo tras seleccionar y verificar explícitamente la BD destino.
-- No ejecutado por la aplicación. No altera GENERAL ni inventa firmantes.
-- Copia metadatos institucionales de una única configuración GENERAL vigente
-- previamente verificada; si no existe o es ambigua, no registra ninguna fila.
-- La nueva variante queda deshabilitada hasta aprobación institucional.
INSERT INTO bbf_documento_formatos
 (CLAVE_FORMATO, CODIGO_FORMATO, NOMBRE, VARIANTE, VERSION_FORMATO, PROCESO,
  TITULO, CONTEXTO_ORIGEN, VIGENCIA_DESDE, VIGENCIA_HASTA, CLAVE_RENDERIZADOR,
  CONTROL_DOCUMENTAL_JSON, FIRMANTES_JSON, CONFIG_CAMPOS_JSON, ACTIVO, HABILITADO_GENERACION)
SELECT G.CLAVE_FORMATO, G.CODIGO_FORMATO,
 'Certificado laboral activo con salario y afiliaciones', 'SALARIO_AFILIACIONES',
 G.VERSION_FORMATO, G.PROCESO, G.TITULO, G.CONTEXTO_ORIGEN,
 G.VIGENCIA_DESDE, G.VIGENCIA_HASTA, 'certificado-laboral-activo-salario-afiliaciones',
 G.CONTROL_DOCUMENTAL_JSON, G.FIRMANTES_JSON,
 '{"campos_declarados":["fondo_solidaridad","retencion_fuente"]}', 1, 0
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
 AND NOT EXISTS (SELECT 1 FROM bbf_documento_formatos S
                 WHERE S.CLAVE_FORMATO = G.CLAVE_FORMATO AND S.VARIANTE = 'SALARIO_AFILIACIONES');

-- Inspeccionar la fila y validar los parámetros referenciados antes de habilitarla.
SELECT * FROM bbf_documento_formatos
WHERE CLAVE_FORMATO = 'CERTIFICADO_LABORAL_ACTIVO' AND VARIANTE = 'SALARIO_AFILIACIONES';


-- Habilitacion de generacion de formatos (HABILITADO_GENERACION = 1)
-- BD/20261013_f003_habilitacion.sql
-- Habilitación de BBTH-F-003 Certificado Laboral de Retiro
-- Ejecutar SOLO en DEV después de verificar la BD destino
-- Este script es idempotente y no destruye datos existentes

-- 1. Actualizar el registro existente de BBTH-F-003
UPDATE bbf_documento_formatos
SET CLAVE_RENDERIZADOR = 'certificado-laboral-retiro',
    HABILITADO_GENERACION = 1,
    FIRMANTES_JSON = (
        SELECT F2.FIRMANTES_JSON
        FROM (SELECT FIRMANTES_JSON FROM bbf_documento_formatos
              WHERE CODIGO_FORMATO = 'BBTH-F-002' AND VARIANTE = 'GENERAL'
              LIMIT 1) F2
    ),
    CONTROL_DOCUMENTAL_JSON = JSON_OBJECT(
        'estado_validacion', 'APROBADO',
        'fuente', '00. Definiciones/Certificados/BBTH -F-003 CERTIFICADO LABORAL DE RETIRO A COLABORADOR.docx',
        'vigencia_fuente', 'Versión 02 del encabezado',
        'observaciones', 'Implementado con motor documental F-002. Campos manuales: fondo_solidaridad, retencion_fuente, auxilio_transporte.'
    )
WHERE CLAVE_FORMATO = 'CERTIFICADO_LABORAL_RETIRO'
  AND CODIGO_FORMATO = 'BBTH-F-003'
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
    HABILITADO_GENERACION,
    ACTIVO
FROM bbf_documento_formatos
WHERE CLAVE_FORMATO = 'CERTIFICADO_LABORAL_RETIRO'
  AND CODIGO_FORMATO = 'BBTH-F-003';

-- 3. Verificar que el SP de listado lo retorna
CALL SP_BBF_DOCUMENTO_FORMATOS_LISTAR('EMPLEADO', DATE(CONVERT_TZ(UTC_TIMESTAMP(), '+00:00', '-05:00')));


-- BD/20261013_f004_habilitacion.sql
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


-- BD/20261013_f005_habilitacion.sql
-- Habilitación de BBTH-F-005 Carta de aceptación de renuncia
-- Ejecutar SOLO en DEV después de verificar la BD destino
-- Este script es idempotente y no destruye datos existentes
-- No modifica otros formatos. No ejecutar automáticamente.

-- 1. Actualizar el registro existente de BBTH-F-005
-- Copia los firmantes institucionales de BBTH-F-002 (ya operativos).
UPDATE bbf_documento_formatos
SET CLAVE_RENDERIZADOR = 'carta-aceptacion-renuncia',
    HABILITADO_GENERACION = 1,
    FIRMANTES_JSON = (
        SELECT F2.FIRMANTES_JSON
        FROM (SELECT FIRMANTES_JSON FROM bbf_documento_formatos
              WHERE CODIGO_FORMATO = 'BBTH-F-002' AND VARIANTE = 'GENERAL'
              LIMIT 1) F2
    ),
    CONTROL_DOCUMENTAL_JSON = JSON_OBJECT(
        'estado_validacion', 'APROBADO',
        'fuente', '00. Definiciones/Certificados/BBTH-F-005 CARTA ACEPTACIÓN RENUNCIA.docx',
        'vigencia_fuente', 'Versión 01 del encabezado',
        'observaciones', 'Solo renuncia voluntaria (motivo con REQUIERE_RENUNCIA). Fecha de presentación suministrada por el usuario. No modifica retiro ni empleado.'
    )
WHERE CLAVE_FORMATO = 'ACEPTACION_RENUNCIA'
  AND CODIGO_FORMATO = 'BBTH-F-005'
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
WHERE CLAVE_FORMATO = 'ACEPTACION_RENUNCIA'
  AND CODIGO_FORMATO = 'BBTH-F-005';

-- 3. Verificar que los SP lo retornan (solo lectura)
CALL SP_BBF_DOCUMENTO_FORMATOS_LISTAR(NULL, DATE(CONVERT_TZ(UTC_TIMESTAMP(), '+00:00', '-05:00')));


-- BD/20261013_f011_habilitacion.sql
-- Habilitación de BBTH-F-011 Carta de retiro de cesantías para vivienda
-- Ejecutar SOLO en DEV después de verificar la BD destino
-- Este script es idempotente y no destruye datos existentes
-- No modifica otros formatos. No ejecutar automáticamente.

-- 1. Actualizar el registro existente de BBTH-F-011
-- Copia los firmantes institucionales de BBTH-F-002 (ya operativos).
UPDATE bbf_documento_formatos
SET CLAVE_RENDERIZADOR = 'carta-retiro-cesantias-vivienda',
    HABILITADO_GENERACION = 1,
    FIRMANTES_JSON = (
        SELECT F2.FIRMANTES_JSON
        FROM (SELECT FIRMANTES_JSON FROM bbf_documento_formatos
              WHERE CODIGO_FORMATO = 'BBTH-F-002' AND VARIANTE = 'GENERAL'
              LIMIT 1) F2
    ),
    CONTROL_DOCUMENTAL_JSON = JSON_OBJECT(
        'estado_validacion', 'APROBADO',
        'fuente', '00. Definiciones/Certificados/BBTH-F-011 CARTA RETIRO DE CESANTIAS PARA VIVIENDA.docx',
        'vigencia_fuente', 'Versión 01 del encabezado',
        'observaciones', 'Modalidad seleccionable (TOTAL/PARCIAL). Monto y concepto suministrados por el usuario. Fondo de cesantías oficial. No modifica registros.'
    )
WHERE CLAVE_FORMATO = 'CESANTIAS_VIVIENDA'
  AND CODIGO_FORMATO = 'BBTH-F-011'
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
WHERE CLAVE_FORMATO = 'CESANTIAS_VIVIENDA'
  AND CODIGO_FORMATO = 'BBTH-F-011';

-- 3. Verificar que los SP lo retornan (solo lectura)
CALL SP_BBF_DOCUMENTO_FORMATOS_LISTAR(NULL, DATE(CONVERT_TZ(UTC_TIMESTAMP(), '+00:00', '-05:00')));


-- BD/20261013_f012_habilitacion.sql
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


-- BD/20261013_f015_habilitacion.sql
-- Habilitación de BBTH-F-015 Carta de notificación de no renovación de contrato
-- Ejecutar SOLO en DEV después de verificar la BD destino
-- Este script es idempotente y no destruye datos existentes
-- No modifica otros formatos ni las plantillas contractuales F-015. No ejecutar automáticamente.

-- 1. Actualizar el registro existente de BBTH-F-015
-- Copia los firmantes institucionales de BBTH-F-002 (ya operativos).
UPDATE bbf_documento_formatos
SET CLAVE_RENDERIZADOR = 'carta-no-renovacion-contrato',
    HABILITADO_GENERACION = 1,
    FIRMANTES_JSON = (
        SELECT F2.FIRMANTES_JSON
        FROM (SELECT FIRMANTES_JSON FROM bbf_documento_formatos
              WHERE CODIGO_FORMATO = 'BBTH-F-002' AND VARIANTE = 'GENERAL'
              LIMIT 1) F2
    ),
    CONTROL_DOCUMENTAL_JSON = JSON_OBJECT(
        'estado_validacion', 'APROBADO',
        'fuente', '00. Definiciones/Certificados/BBTH-F-015 FORMATO DE NO RENOVACION DE CONTRATO.docx',
        'vigencia_fuente', 'Versión 01 del encabezado',
        'observaciones', 'Solo contratos a término fijo activos. NIT suministrado por el usuario. No modifica registros.'
    )
WHERE CLAVE_FORMATO = 'NO_RENOVACION_CONTRATO'
  AND CODIGO_FORMATO = 'BBTH-F-015'
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
WHERE CLAVE_FORMATO = 'NO_RENOVACION_CONTRATO'
  AND CODIGO_FORMATO = 'BBTH-F-015';

-- 3. Verificar que los SP lo retornan (solo lectura)
CALL SP_BBF_DOCUMENTO_FORMATOS_LISTAR(NULL, DATE(CONVERT_TZ(UTC_TIMESTAMP(), '+00:00', '-05:00')));


-- ============================================================
-- 5. CAPACITACIONES
-- ============================================================
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_CAPACITACION_PARTICIPANTES_AGREGAR_TODOS_ACTIVOS` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_CAPACITACION_PARTICIPANTES_AGREGAR_TODOS_ACTIVOS`(
    IN P_ID_SESION INT,
    IN P_ID_USUARIO INT,
    OUT P_INSERTADOS INT,
    OUT P_OMITIDOS_DUPLICADOS INT,
    OUT P_MENSAJE VARCHAR(500)
)
BEGIN
    DECLARE V_REQUIERE_EVALUACION TINYINT;
    DECLARE V_ESTADO_SESION VARCHAR(20);
    DECLARE V_ID_CAPACITACION INT;
    DECLARE V_OBSERVACIONES VARCHAR(200);
    
    -- Validar sesión y obtener configuración de la capacitación
    SELECT S.ESTADO, C.REQUIERE_EVALUACION, C.ID_CAPACITACION
    INTO V_ESTADO_SESION, V_REQUIERE_EVALUACION, V_ID_CAPACITACION
    FROM bbf_capacitacion_sesiones S
    INNER JOIN bbf_capacitaciones C ON C.ID_CAPACITACION = S.ID_CAPACITACION
    WHERE S.ID_CAPACITACION_SESION = P_ID_SESION
    LIMIT 1;
    
    IF V_ESTADO_SESION IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La sesión no existe.';
    END IF;
    
    IF V_ESTADO_SESION = 'ANULADA' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se pueden agregar participantes a una sesión anulada.';
    END IF;
    
    IF V_ESTADO_SESION = 'CERRADA' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se pueden agregar participantes a una sesión cerrada.';
    END IF;
    
    SET V_OBSERVACIONES = CONCAT('Agregado masivo: ', DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s'));
    
    -- Inserción masiva de empleados ACTIVOS que NO estén ya en la sesión
    -- El UNIQUE KEY (ID_CAPACITACION_SESION, ID_EMPLEADO) previene duplicados a nivel BD
    -- El NOT EXISTS evita intentos innecesarios y permite contar omitidos
    INSERT INTO bbf_capacitacion_participantes (
        ID_CAPACITACION_SESION, 
        ID_EMPLEADO, 
        ESTADO_EVALUACION, 
        OBSERVACIONES, 
        ID_REGISTRADO_POR
    )
    SELECT 
        P_ID_SESION,
        E.ID_EMPLEADO,
        IF(V_REQUIERE_EVALUACION = 1, 'PENDIENTE', 'NO_APLICA'),
        V_OBSERVACIONES,
        P_ID_USUARIO
    FROM bbf_empleados E
    WHERE E.ESTADO_EMPLEADO = 'ACTIVO'
      AND E.ELIMINADO = 0
      AND NOT EXISTS (
          SELECT 1 
          FROM bbf_capacitacion_participantes P 
          WHERE P.ID_CAPACITACION_SESION = P_ID_SESION 
            AND P.ID_EMPLEADO = E.ID_EMPLEADO
      );
    
    SET P_INSERTADOS = ROW_COUNT();
    
    -- Contar empleados activos que YA participaban (omitidos por duplicado)
    SELECT COUNT(*) INTO P_OMITIDOS_DUPLICADOS
    FROM bbf_empleados E
    WHERE E.ESTADO_EMPLEADO = 'ACTIVO'
      AND E.ELIMINADO = 0
      AND EXISTS (
          SELECT 1 
          FROM bbf_capacitacion_participantes P 
          WHERE P.ID_CAPACITACION_SESION = P_ID_SESION 
            AND P.ID_EMPLEADO = E.ID_EMPLEADO
      );
    
    SET P_MENSAJE = CONCAT('Proceso completado: ', P_INSERTADOS, ' empleados agregados, ', P_OMITIDOS_DUPLICADOS, ' ya participaban.');
    
    -- Retornar lista completa de participantes actualizada (para refrescar UI)
    SELECT 
        P.*,
        E.NUMERO_DOCUMENTO,
        CONCAT_WS(' ', E.NOMBRES, E.APELLIDOS) AS EMPLEADO,
        E.ESTADO_EMPLEADO
    FROM bbf_capacitacion_participantes P 
    INNER JOIN bbf_empleados E ON E.ID_EMPLEADO = P.ID_EMPLEADO
    WHERE P.ID_CAPACITACION_SESION = P_ID_SESION 
    ORDER BY E.NOMBRES, E.APELLIDOS;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
