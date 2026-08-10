-- Ajuste complementario detectado al validar el archivo real base de pagina.xlsx.
-- Ejecutar una sola vez en bbf_administrativo antes de importar los empleados.
USE `bbf_administrativo`;

INSERT INTO `bbf_cargos` (`NOMBRE`, `DESCRIPCION`, `ACTIVO`)
VALUES
    ('Asesor Legal', 'Cargo recibido en la base inicial del cliente.', 1),
    ('Auxiliar administrativo', 'Cargo recibido en la base inicial del cliente.', 1),
    ('Gerente general', 'Cargo recibido en la base inicial del cliente.', 1),
    ('Jefe de poscosecha', 'Cargo recibido en la base inicial del cliente.', 1),
    ('Coordinador administrativo', 'Cargo recibido en la base inicial del cliente.', 1),
    ('Coordinador contable', 'Cargo recibido en la base inicial del cliente.', 1),
    ('Jardinero', 'Cargo recibido en la base inicial del cliente.', 1),
    ('Monitor', 'Cargo recibido en la base inicial del cliente.', 1),
    ('Operario', 'Cargo recibido en la base inicial del cliente.', 1),
    ('Pasante del SENA', 'Cargo recibido en la base inicial del cliente.', 1),
    ('Servicios generales', 'Cargo recibido en la base inicial del cliente.', 1),
    ('Supervisor de calidad', 'Cargo recibido en la base inicial del cliente.', 1),
    ('Supervisor de poscosecha', 'Cargo recibido en la base inicial del cliente.', 1),
    ('Supervisor general', 'Cargo recibido en la base inicial del cliente.', 1)
ON DUPLICATE KEY UPDATE
    `ACTIVO` = 1,
    `UPDATED_AT` = CURRENT_TIMESTAMP;

INSERT INTO `bbf_entidades_seguridad_social`
    (`TIPO_ENTIDAD`, `NOMBRE`, `NIT`, `ACTIVO`)
VALUES
    ('EPS', 'Aliansalud EPS', NULL, 1),
    ('EPS', 'Mutual Ser EPS', NULL, 1),
    ('EPS', 'Salud Total EPS', NULL, 1),
    ('PENSION', 'Colfondos', NULL, 1),
    ('CAJA_COMPENSACION', 'Colsubsidio', NULL, 1)
ON DUPLICATE KEY UPDATE
    `ACTIVO` = 1,
    `UPDATED_AT` = CURRENT_TIMESTAMP;

SELECT COUNT(*) AS `CARGOS_CLIENTE_ACTIVOS`
FROM `bbf_cargos`
WHERE `ACTIVO` = 1
  AND `NOMBRE` IN (
      'Asesor Legal', 'Auxiliar administrativo', 'Gerente general',
      'Jefe de poscosecha', 'Coordinador administrativo', 'Coordinador contable',
      'Jardinero', 'Monitor', 'Operario', 'Pasante del SENA',
      'Servicios generales', 'Supervisor de calidad',
      'Supervisor de poscosecha', 'Supervisor general'
  );

SELECT COUNT(*) AS `ENTIDADES_CLIENTE_ACTIVAS`
FROM `bbf_entidades_seguridad_social`
WHERE `ACTIVO` = 1
  AND (`TIPO_ENTIDAD`, `NOMBRE`) IN (
      ('EPS', 'Aliansalud EPS'),
      ('EPS', 'Mutual Ser EPS'),
      ('EPS', 'Salud Total EPS'),
      ('PENSION', 'Colfondos'),
      ('CAJA_COMPENSACION', 'Colsubsidio')
  );

-- Resultados esperados:
-- CARGOS_CLIENTE_ACTIVOS = 14
-- ENTIDADES_CLIENTE_ACTIVAS = 5
