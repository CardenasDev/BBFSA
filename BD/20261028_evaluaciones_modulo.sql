-- ============================================================
-- BBF SisAdmin - Modulo Evaluaciones (Evaluaciones Semanales de Labores Agricolas)
-- Archivo: BD/20261028_evaluaciones_modulo.sql
-- Motor: MySQL / MariaDB 10.4+ (utf8mb4)
-- Fecha: 2026-10-28
-- ============================================================

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- ------------------------------------------------------------
-- Limpieza de procedimientos (idempotente)
-- ------------------------------------------------------------
DROP PROCEDURE IF EXISTS `SP_BBF_EVALUACION_PANEL_GERENCIAL_OBTENER`;
DROP PROCEDURE IF EXISTS `SP_BBF_EVALUACION_REGISTRAR_CALIFICACIONES`;
DROP PROCEDURE IF EXISTS `SP_BBF_EVALUACION_EMPLEADO_AGREGAR`;
DROP PROCEDURE IF EXISTS `SP_BBF_EVALUACION_AGREGAR_EMPLEADOS_TODOS`;
DROP PROCEDURE IF EXISTS `SP_BBF_EVALUACION_CREAR`;

-- ------------------------------------------------------------
-- Limpieza de tablas (orden inverso de dependencias)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `bbf_evaluacion_detalles`;
DROP TABLE IF EXISTS `bbf_evaluacion_metas_finca`;
DROP TABLE IF EXISTS `bbf_evaluacion_empleados`;
DROP VIEW IF EXISTS `vw_bbf_evaluacion_totales_empleado`;
DROP TABLE IF EXISTS `bbf_evaluaciones`;
DROP TABLE IF EXISTS `bbf_evaluacion_labores`;

-- ============================================================
-- 1. CATALOGO DE LABORES AGRICOLAS (items parametrizables)
-- ============================================================
CREATE TABLE `bbf_evaluacion_labores` (
  `ID_EVALUACION_LABOR` int(11) NOT NULL AUTO_INCREMENT,
  `CODIGO` varchar(50) NOT NULL,
  `NOMBRE` varchar(150) NOT NULL,
  `DESCRIPCION` varchar(500) DEFAULT NULL,
  `PONDERACION_MAXIMA_DEFAULT` decimal(10,2) NOT NULL DEFAULT 50.00,
  `ORDEN` int(11) NOT NULL DEFAULT 0,
  `ACTIVO` tinyint(1) NOT NULL DEFAULT 1,
  `CREATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  `UPDATED_AT` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`ID_EVALUACION_LABOR`),
  UNIQUE KEY `UQ_BBF_EVAL_LABORES_CODIGO` (`CODIGO`),
  UNIQUE KEY `UQ_BBF_EVAL_LABORES_NOMBRE` (`NOMBRE`),
  KEY `IDX_BBF_EVAL_LABORES_ACTIVO_ORDEN` (`ACTIVO`,`ORDEN`),
  CONSTRAINT `CK_BBF_EVAL_LABORES_PONDERACION` CHECK (`PONDERACION_MAXIMA_DEFAULT` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 2. CABECERA DE EVALUACION SEMANAL
-- ============================================================
CREATE TABLE `bbf_evaluaciones` (
  `ID_EVALUACION` int(11) NOT NULL AUTO_INCREMENT,
  `ANIO` smallint(6) NOT NULL,
  `NUMERO_SEMANA` int(11) NOT NULL,
  `NOMBRE_SEMANA` varchar(100) DEFAULT NULL,
  `FECHA_INICIO` date NOT NULL,
  `FECHA_FIN` date DEFAULT NULL,
  `ESTADO` enum('BORRADOR','EN_PROCESO','COMPLETADA','CERRADA') NOT NULL DEFAULT 'BORRADOR',
  `OBSERVACIONES` text DEFAULT NULL,
  `ID_USUARIO_CREA` int(11) NOT NULL,
  `ID_USUARIO_CIERRE` int(11) DEFAULT NULL,
  `FECHA_CIERRE` datetime DEFAULT NULL,
  `ELIMINADO` tinyint(1) NOT NULL DEFAULT 0,
  `CREATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  `UPDATED_AT` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`ID_EVALUACION`),
  UNIQUE KEY `UQ_BBF_EVALUACIONES_ANIO_SEMANA` (`ANIO`,`NUMERO_SEMANA`),
  KEY `IDX_BBF_EVALUACIONES_ESTADO_FECHA` (`ESTADO`,`FECHA_INICIO`),
  KEY `FK_BBF_EVALUACIONES_USUARIO_CREA` (`ID_USUARIO_CREA`),
  KEY `FK_BBF_EVALUACIONES_USUARIO_CIERRE` (`ID_USUARIO_CIERRE`),
  CONSTRAINT `FK_BBF_EVALUACIONES_USUARIO_CREA` FOREIGN KEY (`ID_USUARIO_CREA`) REFERENCES `bbf_usuarios` (`ID_USUARIO`),
  CONSTRAINT `FK_BBF_EVALUACIONES_USUARIO_CIERRE` FOREIGN KEY (`ID_USUARIO_CIERRE`) REFERENCES `bbf_usuarios` (`ID_USUARIO`),
  CONSTRAINT `CK_BBF_EVALUACIONES_FECHAS` CHECK (`FECHA_FIN` IS NULL OR `FECHA_FIN` >= `FECHA_INICIO`),
  CONSTRAINT `CK_BBF_EVALUACIONES_SEMANA` CHECK (`NUMERO_SEMANA` BETWEEN 1 AND 53)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 3. EMPLEADOS ASIGNADOS A LA EVALUACION SEMANAL
-- ============================================================
CREATE TABLE `bbf_evaluacion_empleados` (
  `ID_EVALUACION_EMPLEADO` bigint(20) NOT NULL AUTO_INCREMENT,
  `ID_EVALUACION` int(11) NOT NULL,
  `ID_EMPLEADO` int(11) NOT NULL,
  `ESTADO_EVALUACION` enum('PENDIENTE','EN_PROCESO','EVALUADA','NO_APLICA') NOT NULL DEFAULT 'PENDIENTE',
  `OBSERVACIONES` text DEFAULT NULL,
  `ID_REGISTRADO_POR` int(11) NOT NULL,
  `CREATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  `UPDATED_AT` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`ID_EVALUACION_EMPLEADO`),
  UNIQUE KEY `UQ_BBF_EVAL_EMPLEADO` (`ID_EVALUACION`,`ID_EMPLEADO`),
  KEY `IDX_BBF_EVAL_EMPLEADOS_EVAL` (`ID_EVALUACION`,`ESTADO_EVALUACION`),
  KEY `FK_BBF_EVAL_EMPLEADOS_EMPLEADO` (`ID_EMPLEADO`),
  KEY `FK_BBF_EVAL_EMPLEADOS_REGISTRADO` (`ID_REGISTRADO_POR`),
  CONSTRAINT `FK_BBF_EVAL_EMPLEADOS_EVALUACION` FOREIGN KEY (`ID_EVALUACION`) REFERENCES `bbf_evaluaciones` (`ID_EVALUACION`) ON DELETE CASCADE,
  CONSTRAINT `FK_BBF_EVAL_EMPLEADOS_EMPLEADO` FOREIGN KEY (`ID_EMPLEADO`) REFERENCES `bbf_empleados` (`ID_EMPLEADO`) ON DELETE RESTRICT,
  CONSTRAINT `FK_BBF_EVAL_EMPLEADOS_REGISTRADO` FOREIGN KEY (`ID_REGISTRADO_POR`) REFERENCES `bbf_usuarios` (`ID_USUARIO`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 4. CALIFICACIONES / PONDERACIONES POR EMPLEADO Y LABOR
-- ============================================================
CREATE TABLE `bbf_evaluacion_detalles` (
  `ID_EVALUACION_DETALLE` bigint(20) NOT NULL AUTO_INCREMENT,
  `ID_EVALUACION_EMPLEADO` bigint(20) NOT NULL,
  `ID_EVALUACION_LABOR` int(11) NOT NULL,
  `VALOR_OBTENIDO` decimal(14,2) NOT NULL DEFAULT 0.00,
  `VALOR_MAXIMO` decimal(10,2) DEFAULT NULL,
  `OBSERVACIONES` varchar(500) DEFAULT NULL,
  `ID_EVALUADO_POR` int(11) NOT NULL,
  `CREATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  `UPDATED_AT` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`ID_EVALUACION_DETALLE`),
  UNIQUE KEY `UQ_BBF_EVAL_DETALLE` (`ID_EVALUACION_EMPLEADO`,`ID_EVALUACION_LABOR`),
  KEY `IDX_BBF_EVAL_DETALLE_LABOR` (`ID_EVALUACION_LABOR`),
  KEY `FK_BBF_EVAL_DETALLE_EVALUADO` (`ID_EVALUADO_POR`),
  CONSTRAINT `FK_BBF_EVAL_DETALLE_EMPLEADO` FOREIGN KEY (`ID_EVALUACION_EMPLEADO`) REFERENCES `bbf_evaluacion_empleados` (`ID_EVALUACION_EMPLEADO`) ON DELETE CASCADE,
  CONSTRAINT `FK_BBF_EVAL_DETALLE_LABOR` FOREIGN KEY (`ID_EVALUACION_LABOR`) REFERENCES `bbf_evaluacion_labores` (`ID_EVALUACION_LABOR`) ON DELETE RESTRICT,
  CONSTRAINT `FK_BBF_EVAL_DETALLE_EVALUADO` FOREIGN KEY (`ID_EVALUADO_POR`) REFERENCES `bbf_usuarios` (`ID_USUARIO`),
  CONSTRAINT `CK_BBF_EVAL_DETALLE_VALORES` CHECK (`VALOR_OBTENIDO` >= 0 AND (`VALOR_MAXIMO` IS NULL OR `VALOR_MAXIMO` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 5. METAS POR LABOR / SEMANA (PANEL GERENCIAL)
-- ============================================================
CREATE TABLE `bbf_evaluacion_metas_finca` (
  `ID_EVALUACION_META` int(11) NOT NULL AUTO_INCREMENT,
  `ID_EVALUACION` int(11) NOT NULL,
  `ID_EVALUACION_LABOR` int(11) NOT NULL,
  `META_CAMAS` decimal(14,2) NOT NULL,
  `OBSERVACIONES` varchar(500) DEFAULT NULL,
  `ID_REGISTRADO_POR` int(11) NOT NULL,
  `CREATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  `UPDATED_AT` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`ID_EVALUACION_META`),
  UNIQUE KEY `UQ_BBF_EVAL_META` (`ID_EVALUACION`,`ID_EVALUACION_LABOR`),
  KEY `FK_BBF_EVAL_META_LABOR` (`ID_EVALUACION_LABOR`),
  KEY `FK_BBF_EVAL_META_REGISTRADO` (`ID_REGISTRADO_POR`),
  CONSTRAINT `FK_BBF_EVAL_META_EVALUACION` FOREIGN KEY (`ID_EVALUACION`) REFERENCES `bbf_evaluaciones` (`ID_EVALUACION`) ON DELETE CASCADE,
  CONSTRAINT `FK_BBF_EVAL_META_LABOR` FOREIGN KEY (`ID_EVALUACION_LABOR`) REFERENCES `bbf_evaluacion_labores` (`ID_EVALUACION_LABOR`) ON DELETE RESTRICT,
  CONSTRAINT `FK_BBF_EVAL_META_REGISTRADO` FOREIGN KEY (`ID_REGISTRADO_POR`) REFERENCES `bbf_usuarios` (`ID_USUARIO`),
  CONSTRAINT `CK_BBF_EVAL_META_CAMAS` CHECK (`META_CAMAS` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 6. VISTA: TOTAL SEMANA POR EMPLEADO
-- ============================================================
CREATE OR REPLACE VIEW `vw_bbf_evaluacion_totales_empleado` AS
SELECT
  `ee`.`ID_EVALUACION` AS `ID_EVALUACION`,
  `ee`.`ID_EVALUACION_EMPLEADO` AS `ID_EVALUACION_EMPLEADO`,
  `ee`.`ID_EMPLEADO` AS `ID_EMPLEADO`,
  `e`.`NUMERO_DOCUMENTO` AS `NUMERO_DOCUMENTO`,
  CONCAT_WS(' ', `e`.`NOMBRES`, `e`.`APELLIDOS`) AS `EMPLEADO`,
  COALESCE(SUM(`ed`.`VALOR_OBTENIDO`), 0) AS `TOTAL_SEMANA`,
  COUNT(`ed`.`ID_EVALUACION_DETALLE`) AS `TOTAL_LABORES_REGISTRADAS`
FROM `bbf_evaluacion_empleados` `ee`
INNER JOIN `bbf_empleados` `e` ON `e`.`ID_EMPLEADO` = `ee`.`ID_EMPLEADO`
LEFT JOIN `bbf_evaluacion_detalles` `ed` ON `ed`.`ID_EVALUACION_EMPLEADO` = `ee`.`ID_EVALUACION_EMPLEADO`
GROUP BY `ee`.`ID_EVALUACION`, `ee`.`ID_EVALUACION_EMPLEADO`, `ee`.`ID_EMPLEADO`, `e`.`NUMERO_DOCUMENTO`, `e`.`NOMBRES`, `e`.`APELLIDOS`;

-- ============================================================
-- 7. SEED: CATALOGO DE LABORES AGRICOLAS
-- ============================================================
INSERT INTO `bbf_evaluacion_labores` (`CODIGO`,`NOMBRE`,`DESCRIPCION`,`PONDERACION_MAXIMA_DEFAULT`,`ORDEN`,`ACTIVO`) VALUES
('DESBOTONE','Desbotone','Labor de desbotone',50.00,1,1),
('GUIADA_TALLOS','Guiada de Tallos','Labor de guiada de tallos',50.00,2,1),
('PROGRAMACIONES','Programaciones','Labor de programaciones',50.00,3,1),
('PINCH_BASALES','Pinch Basales','Labor de pinch basales',50.00,4,1),
('DESCHUPONE','Deschupone','Labor de deschupone',50.00,5,1),
('DESHIERBE','Deshierbe','Labor de deshierbe',50.00,6,1),
('PALO_SECO','Palo Seco','Labor de palo seco',50.00,7,1),
('BARRIDA','Barrida','Labor de barrida',50.00,8,1),
('ENMALLE','Enmalle','Labor de enmalle',50.00,9,1),
('REPORTE_FITO','Reporte Fito','Reporte fitosanitario',50.00,10,1);

-- ============================================================
-- 8. PROCEDIMIENTOS ALMACENADOS
-- ============================================================

DELIMITER ;;

-- 8.1 Crear evaluacion semanal
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_EVALUACION_CREAR`(
    IN P_NUMERO_SEMANA INT,
    IN P_NOMBRE_SEMANA VARCHAR(100),
    IN P_ANIO SMALLINT,
    IN P_FECHA_INICIO DATE,
    IN P_FECHA_FIN DATE,
    IN P_OBSERVACIONES TEXT,
    IN P_ID_USUARIO INT
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM `bbf_usuarios` WHERE `ID_USUARIO` = P_ID_USUARIO) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario creador no existe.';
    END IF;
    IF P_FECHA_FIN IS NOT NULL AND P_FECHA_FIN < P_FECHA_INICIO THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La fecha fin no puede ser anterior a la fecha inicio.';
    END IF;
    IF P_NUMERO_SEMANA < 1 OR P_NUMERO_SEMANA > 53 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Numero de semana invalido (1-53).';
    END IF;

    INSERT INTO `bbf_evaluaciones` (
        `ANIO`, `NUMERO_SEMANA`, `NOMBRE_SEMANA`, `FECHA_INICIO`, `FECHA_FIN`,
        `OBSERVACIONES`, `ID_USUARIO_CREA`
    ) VALUES (
        P_ANIO, P_NUMERO_SEMANA, NULLIF(TRIM(P_NOMBRE_SEMANA), ''), P_FECHA_INICIO, P_FECHA_FIN,
        NULLIF(TRIM(P_OBSERVACIONES), ''), P_ID_USUARIO
    );

    SELECT * FROM `bbf_evaluaciones` WHERE `ID_EVALUACION` = LAST_INSERT_ID();
END ;;

-- 8.2 Agregar un empleado individual
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_EVALUACION_EMPLEADO_AGREGAR`(
    IN P_ID_EVALUACION INT,
    IN P_ID_EMPLEADO INT,
    IN P_OBSERVACIONES TEXT,
    IN P_ID_USUARIO INT
)
BEGIN
    DECLARE V_ESTADO VARCHAR(20);

    IF NOT EXISTS (SELECT 1 FROM `bbf_empleados` WHERE `ID_EMPLEADO` = P_ID_EMPLEADO AND `ELIMINADO` = 0) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El empleado no existe o fue eliminado.';
    END IF;

    SELECT `ESTADO` INTO V_ESTADO FROM `bbf_evaluaciones`
    WHERE `ID_EVALUACION` = P_ID_EVALUACION AND `ELIMINADO` = 0 LIMIT 1;

    IF V_ESTADO IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La evaluacion no existe o fue eliminada.';
    END IF;
    IF V_ESTADO IN ('COMPLETADA','CERRADA') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se pueden agregar empleados a una evaluacion cerrada/completada.';
    END IF;

    INSERT INTO `bbf_evaluacion_empleados` (`ID_EVALUACION`,`ID_EMPLEADO`,`ESTADO_EVALUACION`,`OBSERVACIONES`,`ID_REGISTRADO_POR`)
    VALUES (P_ID_EVALUACION, P_ID_EMPLEADO, 'PENDIENTE', NULLIF(TRIM(P_OBSERVACIONES), ''), P_ID_USUARIO)
    ON DUPLICATE KEY UPDATE `OBSERVACIONES` = VALUES(`OBSERVACIONES`);

    SELECT `ee`.*, `e`.`NUMERO_DOCUMENTO`, CONCAT_WS(' ', `e`.`NOMBRES`, `e`.`APELLIDOS`) AS `EMPLEADO`, `e`.`ESTADO_EMPLEADO`
    FROM `bbf_evaluacion_empleados` `ee`
    INNER JOIN `bbf_empleados` `e` ON `e`.`ID_EMPLEADO` = `ee`.`ID_EMPLEADO`
    WHERE `ee`.`ID_EVALUACION` = P_ID_EVALUACION AND `ee`.`ID_EMPLEADO` = P_ID_EMPLEADO;
END ;;

-- 8.3 Agregar todos los empleados activos (patron capacitaciones)
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_EVALUACION_AGREGAR_EMPLEADOS_TODOS`(
    IN P_ID_EVALUACION INT,
    IN P_ID_USUARIO INT,
    OUT P_INSERTADOS INT,
    OUT P_OMITIDOS_DUPLICADOS INT,
    OUT P_MENSAJE VARCHAR(500)
)
BEGIN
    DECLARE V_ESTADO VARCHAR(20);

    SELECT `ESTADO` INTO V_ESTADO FROM `bbf_evaluaciones`
    WHERE `ID_EVALUACION` = P_ID_EVALUACION AND `ELIMINADO` = 0 LIMIT 1;

    IF V_ESTADO IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La evaluacion no existe o fue eliminada.';
    END IF;
    IF V_ESTADO IN ('COMPLETADA','CERRADA') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se pueden agregar empleados a una evaluacion cerrada/completada.';
    END IF;

    -- Contar omitidos ANTES de insertar (empleados activos que ya estaban asignados)
    SELECT COUNT(*) INTO P_OMITIDOS_DUPLICADOS
    FROM `bbf_empleados` `E`
    WHERE `E`.`ESTADO_EMPLEADO` = 'ACTIVO'
      AND `E`.`ELIMINADO` = 0
      AND EXISTS (
          SELECT 1 FROM `bbf_evaluacion_empleados` `EE`
          WHERE `EE`.`ID_EVALUACION` = P_ID_EVALUACION AND `EE`.`ID_EMPLEADO` = `E`.`ID_EMPLEADO`
      );

    INSERT INTO `bbf_evaluacion_empleados` (
        `ID_EVALUACION`, `ID_EMPLEADO`, `ESTADO_EVALUACION`, `OBSERVACIONES`, `ID_REGISTRADO_POR`
    )
    SELECT
        P_ID_EVALUACION,
        `E`.`ID_EMPLEADO`,
        'PENDIENTE',
        CONCAT('Agregado masivo: ', DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s')),
        P_ID_USUARIO
    FROM `bbf_empleados` `E`
    WHERE `E`.`ESTADO_EMPLEADO` = 'ACTIVO'
      AND `E`.`ELIMINADO` = 0
      AND NOT EXISTS (
          SELECT 1 FROM `bbf_evaluacion_empleados` `EE`
          WHERE `EE`.`ID_EVALUACION` = P_ID_EVALUACION AND `EE`.`ID_EMPLEADO` = `E`.`ID_EMPLEADO`
      );

    SET P_INSERTADOS = ROW_COUNT();

    SET P_MENSAJE = CONCAT('Proceso completado: ', P_INSERTADOS, ' empleados agregados, ', P_OMITIDOS_DUPLICADOS, ' ya participaban.');

    SELECT `EE`.*, `E`.`NUMERO_DOCUMENTO`, CONCAT_WS(' ', `E`.`NOMBRES`, `E`.`APELLIDOS`) AS `EMPLEADO`, `E`.`ESTADO_EMPLEADO`
    FROM `bbf_evaluacion_empleados` `EE`
    INNER JOIN `bbf_empleados` `E` ON `E`.`ID_EMPLEADO` = `EE`.`ID_EMPLEADO`
    WHERE `EE`.`ID_EVALUACION` = P_ID_EVALUACION
    ORDER BY `E`.`NOMBRES`, `E`.`APELLIDOS`;
END ;;

-- 8.4 Registrar / actualizar calificacion por empleado y labor
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_EVALUACION_REGISTRAR_CALIFICACIONES`(
    IN P_ID_EVALUACION INT,
    IN P_ID_EMPLEADO INT,
    IN P_ID_EVALUACION_LABOR INT,
    IN P_VALOR_OBTENIDO DECIMAL(14,2),
    IN P_VALOR_MAXIMO DECIMAL(10,2),
    IN P_OBSERVACIONES VARCHAR(500),
    IN P_ID_USUARIO INT
)
BEGIN
    DECLARE V_ID_EVALUACION_EMPLEADO BIGINT;
    DECLARE V_PONDERACION DECIMAL(10,2);
    DECLARE V_ESTADO VARCHAR(20);

    IF P_VALOR_OBTENIDO IS NULL OR P_VALOR_OBTENIDO < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El valor obtenido no puede ser negativo.';
    END IF;

    SELECT `ESTADO` INTO V_ESTADO FROM `bbf_evaluaciones`
    WHERE `ID_EVALUACION` = P_ID_EVALUACION AND `ELIMINADO` = 0 LIMIT 1;
    IF V_ESTADO IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La evaluacion no existe o fue eliminada.';
    END IF;
    IF V_ESTADO IN ('COMPLETADA','CERRADA') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se pueden registrar calificaciones en una evaluacion cerrada/completada.';
    END IF;

    SELECT `ID_EVALUACION_EMPLEADO` INTO V_ID_EVALUACION_EMPLEADO
    FROM `bbf_evaluacion_empleados`
    WHERE `ID_EVALUACION` = P_ID_EVALUACION AND `ID_EMPLEADO` = P_ID_EMPLEADO LIMIT 1;

    IF V_ID_EVALUACION_EMPLEADO IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El empleado no esta asignado a la evaluacion.';
    END IF;

    SELECT `PONDERACION_MAXIMA_DEFAULT` INTO V_PONDERACION
    FROM `bbf_evaluacion_labores`
    WHERE `ID_EVALUACION_LABOR` = P_ID_EVALUACION_LABOR AND `ACTIVO` = 1 LIMIT 1;

    IF V_PONDERACION IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La labor no existe o esta inactiva.';
    END IF;

    IF P_VALOR_MAXIMO IS NULL THEN
        SET P_VALOR_MAXIMO = V_PONDERACION;
    END IF;

    IF P_VALOR_OBTENIDO > P_VALOR_MAXIMO THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El valor obtenido supera la ponderacion maxima.';
    END IF;

    INSERT INTO `bbf_evaluacion_detalles` (
        `ID_EVALUACION_EMPLEADO`, `ID_EVALUACION_LABOR`, `VALOR_OBTENIDO`,
        `VALOR_MAXIMO`, `OBSERVACIONES`, `ID_EVALUADO_POR`
    ) VALUES (
        V_ID_EVALUACION_EMPLEADO, P_ID_EVALUACION_LABOR, P_VALOR_OBTENIDO,
        P_VALOR_MAXIMO, NULLIF(TRIM(P_OBSERVACIONES), ''), P_ID_USUARIO
    )
    ON DUPLICATE KEY UPDATE
        `VALOR_OBTENIDO` = VALUES(`VALOR_OBTENIDO`),
        `VALOR_MAXIMO` = VALUES(`VALOR_MAXIMO`),
        `OBSERVACIONES` = VALUES(`OBSERVACIONES`),
        `ID_EVALUADO_POR` = VALUES(`ID_EVALUADO_POR`),
        `UPDATED_AT` = CURRENT_TIMESTAMP;

    UPDATE `bbf_evaluacion_empleados`
    SET `ESTADO_EVALUACION` = 'EN_PROCESO'
    WHERE `ID_EVALUACION_EMPLEADO` = V_ID_EVALUACION_EMPLEADO
      AND `ESTADO_EVALUACION` IN ('PENDIENTE');

    SELECT `d`.*, `l`.`NOMBRE` AS `LABOR`, `l`.`CODIGO` AS `CODIGO_LABOR`
    FROM `bbf_evaluacion_detalles` `d`
    INNER JOIN `bbf_evaluacion_labores` `l` ON `l`.`ID_EVALUACION_LABOR` = `d`.`ID_EVALUACION_LABOR`
    WHERE `d`.`ID_EVALUACION_EMPLEADO` = V_ID_EVALUACION_EMPLEADO
      AND `d`.`ID_EVALUACION_LABOR` = P_ID_EVALUACION_LABOR;
END ;;

-- 8.5 Panel gerencial de labores agricolas
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_EVALUACION_PANEL_GERENCIAL_OBTENER`(
    IN P_ID_EVALUACION INT
)
BEGIN
    -- Result set 1: detalle por labor
    SELECT
        `l`.`ID_EVALUACION_LABOR` AS `ID_EVALUACION_LABOR`,
        `l`.`CODIGO` AS `CODIGO`,
        `l`.`NOMBRE` AS `NOMBRE`,
        `l`.`PONDERACION_MAXIMA_DEFAULT` AS `PONDERACION_MAXIMA`,
        COALESCE(SUM(`d`.`VALOR_OBTENIDO`), 0) AS `CAMAS_EJECUTADAS`,
        COALESCE(`m`.`META_CAMAS`, 1168.00) AS `META_CAMAS`,
        CASE
            WHEN COALESCE(`m`.`META_CAMAS`, 1168.00) = 0 THEN 0
            ELSE ROUND(COALESCE(SUM(`d`.`VALOR_OBTENIDO`), 0) / COALESCE(`m`.`META_CAMAS`, 1168.00) * 100, 2)
        END AS `PORCENTAJE_AVANCE`,
        GREATEST(0, COALESCE(`m`.`META_CAMAS`, 1168.00) - COALESCE(SUM(`d`.`VALOR_OBTENIDO`), 0)) AS `CAMAS_PENDIENTES`,
        CASE
            WHEN COALESCE(`m`.`META_CAMAS`, 1168.00) > 0
                 AND COALESCE(SUM(`d`.`VALOR_OBTENIDO`), 0) / COALESCE(`m`.`META_CAMAS`, 1168.00) * 100 >= 100 THEN 'Completado'
            WHEN COALESCE(`m`.`META_CAMAS`, 1168.00) > 0
                 AND COALESCE(SUM(`d`.`VALOR_OBTENIDO`), 0) / COALESCE(`m`.`META_CAMAS`, 1168.00) * 100 >= 50 THEN 'En Proceso'
            WHEN COALESCE(SUM(`d`.`VALOR_OBTENIDO`), 0) > 0 THEN 'Iniciado'
            ELSE 'Sin Iniciar'
        END AS `ESTADO_LABOR`,
        COUNT(DISTINCT `ee`.`ID_EMPLEADO`) AS `TOTAL_EMPLEADOS`
    FROM `bbf_evaluacion_labores` `l`
    LEFT JOIN `bbf_evaluacion_metas_finca` `m`
        ON `m`.`ID_EVALUACION` = P_ID_EVALUACION AND `m`.`ID_EVALUACION_LABOR` = `l`.`ID_EVALUACION_LABOR`
    LEFT JOIN `bbf_evaluacion_empleados` `ee`
        ON `ee`.`ID_EVALUACION` = P_ID_EVALUACION
    LEFT JOIN `bbf_evaluacion_detalles` `d`
        ON `d`.`ID_EVALUACION_EMPLEADO` = `ee`.`ID_EVALUACION_EMPLEADO`
       AND `d`.`ID_EVALUACION_LABOR` = `l`.`ID_EVALUACION_LABOR`
    WHERE `l`.`ACTIVO` = 1
    GROUP BY `l`.`ID_EVALUACION_LABOR`, `l`.`CODIGO`, `l`.`NOMBRE`, `l`.`PONDERACION_MAXIMA_DEFAULT`,
             `l`.`ORDEN`, `m`.`META_CAMAS`
    ORDER BY `l`.`ORDEN`, `l`.`NOMBRE`;

    -- Result set 2: consolidado global de la finca
    SELECT
        (SELECT COALESCE(SUM(`d`.`VALOR_OBTENIDO`), 0)
         FROM `bbf_evaluacion_detalles` `d`
         INNER JOIN `bbf_evaluacion_empleados` `ee` ON `ee`.`ID_EVALUACION_EMPLEADO` = `d`.`ID_EVALUACION_EMPLEADO`
         WHERE `ee`.`ID_EVALUACION` = P_ID_EVALUACION) AS `TOTAL_CAMAS_EJECUTADAS`,
        (SELECT COALESCE(SUM(COALESCE(`m`.`META_CAMAS`, 1168.00)), 0)
         FROM `bbf_evaluacion_labores` `l`
         LEFT JOIN `bbf_evaluacion_metas_finca` `m`
            ON `m`.`ID_EVALUACION` = P_ID_EVALUACION AND `m`.`ID_EVALUACION_LABOR` = `l`.`ID_EVALUACION_LABOR`
         WHERE `l`.`ACTIVO` = 1) AS `TOTAL_META_CAMAS`,
        CASE
            WHEN (SELECT COALESCE(SUM(COALESCE(`m`.`META_CAMAS`, 1168.00)), 0)
                  FROM `bbf_evaluacion_labores` `l`
                  LEFT JOIN `bbf_evaluacion_metas_finca` `m`
                    ON `m`.`ID_EVALUACION` = P_ID_EVALUACION AND `m`.`ID_EVALUACION_LABOR` = `l`.`ID_EVALUACION_LABOR`
                  WHERE `l`.`ACTIVO` = 1) = 0 THEN 0
            ELSE ROUND(
                (SELECT COALESCE(SUM(`d`.`VALOR_OBTENIDO`), 0)
                 FROM `bbf_evaluacion_detalles` `d`
                 INNER JOIN `bbf_evaluacion_empleados` `ee` ON `ee`.`ID_EVALUACION_EMPLEADO` = `d`.`ID_EVALUACION_EMPLEADO`
                 WHERE `ee`.`ID_EVALUACION` = P_ID_EVALUACION)
                /
                (SELECT COALESCE(SUM(COALESCE(`m`.`META_CAMAS`, 1168.00)), 0)
                 FROM `bbf_evaluacion_labores` `l`
                 LEFT JOIN `bbf_evaluacion_metas_finca` `m`
                    ON `m`.`ID_EVALUACION` = P_ID_EVALUACION AND `m`.`ID_EVALUACION_LABOR` = `l`.`ID_EVALUACION_LABOR`
                 WHERE `l`.`ACTIVO` = 1) * 100, 2)
        END AS `PORCENTAJE_COBERTURA_GLOBAL`,
        CASE
            WHEN (SELECT COALESCE(SUM(COALESCE(`m`.`META_CAMAS`, 1168.00)), 0)
                  FROM `bbf_evaluacion_labores` `l`
                  LEFT JOIN `bbf_evaluacion_metas_finca` `m`
                    ON `m`.`ID_EVALUACION` = P_ID_EVALUACION AND `m`.`ID_EVALUACION_LABOR` = `l`.`ID_EVALUACION_LABOR`
                  WHERE `l`.`ACTIVO` = 1) > 0
                 AND (SELECT COALESCE(SUM(`d`.`VALOR_OBTENIDO`), 0)
                      FROM `bbf_evaluacion_detalles` `d`
                      INNER JOIN `bbf_evaluacion_empleados` `ee` ON `ee`.`ID_EVALUACION_EMPLEADO` = `d`.`ID_EVALUACION_EMPLEADO`
                      WHERE `ee`.`ID_EVALUACION` = P_ID_EVALUACION)
                    /
                    (SELECT COALESCE(SUM(COALESCE(`m`.`META_CAMAS`, 1168.00)), 0)
                     FROM `bbf_evaluacion_labores` `l`
                     LEFT JOIN `bbf_evaluacion_metas_finca` `m`
                       ON `m`.`ID_EVALUACION` = P_ID_EVALUACION AND `m`.`ID_EVALUACION_LABOR` = `l`.`ID_EVALUACION_LABOR`
                     WHERE `l`.`ACTIVO` = 1) * 100 >= 100 THEN 'Meta Cumplida'
            ELSE 'En Ejecución'
        END AS `ESTADO_CONSOLIDADO`,
        (SELECT COUNT(*) FROM `bbf_evaluacion_empleados` WHERE `ID_EVALUACION` = P_ID_EVALUACION) AS `TOTAL_EMPLEADOS`;
END ;;

DELIMITER ;

/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
