-- Ejecute sobre la base seleccionada: bbf_administrativo en DEV o cWeb en QA.

START TRANSACTION;

INSERT INTO bbf_permisos (CODIGO, NOMBRE, DESCRIPCION, MODULO, ACTIVO, CREATED_AT)
SELECT
    'CONTRATACION_EXAMENES_ELIMINAR',
    'Eliminar examen médico',
    'Permite eliminar lógicamente exámenes médicos del empleado',
    'Contratación',
    1,
    NOW()
WHERE NOT EXISTS (
    SELECT 1 FROM bbf_permisos WHERE CODIGO = 'CONTRATACION_EXAMENES_ELIMINAR'
);

UPDATE bbf_permisos
SET ACTIVO = 1,
    NOMBRE = 'Eliminar examen médico',
    DESCRIPCION = 'Permite eliminar lógicamente exámenes médicos del empleado',
    MODULO = 'Contratación'
WHERE CODIGO = 'CONTRATACION_EXAMENES_ELIMINAR';

-- Conserva la política actual: los roles autorizados para editar exámenes
-- reciben también la opción de eliminarlos lógicamente.
INSERT INTO bbf_rol_permisos (ID_ROL, ID_PERMISO, CREATED_AT)
SELECT rp.ID_ROL, permiso_eliminar.ID_PERMISO, NOW()
FROM bbf_rol_permisos rp
INNER JOIN bbf_permisos permiso_editar
    ON permiso_editar.ID_PERMISO = rp.ID_PERMISO
   AND permiso_editar.CODIGO = 'CONTRATACION_EXAMENES_EDITAR'
CROSS JOIN bbf_permisos permiso_eliminar
WHERE permiso_eliminar.CODIGO = 'CONTRATACION_EXAMENES_ELIMINAR'
  AND NOT EXISTS (
      SELECT 1
      FROM bbf_rol_permisos existente
      WHERE existente.ID_ROL = rp.ID_ROL
        AND existente.ID_PERMISO = permiso_eliminar.ID_PERMISO
  );

COMMIT;

SELECT ID_PERMISO, CODIGO, NOMBRE, ACTIVO
FROM bbf_permisos
WHERE CODIGO = 'CONTRATACION_EXAMENES_ELIMINAR';
