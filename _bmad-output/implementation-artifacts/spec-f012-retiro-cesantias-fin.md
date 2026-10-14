---
title: 'BBTH-F-012 Carta de retiro de cesantías por finalización de contrato'
type: 'feature'
created: '2026-10-14'
status: 'implemented'
route: 'dispatch'
---

## Intent

**Problem:** BBTH-F-012 existía en el catálogo (`CESANTIAS_FIN_CONTRATO`, deshabilitado, sin renderizador) pero no había motor de consulta, vista previa ni generación PDF. Es una solicitud del trabajador al fondo por terminación del contrato (sin monto, con periodo). El DOCX trae un sello como imagen: se omite y se deja sección de firmas.

**Approach:** Nueva pestaña **F-012** en Certificados, reutilizando el motor documental: servicio propio de solo lectura (sin retiro asociado), renderer institucional extendido, endpoints con permiso `CONTRATACION_VER`, y UI con el mismo diseño de tabs. Cinco campos manuales: periodo (2 fechas), NIT, correo y teléfono (estos tres precargados con los valores del documento).

## Boundaries & Constraints

**Always:** Permiso `CONTRATACION_VER`; empleado existente (sin validar estado); fondo de cesantías oficial obligatorio; periodo válido (hasta ≥ desde, no futuro); NIT con formato dígitos-dv; correo y teléfono válidos; empresa/ciudad y firmantes de parámetros; estructura y textos fieles al DOCX oficial; sello omitido, sección de firmas empleador + trabajador.

**Never:** Inventar periodo, NIT, contacto o fondo; exigir retiro o estado ACTIVO; modificar registros; Eloquent; SQL automático; QA/PROD; commits automáticos; duplicar el componente; nueva opción en el menú.

## Decisiones funcionales aprobadas (2026-10-14)

| Decisión | Valor aprobado |
|----------|----------------|
| Periodo solicitado | Dos fechas manuales en frontend, validadas, no persistidas |
| NIT | Ingresado en frontend, precargado con `900747203-1` (sin parámetro NIT en el sistema) |
| Contacto | Ingresado en frontend, precargado con los valores del documento |
| Sello del DOCX | Omitido (imagen no reproducible en el motor PDF) |
| Sección de firmas | Empleador (config) + trabajador (datos oficiales) |
| Estado del empleado | Solo existencia |

## Fuentes de datos

| Dato | Fuente | Método |
|------|--------|--------|
| Nombre/documento/lugar | Empleados + perfil | `EmployeeRepository::find`, `getProfile` |
| Fondo destinatario | Seguridad social (`fondo_cesantias`) | `ContractingRepository::getSocialSecurity` |
| Periodo/NIT/contacto | Frontend (validados, no persistidos) | `supplied` |
| Empresa/ciudad | Parámetros | `getCurrentParameter` |
| Firmantes | Catálogo `FIRMANTES_JSON` + parámetros | `getCurrentParameter` JSON |
| Código/versión/vigencia | `bbf_documento_formatos` | `CertificateRepository` |

## Fidelidad al DOCX oficial (verificado 2026-10-14)

Texto extraído de `BBTH-F-012  FORMATO DE RETIRO DE CESANTIAS.docx` y reproducido en `cesantiasTerminationBlocks()`:

1. `Señores` + fondo en negrita + `<ciudad>.`
2. `ASUNTO: Retiro Total de Cesantías` (literal con mayúsculas del DOCX).
3. `Estimados señores,` + solicitud con nombre, documento, lugar, fondo, periodo y terminación con razón social y NIT.
4. Contacto con correo y teléfono suministrados.
5. Doble firma (empleador + trabajador). Corrección menor: `solicito` → `solicita` (concordancia gramatical, mismo sentido).

## GAP detectados

| GAP | Estado |
|-----|--------|
| `FIRMANTES_JSON` de F-012 estaba NULL | Cubierto por `BD/20261013_f012_habilitacion.sql` (copia desde F-002) |
| Sin fuente oficial para periodo, NIT ni contacto | Campos manuales validados (decisión aprobada) |
| Sin parámetro NIT en el sistema | NIT manual precargado (decisión aprobada) |
| Sello como imagen en el DOCX | Omitido; sección de firmas en su lugar (instrucción directa) |

## Archivos

### Backend (nuevos/modificados)
- `Back/app/Services/CesantiasTerminationService.php` (nuevo, sin retiro asociado)
- `Back/app/Services/CertificateRenderer.php` (`cesantiasTerminationBlocks`)
- `Back/app/Http/Controllers/Api/CertificateController.php` (3 endpoints + `cesantiasTerminationRules`)
- `Back/routes/api.php` (3 rutas `cesantias-fin-contrato` antes de `{formatKey}`)
- `Back/tests/Feature/CesantiasTerminationApiTest.php` (nuevo, 7 pruebas)
- `Back/tests/Unit/CertificateRendererTest.php` (+1 prueba F-012)

### Frontend
- `Front/src/app/core/services/contracting.service.ts` (+3 métodos)
- `Front/src/app/features/contracting/contracting-certificates.component.ts` (tab F-012, 5 campos con precargas, `generateCesantiasEnd`, descarga con nombre F-012)

### BD (pendiente de ejecución manual en DEV)
- `BD/20261013_f012_habilitacion.sql` (idempotente: renderizador, habilitación, firmantes desde F-002, verificación)

## Evidencia de pruebas (2026-10-14)

- `CesantiasTerminationApiTest`: **7 passed (101 assertions)** — catálogo, generación, validación, periodo invertido/futuro, fondo faltante, descarga PDF.
- `CertificateRendererTest`: **16 passed (679 assertions)** (15 previas + 1 F-012).
- Regresión: F-002 **22 passed**, F-004 **8 passed**, F-005 **11 passed**, F-011 **8 passed**.
- `npm run build`: **exitoso**.
- `npm test`: no ejecutado (requiere @vitest/browser-playwright no disponible en el entorno).

## Revisiones BMAD

- **Técnica:** servicio de solo lectura sin Eloquent y sin dependencia de retiro; renderer reutiliza encabezado, marca de agua, firma, control y paginación; rutas antes de `{formatKey}`; frontend reutiliza señales, vista previa y descarga del mismo contexto confirmado; doble firma secuencial por limitación vertical del motor.
- **Casos límite:** empleado inexistente (404), fondo faltante (422), fechas inválidas/invertidas/futuras (422), NIT/correo/teléfono inválidos (422), formato deshabilitado (404), descarga con nombre F-012.
- **Cobertura:** catálogo, generación, validación quíntuple, autorización, descarga PDF, renderizado fiel al DOCX, regresión F-002/F-004/F-005/F-011 completa.

## Riesgos / pendientes

- El script SQL debe ejecutarse manualmente en DEV (con `SET SQL_SAFE_UPDATES = 0` si el safe mode bloquea); sin eso el tab muestra "No hay cartas de cesantías por finalización disponibles".
- Validación visual del PDF con datos reales pendiente en DEV (comparar contra el DOCX oficial).

## Validación manual en DEV

1. Ejecutar `BD/20261013_f012_habilitacion.sql` en DEV y verificar `FIRMANTES_JSON`.
2. Ir a `/admin/contracting/employees/{id}/certificates` → tab **F-012**.
3. Con empleado con fondo de cesantías: periodo + NIT + contacto (precargados, editables) → **Generar** → verificar vista previa.
4. **Descargar PDF** → verificar destinatario (fondo), ASUNTO, periodo, NIT, contacto, doble firma, marca de agua, paginación.
5. Sin fondo → error `fondo_cesantias`; periodo invertido → 422.
