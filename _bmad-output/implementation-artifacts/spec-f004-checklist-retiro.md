---
title: 'BBTH-F-004 Check list de retiro entregado a excolaborador'
type: 'feature'
created: '2026-10-13'
status: 'implemented'
route: 'dispatch'
---

## Intent

**Problem:** BBTH-F-004 existía en el catálogo (`CONSTANCIA_ENTREGA_RETIRO`, deshabilitado, sin renderizador) pero no había motor de consulta, vista previa ni generación PDF. El módulo de Retiros solo imprimía HTML básico sin los campos de la plantilla.

**Approach:** Nueva pestaña **F-004** en Certificados, reutilizando el motor documental F-002/F-003: servicio propio de solo lectura, renderer institucional extendido, endpoints con permiso `CONTRATACION_VER`, y UI con el mismo diseño de tabs. Sin campos manuales: el checklist no requiere datos suministrados.

## Boundaries & Constraints

**Always:** Permiso `CONTRATACION_VER`; retiro registrado y no cancelado del mismo empleado; datos oficiales de empleado, cargo, motivo y fecha; empresa/ciudad y firmantes de parámetros; estructura y textos fieles al DOCX oficial; motivo real como respuesta de la entrevista y referencia de terminación adaptada; no exigir empleado ACTIVO (RRHH controla el estado manualmente).

**Never:** Registrar entregas, alterar el retiro o el estado del empleado; afirmar entregas efectuadas sin evidencia; copiar datos del DOCX de ejemplo; consecutivos; Eloquent; SQL automático; QA/PROD; commits automáticos; duplicar el componente de certificados.

## Fuentes de datos

| Dato | Fuente | Método |
|------|--------|--------|
| Nombre/identidad | Empleados + retiro | `RetirementChecklistService::generationData` |
| Cargo | Retiro, fallback a contrato ACTIVO | `ContractingRepository::listContracts` |
| Motivo terminación | `bbf_motivos_retiro` vía retiro | `RetirementRepository::detail` |
| Fecha expedición | Sistema (Bogotá) | `CarbonImmutable` |
| Empresa/ciudad | Parámetros | `getCurrentParameter` |
| Firmantes | Catálogo `FIRMANTES_JSON` + parámetros | `getCurrentParameter` JSON |
| Código/versión/vigencia | `bbf_documento_formatos` | `CertificateRepository` |

## Fidelidad al DOCX oficial (verificado 2026-10-13)

Texto extraído del documento real `BBTH-F-004 CHECK LIST DE RETIRO...ENTREGADO A EXCOLABORADOR.docx` y reproducido en `retirementChecklistBlocks()`:

1. `Señor(a)` + nombre en negrita + `Cargo <cargo>`.
2. Intro: "Por medio de la presente, nos permitimos hacer entrega formal de los documentos correspondientes a la finalización de su relación laboral con `<razón social del parámetro>`."
3. Cinco apartados con su descripción institucional:
   - Certificado laboral (tiempo de servicio, cargo y funciones).
   - Planilla de seguridad social (últimos tres meses de aportes).
   - Carta de aceptación de renuncia **o** notificación de terminación según el motivo real registrado.
   - Examen de egreso (remisión).
   - Entrevista (pregunta) + motivo registrado como respuesta.
4. Agradecimiento institucional literal del DOCX.
5. `Para constancia firma,` + firmante(s) de configuración (los nombres del ejemplo no se usan como valores fijos).

## Reglas implementadas

1. Retiro debe existir, pertenecer al empleado y no estar CANCELADO (422 si cancelado, 404 si ajeno/inexistente).
2. Sin validación de `estado_empleado = ACTIVO` (difiere de F-002 a propósito).
3. Cargo con fallback: retiro → contrato ACTIVO listado.
4. Motivo obligatorio; referencia del ítem 3 adaptada: contiene "renuncia" → "Carta de aceptación de renuncia"; si no, "Documento de terminación aplicable (motivo)".
5. Ítems con marcador `( )` y cierre neutral: constancia de revisión, sin certificar entregas no evidenciadas.
6. Solo lectura: no persiste nada, no modifica retiro ni empleado.

## GAP detectados

| GAP | Estado |
|-----|--------|
| `FIRMANTES_JSON` de F-004 estaba NULL (el registro se creó sin copiar firmantes) | Resuelto en DEV copiando desde F-002; script `BD/20261013_f004_habilitacion.sql` lo incluye |
| Versión 01 en encabezado vs 02 en control documental (observación del SQL de carga) | Documentado; no se altera la versión, se usan metadatos del catálogo |
| Sin fuente de confirmación de entrega documental | El documento es carta de entrega formal; la firma del funcionario es el mecanismo de constancia (fiel al DOCX) |
| DOCX de referencia con caracteres especiales en el nombre dificultó la extracción automática | Resuelto: contenido extraído del DOCX real y reproducido literalmente |

## Archivos

### Backend (nuevos/modificados)
- `Back/app/Services/RetirementChecklistService.php` (nuevo)
- `Back/app/Services/CertificateRenderer.php` (`retirementChecklistBlocks` + `terminationDocumentDescription`)
- `Back/app/Http/Controllers/Api/CertificateController.php` (3 endpoints checklist)
- `Back/routes/api.php` (3 rutas checklist antes de `{formatKey}`)
- `Back/tests/Feature/RetirementChecklistApiTest.php` (nuevo, 8 pruebas)
- `Back/tests/Unit/CertificateRendererTest.php` (+2 pruebas F-004)

### Frontend
- `Front/src/app/core/services/contracting.service.ts` (+3 métodos checklist)
- `Front/src/app/features/contracting/contracting-certificates.component.ts` (tab F-004, tabla, `generateChecklist`, descarga con nombre F-004)

### BD (pendiente de ejecución manual en DEV)
- `BD/20261013_f004_habilitacion.sql` (idempotente: renderizador, habilitación, firmantes desde F-002, verificación)

## Evidencia de pruebas (2026-10-13)

- `RetirementChecklistApiTest`: **8 passed (86 assertions)**
- `CertificateRendererTest`: **12 passed (653 assertions)** (10 previas + 2 F-004)
- `CertificateApiTest` (regresión F-002): **22 passed (272 assertions)**
- `npm run build`: **exitoso**
- `npm test`: no ejecutado (requiere @vitest/browser-playwright no disponible en el entorno)

## Revisiones BMAD

- **Técnica:** servicio de solo lectura sin Eloquent; renderer reutiliza encabezado, marca de agua, firma, control y paginación; rutas checklist antes de `{formatKey}` para evitar captura del segmento literal; frontend reutiliza señales, vista previa y descarga del mismo contexto confirmado.
- **Casos límite:** retiro inexistente (404), ajeno (404), cancelado (422), fecha futura (422), cargo/motivo ausentes (422 con fallback a contrato ACTIVO), formato deshabilitado (404), descarga con nombre F-004.
- **Cobertura:** catálogo, generación, validación, autorización, descarga PDF, renderizado (5 apartados con descripción, motivo como respuesta de entrevista, referencia adaptada renuncia/terminación, cierre fiel al DOCX), regresión F-002 completa.

## Riesgos / pendientes

- El script SQL debe ejecutarse manualmente en DEV y luego habilitar la variante; sin eso el tab muestra "No hay checklist de retiro disponibles".
- Validación visual del PDF con datos reales pendiente en DEV (comparar contra el DOCX oficial).

## Validación manual en DEV

1. Ejecutar `BD/20261013_f004_habilitacion.sql` en DEV y verificar `FIRMANTES_JSON` poblado.
2. Ir a `/admin/contracting/employees/{id}/certificates` → tab **F-004**.
3. Seleccionar empleado con retiro registrado → **Generar** → verificar vista previa (nombre, cargo, motivo, fecha).
4. **Descargar PDF** → verificar encabezado BBTH-F-004, 5 ítems con `( )`, cierre neutral, firma, marca de agua, paginación.
5. Probar con empleado sin retiro → error claro; con retiro cancelado → 422.
