USE `cWeb`;

SET FOREIGN_KEY_CHECKS=0;

/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_AREAS_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_AREAS_LISTAR`(
    IN P_SOLO_ACTIVOS TINYINT
)
BEGIN
    SELECT
        ID_AREA,
        NOMBRE,
        DESCRIPCION,
        ACTIVO,
        CREATED_AT,
        UPDATED_AT
    FROM bbf_areas
    WHERE P_SOLO_ACTIVOS = 0 OR ACTIVO = 1
    ORDER BY NOMBRE ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_ASPIRANTES_ACTUALIZAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_ASPIRANTES_ACTUALIZAR`(
    IN P_ID_ASPIRANTE INT,
    IN P_ID_TIPO_DOCUMENTO INT,
    IN P_NUMERO_DOCUMENTO VARCHAR(50),
    IN P_NOMBRES VARCHAR(150),
    IN P_APELLIDOS VARCHAR(150),
    IN P_CORREO VARCHAR(150),
    IN P_TELEFONO VARCHAR(50),
    IN P_DIRECCION VARCHAR(250),
    IN P_FECHA_NACIMIENTO DATE,
    IN P_LUGAR_NACIMIENTO VARCHAR(150),
    IN P_NACIONALIDAD VARCHAR(100),
    IN P_ID_AREA_ASPIRA INT,
    IN P_ID_CARGO_ASPIRA INT,
    IN P_OBSERVACIONES TEXT
)
BEGIN
    DECLARE V_EXISTE INT DEFAULT 0;

    SELECT COUNT(*)
    INTO V_EXISTE
    FROM bbf_aspirantes
    WHERE ID_ASPIRANTE = P_ID_ASPIRANTE
      AND IFNULL(ELIMINADO, 0) = 0;

    IF V_EXISTE = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El aspirante no existe o fue eliminado.';
    END IF;

    SELECT COUNT(*)
    INTO V_EXISTE
    FROM bbf_aspirantes
    WHERE NUMERO_DOCUMENTO = P_NUMERO_DOCUMENTO
      AND ID_ASPIRANTE <> P_ID_ASPIRANTE
      AND IFNULL(ELIMINADO, 0) = 0;

    IF V_EXISTE > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ya existe otro aspirante activo con ese número de documento.';
    END IF;

    UPDATE bbf_aspirantes
    SET
        ID_TIPO_DOCUMENTO = P_ID_TIPO_DOCUMENTO,
        NUMERO_DOCUMENTO = P_NUMERO_DOCUMENTO,
        NOMBRES = P_NOMBRES,
        APELLIDOS = P_APELLIDOS,
        CORREO = P_CORREO,
        TELEFONO = P_TELEFONO,
        DIRECCION = P_DIRECCION,
        FECHA_NACIMIENTO = P_FECHA_NACIMIENTO,
        LUGAR_NACIMIENTO = P_LUGAR_NACIMIENTO,
        NACIONALIDAD = P_NACIONALIDAD,
        ID_AREA_ASPIRA = P_ID_AREA_ASPIRA,
        ID_CARGO_ASPIRA = P_ID_CARGO_ASPIRA,
        OBSERVACIONES = P_OBSERVACIONES,
        UPDATED_AT = CURRENT_TIMESTAMP
    WHERE ID_ASPIRANTE = P_ID_ASPIRANTE;

    SELECT
        P_ID_ASPIRANTE AS ID_ASPIRANTE,
        'ACTUALIZADO' AS RESULTADO;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_ASPIRANTES_CAMBIAR_ESTADO` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_ASPIRANTES_CAMBIAR_ESTADO`(
    IN P_ID_ASPIRANTE INT,
    IN P_ESTADO_NUEVO VARCHAR(50),
    IN P_OBSERVACIONES TEXT,
    IN P_ID_USUARIO INT
)
BEGIN
    DECLARE V_ESTADO_ANTERIOR VARCHAR(50);
    DECLARE V_EXISTE INT DEFAULT 0;

    IF P_ESTADO_NUEVO NOT IN (
        'REGISTRADO',
        'EN_REVISION',
        'APROBADO_CONTRATACION',
        'RECHAZADO',
        'CONVERTIDO_EMPLEADO',
        'CANCELADO'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Estado de aspirante no válido.';
    END IF;

    SELECT COUNT(*)
    INTO V_EXISTE
    FROM bbf_aspirantes
    WHERE ID_ASPIRANTE = P_ID_ASPIRANTE
      AND IFNULL(ELIMINADO, 0) = 0;

    IF V_EXISTE = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El aspirante no existe o fue eliminado.';
    END IF;

    SELECT ESTADO_ASPIRANTE
    INTO V_ESTADO_ANTERIOR
    FROM bbf_aspirantes
    WHERE ID_ASPIRANTE = P_ID_ASPIRANTE
    LIMIT 1;

    IF V_ESTADO_ANTERIOR = 'CONVERTIDO_EMPLEADO' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede cambiar el estado de un aspirante ya convertido en empleado.';
    END IF;

    UPDATE bbf_aspirantes
    SET
        ESTADO_ASPIRANTE = P_ESTADO_NUEVO,
        UPDATED_AT = CURRENT_TIMESTAMP
    WHERE ID_ASPIRANTE = P_ID_ASPIRANTE;

    INSERT INTO bbf_aspirante_estado_historial (
        ID_ASPIRANTE,
        ESTADO_ANTERIOR,
        ESTADO_NUEVO,
        OBSERVACIONES,
        ID_USUARIO_CAMBIO
    )
    VALUES (
        P_ID_ASPIRANTE,
        V_ESTADO_ANTERIOR,
        P_ESTADO_NUEVO,
        P_OBSERVACIONES,
        P_ID_USUARIO
    );

    SELECT
        P_ID_ASPIRANTE AS ID_ASPIRANTE,
        V_ESTADO_ANTERIOR AS ESTADO_ANTERIOR,
        P_ESTADO_NUEVO AS ESTADO_NUEVO;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_ASPIRANTES_CONVERTIR_EMPLEADO` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_ASPIRANTES_CONVERTIR_EMPLEADO`(
    IN P_ID_ASPIRANTE INT,
    IN P_ID_TIPO_CONTRATO INT,
    IN P_FECHA_INGRESO DATE,
    IN P_ID_USUARIO INT,
    IN P_OBSERVACIONES TEXT
)
BEGIN
    DECLARE V_EXISTE INT DEFAULT 0;
    DECLARE V_ESTADO VARCHAR(50);
    DECLARE V_ID_EMPLEADO_GENERADO INT;
    DECLARE V_NUMERO_DOCUMENTO VARCHAR(50);
    DECLARE V_ID_EMPLEADO_NUEVO INT;
    DECLARE V_ESTADO_ANTERIOR VARCHAR(50);

    SELECT COUNT(*)
    INTO V_EXISTE
    FROM bbf_aspirantes
    WHERE ID_ASPIRANTE = P_ID_ASPIRANTE
      AND IFNULL(ELIMINADO, 0) = 0;

    IF V_EXISTE = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El aspirante no existe o fue eliminado.';
    END IF;

    SELECT
        ESTADO_ASPIRANTE,
        ID_EMPLEADO_GENERADO,
        NUMERO_DOCUMENTO
    INTO
        V_ESTADO,
        V_ID_EMPLEADO_GENERADO,
        V_NUMERO_DOCUMENTO
    FROM bbf_aspirantes
    WHERE ID_ASPIRANTE = P_ID_ASPIRANTE
    LIMIT 1;

    IF V_ESTADO <> 'APROBADO_CONTRATACION' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El aspirante debe estar en estado APROBADO_CONTRATACION para convertirse en empleado.';
    END IF;

    IF V_ID_EMPLEADO_GENERADO IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El aspirante ya fue convertido en empleado.';
    END IF;

    SELECT COUNT(*)
    INTO V_EXISTE
    FROM bbf_empleados
    WHERE NUMERO_DOCUMENTO = V_NUMERO_DOCUMENTO
      AND IFNULL(ELIMINADO, 0) = 0;

    IF V_EXISTE > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ya existe un empleado activo con el documento del aspirante.';
    END IF;

    INSERT INTO bbf_empleados (
        ID_ASPIRANTE_ORIGEN,
        ID_TIPO_DOCUMENTO,
        NUMERO_DOCUMENTO,
        NOMBRES,
        APELLIDOS,
        CORREO,
        TELEFONO,
        ID_AREA,
        ID_CARGO,
        ID_TIPO_CONTRATO,
        FECHA_INGRESO,
        ESTADO_EMPLEADO,
        OBSERVACIONES
    )
    SELECT
        A.ID_ASPIRANTE,
        A.ID_TIPO_DOCUMENTO,
        A.NUMERO_DOCUMENTO,
        A.NOMBRES,
        A.APELLIDOS,
        A.CORREO,
        A.TELEFONO,
        A.ID_AREA_ASPIRA,
        A.ID_CARGO_ASPIRA,
        P_ID_TIPO_CONTRATO,
        IFNULL(P_FECHA_INGRESO, CURRENT_DATE()),
        'ACTIVO',
        CONCAT(
            'Empleado generado desde aspirante. ',
            IFNULL(P_OBSERVACIONES, '')
        )
    FROM bbf_aspirantes A
    WHERE A.ID_ASPIRANTE = P_ID_ASPIRANTE;

    SET V_ID_EMPLEADO_NUEVO = LAST_INSERT_ID();

    INSERT INTO bbf_empleado_documentos (
        ID_EMPLEADO,
        ID_TIPO_DOCUMENTO_LABORAL,
        NOMBRE_ARCHIVO,
        ARCHIVO_URL,
        MIME_TYPE,
        PESO_BYTES,
        ESTADO_DOCUMENTO,
        OBSERVACIONES,
        ID_CARGADO_POR
    )
    SELECT
        V_ID_EMPLEADO_NUEVO,
        AD.ID_TIPO_DOCUMENTO_LABORAL,
        AD.NOMBRE_ARCHIVO,
        AD.ARCHIVO_URL,
        AD.MIME_TYPE,
        AD.PESO_BYTES,
        AD.ESTADO_DOCUMENTO,
        CONCAT('Documento migrado desde aspirante. ', IFNULL(AD.OBSERVACIONES, '')),
        AD.ID_CARGADO_POR
    FROM bbf_aspirante_documentos AD
    WHERE AD.ID_ASPIRANTE = P_ID_ASPIRANTE
      AND IFNULL(AD.ELIMINADO, 0) = 0;

    SET V_ESTADO_ANTERIOR = V_ESTADO;

    UPDATE bbf_aspirantes
    SET
        ESTADO_ASPIRANTE = 'CONVERTIDO_EMPLEADO',
        ID_EMPLEADO_GENERADO = V_ID_EMPLEADO_NUEVO,
        UPDATED_AT = CURRENT_TIMESTAMP
    WHERE ID_ASPIRANTE = P_ID_ASPIRANTE;

    INSERT INTO bbf_aspirante_estado_historial (
        ID_ASPIRANTE,
        ESTADO_ANTERIOR,
        ESTADO_NUEVO,
        OBSERVACIONES,
        ID_USUARIO_CAMBIO
    )
    VALUES (
        P_ID_ASPIRANTE,
        V_ESTADO_ANTERIOR,
        'CONVERTIDO_EMPLEADO',
        IFNULL(P_OBSERVACIONES, 'Aspirante convertido en empleado'),
        P_ID_USUARIO
    );

    SELECT
        P_ID_ASPIRANTE AS ID_ASPIRANTE,
        V_ID_EMPLEADO_NUEVO AS ID_EMPLEADO,
        'CONVERTIDO_EMPLEADO' AS ESTADO_ASPIRANTE;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_ASPIRANTES_CREAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_ASPIRANTES_CREAR`(
    IN P_ID_TIPO_DOCUMENTO INT,
    IN P_NUMERO_DOCUMENTO VARCHAR(50),
    IN P_NOMBRES VARCHAR(150),
    IN P_APELLIDOS VARCHAR(150),
    IN P_CORREO VARCHAR(150),
    IN P_TELEFONO VARCHAR(50),
    IN P_DIRECCION VARCHAR(250),
    IN P_FECHA_NACIMIENTO DATE,
    IN P_LUGAR_NACIMIENTO VARCHAR(150),
    IN P_NACIONALIDAD VARCHAR(100),
    IN P_ID_AREA_ASPIRA INT,
    IN P_ID_CARGO_ASPIRA INT,
    IN P_OBSERVACIONES TEXT,
    IN P_ID_USUARIO INT
)
BEGIN
    DECLARE V_ID_ASPIRANTE INT;
    DECLARE V_EXISTE INT DEFAULT 0;

    SELECT COUNT(*)
    INTO V_EXISTE
    FROM bbf_aspirantes
    WHERE NUMERO_DOCUMENTO = P_NUMERO_DOCUMENTO
      AND IFNULL(ELIMINADO, 0) = 0;

    IF V_EXISTE > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ya existe un aspirante activo con ese número de documento.';
    END IF;

    SELECT COUNT(*)
    INTO V_EXISTE
    FROM bbf_empleados
    WHERE NUMERO_DOCUMENTO = P_NUMERO_DOCUMENTO
      AND IFNULL(ELIMINADO, 0) = 0;

    IF V_EXISTE > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ya existe un empleado activo con ese número de documento.';
    END IF;

    INSERT INTO bbf_aspirantes (
        ID_TIPO_DOCUMENTO,
        NUMERO_DOCUMENTO,
        NOMBRES,
        APELLIDOS,
        CORREO,
        TELEFONO,
        DIRECCION,
        FECHA_NACIMIENTO,
        LUGAR_NACIMIENTO,
        NACIONALIDAD,
        ID_AREA_ASPIRA,
        ID_CARGO_ASPIRA,
        ESTADO_ASPIRANTE,
        OBSERVACIONES
    )
    VALUES (
        P_ID_TIPO_DOCUMENTO,
        P_NUMERO_DOCUMENTO,
        P_NOMBRES,
        P_APELLIDOS,
        P_CORREO,
        P_TELEFONO,
        P_DIRECCION,
        P_FECHA_NACIMIENTO,
        P_LUGAR_NACIMIENTO,
        P_NACIONALIDAD,
        P_ID_AREA_ASPIRA,
        P_ID_CARGO_ASPIRA,
        'REGISTRADO',
        P_OBSERVACIONES
    );

    SET V_ID_ASPIRANTE = LAST_INSERT_ID();

    INSERT INTO bbf_aspirante_estado_historial (
        ID_ASPIRANTE,
        ESTADO_ANTERIOR,
        ESTADO_NUEVO,
        OBSERVACIONES,
        ID_USUARIO_CAMBIO
    )
    VALUES (
        V_ID_ASPIRANTE,
        NULL,
        'REGISTRADO',
        'Registro inicial del aspirante',
        P_ID_USUARIO
    );

    SELECT
        V_ID_ASPIRANTE AS ID_ASPIRANTE,
        'REGISTRADO' AS ESTADO_ASPIRANTE;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_ASPIRANTES_DOCUMENTOS_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_ASPIRANTES_DOCUMENTOS_LISTAR`(
    IN P_ID_ASPIRANTE INT
)
BEGIN
    SELECT
        D.ID_ASPIRANTE_DOCUMENTO,
        D.ID_ASPIRANTE,
        D.ID_TIPO_DOCUMENTO_LABORAL,
        TD.NOMBRE AS TIPO_DOCUMENTO_LABORAL,
        TD.OBLIGATORIO,
        TD.REQUIERE_VENCIMIENTO,
        TD.APLICA_ASPIRANTE,

        D.NOMBRE_ARCHIVO,
        D.ARCHIVO_URL,
        D.MIME_TYPE,
        D.PESO_BYTES,
        D.ESTADO_DOCUMENTO,
        D.OBSERVACIONES,

        D.ID_CARGADO_POR,
        U.NOMBRE_USUARIO AS CARGADO_POR,

        D.CREATED_AT,
        D.UPDATED_AT

    FROM bbf_aspirante_documentos D
    INNER JOIN bbf_tipos_documento_laboral TD
        ON TD.ID_TIPO_DOCUMENTO_LABORAL = D.ID_TIPO_DOCUMENTO_LABORAL
    LEFT JOIN bbf_usuarios U
        ON U.ID_USUARIO = D.ID_CARGADO_POR
    WHERE D.ID_ASPIRANTE = P_ID_ASPIRANTE
      AND IFNULL(D.ELIMINADO, 0) = 0
    ORDER BY TD.OBLIGATORIO DESC, TD.NOMBRE ASC, D.CREATED_AT DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_ASPIRANTES_DOCUMENTO_REGISTRAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_ASPIRANTES_DOCUMENTO_REGISTRAR`(
    IN P_ID_ASPIRANTE INT,
    IN P_ID_TIPO_DOCUMENTO_LABORAL INT,
    IN P_NOMBRE_ARCHIVO VARCHAR(255),
    IN P_ARCHIVO_URL VARCHAR(500),
    IN P_MIME_TYPE VARCHAR(100),
    IN P_PESO_BYTES BIGINT,
    IN P_ESTADO_DOCUMENTO VARCHAR(50),
    IN P_OBSERVACIONES TEXT,
    IN P_ID_CARGADO_POR INT
)
BEGIN
    DECLARE V_EXISTE_ASPIRANTE INT DEFAULT 0;
    DECLARE V_APLICA_ASPIRANTE INT DEFAULT 0;
    DECLARE V_ID_DOCUMENTO INT;
    DECLARE V_ESTADO_DOCUMENTO VARCHAR(50);

    SELECT COUNT(*)
    INTO V_EXISTE_ASPIRANTE
    FROM bbf_aspirantes
    WHERE ID_ASPIRANTE = P_ID_ASPIRANTE
      AND IFNULL(ELIMINADO, 0) = 0;

    IF V_EXISTE_ASPIRANTE = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El aspirante no existe o fue eliminado.';
    END IF;

    SELECT IFNULL(APLICA_ASPIRANTE, 0)
    INTO V_APLICA_ASPIRANTE
    FROM bbf_tipos_documento_laboral
    WHERE ID_TIPO_DOCUMENTO_LABORAL = P_ID_TIPO_DOCUMENTO_LABORAL
      AND ACTIVO = 1
    LIMIT 1;

    IF V_APLICA_ASPIRANTE = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El tipo de documento no aplica para aspirantes.';
    END IF;

    SET V_ESTADO_DOCUMENTO = IFNULL(P_ESTADO_DOCUMENTO, 'CARGADO');

    IF V_ESTADO_DOCUMENTO NOT IN ('PENDIENTE', 'CARGADO', 'VALIDADO', 'RECHAZADO', 'VENCIDO') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Estado de documento no válido.';
    END IF;

    INSERT INTO bbf_aspirante_documentos (
        ID_ASPIRANTE,
        ID_TIPO_DOCUMENTO_LABORAL,
        NOMBRE_ARCHIVO,
        ARCHIVO_URL,
        MIME_TYPE,
        PESO_BYTES,
        ESTADO_DOCUMENTO,
        OBSERVACIONES,
        ID_CARGADO_POR
    )
    VALUES (
        P_ID_ASPIRANTE,
        P_ID_TIPO_DOCUMENTO_LABORAL,
        P_NOMBRE_ARCHIVO,
        P_ARCHIVO_URL,
        P_MIME_TYPE,
        P_PESO_BYTES,
        V_ESTADO_DOCUMENTO,
        P_OBSERVACIONES,
        P_ID_CARGADO_POR
    );

    SET V_ID_DOCUMENTO = LAST_INSERT_ID();

    SELECT
        V_ID_DOCUMENTO AS ID_ASPIRANTE_DOCUMENTO,
        P_ID_ASPIRANTE AS ID_ASPIRANTE,
        V_ESTADO_DOCUMENTO AS ESTADO_DOCUMENTO,
        P_NOMBRE_ARCHIVO AS NOMBRE_ARCHIVO,
        P_ARCHIVO_URL AS ARCHIVO_URL;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_ASPIRANTES_HISTORIAL_ESTADOS` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_ASPIRANTES_HISTORIAL_ESTADOS`(
    IN P_ID_ASPIRANTE INT
)
BEGIN
    SELECT
        H.ID_HISTORIAL,
        H.ID_ASPIRANTE,
        H.ESTADO_ANTERIOR,
        H.ESTADO_NUEVO,
        H.OBSERVACIONES,
        H.ID_USUARIO_CAMBIO,
        U.NOMBRE_USUARIO AS USUARIO_CAMBIO,
        H.CREATED_AT
    FROM bbf_aspirante_estado_historial H
    LEFT JOIN bbf_usuarios U
        ON U.ID_USUARIO = H.ID_USUARIO_CAMBIO
    WHERE H.ID_ASPIRANTE = P_ID_ASPIRANTE
    ORDER BY H.CREATED_AT DESC, H.ID_HISTORIAL DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_ASPIRANTES_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_ASPIRANTES_LISTAR`(
    IN P_TEXTO_BUSQUEDA VARCHAR(150),
    IN P_ESTADO_ASPIRANTE VARCHAR(50),
    IN P_ID_AREA INT,
    IN P_ID_CARGO INT
)
BEGIN
    SELECT
        A.ID_ASPIRANTE,
        A.ID_TIPO_DOCUMENTO,
        TD.NOMBRE AS TIPO_DOCUMENTO,
        A.NUMERO_DOCUMENTO,
        A.NOMBRES,
        A.APELLIDOS,
        CONCAT(A.NOMBRES, ' ', A.APELLIDOS) AS NOMBRE_COMPLETO,
        A.CORREO,
        A.TELEFONO,
        A.DIRECCION,
        A.FECHA_NACIMIENTO,
        A.LUGAR_NACIMIENTO,
        A.NACIONALIDAD,
        A.ID_AREA_ASPIRA,
        AR.NOMBRE AS AREA_ASPIRA,
        A.ID_CARGO_ASPIRA,
        C.NOMBRE AS CARGO_ASPIRA,
        A.ESTADO_ASPIRANTE,
        A.OBSERVACIONES,
        A.ID_EMPLEADO_GENERADO,
        A.CREATED_AT,
        A.UPDATED_AT,

        COUNT(D.ID_ASPIRANTE_DOCUMENTO) AS TOTAL_DOCUMENTOS,

        SUM(
            CASE
                WHEN D.ESTADO_DOCUMENTO IN ('PENDIENTE', 'RECHAZADO') THEN 1
                ELSE 0
            END
        ) AS DOCUMENTOS_PENDIENTES

    FROM bbf_aspirantes A
    LEFT JOIN bbf_tipos_documento TD
        ON TD.ID_TIPO_DOCUMENTO = A.ID_TIPO_DOCUMENTO
    LEFT JOIN bbf_areas AR
        ON AR.ID_AREA = A.ID_AREA_ASPIRA
    LEFT JOIN bbf_cargos C
        ON C.ID_CARGO = A.ID_CARGO_ASPIRA
    LEFT JOIN bbf_aspirante_documentos D
        ON D.ID_ASPIRANTE = A.ID_ASPIRANTE
       AND IFNULL(D.ELIMINADO, 0) = 0
    WHERE IFNULL(A.ELIMINADO, 0) = 0
      AND (P_ESTADO_ASPIRANTE IS NULL OR P_ESTADO_ASPIRANTE = '' OR A.ESTADO_ASPIRANTE = P_ESTADO_ASPIRANTE)
      AND (P_ID_AREA IS NULL OR P_ID_AREA = 0 OR A.ID_AREA_ASPIRA = P_ID_AREA)
      AND (P_ID_CARGO IS NULL OR P_ID_CARGO = 0 OR A.ID_CARGO_ASPIRA = P_ID_CARGO)
      AND (
            P_TEXTO_BUSQUEDA IS NULL
            OR P_TEXTO_BUSQUEDA = ''
            OR A.NUMERO_DOCUMENTO LIKE CONCAT('%', P_TEXTO_BUSQUEDA, '%')
            OR A.NOMBRES LIKE CONCAT('%', P_TEXTO_BUSQUEDA, '%')
            OR A.APELLIDOS LIKE CONCAT('%', P_TEXTO_BUSQUEDA, '%')
            OR A.CORREO LIKE CONCAT('%', P_TEXTO_BUSQUEDA, '%')
      )
    GROUP BY
        A.ID_ASPIRANTE,
        A.ID_TIPO_DOCUMENTO,
        TD.NOMBRE,
        A.NUMERO_DOCUMENTO,
        A.NOMBRES,
        A.APELLIDOS,
        A.CORREO,
        A.TELEFONO,
        A.DIRECCION,
        A.FECHA_NACIMIENTO,
        A.LUGAR_NACIMIENTO,
        A.NACIONALIDAD,
        A.ID_AREA_ASPIRA,
        AR.NOMBRE,
        A.ID_CARGO_ASPIRA,
        C.NOMBRE,
        A.ESTADO_ASPIRANTE,
        A.OBSERVACIONES,
        A.ID_EMPLEADO_GENERADO,
        A.CREATED_AT,
        A.UPDATED_AT
    ORDER BY A.CREATED_AT DESC, A.ID_ASPIRANTE DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_ASPIRANTES_OBTENER` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_ASPIRANTES_OBTENER`(
    IN P_ID_ASPIRANTE INT
)
BEGIN
    SELECT
        A.ID_ASPIRANTE,
        A.ID_TIPO_DOCUMENTO,
        TD.NOMBRE AS TIPO_DOCUMENTO,
        A.NUMERO_DOCUMENTO,
        A.NOMBRES,
        A.APELLIDOS,
        CONCAT(A.NOMBRES, ' ', A.APELLIDOS) AS NOMBRE_COMPLETO,
        A.CORREO,
        A.TELEFONO,
        A.DIRECCION,
        A.FECHA_NACIMIENTO,
        A.LUGAR_NACIMIENTO,
        A.NACIONALIDAD,
        A.ID_AREA_ASPIRA,
        AR.NOMBRE AS AREA_ASPIRA,
        A.ID_CARGO_ASPIRA,
        C.NOMBRE AS CARGO_ASPIRA,
        A.ESTADO_ASPIRANTE,
        A.OBSERVACIONES,
        A.ID_EMPLEADO_GENERADO,
        A.CREATED_AT,
        A.UPDATED_AT
    FROM bbf_aspirantes A
    LEFT JOIN bbf_tipos_documento TD
        ON TD.ID_TIPO_DOCUMENTO = A.ID_TIPO_DOCUMENTO
    LEFT JOIN bbf_areas AR
        ON AR.ID_AREA = A.ID_AREA_ASPIRA
    LEFT JOIN bbf_cargos C
        ON C.ID_CARGO = A.ID_CARGO_ASPIRA
    WHERE A.ID_ASPIRANTE = P_ID_ASPIRANTE
      AND IFNULL(A.ELIMINADO, 0) = 0
    LIMIT 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_CARGOS_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_CARGOS_LISTAR`(
    IN P_SOLO_ACTIVOS TINYINT
)
BEGIN
    SELECT
        ID_CARGO,
        NOMBRE,
        DESCRIPCION,
        ACTIVO,
        CREATED_AT,
        UPDATED_AT
    FROM bbf_cargos
    WHERE P_SOLO_ACTIVOS = 0 OR ACTIVO = 1
    ORDER BY NOMBRE ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
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
    IN P_DIAS_ALERTA INT
)
BEGIN
    SET P_DIAS_ALERTA = IFNULL(P_DIAS_ALERTA, 30);

    -- CONTRATOS PRÓXIMOS A VENCER
    SELECT
        'CONTRATO_PROXIMO_VENCER' AS TIPO_ALERTA,
        E.ID_EMPLEADO,
        E.NUMERO_DOCUMENTO,
        CONCAT(E.NOMBRES, ' ', E.APELLIDOS) AS NOMBRE_COMPLETO,
        A.NOMBRE AS AREA,
        C.NOMBRE AS CARGO,
        EC.ID_EMPLEADO_CONTRATO AS ID_REFERENCIA,
        EC.FECHA_FIN AS FECHA_ALERTA,
        DATEDIFF(EC.FECHA_FIN, CURRENT_DATE()) AS DIAS_RESTANTES,
        CONCAT('Contrato próximo a vencer el ', DATE_FORMAT(EC.FECHA_FIN, '%Y-%m-%d')) AS DESCRIPCION
    FROM bbf_empleado_contratos EC
    INNER JOIN bbf_empleados E
        ON E.ID_EMPLEADO = EC.ID_EMPLEADO
    LEFT JOIN bbf_areas A
        ON A.ID_AREA = E.ID_AREA
    LEFT JOIN bbf_cargos C
        ON C.ID_CARGO = E.ID_CARGO
    WHERE IFNULL(EC.ELIMINADO, 0) = 0
      AND IFNULL(E.ELIMINADO, 0) = 0
      AND EC.ESTADO_CONTRATO = 'ACTIVO'
      AND EC.FECHA_FIN IS NOT NULL
      AND EC.FECHA_FIN BETWEEN CURRENT_DATE() AND DATE_ADD(CURRENT_DATE(), INTERVAL P_DIAS_ALERTA DAY)

    UNION ALL

    -- CONTRATOS VENCIDOS
    SELECT
        'CONTRATO_VENCIDO' AS TIPO_ALERTA,
        E.ID_EMPLEADO,
        E.NUMERO_DOCUMENTO,
        CONCAT(E.NOMBRES, ' ', E.APELLIDOS) AS NOMBRE_COMPLETO,
        A.NOMBRE AS AREA,
        C.NOMBRE AS CARGO,
        EC.ID_EMPLEADO_CONTRATO AS ID_REFERENCIA,
        EC.FECHA_FIN AS FECHA_ALERTA,
        DATEDIFF(EC.FECHA_FIN, CURRENT_DATE()) AS DIAS_RESTANTES,
        CONCAT('Contrato vencido desde el ', DATE_FORMAT(EC.FECHA_FIN, '%Y-%m-%d')) AS DESCRIPCION
    FROM bbf_empleado_contratos EC
    INNER JOIN bbf_empleados E
        ON E.ID_EMPLEADO = EC.ID_EMPLEADO
    LEFT JOIN bbf_areas A
        ON A.ID_AREA = E.ID_AREA
    LEFT JOIN bbf_cargos C
        ON C.ID_CARGO = E.ID_CARGO
    WHERE IFNULL(EC.ELIMINADO, 0) = 0
      AND IFNULL(E.ELIMINADO, 0) = 0
      AND EC.ESTADO_CONTRATO = 'ACTIVO'
      AND EC.FECHA_FIN IS NOT NULL
      AND EC.FECHA_FIN < CURRENT_DATE()

    UNION ALL

    -- EXÁMENES MÉDICOS PRÓXIMOS A VENCER
    SELECT
        'EXAMEN_MEDICO_PROXIMO_VENCER' AS TIPO_ALERTA,
        E.ID_EMPLEADO,
        E.NUMERO_DOCUMENTO,
        CONCAT(E.NOMBRES, ' ', E.APELLIDOS) AS NOMBRE_COMPLETO,
        A.NOMBRE AS AREA,
        C.NOMBRE AS CARGO,
        EM.ID_EXAMEN_MEDICO AS ID_REFERENCIA,
        EM.FECHA_VENCIMIENTO AS FECHA_ALERTA,
        DATEDIFF(EM.FECHA_VENCIMIENTO, CURRENT_DATE()) AS DIAS_RESTANTES,
        CONCAT('Examen médico próximo a vencer el ', DATE_FORMAT(EM.FECHA_VENCIMIENTO, '%Y-%m-%d')) AS DESCRIPCION
    FROM bbf_empleado_examenes_medicos EM
    INNER JOIN bbf_empleados E
        ON E.ID_EMPLEADO = EM.ID_EMPLEADO
    LEFT JOIN bbf_areas A
        ON A.ID_AREA = E.ID_AREA
    LEFT JOIN bbf_cargos C
        ON C.ID_CARGO = E.ID_CARGO
    WHERE IFNULL(EM.ELIMINADO, 0) = 0
      AND IFNULL(E.ELIMINADO, 0) = 0
      AND EM.FECHA_VENCIMIENTO IS NOT NULL
      AND EM.FECHA_VENCIMIENTO BETWEEN CURRENT_DATE() AND DATE_ADD(CURRENT_DATE(), INTERVAL P_DIAS_ALERTA DAY)

    UNION ALL

    -- DOCUMENTOS PENDIENTES O RECHAZADOS
    SELECT
        'DOCUMENTO_PENDIENTE' AS TIPO_ALERTA,
        E.ID_EMPLEADO,
        E.NUMERO_DOCUMENTO,
        CONCAT(E.NOMBRES, ' ', E.APELLIDOS) AS NOMBRE_COMPLETO,
        A.NOMBRE AS AREA,
        C.NOMBRE AS CARGO,
        D.ID_EMPLEADO_DOCUMENTO AS ID_REFERENCIA,
        D.FECHA_VENCIMIENTO AS FECHA_ALERTA,
        NULL AS DIAS_RESTANTES,
        CONCAT('Documento ', TD.NOMBRE, ' en estado ', D.ESTADO_DOCUMENTO) AS DESCRIPCION
    FROM bbf_empleado_documentos D
    INNER JOIN bbf_tipos_documento_laboral TD
        ON TD.ID_TIPO_DOCUMENTO_LABORAL = D.ID_TIPO_DOCUMENTO_LABORAL
    INNER JOIN bbf_empleados E
        ON E.ID_EMPLEADO = D.ID_EMPLEADO
    LEFT JOIN bbf_areas A
        ON A.ID_AREA = E.ID_AREA
    LEFT JOIN bbf_cargos C
        ON C.ID_CARGO = E.ID_CARGO
    WHERE IFNULL(D.ELIMINADO, 0) = 0
      AND IFNULL(E.ELIMINADO, 0) = 0
      AND D.ESTADO_DOCUMENTO IN ('PENDIENTE', 'RECHAZADO', 'VENCIDO')

    ORDER BY FECHA_ALERTA ASC, NOMBRE_COMPLETO ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_CONTRATACION_CONTRATOS_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_CONTRATACION_CONTRATOS_LISTAR`(
    IN P_ID_EMPLEADO INT
)
BEGIN
    SELECT
        EC.ID_EMPLEADO_CONTRATO,
        EC.ID_EMPLEADO,

        EC.ID_TIPO_CONTRATO,
        TC.NOMBRE AS TIPO_CONTRATO,

        EC.ID_AREA,
        A.NOMBRE AS AREA,

        EC.ID_CARGO,
        C.NOMBRE AS CARGO,

        EC.FECHA_INICIO,
        EC.FECHA_FIN,
        EC.DURACION_MESES,
        EC.SALARIO_BASE,

        EC.AUXILIO_TRANSPORTE,
        EC.PERIODO_PAGO,
        EC.LUGAR_LABORES,
        EC.NUMERO_CONTRATO,
        EC.TIPO_CARGO_CONTRATO,
        EC.OBJETO_OBRA_LABOR,
        EC.PRORROGA_DIAS,
        EC.CLAUSULA_FUNCIONES,

        EC.JORNADA_LABORAL,
        EC.PERIODO_PRUEBA_DIAS,
        EC.ESTADO_CONTRATO,
        EC.ARCHIVO_CONTRATO_URL,
        EC.OBSERVACIONES,

        EC.ID_REGISTRADO_POR,
        U.NOMBRE_USUARIO AS REGISTRADO_POR,

        EC.CREATED_AT,
        EC.UPDATED_AT
    FROM bbf_empleado_contratos EC
    LEFT JOIN bbf_tipos_contrato TC
        ON TC.ID_TIPO_CONTRATO = EC.ID_TIPO_CONTRATO
    LEFT JOIN bbf_areas A
        ON A.ID_AREA = EC.ID_AREA
    LEFT JOIN bbf_cargos C
        ON C.ID_CARGO = EC.ID_CARGO
    LEFT JOIN bbf_usuarios U
        ON U.ID_USUARIO = EC.ID_REGISTRADO_POR
    WHERE EC.ID_EMPLEADO = P_ID_EMPLEADO
      AND IFNULL(EC.ELIMINADO, 0) = 0
    ORDER BY EC.FECHA_INICIO DESC, EC.ID_EMPLEADO_CONTRATO DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_CONTRATACION_CONTRATO_CREAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_CONTRATACION_CONTRATO_CREAR`(
    IN P_ID_EMPLEADO INT,
    IN P_ID_TIPO_CONTRATO INT,
    IN P_ID_AREA INT,
    IN P_ID_CARGO INT,
    IN P_FECHA_INICIO DATE,
    IN P_FECHA_FIN DATE,
    IN P_DURACION_MESES INT,
    IN P_SALARIO_BASE DECIMAL(12,2),

    IN P_AUXILIO_TRANSPORTE TINYINT,
    IN P_PERIODO_PAGO VARCHAR(100),
    IN P_LUGAR_LABORES VARCHAR(250),
    IN P_NUMERO_CONTRATO VARCHAR(100),
    IN P_TIPO_CARGO_CONTRATO VARCHAR(50),
    IN P_OBJETO_OBRA_LABOR TEXT,
    IN P_PRORROGA_DIAS INT,
    IN P_CLAUSULA_FUNCIONES TEXT,

    IN P_JORNADA_LABORAL VARCHAR(150),
    IN P_PERIODO_PRUEBA_DIAS INT,
    IN P_ESTADO_CONTRATO VARCHAR(50),
    IN P_ARCHIVO_CONTRATO_URL VARCHAR(500),
    IN P_OBSERVACIONES TEXT,
    IN P_ID_REGISTRADO_POR INT
)
BEGIN
    DECLARE V_EXISTE_EMPLEADO INT DEFAULT 0;
    DECLARE V_ID_CONTRATO INT;
    DECLARE V_ESTADO_CONTRATO VARCHAR(50);

    SELECT COUNT(*)
    INTO V_EXISTE_EMPLEADO
    FROM bbf_empleados
    WHERE ID_EMPLEADO = P_ID_EMPLEADO
      AND IFNULL(ELIMINADO, 0) = 0;

    IF V_EXISTE_EMPLEADO = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El empleado no existe o fue eliminado.';
    END IF;

    IF P_FECHA_FIN IS NOT NULL AND P_FECHA_FIN < P_FECHA_INICIO THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La fecha fin no puede ser menor a la fecha de inicio.';
    END IF;

    IF P_PRORROGA_DIAS IS NOT NULL AND P_PRORROGA_DIAS < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La prórroga en días no puede ser negativa.';
    END IF;

    IF P_PERIODO_PRUEBA_DIAS IS NOT NULL AND P_PERIODO_PRUEBA_DIAS < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El periodo de prueba no puede ser negativo.';
    END IF;

    IF P_DURACION_MESES IS NOT NULL AND P_DURACION_MESES < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La duración en meses no puede ser negativa.';
    END IF;

    IF P_SALARIO_BASE IS NOT NULL AND P_SALARIO_BASE < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El salario base no puede ser negativo.';
    END IF;

    SET V_ESTADO_CONTRATO = IFNULL(P_ESTADO_CONTRATO, 'ACTIVO');

    IF V_ESTADO_CONTRATO NOT IN ('ACTIVO', 'VENCIDO', 'RENOVADO', 'FINALIZADO', 'ANULADO') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Estado de contrato no válido.';
    END IF;

    IF P_TIPO_CARGO_CONTRATO IS NOT NULL
       AND P_TIPO_CARGO_CONTRATO NOT IN ('ADMINISTRATIVO', 'OPERATIVO', 'OTRO') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Tipo de cargo de contrato no válido.';
    END IF;

    -- Si se crea un nuevo contrato ACTIVO, los anteriores activos quedan como RENOVADO
    IF V_ESTADO_CONTRATO = 'ACTIVO' THEN
        UPDATE bbf_empleado_contratos
        SET
            ESTADO_CONTRATO = 'RENOVADO',
            UPDATED_AT = CURRENT_TIMESTAMP
        WHERE ID_EMPLEADO = P_ID_EMPLEADO
          AND ESTADO_CONTRATO = 'ACTIVO'
          AND IFNULL(ELIMINADO, 0) = 0;
    END IF;

    INSERT INTO bbf_empleado_contratos (
        ID_EMPLEADO,
        ID_TIPO_CONTRATO,
        ID_AREA,
        ID_CARGO,
        FECHA_INICIO,
        FECHA_FIN,
        DURACION_MESES,
        SALARIO_BASE,

        AUXILIO_TRANSPORTE,
        PERIODO_PAGO,
        LUGAR_LABORES,
        NUMERO_CONTRATO,
        TIPO_CARGO_CONTRATO,
        OBJETO_OBRA_LABOR,
        PRORROGA_DIAS,
        CLAUSULA_FUNCIONES,

        JORNADA_LABORAL,
        PERIODO_PRUEBA_DIAS,
        ESTADO_CONTRATO,
        ARCHIVO_CONTRATO_URL,
        OBSERVACIONES,
        ID_REGISTRADO_POR
    )
    VALUES (
        P_ID_EMPLEADO,
        P_ID_TIPO_CONTRATO,
        P_ID_AREA,
        P_ID_CARGO,
        P_FECHA_INICIO,
        P_FECHA_FIN,
        P_DURACION_MESES,
        P_SALARIO_BASE,

        P_AUXILIO_TRANSPORTE,
        P_PERIODO_PAGO,
        P_LUGAR_LABORES,
        P_NUMERO_CONTRATO,
        P_TIPO_CARGO_CONTRATO,
        P_OBJETO_OBRA_LABOR,
        P_PRORROGA_DIAS,
        P_CLAUSULA_FUNCIONES,

        P_JORNADA_LABORAL,
        P_PERIODO_PRUEBA_DIAS,
        V_ESTADO_CONTRATO,
        P_ARCHIVO_CONTRATO_URL,
        P_OBSERVACIONES,
        P_ID_REGISTRADO_POR
    );

    SET V_ID_CONTRATO = LAST_INSERT_ID();

    SELECT
        V_ID_CONTRATO AS ID_EMPLEADO_CONTRATO,
        P_ID_EMPLEADO AS ID_EMPLEADO,
        V_ESTADO_CONTRATO AS ESTADO_CONTRATO,
        P_FECHA_INICIO AS FECHA_INICIO,
        P_FECHA_FIN AS FECHA_FIN,
        P_AUXILIO_TRANSPORTE AS AUXILIO_TRANSPORTE,
        P_PERIODO_PAGO AS PERIODO_PAGO,
        P_LUGAR_LABORES AS LUGAR_LABORES,
        P_NUMERO_CONTRATO AS NUMERO_CONTRATO,
        P_TIPO_CARGO_CONTRATO AS TIPO_CARGO_CONTRATO;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_CONTRATACION_DOCUMENTOS_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_CONTRATACION_DOCUMENTOS_LISTAR`(
    IN P_ID_EMPLEADO INT
)
BEGIN
    SELECT
        D.ID_EMPLEADO_DOCUMENTO,
        D.ID_EMPLEADO,
        D.ID_TIPO_DOCUMENTO_LABORAL,
        TD.NOMBRE AS TIPO_DOCUMENTO_LABORAL,
        TD.OBLIGATORIO,
        TD.REQUIERE_VENCIMIENTO,

        D.NOMBRE_ARCHIVO,
        D.ARCHIVO_URL,
        D.MIME_TYPE,
        D.PESO_BYTES,
        D.FECHA_CARGA,
        D.FECHA_VENCIMIENTO,
        D.ESTADO_DOCUMENTO,
        D.OBSERVACIONES,

        D.ID_CARGADO_POR,
        UC.NOMBRE_USUARIO AS CARGADO_POR,

        D.ID_VALIDADO_POR,
        UV.NOMBRE_USUARIO AS VALIDADO_POR,
        D.FECHA_VALIDACION,

        CASE
            WHEN D.FECHA_VENCIMIENTO IS NOT NULL
             AND D.FECHA_VENCIMIENTO < CURRENT_DATE()
            THEN 1
            ELSE 0
        END AS VENCIDO,

        CASE
            WHEN D.FECHA_VENCIMIENTO IS NOT NULL
             AND D.FECHA_VENCIMIENTO BETWEEN CURRENT_DATE() AND DATE_ADD(CURRENT_DATE(), INTERVAL 30 DAY)
            THEN 1
            ELSE 0
        END AS PROXIMO_VENCER,

        D.CREATED_AT,
        D.UPDATED_AT

    FROM bbf_empleado_documentos D
    INNER JOIN bbf_tipos_documento_laboral TD
        ON TD.ID_TIPO_DOCUMENTO_LABORAL = D.ID_TIPO_DOCUMENTO_LABORAL
    LEFT JOIN bbf_usuarios UC
        ON UC.ID_USUARIO = D.ID_CARGADO_POR
    LEFT JOIN bbf_usuarios UV
        ON UV.ID_USUARIO = D.ID_VALIDADO_POR
    WHERE D.ID_EMPLEADO = P_ID_EMPLEADO
      AND IFNULL(D.ELIMINADO, 0) = 0
    ORDER BY TD.OBLIGATORIO DESC, TD.NOMBRE ASC, D.FECHA_CARGA DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_CONTRATACION_DOCUMENTO_REGISTRAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_CONTRATACION_DOCUMENTO_REGISTRAR`(
    IN P_ID_EMPLEADO INT,
    IN P_ID_TIPO_DOCUMENTO_LABORAL INT,
    IN P_NOMBRE_ARCHIVO VARCHAR(255),
    IN P_ARCHIVO_URL VARCHAR(500),
    IN P_MIME_TYPE VARCHAR(100),
    IN P_PESO_BYTES BIGINT,
    IN P_FECHA_VENCIMIENTO DATE,
    IN P_ESTADO_DOCUMENTO VARCHAR(50),
    IN P_OBSERVACIONES TEXT,
    IN P_ID_CARGADO_POR INT
)
BEGIN
    DECLARE V_EXISTE_EMPLEADO INT DEFAULT 0;
    DECLARE V_ID_DOCUMENTO INT;

    SELECT COUNT(*)
    INTO V_EXISTE_EMPLEADO
    FROM bbf_empleados
    WHERE ID_EMPLEADO = P_ID_EMPLEADO
      AND IFNULL(ELIMINADO, 0) = 0;

    IF V_EXISTE_EMPLEADO = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El empleado no existe o fue eliminado.';
    END IF;

    INSERT INTO bbf_empleado_documentos (
        ID_EMPLEADO,
        ID_TIPO_DOCUMENTO_LABORAL,
        NOMBRE_ARCHIVO,
        ARCHIVO_URL,
        MIME_TYPE,
        PESO_BYTES,
        FECHA_VENCIMIENTO,
        ESTADO_DOCUMENTO,
        OBSERVACIONES,
        ID_CARGADO_POR
    )
    VALUES (
        P_ID_EMPLEADO,
        P_ID_TIPO_DOCUMENTO_LABORAL,
        P_NOMBRE_ARCHIVO,
        P_ARCHIVO_URL,
        P_MIME_TYPE,
        P_PESO_BYTES,
        P_FECHA_VENCIMIENTO,
        IFNULL(P_ESTADO_DOCUMENTO, 'CARGADO'),
        P_OBSERVACIONES,
        P_ID_CARGADO_POR
    );

    SET V_ID_DOCUMENTO = LAST_INSERT_ID();

    SELECT
        V_ID_DOCUMENTO AS ID_EMPLEADO_DOCUMENTO,
        P_ID_EMPLEADO AS ID_EMPLEADO,
        P_ID_TIPO_DOCUMENTO_LABORAL AS ID_TIPO_DOCUMENTO_LABORAL,
        IFNULL(P_ESTADO_DOCUMENTO, 'CARGADO') AS ESTADO_DOCUMENTO,
        P_NOMBRE_ARCHIVO AS NOMBRE_ARCHIVO,
        P_ARCHIVO_URL AS ARCHIVO_URL;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_CONTRATACION_EXAMENES_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_CONTRATACION_EXAMENES_LISTAR`(
    IN P_ID_EMPLEADO INT
)
BEGIN
    SELECT
        EM.ID_EXAMEN_MEDICO,
        EM.ID_EMPLEADO,
        EM.ID_TIPO_EXAMEN_MEDICO,
        TEM.NOMBRE AS TIPO_EXAMEN_MEDICO,
        EM.FECHA_EXAMEN,
        EM.ENTIDAD_REALIZA,
        EM.RESULTADO_GENERAL,
        EM.FECHA_VENCIMIENTO,
        EM.ARCHIVO_URL,
        EM.OBSERVACIONES,

        CASE
            WHEN EM.FECHA_VENCIMIENTO IS NOT NULL
             AND EM.FECHA_VENCIMIENTO < CURRENT_DATE()
            THEN 1
            ELSE 0
        END AS VENCIDO,

        CASE
            WHEN EM.FECHA_VENCIMIENTO IS NOT NULL
             AND EM.FECHA_VENCIMIENTO BETWEEN CURRENT_DATE() AND DATE_ADD(CURRENT_DATE(), INTERVAL 30 DAY)
            THEN 1
            ELSE 0
        END AS PROXIMO_VENCER,

        EM.CREATED_AT,
        EM.UPDATED_AT

    FROM bbf_empleado_examenes_medicos EM
    INNER JOIN bbf_tipos_examen_medico TEM
        ON TEM.ID_TIPO_EXAMEN_MEDICO = EM.ID_TIPO_EXAMEN_MEDICO
    WHERE EM.ID_EMPLEADO = P_ID_EMPLEADO
      AND IFNULL(EM.ELIMINADO, 0) = 0
    ORDER BY EM.FECHA_EXAMEN DESC, EM.ID_EXAMEN_MEDICO DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_CONTRATACION_EXAMEN_CREAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_CONTRATACION_EXAMEN_CREAR`(
    IN P_ID_EMPLEADO INT,
    IN P_ID_TIPO_EXAMEN_MEDICO INT,
    IN P_FECHA_EXAMEN DATE,
    IN P_ENTIDAD_REALIZA VARCHAR(200),
    IN P_RESULTADO_GENERAL VARCHAR(250),
    IN P_FECHA_VENCIMIENTO DATE,
    IN P_ARCHIVO_URL VARCHAR(500),
    IN P_OBSERVACIONES TEXT
)
BEGIN
    DECLARE V_EXISTE_EMPLEADO INT DEFAULT 0;
    DECLARE V_ID_EXAMEN_MEDICO INT;

    SELECT COUNT(*)
    INTO V_EXISTE_EMPLEADO
    FROM bbf_empleados
    WHERE ID_EMPLEADO = P_ID_EMPLEADO
      AND IFNULL(ELIMINADO, 0) = 0;

    IF V_EXISTE_EMPLEADO = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El empleado no existe o fue eliminado.';
    END IF;

    IF P_FECHA_VENCIMIENTO IS NOT NULL AND P_FECHA_VENCIMIENTO < P_FECHA_EXAMEN THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La fecha de vencimiento no puede ser menor a la fecha del examen.';
    END IF;

    INSERT INTO bbf_empleado_examenes_medicos (
        ID_EMPLEADO,
        ID_TIPO_EXAMEN_MEDICO,
        FECHA_EXAMEN,
        ENTIDAD_REALIZA,
        RESULTADO_GENERAL,
        FECHA_VENCIMIENTO,
        ARCHIVO_URL,
        OBSERVACIONES
    )
    VALUES (
        P_ID_EMPLEADO,
        P_ID_TIPO_EXAMEN_MEDICO,
        P_FECHA_EXAMEN,
        P_ENTIDAD_REALIZA,
        P_RESULTADO_GENERAL,
        P_FECHA_VENCIMIENTO,
        P_ARCHIVO_URL,
        P_OBSERVACIONES
    );

    SET V_ID_EXAMEN_MEDICO = LAST_INSERT_ID();

    SELECT
        V_ID_EXAMEN_MEDICO AS ID_EXAMEN_MEDICO,
        P_ID_EMPLEADO AS ID_EMPLEADO,
        P_ID_TIPO_EXAMEN_MEDICO AS ID_TIPO_EXAMEN_MEDICO,
        P_FECHA_EXAMEN AS FECHA_EXAMEN,
        P_FECHA_VENCIMIENTO AS FECHA_VENCIMIENTO;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_CONTRATACION_FICHA_GUARDAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_CONTRATACION_FICHA_GUARDAR`(
    IN P_ID_EMPLEADO INT,
    IN P_LUGAR_NACIMIENTO VARCHAR(150),
    IN P_DEPARTAMENTO_NACIMIENTO VARCHAR(150),
    IN P_CIUDAD_RESIDENCIA VARCHAR(150),
    IN P_DEPARTAMENTO_RESIDENCIA VARCHAR(150),
    IN P_DIRECCION_RESIDENCIA VARCHAR(250),
    IN P_TELEFONO_ALTERNO VARCHAR(50),
    IN P_CORREO_PERSONAL VARCHAR(150),
    IN P_ESTADO_CIVIL VARCHAR(50),
    IN P_NIVEL_EDUCATIVO VARCHAR(50),
    IN P_PERSONAS_A_CARGO INT,
    IN P_NUMERO_HIJOS INT,
    IN P_OBSERVACIONES TEXT,

    IN P_CONTACTO_NOMBRE_COMPLETO VARCHAR(200),
    IN P_CONTACTO_PARENTESCO VARCHAR(100),
    IN P_CONTACTO_TELEFONO VARCHAR(50),
    IN P_CONTACTO_TELEFONO_ALTERNO VARCHAR(50),
    IN P_CONTACTO_DIRECCION VARCHAR(250),
    IN P_CONTACTO_OBSERVACIONES VARCHAR(500)
)
BEGIN
    DECLARE V_EXISTE_EMPLEADO INT DEFAULT 0;
    DECLARE V_ID_FICHA INT DEFAULT NULL;
    DECLARE V_ID_CONTACTO INT DEFAULT NULL;
    DECLARE V_ESTADO_FICHA VARCHAR(50);

    SELECT COUNT(*)
    INTO V_EXISTE_EMPLEADO
    FROM bbf_empleados
    WHERE ID_EMPLEADO = P_ID_EMPLEADO
      AND IFNULL(ELIMINADO, 0) = 0;

    IF V_EXISTE_EMPLEADO = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El empleado no existe o fue eliminado.';
    END IF;

    SET V_ESTADO_FICHA =
        CASE
            WHEN P_CIUDAD_RESIDENCIA IS NOT NULL
             AND P_DIRECCION_RESIDENCIA IS NOT NULL
             AND P_CORREO_PERSONAL IS NOT NULL
             AND P_CONTACTO_NOMBRE_COMPLETO IS NOT NULL
             AND P_CONTACTO_TELEFONO IS NOT NULL
            THEN 'COMPLETA'
            ELSE 'INCOMPLETA'
        END;

    SELECT ID_FICHA_INGRESO
    INTO V_ID_FICHA
    FROM bbf_empleado_ficha_ingreso
    WHERE ID_EMPLEADO = P_ID_EMPLEADO
      AND IFNULL(ELIMINADO, 0) = 0
    LIMIT 1;

    IF V_ID_FICHA IS NULL THEN
        INSERT INTO bbf_empleado_ficha_ingreso (
            ID_EMPLEADO,
            LUGAR_NACIMIENTO,
            DEPARTAMENTO_NACIMIENTO,
            CIUDAD_RESIDENCIA,
            DEPARTAMENTO_RESIDENCIA,
            DIRECCION_RESIDENCIA,
            TELEFONO_ALTERNO,
            CORREO_PERSONAL,
            ESTADO_CIVIL,
            NIVEL_EDUCATIVO,
            PERSONAS_A_CARGO,
            NUMERO_HIJOS,
            ESTADO_FICHA,
            OBSERVACIONES
        )
        VALUES (
            P_ID_EMPLEADO,
            P_LUGAR_NACIMIENTO,
            P_DEPARTAMENTO_NACIMIENTO,
            P_CIUDAD_RESIDENCIA,
            P_DEPARTAMENTO_RESIDENCIA,
            P_DIRECCION_RESIDENCIA,
            P_TELEFONO_ALTERNO,
            P_CORREO_PERSONAL,
            P_ESTADO_CIVIL,
            P_NIVEL_EDUCATIVO,
            IFNULL(P_PERSONAS_A_CARGO, 0),
            IFNULL(P_NUMERO_HIJOS, 0),
            V_ESTADO_FICHA,
            P_OBSERVACIONES
        );

        SET V_ID_FICHA = LAST_INSERT_ID();
    ELSE
        UPDATE bbf_empleado_ficha_ingreso
        SET
            LUGAR_NACIMIENTO = P_LUGAR_NACIMIENTO,
            DEPARTAMENTO_NACIMIENTO = P_DEPARTAMENTO_NACIMIENTO,
            CIUDAD_RESIDENCIA = P_CIUDAD_RESIDENCIA,
            DEPARTAMENTO_RESIDENCIA = P_DEPARTAMENTO_RESIDENCIA,
            DIRECCION_RESIDENCIA = P_DIRECCION_RESIDENCIA,
            TELEFONO_ALTERNO = P_TELEFONO_ALTERNO,
            CORREO_PERSONAL = P_CORREO_PERSONAL,
            ESTADO_CIVIL = P_ESTADO_CIVIL,
            NIVEL_EDUCATIVO = P_NIVEL_EDUCATIVO,
            PERSONAS_A_CARGO = IFNULL(P_PERSONAS_A_CARGO, 0),
            NUMERO_HIJOS = IFNULL(P_NUMERO_HIJOS, 0),
            ESTADO_FICHA = V_ESTADO_FICHA,
            OBSERVACIONES = P_OBSERVACIONES,
            UPDATED_AT = CURRENT_TIMESTAMP
        WHERE ID_FICHA_INGRESO = V_ID_FICHA;
    END IF;

    SELECT ID_CONTACTO_EMERGENCIA
    INTO V_ID_CONTACTO
    FROM bbf_empleado_contacto_emergencia
    WHERE ID_EMPLEADO = P_ID_EMPLEADO
      AND IFNULL(ELIMINADO, 0) = 0
    ORDER BY ID_CONTACTO_EMERGENCIA DESC
    LIMIT 1;

    IF P_CONTACTO_NOMBRE_COMPLETO IS NOT NULL OR P_CONTACTO_TELEFONO IS NOT NULL THEN

        IF V_ID_CONTACTO IS NULL THEN
            INSERT INTO bbf_empleado_contacto_emergencia (
                ID_EMPLEADO,
                NOMBRE_COMPLETO,
                PARENTESCO,
                TELEFONO,
                TELEFONO_ALTERNO,
                DIRECCION,
                OBSERVACIONES
            )
            VALUES (
                P_ID_EMPLEADO,
                P_CONTACTO_NOMBRE_COMPLETO,
                P_CONTACTO_PARENTESCO,
                P_CONTACTO_TELEFONO,
                P_CONTACTO_TELEFONO_ALTERNO,
                P_CONTACTO_DIRECCION,
                P_CONTACTO_OBSERVACIONES
            );

            SET V_ID_CONTACTO = LAST_INSERT_ID();
        ELSE
            UPDATE bbf_empleado_contacto_emergencia
            SET
                NOMBRE_COMPLETO = P_CONTACTO_NOMBRE_COMPLETO,
                PARENTESCO = P_CONTACTO_PARENTESCO,
                TELEFONO = P_CONTACTO_TELEFONO,
                TELEFONO_ALTERNO = P_CONTACTO_TELEFONO_ALTERNO,
                DIRECCION = P_CONTACTO_DIRECCION,
                OBSERVACIONES = P_CONTACTO_OBSERVACIONES,
                UPDATED_AT = CURRENT_TIMESTAMP
            WHERE ID_CONTACTO_EMERGENCIA = V_ID_CONTACTO;
        END IF;

    END IF;

    SELECT
        V_ID_FICHA AS ID_FICHA_INGRESO,
        P_ID_EMPLEADO AS ID_EMPLEADO,
        V_ESTADO_FICHA AS ESTADO_FICHA,
        V_ID_CONTACTO AS ID_CONTACTO_EMERGENCIA;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_CONTRATACION_FICHA_OBTENER` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_CONTRATACION_FICHA_OBTENER`(
    IN P_ID_EMPLEADO INT
)
BEGIN
    SELECT
        E.ID_EMPLEADO,
        E.NUMERO_DOCUMENTO,
        E.NOMBRES,
        E.APELLIDOS,
        CONCAT(E.NOMBRES, ' ', E.APELLIDOS) AS NOMBRE_COMPLETO,
        E.CORREO,
        E.TELEFONO,
        E.FECHA_INGRESO,
        E.FECHA_RETIRO,
        E.ESTADO_EMPLEADO,
        E.ID_AREA,
        A.NOMBRE AS AREA,
        E.ID_CARGO,
        C.NOMBRE AS CARGO,
        E.ID_TIPO_CONTRATO,
        TC.NOMBRE AS TIPO_CONTRATO,

        FI.ID_FICHA_INGRESO,
        FI.LUGAR_NACIMIENTO,
        FI.DEPARTAMENTO_NACIMIENTO,
        FI.CIUDAD_RESIDENCIA,
        FI.DEPARTAMENTO_RESIDENCIA,
        FI.DIRECCION_RESIDENCIA,
        FI.TELEFONO_ALTERNO,
        FI.CORREO_PERSONAL,
        FI.ESTADO_CIVIL,
        FI.NIVEL_EDUCATIVO,
        FI.PERSONAS_A_CARGO,
        FI.NUMERO_HIJOS,
        IFNULL(FI.ESTADO_FICHA, 'PENDIENTE') AS ESTADO_FICHA,
        FI.OBSERVACIONES,

        CE.ID_CONTACTO_EMERGENCIA,
        CE.NOMBRE_COMPLETO AS CONTACTO_NOMBRE_COMPLETO,
        CE.PARENTESCO AS CONTACTO_PARENTESCO,
        CE.TELEFONO AS CONTACTO_TELEFONO,
        CE.TELEFONO_ALTERNO AS CONTACTO_TELEFONO_ALTERNO,
        CE.DIRECCION AS CONTACTO_DIRECCION,
        CE.OBSERVACIONES AS CONTACTO_OBSERVACIONES

    FROM bbf_empleados E
    LEFT JOIN bbf_areas A
        ON A.ID_AREA = E.ID_AREA
    LEFT JOIN bbf_cargos C
        ON C.ID_CARGO = E.ID_CARGO
    LEFT JOIN bbf_tipos_contrato TC
        ON TC.ID_TIPO_CONTRATO = E.ID_TIPO_CONTRATO
    LEFT JOIN bbf_empleado_ficha_ingreso FI
        ON FI.ID_EMPLEADO = E.ID_EMPLEADO
       AND IFNULL(FI.ELIMINADO, 0) = 0
    LEFT JOIN bbf_empleado_contacto_emergencia CE
        ON CE.ID_EMPLEADO = E.ID_EMPLEADO
       AND IFNULL(CE.ELIMINADO, 0) = 0
    WHERE E.ID_EMPLEADO = P_ID_EMPLEADO
      AND IFNULL(E.ELIMINADO, 0) = 0
    LIMIT 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_CONTRATACION_LISTAR_EMPLEADOS` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_CONTRATACION_LISTAR_EMPLEADOS`(
    IN P_TEXTO_BUSQUEDA VARCHAR(150),
    IN P_ID_AREA INT,
    IN P_ID_CARGO INT,
    IN P_ESTADO_EMPLEADO VARCHAR(50)
)
BEGIN
    SELECT
        E.ID_EMPLEADO,
        E.NUMERO_DOCUMENTO,
        E.NOMBRES,
        E.APELLIDOS,
        CONCAT(E.NOMBRES, ' ', E.APELLIDOS) AS NOMBRE_COMPLETO,
        E.CORREO,
        E.TELEFONO,

        E.ID_AREA,
        A.NOMBRE AS AREA,

        E.ID_CARGO,
        C.NOMBRE AS CARGO,

        E.ID_TIPO_CONTRATO,
        TC.NOMBRE AS TIPO_CONTRATO,

        E.FECHA_INGRESO,
        E.FECHA_RETIRO,
        E.ESTADO_EMPLEADO,

        FI.ID_FICHA_INGRESO,
        IFNULL(FI.ESTADO_FICHA, 'PENDIENTE') AS ESTADO_FICHA,

        EC.ID_EMPLEADO_CONTRATO AS ID_ULTIMO_CONTRATO,
        EC.FECHA_INICIO AS FECHA_INICIO_CONTRATO,
        EC.FECHA_FIN AS FECHA_FIN_CONTRATO,
        EC.ESTADO_CONTRATO,

        EC.AUXILIO_TRANSPORTE,
        EC.PERIODO_PAGO,
        EC.LUGAR_LABORES,
        EC.NUMERO_CONTRATO,
        EC.TIPO_CARGO_CONTRATO,
        EC.PRORROGA_DIAS,

        CASE
            WHEN FI.ID_FICHA_INGRESO IS NULL THEN 1
            ELSE 0
        END AS FICHA_PENDIENTE,

        CASE
            WHEN EC.FECHA_FIN IS NOT NULL
             AND EC.FECHA_FIN BETWEEN CURRENT_DATE() AND DATE_ADD(CURRENT_DATE(), INTERVAL 30 DAY)
            THEN 1
            ELSE 0
        END AS CONTRATO_PROXIMO_VENCER,

        CASE
            WHEN EC.FECHA_FIN IS NOT NULL
             AND EC.FECHA_FIN < CURRENT_DATE()
             AND EC.ESTADO_CONTRATO = 'ACTIVO'
            THEN 1
            ELSE 0
        END AS CONTRATO_VENCIDO

    FROM bbf_empleados E
    LEFT JOIN bbf_areas A
        ON A.ID_AREA = E.ID_AREA
    LEFT JOIN bbf_cargos C
        ON C.ID_CARGO = E.ID_CARGO
    LEFT JOIN bbf_tipos_contrato TC
        ON TC.ID_TIPO_CONTRATO = E.ID_TIPO_CONTRATO

    LEFT JOIN bbf_empleado_ficha_ingreso FI
        ON FI.ID_EMPLEADO = E.ID_EMPLEADO
       AND IFNULL(FI.ELIMINADO, 0) = 0

    LEFT JOIN bbf_empleado_contratos EC
        ON EC.ID_EMPLEADO_CONTRATO = (
            SELECT EC2.ID_EMPLEADO_CONTRATO
            FROM bbf_empleado_contratos EC2
            WHERE EC2.ID_EMPLEADO = E.ID_EMPLEADO
              AND IFNULL(EC2.ELIMINADO, 0) = 0
            ORDER BY EC2.FECHA_INICIO DESC, EC2.ID_EMPLEADO_CONTRATO DESC
            LIMIT 1
        )

    WHERE
        IFNULL(E.ELIMINADO, 0) = 0
        AND (P_ID_AREA IS NULL OR P_ID_AREA = 0 OR E.ID_AREA = P_ID_AREA)
        AND (P_ID_CARGO IS NULL OR P_ID_CARGO = 0 OR E.ID_CARGO = P_ID_CARGO)
        AND (P_ESTADO_EMPLEADO IS NULL OR P_ESTADO_EMPLEADO = '' OR E.ESTADO_EMPLEADO = P_ESTADO_EMPLEADO)
        AND (
            P_TEXTO_BUSQUEDA IS NULL
            OR P_TEXTO_BUSQUEDA = ''
            OR E.NUMERO_DOCUMENTO LIKE CONCAT('%', P_TEXTO_BUSQUEDA, '%')
            OR E.NOMBRES LIKE CONCAT('%', P_TEXTO_BUSQUEDA, '%')
            OR E.APELLIDOS LIKE CONCAT('%', P_TEXTO_BUSQUEDA, '%')
            OR E.CORREO LIKE CONCAT('%', P_TEXTO_BUSQUEDA, '%')
        )
    ORDER BY E.NOMBRES ASC, E.APELLIDOS ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_CONTRATACION_SEGURIDAD_SOCIAL_GUARDAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_CONTRATACION_SEGURIDAD_SOCIAL_GUARDAR`(
    IN P_ID_EMPLEADO INT,
    IN P_ID_EPS INT,
    IN P_ID_ARL INT,
    IN P_ID_FONDO_PENSION INT,
    IN P_ID_FONDO_CESANTIAS INT,
    IN P_ID_CAJA_COMPENSACION INT,
    IN P_FECHA_AFILIACION_EPS DATE,
    IN P_FECHA_AFILIACION_ARL DATE,
    IN P_FECHA_AFILIACION_PENSION DATE,
    IN P_FECHA_AFILIACION_CESANTIAS DATE,
    IN P_FECHA_AFILIACION_CAJA DATE,
    IN P_OBSERVACIONES TEXT
)
BEGIN
    DECLARE V_ID_SEGURIDAD_SOCIAL INT DEFAULT NULL;
    DECLARE V_EXISTE_EMPLEADO INT DEFAULT 0;

    SELECT COUNT(*)
    INTO V_EXISTE_EMPLEADO
    FROM bbf_empleados
    WHERE ID_EMPLEADO = P_ID_EMPLEADO
      AND IFNULL(ELIMINADO, 0) = 0;

    IF V_EXISTE_EMPLEADO = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El empleado no existe o fue eliminado.';
    END IF;

    SELECT ID_SEGURIDAD_SOCIAL
    INTO V_ID_SEGURIDAD_SOCIAL
    FROM bbf_empleado_seguridad_social
    WHERE ID_EMPLEADO = P_ID_EMPLEADO
      AND IFNULL(ELIMINADO, 0) = 0
    LIMIT 1;

    IF V_ID_SEGURIDAD_SOCIAL IS NULL THEN
        INSERT INTO bbf_empleado_seguridad_social (
            ID_EMPLEADO,
            ID_EPS,
            ID_ARL,
            ID_FONDO_PENSION,
            ID_FONDO_CESANTIAS,
            ID_CAJA_COMPENSACION,
            FECHA_AFILIACION_EPS,
            FECHA_AFILIACION_ARL,
            FECHA_AFILIACION_PENSION,
            FECHA_AFILIACION_CESANTIAS,
            FECHA_AFILIACION_CAJA,
            OBSERVACIONES
        )
        VALUES (
            P_ID_EMPLEADO,
            P_ID_EPS,
            P_ID_ARL,
            P_ID_FONDO_PENSION,
            P_ID_FONDO_CESANTIAS,
            P_ID_CAJA_COMPENSACION,
            P_FECHA_AFILIACION_EPS,
            P_FECHA_AFILIACION_ARL,
            P_FECHA_AFILIACION_PENSION,
            P_FECHA_AFILIACION_CESANTIAS,
            P_FECHA_AFILIACION_CAJA,
            P_OBSERVACIONES
        );

        SET V_ID_SEGURIDAD_SOCIAL = LAST_INSERT_ID();
    ELSE
        UPDATE bbf_empleado_seguridad_social
        SET
            ID_EPS = P_ID_EPS,
            ID_ARL = P_ID_ARL,
            ID_FONDO_PENSION = P_ID_FONDO_PENSION,
            ID_FONDO_CESANTIAS = P_ID_FONDO_CESANTIAS,
            ID_CAJA_COMPENSACION = P_ID_CAJA_COMPENSACION,
            FECHA_AFILIACION_EPS = P_FECHA_AFILIACION_EPS,
            FECHA_AFILIACION_ARL = P_FECHA_AFILIACION_ARL,
            FECHA_AFILIACION_PENSION = P_FECHA_AFILIACION_PENSION,
            FECHA_AFILIACION_CESANTIAS = P_FECHA_AFILIACION_CESANTIAS,
            FECHA_AFILIACION_CAJA = P_FECHA_AFILIACION_CAJA,
            OBSERVACIONES = P_OBSERVACIONES,
            UPDATED_AT = CURRENT_TIMESTAMP
        WHERE ID_SEGURIDAD_SOCIAL = V_ID_SEGURIDAD_SOCIAL;
    END IF;

    SELECT
        V_ID_SEGURIDAD_SOCIAL AS ID_SEGURIDAD_SOCIAL,
        P_ID_EMPLEADO AS ID_EMPLEADO;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_CONTRATACION_SEGURIDAD_SOCIAL_OBTENER` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_CONTRATACION_SEGURIDAD_SOCIAL_OBTENER`(
    IN P_ID_EMPLEADO INT
)
BEGIN
    SELECT
        SS.ID_SEGURIDAD_SOCIAL,
        SS.ID_EMPLEADO,

        SS.ID_EPS,
        EPS.NOMBRE AS EPS,

        SS.ID_ARL,
        ARL.NOMBRE AS ARL,

        SS.ID_FONDO_PENSION,
        PEN.NOMBRE AS FONDO_PENSION,

        SS.ID_FONDO_CESANTIAS,
        CES.NOMBRE AS FONDO_CESANTIAS,

        SS.ID_CAJA_COMPENSACION,
        CAJA.NOMBRE AS CAJA_COMPENSACION,

        SS.FECHA_AFILIACION_EPS,
        SS.FECHA_AFILIACION_ARL,
        SS.FECHA_AFILIACION_PENSION,
        SS.FECHA_AFILIACION_CESANTIAS,
        SS.FECHA_AFILIACION_CAJA,

        SS.OBSERVACIONES,
        SS.CREATED_AT,
        SS.UPDATED_AT

    FROM bbf_empleado_seguridad_social SS
    LEFT JOIN bbf_entidades_seguridad_social EPS
        ON EPS.ID_ENTIDAD_SEGURIDAD_SOCIAL = SS.ID_EPS
    LEFT JOIN bbf_entidades_seguridad_social ARL
        ON ARL.ID_ENTIDAD_SEGURIDAD_SOCIAL = SS.ID_ARL
    LEFT JOIN bbf_entidades_seguridad_social PEN
        ON PEN.ID_ENTIDAD_SEGURIDAD_SOCIAL = SS.ID_FONDO_PENSION
    LEFT JOIN bbf_entidades_seguridad_social CES
        ON CES.ID_ENTIDAD_SEGURIDAD_SOCIAL = SS.ID_FONDO_CESANTIAS
    LEFT JOIN bbf_entidades_seguridad_social CAJA
        ON CAJA.ID_ENTIDAD_SEGURIDAD_SOCIAL = SS.ID_CAJA_COMPENSACION
    WHERE SS.ID_EMPLEADO = P_ID_EMPLEADO
      AND IFNULL(SS.ELIMINADO, 0) = 0
    LIMIT 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_DOMINIOS_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_DOMINIOS_LISTAR`(
    IN P_SOLO_ACTIVOS TINYINT
)
BEGIN
    SELECT
        ID_DOMINIO,
        DOMINIO,
        DESCRIPCION,
        ACTIVO,
        CREATED_AT,
        UPDATED_AT
    FROM bbf_dominios_autorizados
    WHERE P_SOLO_ACTIVOS = 0 OR ACTIVO = 1
    ORDER BY DOMINIO ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_DOMINIOS_VALIDAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_DOMINIOS_VALIDAR`(
    IN P_CORREO VARCHAR(150)
)
BEGIN
    DECLARE V_DOMINIO VARCHAR(150);

    SET V_DOMINIO = SUBSTRING_INDEX(P_CORREO, '@', -1);

    SELECT
        D.ID_DOMINIO,
        D.DOMINIO,
        D.ACTIVO,
        CASE
            WHEN D.ID_DOMINIO IS NOT NULL AND D.ACTIVO = 1 THEN 1
            ELSE 0
        END AS ES_VALIDO
    FROM bbf_dominios_autorizados D
    WHERE D.DOMINIO = V_DOMINIO
    LIMIT 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_DOTACION_EMPLEADOS_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_DOTACION_EMPLEADOS_LISTAR`(
    IN P_TEXTO_BUSQUEDA VARCHAR(150),
    IN P_ID_AREA INT,
    IN P_ID_CARGO INT
)
BEGIN
    SELECT
        E.ID_EMPLEADO,
        E.NUMERO_DOCUMENTO,
        CONCAT(E.NOMBRES, ' ', E.APELLIDOS) AS NOMBRE_COMPLETO,
        E.CORREO,
        E.TELEFONO,
        E.ID_AREA,
        A.NOMBRE AS AREA,
        E.ID_CARGO,
        C.NOMBRE AS CARGO,
        E.ESTADO_EMPLEADO,

        COUNT(DISTINCT DE.ID_DOTACION_ENTREGA) AS TOTAL_ENTREGAS,

        COUNT(DISTINCT CASE
            WHEN DE.ID_DOTACION_ENTREGA IS NOT NULL
             AND DE.FECHA_CONFIRMACION IS NULL
             AND DE.ESTADO = 'REGISTRADA'
            THEN DE.ID_DOTACION_ENTREGA
        END) AS PENDIENTES,

        MAX(DE.FECHA_ENTREGA) AS ULTIMA_ENTREGA,

        GROUP_CONCAT(
            DISTINCT CONCAT(TD.NOMBRE, ': ', IFNULL(T.TALLA, 'Sin talla'))
            ORDER BY TD.NOMBRE ASC
            SEPARATOR ' | '
        ) AS RESUMEN_TALLAS

    FROM bbf_empleados E
    LEFT JOIN bbf_areas A
        ON A.ID_AREA = E.ID_AREA
    LEFT JOIN bbf_cargos C
        ON C.ID_CARGO = E.ID_CARGO

    LEFT JOIN bbf_dotacion_entregas DE
        ON DE.ID_EMPLEADO = E.ID_EMPLEADO
       AND IFNULL(DE.ELIMINADO, 0) = 0

    LEFT JOIN bbf_tipos_dotacion TD
        ON TD.ACTIVO = 1

    LEFT JOIN bbf_empleado_dotacion_tallas EDT
        ON EDT.ID_EMPLEADO = E.ID_EMPLEADO
       AND EDT.ID_TIPO_DOTACION = TD.ID_TIPO_DOTACION

    LEFT JOIN bbf_tallas_dotacion T
        ON T.ID_TALLA_DOTACION = EDT.ID_TALLA_DOTACION

    WHERE
        E.ESTADO_EMPLEADO = 'ACTIVO'
        AND IFNULL(E.ELIMINADO, 0) = 0
        AND (P_ID_AREA IS NULL OR P_ID_AREA = 0 OR E.ID_AREA = P_ID_AREA)
        AND (P_ID_CARGO IS NULL OR P_ID_CARGO = 0 OR E.ID_CARGO = P_ID_CARGO)
        AND (
            P_TEXTO_BUSQUEDA IS NULL
            OR P_TEXTO_BUSQUEDA = ''
            OR E.NUMERO_DOCUMENTO LIKE CONCAT('%', P_TEXTO_BUSQUEDA, '%')
            OR E.NOMBRES LIKE CONCAT('%', P_TEXTO_BUSQUEDA, '%')
            OR E.APELLIDOS LIKE CONCAT('%', P_TEXTO_BUSQUEDA, '%')
            OR E.CORREO LIKE CONCAT('%', P_TEXTO_BUSQUEDA, '%')
        )
    GROUP BY
        E.ID_EMPLEADO,
        E.NUMERO_DOCUMENTO,
        E.NOMBRES,
        E.APELLIDOS,
        E.CORREO,
        E.TELEFONO,
        E.ID_AREA,
        A.NOMBRE,
        E.ID_CARGO,
        C.NOMBRE,
        E.ESTADO_EMPLEADO
    ORDER BY E.NOMBRES ASC, E.APELLIDOS ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_DOTACION_ENTREGAS_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_DOTACION_ENTREGAS_LISTAR`(
    IN P_ID_EMPLEADO INT,
    IN P_FECHA_INICIO DATE,
    IN P_FECHA_FIN DATE
)
BEGIN
    SELECT
        DE.ID_DOTACION_ENTREGA,
        DE.ID_EMPLEADO,
        E.NUMERO_DOCUMENTO,
        CONCAT(E.NOMBRES, ' ', E.APELLIDOS) AS NOMBRE_COMPLETO,
        DE.FECHA_ENTREGA,
        DE.FECHA_CONFIRMACION,
        DE.ESTADO,
        DE.OBSERVACIONES,
        DE.OBSERVACION_CONFIRMACION,
        DE.FIRMA_URL,
        DE.ID_REGISTRADO_POR,
        UR.NOMBRE_USUARIO AS REGISTRADO_POR,
        DE.ID_CONFIRMADO_POR,
        UC.NOMBRE_USUARIO AS CONFIRMADO_POR,
        DE.CREATED_AT,
        DE.UPDATED_AT
    FROM bbf_dotacion_entregas DE
    INNER JOIN bbf_empleados E
        ON E.ID_EMPLEADO = DE.ID_EMPLEADO
    LEFT JOIN bbf_usuarios UR
        ON UR.ID_USUARIO = DE.ID_REGISTRADO_POR
    LEFT JOIN bbf_usuarios UC
        ON UC.ID_USUARIO = DE.ID_CONFIRMADO_POR
    WHERE
        IFNULL(DE.ELIMINADO, 0) = 0
        AND (P_ID_EMPLEADO IS NULL OR P_ID_EMPLEADO = 0 OR DE.ID_EMPLEADO = P_ID_EMPLEADO)
        AND (P_FECHA_INICIO IS NULL OR DE.FECHA_ENTREGA >= P_FECHA_INICIO)
        AND (P_FECHA_FIN IS NULL OR DE.FECHA_ENTREGA <= P_FECHA_FIN)
    ORDER BY DE.FECHA_ENTREGA DESC, DE.ID_DOTACION_ENTREGA DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_DOTACION_ENTREGA_CONFIRMAR_RECIBIDO` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_DOTACION_ENTREGA_CONFIRMAR_RECIBIDO`(
    IN P_ID_USUARIO INT,
    IN P_ID_DOTACION_ENTREGA INT,
    IN P_OBSERVACION_CONFIRMACION VARCHAR(500),
    IN P_FIRMA_URL VARCHAR(500)
)
BEGIN
    DECLARE V_ID_EMPLEADO INT;
    DECLARE V_ID_EMPLEADO_ENTREGA INT;
    DECLARE V_ESTADO VARCHAR(50);

    SELECT ID_EMPLEADO
    INTO V_ID_EMPLEADO
    FROM bbf_usuarios
    WHERE ID_USUARIO = P_ID_USUARIO
    LIMIT 1;

    IF V_ID_EMPLEADO IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El usuario no tiene un empleado asociado.';
    END IF;

    SELECT ID_EMPLEADO, ESTADO
    INTO V_ID_EMPLEADO_ENTREGA, V_ESTADO
    FROM bbf_dotacion_entregas
    WHERE ID_DOTACION_ENTREGA = P_ID_DOTACION_ENTREGA
    LIMIT 1;

    IF V_ID_EMPLEADO_ENTREGA IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La entrega de dotación no existe.';
    END IF;

    IF V_ID_EMPLEADO_ENTREGA <> V_ID_EMPLEADO THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No puede confirmar una entrega asociada a otro empleado.';
    END IF;

    IF V_ESTADO = 'ANULADA' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede confirmar una entrega anulada.';
    END IF;

    IF V_ESTADO = 'ENTREGADA' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La entrega ya fue confirmada anteriormente.';
    END IF;

    UPDATE bbf_dotacion_entregas
    SET
        ESTADO = 'ENTREGADA',
        FECHA_CONFIRMACION = CURRENT_TIMESTAMP,
        ID_CONFIRMADO_POR = P_ID_USUARIO,
        OBSERVACION_CONFIRMACION = P_OBSERVACION_CONFIRMACION,
        FIRMA_URL = P_FIRMA_URL
    WHERE ID_DOTACION_ENTREGA = P_ID_DOTACION_ENTREGA;

    SELECT
        DE.ID_DOTACION_ENTREGA,
        DE.ID_EMPLEADO,
        DE.FECHA_ENTREGA,
        DE.FECHA_CONFIRMACION,
        DE.ESTADO,
        DE.OBSERVACIONES,
        DE.OBSERVACION_CONFIRMACION,
        DE.FIRMA_URL,
        DE.ID_CONFIRMADO_POR
    FROM bbf_dotacion_entregas DE
    WHERE DE.ID_DOTACION_ENTREGA = P_ID_DOTACION_ENTREGA;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_DOTACION_ENTREGA_CREAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_DOTACION_ENTREGA_CREAR`(
    IN P_ID_EMPLEADO INT,
    IN P_FECHA_ENTREGA DATE,
    IN P_ID_REGISTRADO_POR INT,
    IN P_OBSERVACIONES TEXT
)
BEGIN
    INSERT INTO bbf_dotacion_entregas (
        ID_EMPLEADO,
        FECHA_ENTREGA,
        ESTADO,
        OBSERVACIONES,
        ID_REGISTRADO_POR
    )
    VALUES (
        P_ID_EMPLEADO,
        P_FECHA_ENTREGA,
        'REGISTRADA',
        P_OBSERVACIONES,
        P_ID_REGISTRADO_POR
    );

    SELECT LAST_INSERT_ID() AS ID_DOTACION_ENTREGA;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_DOTACION_ENTREGA_DETALLE_AGREGAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_DOTACION_ENTREGA_DETALLE_AGREGAR`(
    IN P_ID_DOTACION_ENTREGA INT,
    IN P_ID_TIPO_DOTACION INT,
    IN P_ID_TALLA_DOTACION INT,
    IN P_CANTIDAD INT,
    IN P_OBSERVACIONES VARCHAR(250)
)
BEGIN
    INSERT INTO bbf_dotacion_entrega_detalle (
        ID_DOTACION_ENTREGA,
        ID_TIPO_DOTACION,
        ID_TALLA_DOTACION,
        CANTIDAD,
        OBSERVACIONES
    )
    VALUES (
        P_ID_DOTACION_ENTREGA,
        P_ID_TIPO_DOTACION,
        P_ID_TALLA_DOTACION,
        IFNULL(P_CANTIDAD, 1),
        P_OBSERVACIONES
    );

    SELECT LAST_INSERT_ID() AS ID_DOTACION_ENTREGA_DETALLE;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_DOTACION_ENTREGA_DETALLE_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_DOTACION_ENTREGA_DETALLE_LISTAR`(
    IN P_ID_DOTACION_ENTREGA INT
)
BEGIN
    SELECT
        DD.ID_DOTACION_ENTREGA_DETALLE,
        DD.ID_DOTACION_ENTREGA,
        DD.ID_TIPO_DOTACION,
        TD.NOMBRE AS TIPO_DOTACION,
        DD.ID_TALLA_DOTACION,
        T.TALLA,
        DD.CANTIDAD,
        DD.OBSERVACIONES,
        DD.CREATED_AT
    FROM bbf_dotacion_entrega_detalle DD
    INNER JOIN bbf_tipos_dotacion TD
        ON TD.ID_TIPO_DOTACION = DD.ID_TIPO_DOTACION
    LEFT JOIN bbf_tallas_dotacion T
        ON T.ID_TALLA_DOTACION = DD.ID_TALLA_DOTACION
    WHERE DD.ID_DOTACION_ENTREGA = P_ID_DOTACION_ENTREGA
    ORDER BY TD.NOMBRE ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_DOTACION_ENTREGA_ELIMINAR_LOGICO` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_DOTACION_ENTREGA_ELIMINAR_LOGICO`(
    IN P_ID_DOTACION_ENTREGA INT,
    IN P_ID_USUARIO INT,
    IN P_MOTIVO_ELIMINACION VARCHAR(500)
)
BEGIN
    DECLARE V_EXISTE INT DEFAULT 0;
    DECLARE V_ESTADO VARCHAR(50);

    SELECT COUNT(*)
    INTO V_EXISTE
    FROM bbf_dotacion_entregas
    WHERE ID_DOTACION_ENTREGA = P_ID_DOTACION_ENTREGA
      AND IFNULL(ELIMINADO, 0) = 0;

    IF V_EXISTE = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La entrega de dotación no existe o ya fue eliminada.';
    END IF;

    SELECT ESTADO
    INTO V_ESTADO
    FROM bbf_dotacion_entregas
    WHERE ID_DOTACION_ENTREGA = P_ID_DOTACION_ENTREGA
    LIMIT 1;

    IF V_ESTADO = 'ENTREGADA' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede eliminar una entrega ya confirmada por el empleado.';
    END IF;

    UPDATE bbf_dotacion_entregas
    SET
        ELIMINADO = 1,
        ESTADO = 'ANULADA',
        FECHA_ELIMINACION = CURRENT_TIMESTAMP,
        ID_ELIMINADO_POR = P_ID_USUARIO,
        MOTIVO_ELIMINACION = P_MOTIVO_ELIMINACION
    WHERE ID_DOTACION_ENTREGA = P_ID_DOTACION_ENTREGA;

    UPDATE bbf_dotacion_entrega_detalle
    SET
        ELIMINADO = 1,
        FECHA_ELIMINACION = CURRENT_TIMESTAMP,
        ID_ELIMINADO_POR = P_ID_USUARIO
    WHERE ID_DOTACION_ENTREGA = P_ID_DOTACION_ENTREGA;

    SELECT
        P_ID_DOTACION_ENTREGA AS ID_DOTACION_ENTREGA,
        1 AS ELIMINADO,
        'ANULADA' AS ESTADO,
        CURRENT_TIMESTAMP AS FECHA_ELIMINACION;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_DOTACION_HISTORIAL_EMPLEADO` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_DOTACION_HISTORIAL_EMPLEADO`(
    IN P_ID_EMPLEADO INT
)
BEGIN
    SELECT
        DE.ID_DOTACION_ENTREGA,
        DE.ID_EMPLEADO,
        E.NUMERO_DOCUMENTO,
        CONCAT(E.NOMBRES, ' ', E.APELLIDOS) AS NOMBRE_COMPLETO,
        A.NOMBRE AS AREA,
        C.NOMBRE AS CARGO,

        DE.FECHA_ENTREGA,
        DE.FECHA_CONFIRMACION,
        DE.ESTADO,
        DE.OBSERVACIONES AS OBSERVACIONES_ENTREGA,
        DE.OBSERVACION_CONFIRMACION,
        DE.FIRMA_URL,

        DE.ID_REGISTRADO_POR,
        UR.NOMBRE_USUARIO AS REGISTRADO_POR,
        DE.ID_CONFIRMADO_POR,
        UC.NOMBRE_USUARIO AS CONFIRMADO_POR,

        DD.ID_DOTACION_ENTREGA_DETALLE,
        DD.ID_TIPO_DOTACION,
        TD.NOMBRE AS TIPO_DOTACION,
        DD.ID_TALLA_DOTACION,
        T.TALLA,
        DD.CANTIDAD,
        DD.OBSERVACIONES AS OBSERVACIONES_DETALLE,

        DE.CREATED_AT,
        DE.UPDATED_AT
    FROM bbf_dotacion_entregas DE
    INNER JOIN bbf_empleados E
        ON E.ID_EMPLEADO = DE.ID_EMPLEADO
    LEFT JOIN bbf_areas A
        ON A.ID_AREA = E.ID_AREA
    LEFT JOIN bbf_cargos C
        ON C.ID_CARGO = E.ID_CARGO
    LEFT JOIN bbf_usuarios UR
        ON UR.ID_USUARIO = DE.ID_REGISTRADO_POR
    LEFT JOIN bbf_usuarios UC
        ON UC.ID_USUARIO = DE.ID_CONFIRMADO_POR
    INNER JOIN bbf_dotacion_entrega_detalle DD
        ON DD.ID_DOTACION_ENTREGA = DE.ID_DOTACION_ENTREGA
    INNER JOIN bbf_tipos_dotacion TD
        ON TD.ID_TIPO_DOTACION = DD.ID_TIPO_DOTACION
    LEFT JOIN bbf_tallas_dotacion T
        ON T.ID_TALLA_DOTACION = DD.ID_TALLA_DOTACION
    WHERE DE.ID_EMPLEADO = P_ID_EMPLEADO
      AND IFNULL(DE.ELIMINADO, 0) = 0
      AND IFNULL(DD.ELIMINADO, 0) = 0
    ORDER BY DE.FECHA_ENTREGA DESC, DE.ID_DOTACION_ENTREGA DESC, TD.NOMBRE ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_DOTACION_MIS_ENTREGAS_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_DOTACION_MIS_ENTREGAS_LISTAR`(
    IN P_ID_USUARIO INT
)
BEGIN
    DECLARE V_ID_EMPLEADO INT;

    SELECT ID_EMPLEADO
    INTO V_ID_EMPLEADO
    FROM bbf_usuarios
    WHERE ID_USUARIO = P_ID_USUARIO
    LIMIT 1;

    IF V_ID_EMPLEADO IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El usuario no tiene un empleado asociado.';
    END IF;

    SELECT
        DE.ID_DOTACION_ENTREGA,
        DE.ID_EMPLEADO,
        E.NUMERO_DOCUMENTO,
        CONCAT(E.NOMBRES, ' ', E.APELLIDOS) AS NOMBRE_COMPLETO,
        DE.FECHA_ENTREGA,
        DE.FECHA_CONFIRMACION,
        DE.ESTADO,
        DE.OBSERVACIONES,
        DE.OBSERVACION_CONFIRMACION,
        DE.FIRMA_URL,
        DE.ID_REGISTRADO_POR,
        UR.NOMBRE_USUARIO AS REGISTRADO_POR,
        DE.ID_CONFIRMADO_POR,
        UC.NOMBRE_USUARIO AS CONFIRMADO_POR,
        DE.CREATED_AT,
        DE.UPDATED_AT
    FROM bbf_dotacion_entregas DE
    INNER JOIN bbf_empleados E
        ON E.ID_EMPLEADO = DE.ID_EMPLEADO
    LEFT JOIN bbf_usuarios UR
        ON UR.ID_USUARIO = DE.ID_REGISTRADO_POR
    LEFT JOIN bbf_usuarios UC
        ON UC.ID_USUARIO = DE.ID_CONFIRMADO_POR
    WHERE DE.ID_EMPLEADO = V_ID_EMPLEADO
      AND IFNULL(DE.ELIMINADO, 0) = 0
    ORDER BY DE.FECHA_ENTREGA DESC, DE.ID_DOTACION_ENTREGA DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_DOTACION_MIS_TALLAS_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_DOTACION_MIS_TALLAS_LISTAR`(
    IN P_ID_USUARIO INT
)
BEGIN
    DECLARE V_ID_EMPLEADO INT;

    SELECT ID_EMPLEADO
    INTO V_ID_EMPLEADO
    FROM bbf_usuarios
    WHERE ID_USUARIO = P_ID_USUARIO
    LIMIT 1;

    IF V_ID_EMPLEADO IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El usuario no tiene un empleado asociado.';
    END IF;

    SELECT
        TD.ID_TIPO_DOTACION,
        TD.NOMBRE AS TIPO_DOTACION,
        TD.DESCRIPCION AS TIPO_DOTACION_DESCRIPCION,
        TD.REQUIERE_TALLA,
        EDT.ID_EMPLEADO_DOTACION_TALLA,
        EDT.ID_EMPLEADO,
        EDT.ID_TALLA_DOTACION,
        T.TALLA,
        T.DESCRIPCION AS TALLA_DESCRIPCION,
        EDT.OBSERVACIONES,
        EDT.CREATED_AT,
        EDT.UPDATED_AT
    FROM bbf_tipos_dotacion TD
    LEFT JOIN bbf_empleado_dotacion_tallas EDT
        ON EDT.ID_TIPO_DOTACION = TD.ID_TIPO_DOTACION
       AND EDT.ID_EMPLEADO = V_ID_EMPLEADO
    LEFT JOIN bbf_tallas_dotacion T
        ON T.ID_TALLA_DOTACION = EDT.ID_TALLA_DOTACION
    WHERE TD.ACTIVO = 1
    ORDER BY TD.NOMBRE ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_DOTACION_MI_TALLA_GUARDAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_DOTACION_MI_TALLA_GUARDAR`(
    IN P_ID_USUARIO INT,
    IN P_ID_TIPO_DOTACION INT,
    IN P_ID_TALLA_DOTACION INT,
    IN P_OBSERVACIONES VARCHAR(250)
)
BEGIN
    DECLARE V_ID_EMPLEADO INT;
    DECLARE V_EXISTE_TIPO INT DEFAULT 0;
    DECLARE V_EXISTE_TALLA INT DEFAULT 0;

    SELECT ID_EMPLEADO
    INTO V_ID_EMPLEADO
    FROM bbf_usuarios
    WHERE ID_USUARIO = P_ID_USUARIO
    LIMIT 1;

    IF V_ID_EMPLEADO IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El usuario no tiene un empleado asociado.';
    END IF;

    SELECT COUNT(*)
    INTO V_EXISTE_TIPO
    FROM bbf_tipos_dotacion
    WHERE ID_TIPO_DOTACION = P_ID_TIPO_DOTACION
      AND ACTIVO = 1;

    IF V_EXISTE_TIPO = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El tipo de dotación no existe o está inactivo.';
    END IF;

    IF P_ID_TALLA_DOTACION IS NOT NULL THEN
        SELECT COUNT(*)
        INTO V_EXISTE_TALLA
        FROM bbf_tallas_dotacion
        WHERE ID_TALLA_DOTACION = P_ID_TALLA_DOTACION
          AND ID_TIPO_DOTACION = P_ID_TIPO_DOTACION
          AND ACTIVO = 1;

        IF V_EXISTE_TALLA = 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La talla no corresponde al tipo de dotación indicado.';
        END IF;
    END IF;

    INSERT INTO bbf_empleado_dotacion_tallas (
        ID_EMPLEADO,
        ID_TIPO_DOTACION,
        ID_TALLA_DOTACION,
        OBSERVACIONES,
        ACTUALIZADO_POR_USUARIO
    )
    VALUES (
        V_ID_EMPLEADO,
        P_ID_TIPO_DOTACION,
        P_ID_TALLA_DOTACION,
        P_OBSERVACIONES,
        P_ID_USUARIO
    )
    ON DUPLICATE KEY UPDATE
        ID_TALLA_DOTACION = VALUES(ID_TALLA_DOTACION),
        OBSERVACIONES = VALUES(OBSERVACIONES),
        ACTUALIZADO_POR_USUARIO = VALUES(ACTUALIZADO_POR_USUARIO),
        UPDATED_AT = CURRENT_TIMESTAMP;

    SELECT
        EDT.ID_EMPLEADO_DOTACION_TALLA,
        EDT.ID_EMPLEADO,
        EDT.ID_TIPO_DOTACION,
        TD.NOMBRE AS TIPO_DOTACION,
        EDT.ID_TALLA_DOTACION,
        T.TALLA,
        EDT.OBSERVACIONES,
        EDT.CREATED_AT,
        EDT.UPDATED_AT
    FROM bbf_empleado_dotacion_tallas EDT
    INNER JOIN bbf_tipos_dotacion TD
        ON TD.ID_TIPO_DOTACION = EDT.ID_TIPO_DOTACION
    LEFT JOIN bbf_tallas_dotacion T
        ON T.ID_TALLA_DOTACION = EDT.ID_TALLA_DOTACION
    WHERE EDT.ID_EMPLEADO = V_ID_EMPLEADO
      AND EDT.ID_TIPO_DOTACION = P_ID_TIPO_DOTACION;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_DOTACION_TALLAS_EMPLEADO_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_DOTACION_TALLAS_EMPLEADO_LISTAR`(
    IN P_ID_EMPLEADO INT
)
BEGIN
    SELECT
        E.ID_EMPLEADO,
        E.NUMERO_DOCUMENTO,
        CONCAT(E.NOMBRES, ' ', E.APELLIDOS) AS NOMBRE_COMPLETO,
        TD.ID_TIPO_DOTACION,
        TD.NOMBRE AS TIPO_DOTACION,
        EDT.ID_EMPLEADO_DOTACION_TALLA,
        EDT.ID_TALLA_DOTACION,
        T.TALLA,
        EDT.OBSERVACIONES,
        EDT.CREATED_AT,
        EDT.UPDATED_AT
    FROM bbf_tipos_dotacion TD
    CROSS JOIN bbf_empleados E
    LEFT JOIN bbf_empleado_dotacion_tallas EDT
        ON EDT.ID_TIPO_DOTACION = TD.ID_TIPO_DOTACION
       AND EDT.ID_EMPLEADO = E.ID_EMPLEADO
    LEFT JOIN bbf_tallas_dotacion T
        ON T.ID_TALLA_DOTACION = EDT.ID_TALLA_DOTACION
    WHERE E.ID_EMPLEADO = P_ID_EMPLEADO
      AND TD.ACTIVO = 1
    ORDER BY TD.NOMBRE ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_DOTACION_TALLAS_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_DOTACION_TALLAS_LISTAR`(
    IN P_ID_TIPO_DOTACION INT,
    IN P_SOLO_ACTIVOS TINYINT
)
BEGIN
    SELECT
        ID_TALLA_DOTACION,
        ID_TIPO_DOTACION,
        TALLA,
        DESCRIPCION,
        ORDEN,
        ACTIVO,
        CREATED_AT,
        UPDATED_AT
    FROM bbf_tallas_dotacion
    WHERE
        (P_ID_TIPO_DOTACION IS NULL OR P_ID_TIPO_DOTACION = 0 OR ID_TIPO_DOTACION = P_ID_TIPO_DOTACION)
        AND (P_SOLO_ACTIVOS = 0 OR ACTIVO = 1)
    ORDER BY ID_TIPO_DOTACION ASC, ORDEN ASC, TALLA ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_DOTACION_TIPOS_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_DOTACION_TIPOS_LISTAR`(
    IN P_SOLO_ACTIVOS TINYINT
)
BEGIN
    SELECT
        ID_TIPO_DOTACION,
        NOMBRE,
        DESCRIPCION,
        REQUIERE_TALLA,
        ACTIVO,
        CREATED_AT,
        UPDATED_AT
    FROM bbf_tipos_dotacion
    WHERE P_SOLO_ACTIVOS = 0 OR ACTIVO = 1
    ORDER BY NOMBRE ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_EMPLEADOS_ACTUALIZAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_EMPLEADOS_ACTUALIZAR`(
    IN P_ID_EMPLEADO INT,
    IN P_ID_TIPO_DOCUMENTO INT,
    IN P_NUMERO_DOCUMENTO VARCHAR(50),
    IN P_NOMBRES VARCHAR(150),
    IN P_APELLIDOS VARCHAR(150),
    IN P_CORREO VARCHAR(150),
    IN P_TELEFONO VARCHAR(50),
    IN P_FOTO_URL VARCHAR(500),
    IN P_ID_AREA INT,
    IN P_ID_CARGO INT,
    IN P_ID_TIPO_CONTRATO INT,
    IN P_FECHA_INGRESO DATE,
    IN P_FECHA_RETIRO DATE,
    IN P_ESTADO_EMPLEADO VARCHAR(50),
    IN P_OBSERVACIONES TEXT
)
BEGIN
    UPDATE bbf_empleados
    SET
        ID_TIPO_DOCUMENTO = P_ID_TIPO_DOCUMENTO,
        NUMERO_DOCUMENTO = P_NUMERO_DOCUMENTO,
        NOMBRES = P_NOMBRES,
        APELLIDOS = P_APELLIDOS,
        CORREO = P_CORREO,
        TELEFONO = P_TELEFONO,
        FOTO_URL = P_FOTO_URL,
        ID_AREA = P_ID_AREA,
        ID_CARGO = P_ID_CARGO,
        ID_TIPO_CONTRATO = P_ID_TIPO_CONTRATO,
        FECHA_INGRESO = P_FECHA_INGRESO,
        FECHA_RETIRO = P_FECHA_RETIRO,
        ESTADO_EMPLEADO = P_ESTADO_EMPLEADO,
        OBSERVACIONES = P_OBSERVACIONES
    WHERE ID_EMPLEADO = P_ID_EMPLEADO;

    SELECT ROW_COUNT() AS FILAS_AFECTADAS;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_EMPLEADOS_CAMBIAR_ESTADO` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_EMPLEADOS_CAMBIAR_ESTADO`(
    IN P_ID_EMPLEADO INT,
    IN P_ESTADO_EMPLEADO VARCHAR(50),
    IN P_FECHA_RETIRO DATE
)
BEGIN
    UPDATE bbf_empleados
    SET
        ESTADO_EMPLEADO = P_ESTADO_EMPLEADO,
        FECHA_RETIRO = CASE
            WHEN P_ESTADO_EMPLEADO = 'RETIRADO' THEN IFNULL(P_FECHA_RETIRO, CURRENT_DATE)
            WHEN P_ESTADO_EMPLEADO = 'EN_PROCESO_RETIRO' THEN P_FECHA_RETIRO
            ELSE NULL
        END,
        UPDATED_AT = CURRENT_TIMESTAMP
    WHERE
        ID_EMPLEADO = P_ID_EMPLEADO
        AND ELIMINADO = 0
        AND P_ESTADO_EMPLEADO IN (
            'ACTIVO',
            'RETIRADO',
            'SUSPENDIDO',
            'INCAPACITADO',
            'EN_PROCESO_RETIRO'
        );

    SELECT ROW_COUNT() AS FILAS_AFECTADAS;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_EMPLEADOS_CREAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_EMPLEADOS_CREAR`(
    IN P_ID_TIPO_DOCUMENTO INT,
    IN P_NUMERO_DOCUMENTO VARCHAR(50),
    IN P_NOMBRES VARCHAR(150),
    IN P_APELLIDOS VARCHAR(150),
    IN P_CORREO VARCHAR(150),
    IN P_TELEFONO VARCHAR(50),
    IN P_FOTO_URL VARCHAR(500),
    IN P_ID_AREA INT,
    IN P_ID_CARGO INT,
    IN P_ID_TIPO_CONTRATO INT,
    IN P_FECHA_INGRESO DATE,
    IN P_FECHA_RETIRO DATE,
    IN P_ESTADO_EMPLEADO VARCHAR(50),
    IN P_OBSERVACIONES TEXT
)
BEGIN
    INSERT INTO bbf_empleados (
        ID_TIPO_DOCUMENTO,
        NUMERO_DOCUMENTO,
        NOMBRES,
        APELLIDOS,
        CORREO,
        TELEFONO,
        FOTO_URL,
        ID_AREA,
        ID_CARGO,
        ID_TIPO_CONTRATO,
        FECHA_INGRESO,
        FECHA_RETIRO,
        ESTADO_EMPLEADO,
        OBSERVACIONES
    )
    VALUES (
        P_ID_TIPO_DOCUMENTO,
        P_NUMERO_DOCUMENTO,
        P_NOMBRES,
        P_APELLIDOS,
        P_CORREO,
        P_TELEFONO,
        P_FOTO_URL,
        P_ID_AREA,
        P_ID_CARGO,
        P_ID_TIPO_CONTRATO,
        P_FECHA_INGRESO,
        P_FECHA_RETIRO,
        IFNULL(P_ESTADO_EMPLEADO, 'ACTIVO'),
        P_OBSERVACIONES
    );

    SELECT LAST_INSERT_ID() AS ID_EMPLEADO;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_EMPLEADOS_ELIMINAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_EMPLEADOS_ELIMINAR`(
    IN P_ID_EMPLEADO INT
)
BEGIN
    UPDATE bbf_empleados
    SET
        ELIMINADO = 1,
        FECHA_ELIMINACION = CURRENT_TIMESTAMP,
        UPDATED_AT = CURRENT_TIMESTAMP
    WHERE
        ID_EMPLEADO = P_ID_EMPLEADO
        AND ELIMINADO = 0;

    SELECT ROW_COUNT() AS FILAS_AFECTADAS;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_EMPLEADOS_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_EMPLEADOS_LISTAR`(
    IN P_ESTADO_EMPLEADO VARCHAR(50),
    IN P_ID_AREA INT,
    IN P_ID_CARGO INT,
    IN P_TEXTO_BUSQUEDA VARCHAR(150)
)
BEGIN
    SELECT
        E.ID_EMPLEADO,
        E.ID_TIPO_DOCUMENTO,
        TD.NOMBRE AS TIPO_DOCUMENTO,
        E.NUMERO_DOCUMENTO,
        E.NOMBRES,
        E.APELLIDOS,
        CONCAT(E.NOMBRES, ' ', E.APELLIDOS) AS NOMBRE_COMPLETO,
        E.CORREO,
        E.TELEFONO,
        E.FOTO_URL,
        E.ID_AREA,
        A.NOMBRE AS AREA,
        E.ID_CARGO,
        C.NOMBRE AS CARGO,
        E.ID_TIPO_CONTRATO,
        TC.NOMBRE AS TIPO_CONTRATO,
        E.FECHA_INGRESO,
        E.FECHA_RETIRO,
        E.ESTADO_EMPLEADO,
        E.OBSERVACIONES,
        E.CREATED_AT,
        E.UPDATED_AT
    FROM bbf_empleados E
    LEFT JOIN bbf_tipos_documento TD
        ON TD.ID_TIPO_DOCUMENTO = E.ID_TIPO_DOCUMENTO
    LEFT JOIN bbf_areas A
        ON A.ID_AREA = E.ID_AREA
    LEFT JOIN bbf_cargos C
        ON C.ID_CARGO = E.ID_CARGO
    LEFT JOIN bbf_tipos_contrato TC
        ON TC.ID_TIPO_CONTRATO = E.ID_TIPO_CONTRATO
    WHERE
        IFNULL(E.ELIMINADO, 0) = 0
        AND (P_ESTADO_EMPLEADO IS NULL OR P_ESTADO_EMPLEADO = '' OR E.ESTADO_EMPLEADO = P_ESTADO_EMPLEADO)
        AND (P_ID_AREA IS NULL OR P_ID_AREA = 0 OR E.ID_AREA = P_ID_AREA)
        AND (P_ID_CARGO IS NULL OR P_ID_CARGO = 0 OR E.ID_CARGO = P_ID_CARGO)
        AND (
            P_TEXTO_BUSQUEDA IS NULL
            OR P_TEXTO_BUSQUEDA = ''
            OR E.NUMERO_DOCUMENTO LIKE CONCAT('%', P_TEXTO_BUSQUEDA, '%')
            OR E.NOMBRES LIKE CONCAT('%', P_TEXTO_BUSQUEDA, '%')
            OR E.APELLIDOS LIKE CONCAT('%', P_TEXTO_BUSQUEDA, '%')
            OR E.CORREO LIKE CONCAT('%', P_TEXTO_BUSQUEDA, '%')
        )
    ORDER BY E.CREATED_AT DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_EMPLEADOS_OBTENER_POR_DOCUMENTO` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_EMPLEADOS_OBTENER_POR_DOCUMENTO`(
    IN P_NUMERO_DOCUMENTO VARCHAR(50)
)
BEGIN
    SELECT
        E.ID_EMPLEADO,
        E.ID_TIPO_DOCUMENTO,
        TD.NOMBRE AS TIPO_DOCUMENTO,
        E.NUMERO_DOCUMENTO,
        E.NOMBRES,
        E.APELLIDOS,
        CONCAT(E.NOMBRES, ' ', E.APELLIDOS) AS NOMBRE_COMPLETO,
        E.CORREO,
        E.TELEFONO,
        E.FOTO_URL,
        E.ID_AREA,
        A.NOMBRE AS AREA,
        E.ID_CARGO,
        C.NOMBRE AS CARGO,
        E.ID_TIPO_CONTRATO,
        TC.NOMBRE AS TIPO_CONTRATO,
        E.ESTADO_EMPLEADO,
        E.FECHA_INGRESO,
        E.FECHA_RETIRO,
        E.OBSERVACIONES
    FROM bbf_empleados E
    LEFT JOIN bbf_tipos_documento TD
        ON TD.ID_TIPO_DOCUMENTO = E.ID_TIPO_DOCUMENTO
    LEFT JOIN bbf_areas A
        ON A.ID_AREA = E.ID_AREA
    LEFT JOIN bbf_cargos C
        ON C.ID_CARGO = E.ID_CARGO
    LEFT JOIN bbf_tipos_contrato TC
        ON TC.ID_TIPO_CONTRATO = E.ID_TIPO_CONTRATO
    WHERE E.NUMERO_DOCUMENTO = P_NUMERO_DOCUMENTO
    LIMIT 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_EMPLEADOS_OBTENER_POR_ID` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_EMPLEADOS_OBTENER_POR_ID`(
    IN P_ID_EMPLEADO INT
)
BEGIN
    SELECT
        E.ID_EMPLEADO,
        E.ID_TIPO_DOCUMENTO,
        TD.NOMBRE AS TIPO_DOCUMENTO,
        E.NUMERO_DOCUMENTO,
        E.NOMBRES,
        E.APELLIDOS,
        CONCAT(E.NOMBRES, ' ', E.APELLIDOS) AS NOMBRE_COMPLETO,
        E.CORREO,
        E.TELEFONO,
        E.FOTO_URL,
        E.ID_AREA,
        A.NOMBRE AS AREA,
        E.ID_CARGO,
        C.NOMBRE AS CARGO,
        E.ID_TIPO_CONTRATO,
        TC.NOMBRE AS TIPO_CONTRATO,
        E.FECHA_INGRESO,
        E.FECHA_RETIRO,
        E.ESTADO_EMPLEADO,
        E.OBSERVACIONES,
        E.CREATED_AT,
        E.UPDATED_AT
    FROM bbf_empleados E
    LEFT JOIN bbf_tipos_documento TD
        ON TD.ID_TIPO_DOCUMENTO = E.ID_TIPO_DOCUMENTO
    LEFT JOIN bbf_areas A
        ON A.ID_AREA = E.ID_AREA
    LEFT JOIN bbf_cargos C
        ON C.ID_CARGO = E.ID_CARGO
    LEFT JOIN bbf_tipos_contrato TC
        ON TC.ID_TIPO_CONTRATO = E.ID_TIPO_CONTRATO
    WHERE E.ID_EMPLEADO = P_ID_EMPLEADO;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_LOGIN_MARCAR_EXITOSO` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_LOGIN_MARCAR_EXITOSO`(
    IN P_ID_USUARIO INT
)
BEGIN
    UPDATE bbf_usuarios
    SET
        ULTIMO_LOGIN = CURRENT_TIMESTAMP,
        INTENTOS_FALLIDOS = 0,
        FECHA_BLOQUEO = NULL
    WHERE ID_USUARIO = P_ID_USUARIO;

    SELECT ROW_COUNT() AS FILAS_AFECTADAS;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_LOGIN_MARCAR_FALLIDO` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_LOGIN_MARCAR_FALLIDO`(
    IN P_ID_USUARIO INT
)
BEGIN
    UPDATE bbf_usuarios
    SET
        INTENTOS_FALLIDOS = INTENTOS_FALLIDOS + 1,
        ESTADO = CASE
            WHEN INTENTOS_FALLIDOS + 1 >= 5 THEN 'BLOQUEADO'
            ELSE ESTADO
        END,
        FECHA_BLOQUEO = CASE
            WHEN INTENTOS_FALLIDOS + 1 >= 5 THEN CURRENT_TIMESTAMP
            ELSE FECHA_BLOQUEO
        END
    WHERE ID_USUARIO = P_ID_USUARIO;

    SELECT
        ID_USUARIO,
        ESTADO,
        INTENTOS_FALLIDOS,
        FECHA_BLOQUEO
    FROM bbf_usuarios
    WHERE ID_USUARIO = P_ID_USUARIO;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_LOGIN_OBTENER_USUARIO` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_LOGIN_OBTENER_USUARIO`(
    IN P_USUARIO_O_CORREO VARCHAR(150)
)
BEGIN
    SELECT
        U.ID_USUARIO,
        U.ID_EMPLEADO,
        U.NOMBRE_USUARIO,
        U.CORREO,
        U.PASSWORD_HASH,
        U.TIPO_USUARIO,
        U.TIPO_AUTENTICACION,
        U.REQUIERE_CAMBIO_PASSWORD,
        U.CORREO_VERIFICADO,
        U.ESTADO,
        U.INTENTOS_FALLIDOS,
        U.FECHA_BLOQUEO,
        U.ULTIMO_LOGIN,
        E.NOMBRES,
        E.APELLIDOS,
        CONCAT(E.NOMBRES, ' ', E.APELLIDOS) AS NOMBRE_COMPLETO
    FROM bbf_usuarios U
    LEFT JOIN bbf_empleados E ON E.ID_EMPLEADO = U.ID_EMPLEADO
    WHERE U.CORREO = P_USUARIO_O_CORREO
       OR U.NOMBRE_USUARIO = P_USUARIO_O_CORREO
    LIMIT 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_LOG_AUDITORIA_CREAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_LOG_AUDITORIA_CREAR`(
    IN P_ID_USUARIO INT,
    IN P_MODULO VARCHAR(100),
    IN P_ACCION VARCHAR(100),
    IN P_ENTIDAD VARCHAR(100),
    IN P_ENTIDAD_ID INT,
    IN P_DATOS_ANTERIORES JSON,
    IN P_DATOS_NUEVOS JSON,
    IN P_IP_ORIGEN VARCHAR(50),
    IN P_USER_AGENT VARCHAR(500)
)
BEGIN
    INSERT INTO bbf_log_auditoria (
        ID_USUARIO,
        MODULO,
        ACCION,
        ENTIDAD,
        ENTIDAD_ID,
        DATOS_ANTERIORES,
        DATOS_NUEVOS,
        IP_ORIGEN,
        USER_AGENT
    )
    VALUES (
        P_ID_USUARIO,
        P_MODULO,
        P_ACCION,
        P_ENTIDAD,
        P_ENTIDAD_ID,
        P_DATOS_ANTERIORES,
        P_DATOS_NUEVOS,
        P_IP_ORIGEN,
        P_USER_AGENT
    );

    SELECT LAST_INSERT_ID() AS ID_LOG;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_LOG_AUDITORIA_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_LOG_AUDITORIA_LISTAR`(
    IN P_FECHA_INICIO DATETIME,
    IN P_FECHA_FIN DATETIME,
    IN P_ID_USUARIO INT,
    IN P_MODULO VARCHAR(100),
    IN P_ACCION VARCHAR(100)
)
BEGIN
    SELECT
        L.ID_LOG,
        L.ID_USUARIO,
        U.CORREO AS USUARIO_CORREO,
        U.NOMBRE_USUARIO,
        L.MODULO,
        L.ACCION,
        L.ENTIDAD,
        L.ENTIDAD_ID,
        L.IP_ORIGEN,
        L.USER_AGENT,
        L.CREATED_AT
    FROM bbf_log_auditoria L
    LEFT JOIN bbf_usuarios U ON U.ID_USUARIO = L.ID_USUARIO
    WHERE
        (P_FECHA_INICIO IS NULL OR L.CREATED_AT >= P_FECHA_INICIO)
        AND (P_FECHA_FIN IS NULL OR L.CREATED_AT <= P_FECHA_FIN)
        AND (P_ID_USUARIO IS NULL OR P_ID_USUARIO = 0 OR L.ID_USUARIO = P_ID_USUARIO)
        AND (P_MODULO IS NULL OR P_MODULO = '' OR L.MODULO = P_MODULO)
        AND (P_ACCION IS NULL OR P_ACCION = '' OR L.ACCION = P_ACCION)
    ORDER BY L.CREATED_AT DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_LOG_AUDITORIA_OBTENER_POR_ID` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_LOG_AUDITORIA_OBTENER_POR_ID`(
    IN P_ID_LOG BIGINT
)
BEGIN
    SELECT
        L.ID_LOG,
        L.ID_USUARIO,
        U.CORREO AS USUARIO_CORREO,
        U.NOMBRE_USUARIO,
        L.MODULO,
        L.ACCION,
        L.ENTIDAD,
        L.ENTIDAD_ID,
        L.DATOS_ANTERIORES,
        L.DATOS_NUEVOS,
        L.IP_ORIGEN,
        L.USER_AGENT,
        L.CREATED_AT
    FROM bbf_log_auditoria L
    LEFT JOIN bbf_usuarios U ON U.ID_USUARIO = L.ID_USUARIO
    WHERE L.ID_LOG = P_ID_LOG;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_PASSWORD_RESET_CREAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_PASSWORD_RESET_CREAR`(
    IN P_ID_USUARIO INT,
    IN P_TOKEN_HASH VARCHAR(255),
    IN P_FECHA_EXPIRACION DATETIME,
    IN P_IP_SOLICITUD VARCHAR(50)
)
BEGIN
    -- Se invalidan tokens anteriores pendientes.
    UPDATE bbf_usuario_password_reset
    SET
        USADO = 1,
        FECHA_USO = CURRENT_TIMESTAMP
    WHERE ID_USUARIO = P_ID_USUARIO
      AND USADO = 0;

    INSERT INTO bbf_usuario_password_reset (
        ID_USUARIO,
        TOKEN_HASH,
        FECHA_EXPIRACION,
        IP_SOLICITUD,
        USADO
    )
    VALUES (
        P_ID_USUARIO,
        P_TOKEN_HASH,
        P_FECHA_EXPIRACION,
        P_IP_SOLICITUD,
        0
    );

    SELECT LAST_INSERT_ID() AS ID_RESET;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_PASSWORD_RESET_MARCAR_USADO` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_PASSWORD_RESET_MARCAR_USADO`(
    IN P_ID_RESET BIGINT
)
BEGIN
    UPDATE bbf_usuario_password_reset
    SET
        USADO = 1,
        FECHA_USO = CURRENT_TIMESTAMP
    WHERE ID_RESET = P_ID_RESET
      AND USADO = 0;

    SELECT ROW_COUNT() AS FILAS_AFECTADAS;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_PASSWORD_RESET_OBTENER` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_PASSWORD_RESET_OBTENER`(
    IN P_TOKEN_HASH VARCHAR(255)
)
BEGIN
    SELECT
        PR.ID_RESET,
        PR.ID_USUARIO,
        PR.TOKEN_HASH,
        PR.FECHA_CREACION,
        PR.FECHA_EXPIRACION,
        PR.FECHA_USO,
        PR.USADO,
        U.CORREO,
        U.NOMBRE_USUARIO,
        U.ESTADO
    FROM bbf_usuario_password_reset PR
    INNER JOIN bbf_usuarios U ON U.ID_USUARIO = PR.ID_USUARIO
    WHERE PR.TOKEN_HASH = P_TOKEN_HASH
    LIMIT 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_PERMISOS_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_PERMISOS_LISTAR`(
    IN P_SOLO_ACTIVOS TINYINT,
    IN P_MODULO VARCHAR(100)
)
BEGIN
    SELECT
        ID_PERMISO,
        CODIGO,
        NOMBRE,
        DESCRIPCION,
        MODULO,
        ACTIVO,
        CREATED_AT,
        UPDATED_AT
    FROM bbf_permisos
    WHERE
        (P_SOLO_ACTIVOS = 0 OR ACTIVO = 1)
        AND (P_MODULO IS NULL OR P_MODULO = '' OR MODULO = P_MODULO)
    ORDER BY MODULO ASC, CODIGO ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_ROLES_CAMBIAR_ESTADO` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_ROLES_CAMBIAR_ESTADO`(
    IN P_ID_ROL INT,
    IN P_ACTIVO TINYINT
)
BEGIN
    UPDATE bbf_roles
    SET 
        ACTIVO = P_ACTIVO,
        ELIMINADO = 0,
        FECHA_ELIMINACION = NULL,
        UPDATED_AT = CURRENT_TIMESTAMP
    WHERE ID_ROL = P_ID_ROL
      AND ELIMINADO = 0;

    SELECT ROW_COUNT() AS FILAS_AFECTADAS;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_ROLES_CREAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_ROLES_CREAR`(
    IN P_NOMBRE VARCHAR(100),
    IN P_DESCRIPCION TEXT
)
BEGIN
    INSERT INTO bbf_roles (
        NOMBRE,
        DESCRIPCION,
        ACTIVO
    )
    VALUES (
        P_NOMBRE,
        P_DESCRIPCION,
        1
    );

    SELECT LAST_INSERT_ID() AS ID_ROL;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_ROLES_ELIMINAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_ROLES_ELIMINAR`(
    IN P_ID_ROL INT
)
BEGIN
    UPDATE bbf_roles
    SET
        ACTIVO = 0,
        ELIMINADO = 1,
        FECHA_ELIMINACION = CURRENT_TIMESTAMP,
        UPDATED_AT = CURRENT_TIMESTAMP
    WHERE ID_ROL = P_ID_ROL
      AND ELIMINADO = 0;

    SELECT ROW_COUNT() AS FILAS_AFECTADAS;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_ROLES_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_ROLES_LISTAR`(IN P_SOLO_ACTIVOS TINYINT)
BEGIN SELECT ID_ROL, NOMBRE, DESCRIPCION, ACTIVO, CREATED_AT, UPDATED_AT FROM bbf_roles WHERE ELIMINADO = 0 AND (P_SOLO_ACTIVOS = 0 OR ACTIVO = 1) ORDER BY NOMBRE ASC; END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_ROL_OBTENER_PERMISOS` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_ROL_OBTENER_PERMISOS`(
    IN P_ID_ROL INT
)
BEGIN
    SELECT
        P.ID_PERMISO,
        P.CODIGO,
        P.NOMBRE,
        P.DESCRIPCION,
        P.MODULO,
        P.ACTIVO
    FROM bbf_rol_permisos RP
    INNER JOIN bbf_permisos P ON P.ID_PERMISO = RP.ID_PERMISO
    WHERE RP.ID_ROL = P_ID_ROL
    ORDER BY P.MODULO ASC, P.CODIGO ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_ROL_PERMISOS_ASIGNAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_ROL_PERMISOS_ASIGNAR`(
    IN P_ID_ROL INT,
    IN P_ID_PERMISO INT
)
BEGIN
    INSERT IGNORE INTO bbf_rol_permisos (
        ID_ROL,
        ID_PERMISO
    )
    VALUES (
        P_ID_ROL,
        P_ID_PERMISO
    );

    SELECT ROW_COUNT() AS FILAS_AFECTADAS;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_ROL_PERMISOS_QUITAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_ROL_PERMISOS_QUITAR`(
    IN P_ID_ROL INT,
    IN P_ID_PERMISO INT
)
BEGIN
    DELETE FROM bbf_rol_permisos
    WHERE ID_ROL = P_ID_ROL
      AND ID_PERMISO = P_ID_PERMISO;

    SELECT ROW_COUNT() AS FILAS_AFECTADAS;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_TIPOS_CONTRATO_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_TIPOS_CONTRATO_LISTAR`(
    IN P_SOLO_ACTIVOS TINYINT
)
BEGIN
    SELECT
        ID_TIPO_CONTRATO,
        NOMBRE,
        DESCRIPCION,
        ACTIVO,
        CREATED_AT,
        UPDATED_AT
    FROM bbf_tipos_contrato
    WHERE P_SOLO_ACTIVOS = 0 OR ACTIVO = 1
    ORDER BY NOMBRE ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_TIPOS_DOCUMENTO_LABORAL_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_TIPOS_DOCUMENTO_LABORAL_LISTAR`(
    IN P_SOLO_ACTIVOS TINYINT,
    IN P_APLICA_ASPIRANTE TINYINT,
    IN P_APLICA_CONTRATACION TINYINT,
    IN P_APLICA_RETIRO TINYINT
)
BEGIN
    SELECT
        ID_TIPO_DOCUMENTO_LABORAL,
        NOMBRE,
        DESCRIPCION,
        OBLIGATORIO,
        REQUIERE_VENCIMIENTO,
        APLICA_ASPIRANTE,
        APLICA_CONTRATACION,
        APLICA_RETIRO,
        ACTIVO,
        CREATED_AT,
        UPDATED_AT
    FROM bbf_tipos_documento_laboral
    WHERE
        (P_SOLO_ACTIVOS IS NULL OR P_SOLO_ACTIVOS = 0 OR ACTIVO = 1)
        AND (P_APLICA_ASPIRANTE IS NULL OR APLICA_ASPIRANTE = P_APLICA_ASPIRANTE)
        AND (P_APLICA_CONTRATACION IS NULL OR APLICA_CONTRATACION = P_APLICA_CONTRATACION)
        AND (P_APLICA_RETIRO IS NULL OR APLICA_RETIRO = P_APLICA_RETIRO)
    ORDER BY OBLIGATORIO DESC, NOMBRE ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_TIPOS_DOCUMENTO_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_TIPOS_DOCUMENTO_LISTAR`(IN P_SOLO_ACTIVOS TINYINT)
BEGIN
    SELECT
        ID_TIPO_DOCUMENTO,
        NOMBRE,
        ACTIVO,
        CREATED_AT,
        UPDATED_AT
    FROM bbf_tipos_documento
    WHERE COALESCE(P_SOLO_ACTIVOS, 1) = 0
        OR ACTIVO = 1
    ORDER BY NOMBRE;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_USUARIOS_ACTUALIZAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_USUARIOS_ACTUALIZAR`(
    IN P_ID_USUARIO INT,
    IN P_ID_EMPLEADO INT,
    IN P_NOMBRE_USUARIO VARCHAR(100),
    IN P_CORREO VARCHAR(150),
    IN P_TIPO_USUARIO VARCHAR(50),
    IN P_TIPO_AUTENTICACION VARCHAR(50),
    IN P_REQUIERE_CAMBIO_PASSWORD TINYINT,
    IN P_CORREO_VERIFICADO TINYINT,
    IN P_ESTADO VARCHAR(50)
)
BEGIN
    DECLARE V_DOMINIO VARCHAR(150);
    DECLARE V_EXISTE_DOMINIO INT DEFAULT 0;

    SET V_DOMINIO = SUBSTRING_INDEX(P_CORREO, '@', -1);

    IF P_TIPO_AUTENTICACION = 'DOMINIO_EMPRESA' THEN

        SELECT COUNT(*)
        INTO V_EXISTE_DOMINIO
        FROM bbf_dominios_autorizados
        WHERE DOMINIO = V_DOMINIO
          AND ACTIVO = 1;

        IF V_EXISTE_DOMINIO = 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El correo no pertenece a un dominio autorizado.';
        END IF;

    END IF;

    UPDATE bbf_usuarios
    SET
        ID_EMPLEADO = P_ID_EMPLEADO,
        NOMBRE_USUARIO = P_NOMBRE_USUARIO,
        CORREO = P_CORREO,
        TIPO_USUARIO = P_TIPO_USUARIO,
        TIPO_AUTENTICACION = P_TIPO_AUTENTICACION,
        REQUIERE_CAMBIO_PASSWORD = P_REQUIERE_CAMBIO_PASSWORD,
        CORREO_VERIFICADO = P_CORREO_VERIFICADO,
        ESTADO = P_ESTADO
    WHERE ID_USUARIO = P_ID_USUARIO;

    SELECT ROW_COUNT() AS FILAS_AFECTADAS;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_USUARIOS_CAMBIAR_ESTADO` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_USUARIOS_CAMBIAR_ESTADO`(
    IN P_ID_USUARIO INT,
    IN P_ESTADO VARCHAR(50)
)
BEGIN
    UPDATE bbf_usuarios
    SET
        ESTADO = P_ESTADO,
        FECHA_BLOQUEO = CASE
            WHEN P_ESTADO = 'BLOQUEADO' THEN CURRENT_TIMESTAMP
            ELSE NULL
        END,
        INTENTOS_FALLIDOS = CASE
            WHEN P_ESTADO = 'ACTIVO' THEN 0
            ELSE INTENTOS_FALLIDOS
        END,
        UPDATED_AT = CURRENT_TIMESTAMP
    WHERE ID_USUARIO = P_ID_USUARIO
      AND P_ESTADO IN ('ACTIVO', 'INACTIVO', 'BLOQUEADO', 'ELIMINADO');

    SELECT ROW_COUNT() AS FILAS_AFECTADAS;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_USUARIOS_CAMBIAR_PASSWORD` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_USUARIOS_CAMBIAR_PASSWORD`(
    IN P_ID_USUARIO INT,
    IN P_PASSWORD_HASH_NUEVO VARCHAR(255),
    IN P_GUARDAR_HISTORIAL TINYINT
)
BEGIN
    DECLARE V_PASSWORD_HASH_ANTERIOR VARCHAR(255);

    SELECT PASSWORD_HASH
    INTO V_PASSWORD_HASH_ANTERIOR
    FROM bbf_usuarios
    WHERE ID_USUARIO = P_ID_USUARIO;

    IF P_GUARDAR_HISTORIAL = 1 THEN
        INSERT INTO bbf_usuario_password_historial (
            ID_USUARIO,
            PASSWORD_HASH
        )
        VALUES (
            P_ID_USUARIO,
            V_PASSWORD_HASH_ANTERIOR
        );
    END IF;

    UPDATE bbf_usuarios
    SET
        PASSWORD_HASH = P_PASSWORD_HASH_NUEVO,
        REQUIERE_CAMBIO_PASSWORD = 0,
        INTENTOS_FALLIDOS = 0,
        FECHA_BLOQUEO = NULL,
        ESTADO = 'ACTIVO'
    WHERE ID_USUARIO = P_ID_USUARIO;

    SELECT ROW_COUNT() AS FILAS_AFECTADAS;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_USUARIOS_CREAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_USUARIOS_CREAR`(
    IN P_ID_EMPLEADO INT,
    IN P_NOMBRE_USUARIO VARCHAR(100),
    IN P_CORREO VARCHAR(150),
    IN P_PASSWORD_HASH VARCHAR(255),
    IN P_TIPO_USUARIO VARCHAR(50),
    IN P_TIPO_AUTENTICACION VARCHAR(50),
    IN P_REQUIERE_CAMBIO_PASSWORD TINYINT,
    IN P_CORREO_VERIFICADO TINYINT
)
BEGIN
    DECLARE V_DOMINIO VARCHAR(150);
    DECLARE V_EXISTE_DOMINIO INT DEFAULT 0;

    SET V_DOMINIO = SUBSTRING_INDEX(P_CORREO, '@', -1);

    IF P_TIPO_AUTENTICACION = 'DOMINIO_EMPRESA' THEN

        SELECT COUNT(*)
        INTO V_EXISTE_DOMINIO
        FROM bbf_dominios_autorizados
        WHERE DOMINIO = V_DOMINIO
          AND ACTIVO = 1;

        IF V_EXISTE_DOMINIO = 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El correo no pertenece a un dominio autorizado.';
        END IF;

    END IF;

    INSERT INTO bbf_usuarios (
        ID_EMPLEADO,
        NOMBRE_USUARIO,
        CORREO,
        PASSWORD_HASH,
        TIPO_USUARIO,
        TIPO_AUTENTICACION,
        REQUIERE_CAMBIO_PASSWORD,
        CORREO_VERIFICADO,
        ESTADO
    )
    VALUES (
        P_ID_EMPLEADO,
        P_NOMBRE_USUARIO,
        P_CORREO,
        P_PASSWORD_HASH,
        P_TIPO_USUARIO,
        P_TIPO_AUTENTICACION,
        P_REQUIERE_CAMBIO_PASSWORD,
        P_CORREO_VERIFICADO,
        'ACTIVO'
    );

    SELECT LAST_INSERT_ID() AS ID_USUARIO;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_USUARIOS_CREAR_POR_DOCUMENTO` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_USUARIOS_CREAR_POR_DOCUMENTO`(
    IN P_NUMERO_DOCUMENTO VARCHAR(50),
    IN P_NOMBRE_USUARIO VARCHAR(100),
    IN P_CORREO VARCHAR(150),
    IN P_PASSWORD_HASH VARCHAR(255),
    IN P_TIPO_USUARIO VARCHAR(50),
    IN P_TIPO_AUTENTICACION VARCHAR(50),
    IN P_REQUIERE_CAMBIO_PASSWORD TINYINT,
    IN P_CORREO_VERIFICADO TINYINT
)
BEGIN
    DECLARE V_ID_EMPLEADO INT DEFAULT NULL;
    DECLARE V_DOMINIO VARCHAR(150);
    DECLARE V_EXISTE_DOMINIO INT DEFAULT 0;

    IF P_NUMERO_DOCUMENTO IS NOT NULL AND P_NUMERO_DOCUMENTO <> '' THEN
        SELECT ID_EMPLEADO
        INTO V_ID_EMPLEADO
        FROM bbf_empleados
        WHERE NUMERO_DOCUMENTO = P_NUMERO_DOCUMENTO
        LIMIT 1;

        IF V_ID_EMPLEADO IS NULL THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No existe un empleado con el documento indicado.';
        END IF;
    END IF;

    SET V_DOMINIO = SUBSTRING_INDEX(P_CORREO, '@', -1);

    IF P_TIPO_AUTENTICACION = 'DOMINIO_EMPRESA' THEN
        SELECT COUNT(*)
        INTO V_EXISTE_DOMINIO
        FROM bbf_dominios_autorizados
        WHERE DOMINIO = V_DOMINIO
          AND ACTIVO = 1;

        IF V_EXISTE_DOMINIO = 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El correo no pertenece a un dominio autorizado.';
        END IF;
    END IF;

    INSERT INTO bbf_usuarios (
        ID_EMPLEADO,
        NOMBRE_USUARIO,
        CORREO,
        PASSWORD_HASH,
        TIPO_USUARIO,
        TIPO_AUTENTICACION,
        REQUIERE_CAMBIO_PASSWORD,
        CORREO_VERIFICADO,
        ESTADO
    )
    VALUES (
        V_ID_EMPLEADO,
        P_NOMBRE_USUARIO,
        P_CORREO,
        P_PASSWORD_HASH,
        P_TIPO_USUARIO,
        P_TIPO_AUTENTICACION,
        P_REQUIERE_CAMBIO_PASSWORD,
        P_CORREO_VERIFICADO,
        'ACTIVO'
    );

    SELECT LAST_INSERT_ID() AS ID_USUARIO;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_USUARIOS_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_USUARIOS_LISTAR`(
    IN P_ESTADO VARCHAR(50),
    IN P_TIPO_USUARIO VARCHAR(50),
    IN P_TEXTO_BUSQUEDA VARCHAR(150)
)
BEGIN
    SELECT
        U.ID_USUARIO,
        U.ID_EMPLEADO,
        U.NOMBRE_USUARIO,
        U.CORREO,
        U.TIPO_USUARIO,
        U.TIPO_AUTENTICACION,
        U.REQUIERE_CAMBIO_PASSWORD,
        U.CORREO_VERIFICADO,
        U.ESTADO,
        U.ULTIMO_LOGIN,
        U.CREATED_AT,
        CONCAT(E.NOMBRES, ' ', E.APELLIDOS) AS NOMBRE_COMPLETO
    FROM bbf_usuarios U
    LEFT JOIN bbf_empleados E ON E.ID_EMPLEADO = U.ID_EMPLEADO
    WHERE
        U.ESTADO <> 'ELIMINADO'
        AND (P_ESTADO IS NULL OR P_ESTADO = '' OR U.ESTADO = P_ESTADO)
        AND (P_TIPO_USUARIO IS NULL OR P_TIPO_USUARIO = '' OR U.TIPO_USUARIO = P_TIPO_USUARIO)
        AND (
            P_TEXTO_BUSQUEDA IS NULL
            OR P_TEXTO_BUSQUEDA = ''
            OR U.NOMBRE_USUARIO LIKE CONCAT('%', P_TEXTO_BUSQUEDA, '%')
            OR U.CORREO LIKE CONCAT('%', P_TEXTO_BUSQUEDA, '%')
            OR E.NOMBRES LIKE CONCAT('%', P_TEXTO_BUSQUEDA, '%')
            OR E.APELLIDOS LIKE CONCAT('%', P_TEXTO_BUSQUEDA, '%')
        )
    ORDER BY U.CREATED_AT DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_USUARIOS_OBTENER_POR_ID` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_USUARIOS_OBTENER_POR_ID`(
    IN P_ID_USUARIO INT
)
BEGIN
    SELECT
        U.ID_USUARIO,
        U.ID_EMPLEADO,
        U.NOMBRE_USUARIO,
        U.CORREO,
        U.TIPO_USUARIO,
        U.TIPO_AUTENTICACION,
        U.REQUIERE_CAMBIO_PASSWORD,
        U.CORREO_VERIFICADO,
        U.ESTADO,
        U.INTENTOS_FALLIDOS,
        U.FECHA_BLOQUEO,
        U.ULTIMO_LOGIN,
        U.CREATED_AT,
        U.UPDATED_AT,
        E.NOMBRES,
        E.APELLIDOS,
        CONCAT(E.NOMBRES, ' ', E.APELLIDOS) AS NOMBRE_COMPLETO
    FROM bbf_usuarios U
    LEFT JOIN bbf_empleados E ON E.ID_EMPLEADO = U.ID_EMPLEADO
    WHERE U.ID_USUARIO = P_ID_USUARIO;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_USUARIO_OBTENER_PERMISOS` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_USUARIO_OBTENER_PERMISOS`(
    IN P_ID_USUARIO INT
)
BEGIN
    SELECT DISTINCT
        P.ID_PERMISO,
        P.CODIGO,
        P.NOMBRE,
        P.DESCRIPCION,
        P.MODULO
    FROM bbf_usuario_roles UR
    INNER JOIN bbf_roles R ON R.ID_ROL = UR.ID_ROL
    INNER JOIN bbf_rol_permisos RP ON RP.ID_ROL = R.ID_ROL
    INNER JOIN bbf_permisos P ON P.ID_PERMISO = RP.ID_PERMISO
    WHERE UR.ID_USUARIO = P_ID_USUARIO
      AND R.ACTIVO = 1
      AND P.ACTIVO = 1
    ORDER BY P.MODULO ASC, P.CODIGO ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_USUARIO_OBTENER_ROLES` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_USUARIO_OBTENER_ROLES`(
    IN P_ID_USUARIO INT
)
BEGIN
    SELECT
        R.ID_ROL,
        R.NOMBRE,
        R.DESCRIPCION,
        R.ACTIVO
    FROM bbf_usuario_roles UR
    INNER JOIN bbf_roles R ON R.ID_ROL = UR.ID_ROL
    WHERE UR.ID_USUARIO = P_ID_USUARIO
      AND R.ACTIVO = 1
    ORDER BY R.NOMBRE ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_USUARIO_ROLES_ASIGNAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_USUARIO_ROLES_ASIGNAR`(
    IN P_ID_USUARIO INT,
    IN P_ID_ROL INT
)
BEGIN
    INSERT IGNORE INTO bbf_usuario_roles (
        ID_USUARIO,
        ID_ROL
    )
    VALUES (
        P_ID_USUARIO,
        P_ID_ROL
    );

    SELECT ROW_COUNT() AS FILAS_AFECTADAS;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_USUARIO_ROLES_QUITAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_USUARIO_ROLES_QUITAR`(
    IN P_ID_USUARIO INT,
    IN P_ID_ROL INT
)
BEGIN
    DELETE FROM bbf_usuario_roles
    WHERE ID_USUARIO = P_ID_USUARIO
      AND ID_ROL = P_ID_ROL;

    SELECT ROW_COUNT() AS FILAS_AFECTADAS;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_USUARIO_SESIONES_CREAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_USUARIO_SESIONES_CREAR`(
    IN P_ID_USUARIO INT,
    IN P_REFRESH_TOKEN_HASH VARCHAR(255),
    IN P_IP_ORIGEN VARCHAR(50),
    IN P_USER_AGENT VARCHAR(500),
    IN P_FECHA_EXPIRACION DATETIME
)
BEGIN
    INSERT INTO bbf_usuario_sesiones (
        ID_USUARIO,
        REFRESH_TOKEN_HASH,
        IP_ORIGEN,
        USER_AGENT,
        FECHA_EXPIRACION,
        ACTIVO
    )
    VALUES (
        P_ID_USUARIO,
        P_REFRESH_TOKEN_HASH,
        P_IP_ORIGEN,
        P_USER_AGENT,
        P_FECHA_EXPIRACION,
        1
    );

    SELECT LAST_INSERT_ID() AS ID_SESION;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_USUARIO_SESIONES_OBTENER_POR_TOKEN` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_USUARIO_SESIONES_OBTENER_POR_TOKEN`(
    IN P_REFRESH_TOKEN_HASH VARCHAR(255)
)
BEGIN
    SELECT
        S.ID_SESION,
        S.ID_USUARIO,
        S.REFRESH_TOKEN_HASH,
        S.IP_ORIGEN,
        S.USER_AGENT,
        S.FECHA_CREACION,
        S.FECHA_EXPIRACION,
        S.FECHA_REVOCACION,
        S.ACTIVO,
        U.CORREO,
        U.NOMBRE_USUARIO,
        U.TIPO_USUARIO,
        U.ESTADO
    FROM bbf_usuario_sesiones S
    INNER JOIN bbf_usuarios U ON U.ID_USUARIO = S.ID_USUARIO
    WHERE S.REFRESH_TOKEN_HASH = P_REFRESH_TOKEN_HASH
    LIMIT 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_USUARIO_SESIONES_REVOCAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_USUARIO_SESIONES_REVOCAR`(
    IN P_ID_SESION BIGINT
)
BEGIN
    UPDATE bbf_usuario_sesiones
    SET
        ACTIVO = 0,
        FECHA_REVOCACION = CURRENT_TIMESTAMP
    WHERE ID_SESION = P_ID_SESION
      AND ACTIVO = 1;

    SELECT ROW_COUNT() AS FILAS_AFECTADAS;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_USUARIO_SESIONES_REVOCAR_TODAS` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_USUARIO_SESIONES_REVOCAR_TODAS`(
    IN P_ID_USUARIO INT
)
BEGIN
    UPDATE bbf_usuario_sesiones
    SET
        ACTIVO = 0,
        FECHA_REVOCACION = CURRENT_TIMESTAMP
    WHERE ID_USUARIO = P_ID_USUARIO
      AND ACTIVO = 1;

    SELECT ROW_COUNT() AS FILAS_AFECTADAS;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-06-24 15:44:24
