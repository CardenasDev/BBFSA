---
title: 'Script SQL de base documental'
type: 'feature'
created: '2026-10-06'
status: 'done'
route: 'oneshot'
review_loop_iteration: 0
context: []
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

Entregar el script solicitado para crear `bbf_documento_formatos` y los SP `SP_BBF_DOCUMENTO_FORMATOS_LISTAR` y `SP_BBF_DOCUMENTO_FORMATO_OBTENER`. Reutilizar parámetros existentes; no crear registro de emisiones. Entregar objetos vacíos, sin convertir datos de ejemplo en configuración oficial ni ejecutar el script en una BD de negocio. El catálogo permite variantes, metadatos de control, referencia a firmantes y clave de renderizador; solo devuelve filas habilitadas y vigentes. Obtener detecta ausencia o ambigüedad y listar detecta variantes vigentes superpuestas. El código impreso no es identidad global.

</frozen-after-approval>

## Implementation Notes

- Ruta pequeña: un script de objetos y documentación de ejecución, sin cambios BE/Front ni migración ejecutada. Evidencia previa en `validacion-bd-base-documental.md`.
- Los archivos no rastreados ya pertenecen a las definiciones del usuario y al análisis autorizado; se conservan. No se modifica la rama Dev ni se hacen commits.
- MySQL/MariaDB: seguir utf8mb4_unicode_ci, InnoDB, DELIMITER y SIGNAL de los SQL existentes; sin DEFINER fijo. Fecha de consulta explícita para resolver vigencia.
- Reejecución: CREATE TABLE IF NOT EXISTS sin borrar datos y reemplazo explícito de los dos SP propios. No es rollback transaccional: DDL tiene commits implícitos. Un esquema existente incompatible debe revisarse; no migrarlo silenciosamente.
- Entregados `BD/20261006_base_documental.sql` y guía homónima `.md`. El catálogo queda vacío. No hay cambios de backend, frontend o BD de negocio.
- Verificación: 24 comprobaciones pasaron en MariaDB 10.4.32 temporal, mediante named pipe sin TCP ni servicio Windows. Prueba de creación, reejecución con conservación de filas, vigencias límite, flags, JSON/intervalos/claves inválidos, ambigüedad y limpieza temporal. La instancia se apagó. El motor evidenciado del destino es MariaDB 10.11; no se validó despliegue en ese ambiente.
- uv 0.12.23 instalado para el usuario en `.local/share/uv-bootstrap`, directorio `bin` añadido al PATH de usuario. Activación real del renderizador BMAD exitosa usando Python 3.12 del runtime.

## Review Triage Log

- Medium, corregido: lecturas separadas podían observar distintas versiones del catálogo. Ahora una materialización temporal privada alimenta validación y resultado; se limpia ante éxito/error y se documenta CREATE TEMPORARY TABLES.
- Medium, corregido: claves con espacios periféricos no eran recuperables al normalizar argumentos. CHECK de longitudes de bytes impide persistir esos espacios; probado con error de constraint.
- Low, corregido: encabezado omitía EXECUTE para CALL e invocadores. Se documentaron permisos de instalación y consumo, además de pérdida de grants específicos al reemplazar rutinas.
