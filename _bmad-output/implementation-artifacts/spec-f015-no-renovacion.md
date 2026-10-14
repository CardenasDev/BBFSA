---
title: 'BBTH-F-015 Carta de no renovación de contrato a término fijo'
type: 'feature'
created: '2026-10-14'
status: 'implemented'
route: 'dispatch'
---

## Intent

**Problem:** BBTH-F-015 existía en el catálogo (`NO_RENOVACION_CONTRATO`, deshabilitado, sin renderizador) pero no había motor de consulta, vista previa ni generación PDF. Es una notificación al colaborador de que su contrato a término fijo no será prorrogado. No debe mezclarse con las plantillas contractuales F-015.

**Approach:** Nueva pestaña **F-015** en Certificados, reutilizando el motor documental: servicio propio de solo lectura con contrato seleccionable, renderer institucional extendido, endpoints con permiso `CONTRATACION_VER`, y UI con el mismo diseño de tabs. Un campo manual: NIT precargado (sin parámetro NIT en el sistema).

## Boundaries & Constraints

**Always:** Permiso `CONTRATACION_VER`; empleado existente (sin validar estado); contrato del empleado, ACTIVO y a término fijo (`tipo_contrato` contiene "fijo"); fechas de suscripción y vencimiento oficiales válidas; NIT suministrado con formato; empresa/ciudad y firmantes de parámetros; estructura y textos fieles al DOCX oficial.

**Never:** Generar para contratos indefinidos, obra/labor u otros tipos; inventar fechas, NIT o contratos; modificar registros; Eloquent; SQL automático; QA/PROD; commits automáticos; duplicar el componente; nueva opción en el menú; mezclar con plantillas contractuales F-015.

## Decisiones aplicadas (derivadas del DOCX y los datos)

| Decisión | Valor |
|----------|-------|
| Contrato | Seleccionable en frontend (dropdown de contratos del empleado) |
| Elegibilidad | Solo `tipo_contrato` con "fijo" + `estado_contrato` ACTIVO + `fecha_fin` válida |
| NIT | Manual precargado `900747203` (formato del DOCX, sin DV; sin parámetro en el sistema) |
| Preaviso 30 días | No validado (evita bloqueos; la carta enuncia la regla) |
| Encabezado de género | `Señor(a):` neutral (el DOCX dice `Señora:` por ser ejemplo) |
| Estado del empleado | Solo existencia |

## Fuentes de datos

| Dato | Fuente | Método |
|------|--------|--------|
| Nombre | Empleados | `EmployeeRepository::find` |
| Contrato/tipo/fechas | `bbf_empleado_contratos` | `ContractingRepository::getContractGenerationData` |
| NIT | Frontend (validado, no persistido) | `supplied` |
| Empresa/ciudad | Parámetros | `getCurrentParameter` |
| Firmantes | Catálogo `FIRMANTES_JSON` + parámetros | `getCurrentParameter` JSON |
| Código/versión/vigencia | `bbf_documento_formatos` | `CertificateRepository` |

## Fidelidad al DOCX oficial (verificado 2026-10-14)

Texto extraído de `BBTH-F-015 FORMATO DE NO RENOVACION DE CONTRATO.docx` y reproducido en `contractNonRenewalBlocks()`:

1. `Señor(a):` + nombre en negrita + `<ciudad>.`
2. `Referencia: Notificación de no renovación de contrato de trabajo a término fijo`.
3. Notificación con razón social, NIT, suscripción, vencimiento y `NO será prorrogado ni renovado`.
4. Fundamento del artículo 46 CST y preaviso de 30 días (literal).
5. Liquidación definitiva al vencimiento (literal) + agradecimiento (literal).
6. `Cordialmente,` + firmante(s) de configuración.

## GAP detectados

| GAP | Estado |
|-----|--------|
| `FIRMANTES_JSON` de F-015 estaba NULL | Cubierto por `BD/20261013_f015_habilitacion.sql` (copia desde F-002) |
| Sin parámetro NIT en el sistema | NIT manual precargado con el valor del documento |
| Sin validación del preaviso de 30 días | No implementada a propósito para no bloquear; documentado |

## Archivos

### Backend (nuevos/modificados)
- `Back/app/Services/ContractNonRenewalService.php` (nuevo, con contrato seleccionable)
- `Back/app/Services/CertificateRenderer.php` (`contractNonRenewalBlocks`)
- `Back/app/Http/Controllers/Api/CertificateController.php` (3 endpoints + `nonRenewalRules`)
- `Back/routes/api.php` (3 rutas `non-renewal` antes de `{formatKey}`)
- `Back/tests/Feature/ContractNonRenewalApiTest.php` (nuevo, 8 pruebas)
- `Back/tests/Unit/CertificateRendererTest.php` (+1 prueba F-015)

### Frontend
- `Front/src/app/core/services/contracting.service.ts` (+3 métodos)
- `Front/src/app/features/contracting/contracting-certificates.component.ts` (tab F-015, selector de contrato, NIT precargado, `generateNonRenewal`, descarga con nombre F-015)

### BD (pendiente de ejecución manual en DEV)
- `BD/20261013_f015_habilitacion.sql` (idempotente: renderizador, habilitación, firmantes desde F-002, verificación)

## Evidencia de pruebas (2026-10-14)

- `ContractNonRenewalApiTest`: **8 passed (87 assertions)** — catálogo, generación, tipo no-fijo rechazado, sin fecha fin, contrato ajeno/inactivo, validación, descarga PDF.
- `CertificateRendererTest`: **17 passed (685 assertions)** (16 previas + 1 F-015).
- Regresión: F-002 **22 passed**, F-004 **8 passed**, F-005 **11 passed**, F-011 **8 passed**, F-012 **7 passed**.
- `npm run build`: **exitoso**.
- `npm test`: no ejecutado (requiere @vitest/browser-playwright no disponible en el entorno).

## Revisiones BMAD

- **Técnica:** servicio de solo lectura sin Eloquent; renderer reutiliza encabezado, marca de agua, firma, control y paginación; rutas antes de `{formatKey}`; frontend reutiliza señales, vista previa y descarga del mismo contexto confirmado; selector de contrato reutiliza la lista ya cargada.
- **Casos límite:** empleado inexistente (404), contrato ajeno (404), inactivo (422), tipo no-fijo (422), sin fecha fin/inicio (422), NIT inválido (422), formato deshabilitado (404), descarga con nombre F-015.
- **Cobertura:** catálogo, generación, elegibilidad, validación, autorización, descarga PDF, renderizado fiel al DOCX, regresión F-002/F-004/F-005/F-011/F-012 completa.

## Riesgos / pendientes

- El script SQL debe ejecutarse manualmente en DEV (con `SET SQL_SAFE_UPDATES = 0` si el safe mode bloquea); sin eso el tab muestra "No hay cartas de no renovación disponibles".
- Validación visual del PDF con datos reales pendiente en DEV (comparar contra el DOCX oficial).

## Validación manual en DEV

1. Ejecutar `BD/20261013_f015_habilitacion.sql` en DEV y verificar `FIRMANTES_JSON`.
2. Ir a `/admin/contracting/employees/{id}/certificates` → tab **F-015**.
3. Con empleado con contrato fijo activo: seleccionar contrato + NIT → **Generar** → verificar vista previa.
4. **Descargar PDF** → verificar referencia, fechas de suscripción/vencimiento, NIT, firma, marca de agua, paginación.
5. Con contrato indefinido → 422 `tipo_contrato`; sin fecha fin → 422.
