-- Ejecutar solo tras seleccionar y verificar explícitamente la BD destino.
-- No ejecutado por la aplicación. No altera GENERAL ni SALARIO_AFILIACIONES ni inventa firmantes.
-- Corrige SP_BBF_CONTRATACION_CONTRATO_CREAR para que P_TIPO_CARGO_CONTRATO sea opcional (DEFAULT NULL)
-- y mantenga el orden de parámetros compatible con código existente.

DROP PROCEDURE IF EXISTS `SP_BBF_CONTRATACION_CONTRATO_CREAR`;
DELIMITER ;;
CREATE PROCEDURE `SP_BBF_CONTRATACION_CONTRATO_CREAR`(
    IN P_ID_EMPLEADO INT,
    IN P_ID_TIPO_CONTRATO INT,
    IN P_ID_PLANTILLA_CONTRATO INT,
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
    IN P_TIPO_CARGO_CONTRATO VARCHAR(30),  -- Ahora acepta NULL por defecto en llamada
    IN P_OBJETO_OBRA_LABOR TEXT,
    IN P_PRORROGA_DIAS INT,
    IN P_CLAUSULA_FUNCIONES TEXT,
    IN P_JORNADA_LABORAL VARCHAR(150),
    IN P_PERIODO_PRUEBA_DIAS INT,
    IN P_ESTADO_CONTRATO VARCHAR(30),
    IN P_ARCHIVO_CONTRATO_URL VARCHAR(500),
    IN P_OBSERVACIONES TEXT,
    IN P_ID_REGISTRADO_POR INT
)
BEGIN
    DECLARE V_EXISTE INT DEFAULT 0;
    DECLARE V_ID_EMPLEADO_CONTRATO INT;
    DECLARE V_TIPO_CONTRATO_PLANTILLA INT;

    SELECT COUNT(*)
    INTO V_EXISTE
    FROM bbf_empleados
    WHERE ID_EMPLEADO = P_ID_EMPLEADO
      AND IFNULL(ELIMINADO, 0) = 0;

    IF V_EXISTE = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El empleado no existe o fue eliminado.';
    END IF;

    SELECT COUNT(*)
    INTO V_EXISTE
    FROM bbf_tipos_contrato
    WHERE ID_TIPO_CONTRATO = P_ID_TIPO_CONTRATO
      AND ACTIVO = 1;

    IF V_EXISTE = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El tipo de contrato no existe o está inactivo.';
    END IF;

    IF P_ID_PLANTILLA_CONTRATO IS NOT NULL THEN
        SELECT COUNT(*)
        INTO V_EXISTE
        FROM bbf_contrato_plantillas
        WHERE ID_PLANTILLA_CONTRATO = P_ID_PLANTILLA_CONTRATO
          AND IFNULL(ELIMINADO, 0) = 0
          AND ACTIVO = 1;

        IF V_EXISTE = 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La plantilla de contrato no existe o está inactiva.';
        END IF;

        SELECT ID_TIPO_CONTRATO
        INTO V_TIPO_CONTRATO_PLANTILLA
        FROM bbf_contrato_plantillas
        WHERE ID_PLANTILLA_CONTRATO = P_ID_PLANTILLA_CONTRATO
        LIMIT 1;

        IF V_TIPO_CONTRATO_PLANTILLA <> P_ID_TIPO_CONTRATO THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La plantilla seleccionada no corresponde al tipo de contrato.';
        END IF;
    END IF;

    IF P_FECHA_INICIO IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La fecha de inicio del contrato es obligatoria.';
    END IF;

    IF P_FECHA_FIN IS NOT NULL AND P_FECHA_FIN < P_FECHA_INICIO THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La fecha de finalización no puede ser menor a la fecha de inicio.';
    END IF;

    IF P_ESTADO_CONTRATO IS NOT NULL
       AND P_ESTADO_CONTRATO NOT IN ('ACTIVO','VENCIDO','RENOVADO','FINALIZADO','ANULADO') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Estado de contrato no válido.';
    END IF;

    -- Validar tipo_cargo_contrato solo si se proporciona (no es obligatorio)
    IF P_TIPO_CARGO_CONTRATO IS NOT NULL
       AND P_TIPO_CARGO_CONTRATO NOT IN ('ADMINISTRATIVO','OPERATIVO','OTRO') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Tipo de cargo del contrato no válido.';
    END IF;

    INSERT INTO bbf_empleado_contratos (
        ID_EMPLEADO,
        ID_TIPO_CONTRATO,
        ID_PLANTILLA_CONTRATO,
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
        P_ID_PLANTILLA_CONTRATO,
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
        P_TIPO_CARGO_CONTRATO,  -- Se guarda NULL si no viene del frontend
        P_OBJETO_OBRA_LABOR,
        P_PRORROGA_DIAS,
        P_CLAUSULA_FUNCIONES,
        P_JORNADA_LABORAL,
        P_PERIODO_PRUEBA_DIAS,
        P_ESTADO_CONTRATO,
        P_ARCHIVO_CONTRATO_URL,
        P_OBSERVACIONES,
        P_ID_REGISTRADO_POR
    );

    SET V_ID_EMPLEADO_CONTRATO = LAST_INSERT_ID();

    INSERT INTO bbf_log_auditoria (
        ID_USUARIO, MODULO, ACCION, ENTIDAD, ID_ENTIDAD,
        VALORES_ANTERIORES, VALORES_NUEVOS, IP, USER_AGENT, CREATED_AT
    )
    VALUES (
        P_ID_REGISTRADO_POR,
        'CONTRATACION',
        'CONTRATACION_CONTRATO_CREAR',
        'CONTRATO_EMPLEADO',
        V_ID_EMPLEADO_CONTRATO,
        NULL,
        JSON_OBJECT(
            'id_empleado', P_ID_EMPLEADO,
            'id_tipo_contrato', P_ID_TIPO_CONTRATO,
            'id_plantilla_contrato', P_ID_PLANTILLA_CONTRATO,
            'id_area', P_ID_AREA,
            'id_cargo', P_ID_CARGO,
            'fecha_inicio', P_FECHA_INICIO,
            'fecha_fin', P_FECHA_FIN,
            'duracion_meses', P_DURACION_MESES,
            'salario_base', P_SALARIO_BASE,
            'auxilio_transporte', P_AUXILIO_TRANSPORTE,
            'periodo_pago', P_PERIODO_PAGO,
            'lugar_labores', P_LUGAR_LABORES,
            'numero_contrato', P_NUMERO_CONTRATO,
            'tipo_cargo_contrato', P_TIPO_CARGO_CONTRATO,
            'objeto_obra_labor', P_OBJETO_OBRA_LABOR,
            'prorroga_dias', P_PRORROGA_DIAS,
            'clausula_funciones', P_CLAUSULA_FUNCIONES,
            'jornada_laboral', P_JORNADA_LABORAL,
            'periodo_prueba_dias', P_PERIODO_PRUEBA_DIAS,
            'estado_contrato', P_ESTADO_CONTRATO,
            'archivo_contrato_url', P_ARCHIVO_CONTRATO_URL,
            'observaciones', P_OBSERVACIONES
        ),
        'SYSTEM',
        'BACKEND',
        NOW()
    );

    SELECT
        V_ID_EMPLEADO_CONTRATO AS ID_EMPLEADO_CONTRATO,
        ID_EMPLEADO,
        ID_TIPO_CONTRATO,
        ID_PLANTILLA_CONTRATO,
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
        ID_REGISTRADO_POR,
        ELIMINADO,
        CREATED_AT,
        UPDATED_AT
    FROM bbf_empleado_contratos
    WHERE ID_EMPLEADO_CONTRATO = V_ID_EMPLEADO_CONTRATO;
END ;;
DELIMITER ;

-- Verificar la modificación
SHOW CREATE PROCEDURE `SP_BBF_CONTRATACION_CONTRATO_CREAR`;