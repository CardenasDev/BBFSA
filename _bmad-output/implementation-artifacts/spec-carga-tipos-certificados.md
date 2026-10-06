---
title: 'Carga inicial de tipos documentales'
type: 'chore'
created: '2026-10-06'
status: 'done'
route: 'oneshot'
review_loop_iteration: 0
context: []
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

Entregar un script SQL de carga inicial para los ocho tipos de certificados/cartas de los DOCX en `bbf_administrativo.bbf_documento_formatos`. Cargar nombres, códigos, contexto y metadatos del documento fuente, sin declarar aprobados los formatos ni habilitar renderizadores inexistentes. F-002 tendrá una fila GENERAL de catálogo, pendiente de seleccionar sus variantes; F-004 conserva la versión de encabezado y registra la contradicción con la revisión. No ejecutar en la BD del usuario, no duplicar en reejecución y no sobrescribir ajustes existentes.

</frozen-after-approval>

## Implementation Notes

- Reutilizar tabla y consultas creadas por `BD/20261006_base_documental.sql`. Crear solo `BD/20261006_carga_tipos_certificados.sql`; sin cambios Front/Back ni nuevas tablas/SP.
- Una sentencia INSERT SELECT carga los ocho tipos con comprobación de existencia por clave/variante, incluso si una revisión previa usa otra vigencia. Conflicto concurrente de clave única no debe sobrescribir datos.
- Los nombres/contextos provienen del análisis de DOCX. Vigencia 18/06/2026 corresponde a los encabezados. Firmantes nulos y habilitación cero; notas JSON declaran validación pendiente.
- Árbol no rastreado corresponde al material y análisis autorizado del usuario y se conserva.
- Verificación: diez comprobaciones correctas en instancia temporal MariaDB 10.4.32, sin TCP ni cambios a la BD del usuario. Cobertura de ocho filas, deshabilitación, vigencia, UTF-8, contexto F-011, JSON pendientes, reejecución y preservación exacta de ajustes del cliente.

## Review Triage Log

- Low: listado de verificación puede incluir varias revisiones por clave; es correcto conservarlas. El script lista todas las revisiones GENERAL para inspección, no promete exactamente ocho filas cuando hay un catálogo anterior. Se descarta añadir más consultas para esta carga simple.
- Low, corregido: ROW_COUNT podía contar filas encontradas según cliente en conflictos concurrentes. Alias cambiado a FILAS_AFECTADAS_REPORTADAS y limitación documentada.
- Low, corregido: fecha común necesitaba procedencia. Comentario y JSON registran su extracción de encabezados y validación pendiente.
