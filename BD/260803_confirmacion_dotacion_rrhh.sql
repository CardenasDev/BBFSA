-- ============================================================
-- BBF ADMINISTRATIVO
-- Confirmacion presencial de dotacion por Recursos Humanos
-- Base: bbf_administrativo
-- Fecha: 2026-08-03
-- ============================================================

USE `bbf_administrativo`;

DELIMITER $$

DROP PROCEDURE IF EXISTS `SP_BBF_DOTACION_ENTREGA_CONFIRMAR_POR_RRHH`$$

CREATE PROCEDURE `SP_BBF_DOTACION_ENTREGA_CONFIRMAR_POR_RRHH`(
    IN P_ID_USUARIO_RRHH INT,
    IN P_ID_DOTACION_ENTREGA INT,
    IN P_OBSERVACION_CONFIRMACION VARCHAR(500)
)
BEGIN
    DECLARE V_ESTADO VARCHAR(50) DEFAULT NULL;
    DECLARE V_ELIMINADO TINYINT DEFAULT 0;
    DECLARE V_TOTAL_DETALLES INT DEFAULT 0;
    DECLARE V_DETALLES_SIN_ARTICULO INT DEFAULT 0;

    IF NOT EXISTS (
        SELECT 1
        FROM bbf_usuarios
        WHERE ID_USUARIO = P_ID_USUARIO_RRHH
          AND ESTADO = 'ACTIVO'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El usuario de Recursos Humanos no existe o esta inactivo.';
    END IF;

    SELECT ESTADO, ELIMINADO
    INTO V_ESTADO, V_ELIMINADO
    FROM bbf_dotacion_entregas
    WHERE ID_DOTACION_ENTREGA = P_ID_DOTACION_ENTREGA
    LIMIT 1;

    IF V_ESTADO IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La entrega de dotacion no existe.';
    END IF;

    IF IFNULL(V_ELIMINADO, 0) = 1 OR V_ESTADO = 'ANULADA' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede confirmar una entrega anulada o eliminada.';
    END IF;

    IF V_ESTADO = 'POR_COMPRAR' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La dotacion todavia se encuentra por comprar.';
    END IF;

    IF V_ESTADO = 'ENTREGADA' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La entrega ya fue confirmada anteriormente.';
    END IF;

    IF V_ESTADO <> 'REGISTRADA' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La entrega no se encuentra disponible para confirmacion.';
    END IF;

    SELECT
        COUNT(*),
        COALESCE(SUM(CASE WHEN ID_DOTACION_ARTICULO IS NULL THEN 1 ELSE 0 END), 0)
    INTO V_TOTAL_DETALLES, V_DETALLES_SIN_ARTICULO
    FROM bbf_dotacion_entrega_detalle
    WHERE ID_DOTACION_ENTREGA = P_ID_DOTACION_ENTREGA
      AND IFNULL(ELIMINADO, 0) = 0;

    IF V_TOTAL_DETALLES = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La entrega no contiene articulos para confirmar.';
    END IF;

    IF V_DETALLES_SIN_ARTICULO > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La entrega contiene detalles sin articulo asociado.';
    END IF;

    UPDATE bbf_dotacion_entregas
    SET ESTADO = 'ENTREGADA',
        FECHA_CONFIRMACION = CURRENT_TIMESTAMP,
        ID_CONFIRMADO_POR = P_ID_USUARIO_RRHH,
        OBSERVACION_CONFIRMACION = COALESCE(
            NULLIF(TRIM(P_OBSERVACION_CONFIRMACION), ''),
            'Entrega presencial confirmada por Recursos Humanos.'
        ),
        UPDATED_AT = CURRENT_TIMESTAMP
    WHERE ID_DOTACION_ENTREGA = P_ID_DOTACION_ENTREGA
      AND ESTADO = 'REGISTRADA'
      AND IFNULL(ELIMINADO, 0) = 0;

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
END$$

DELIMITER ;

-- Validacion: debe devolver una fila.
SELECT ROUTINE_NAME
FROM information_schema.ROUTINES
WHERE ROUTINE_SCHEMA = DATABASE()
  AND ROUTINE_NAME = 'SP_BBF_DOTACION_ENTREGA_CONFIRMAR_POR_RRHH';
