-- ============================================================================
-- BBF ADMINISTRATIVO - MODULO DE CAPACITACIONES
-- Procedimiento: Agregar todos los empleados activos a una sesión
-- Fecha: 2026-10-21
-- ============================================================================

USE `bbf_administrativo`;

DELIMITER $$

DROP PROCEDURE IF EXISTS `SP_BBF_CAPACITACION_PARTICIPANTES_AGREGAR_TODOS_ACTIVOS`$$

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

END$$

DELIMITER ;

-- ============================================================================
-- VALIDACIÓN RÁPIDA
-- ============================================================================

SELECT 'SP_BBF_CAPACITACION_PARTICIPANTES_AGREGAR_TODOS_ACTIVOS' AS PROCEDIMIENTO,
       ROUTINE_TYPE,
       CREATED,
       LAST_ALTERED
FROM information_schema.ROUTINES
WHERE ROUTINE_SCHEMA = 'bbf_administrativo'
  AND ROUTINE_NAME = 'SP_BBF_CAPACITACION_PARTICIPANTES_AGREGAR_TODOS_ACTIVOS';