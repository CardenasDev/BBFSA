-- ============================================================
-- BBF SisAdmin - Borrado logico de evaluaciones semanales
-- ============================================================

DROP PROCEDURE IF EXISTS `SP_BBF_EVALUACION_ELIMINAR`;

DELIMITER ;;

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_EVALUACION_ELIMINAR`(
    IN P_ID_EVALUACION INT,
    IN P_ID_USUARIO INT
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM `bbf_evaluaciones`
        WHERE `ID_EVALUACION` = P_ID_EVALUACION
          AND `ELIMINADO` = 0
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La evaluacion no existe o ya fue eliminada.';
    END IF;

    UPDATE `bbf_evaluaciones`
    SET `ELIMINADO` = 1,
        `UPDATED_AT` = CURRENT_TIMESTAMP
    WHERE `ID_EVALUACION` = P_ID_EVALUACION
      AND `ELIMINADO` = 0;

    SELECT ROW_COUNT() AS `FILAS_AFECTADAS`;
END ;;

DELIMITER ;
