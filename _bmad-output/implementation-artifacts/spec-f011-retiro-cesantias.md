---
title: 'BBTH-F-011 Carta de retiro de cesantías para vivienda'
type: 'feature'
created: '2026-10-14'
status: 'implemented'
route: 'dispatch'
---

## Intent

**Problem:** BBTH-F-011 existía en el catálogo (`CESANTIAS_VIVIENDA`, deshabilitado, sin renderizador) pero no había motor de consulta, vista previa ni generación PDF. Es una carta al fondo de cesantías (no un certificado laboral): autoriza el retiro para vivienda con monto y concepto.

**Approach:** Nueva pestaña **F-011** en Certificados, reutilizando el motor documental: servicio propio de solo lectura (sin retiro asociado), renderer institucional extendido, endpoints con permiso `CONTRATACION_VER`, y UI con el mismo diseño de tabs. Tres campos manuales: modalidad (seleccionable), concepto y monto (decisiones funcionales aprobadas).

## Boundaries & Constraints

**Always:** Permiso `CONTRATACION_VER`; empleado existente (sin validar estado, decisión aprobada); fondo de cesantías oficial obligatorio; modalidad TOTAL o PARCIAL seleccionada; concepto y monto suministrados y validados (monto > 0, ≤2 decimales, reutiliza `SalaryTextFormatter`); empresa/ciudad y firmantes de parámetros; estructura y textos fieles al DOCX oficial.

**Never:** Inventar monto, concepto o fondo; exigir retiro o estado ACTIVO; modificar registros; Eloquent; SQL automático; QA/PROD; commits automáticos; duplicar el componente; nueva opción en el menú.

## Decisiones funcionales aprobadas (2026-10-14)

| Decisión | Valor aprobado |
|----------|----------------|
| Modalidad total/parcial | Seleccionable en frontend (el DOCX se contradice: asunto dice total, cuerpo dice parcial) |
| Monto y concepto | Campos manuales en frontend, validados, no persistidos (sin fuente oficial ni catálogo) |
| Estado del empleado | Solo existencia, sin exigir ACTIVO |

## Fuentes de datos

| Dato | Fuente | Método |
|------|--------|--------|
| Nombre/documento | Empleados | `EmployeeRepository::find` |
| Fondo destinatario | Seguridad social (`fondo_cesantias`) | `ContractingRepository::getSocialSecurity` |
| Modalidad/concepto/monto | Frontend (validados, no persistidos) | `supplied` |
| Empresa/ciudad | Parámetros | `getCurrentParameter` |
| Firmantes | Catálogo `FIRMANTES_JSON` + parámetros | `getCurrentParameter` JSON |
| Código/versión/vigencia | `bbf_documento_formatos` | `CertificateRepository` |

## Fidelidad al DOCX oficial (verificado 2026-10-14)

Texto extraído de `BBTH-F-011 CARTA RETIRO DE CESANTIAS PARA VIVIENDA.docx` y reproducido en `cesantiasWithdrawalBlocks()`:

1. `Señores:` + fondo en negrita + `<ciudad>.`
2. `ASUNTO: Retiro total/parcial de cesantías para mejoras de vivienda` según modalidad.
3. Fundamento legal (Ley 1429 de 2010, Carta Circular 011 de 2011) + autorización con frase según modalidad.
4. Nombres, identificación (`<tipo>. <número>`), concepto y monto en cifra (`$1.500.000,00`).
5. Párrafo de verificación del empleador (literal).
6. `Cordialmente,` + firma del empleador (config) + firma del trabajador (nombre y C.C. oficiales).

## GAP detectados

| GAP | Estado |
|-----|--------|
| `FIRMANTES_JSON` de F-011 estaba NULL | Cubierto por `BD/20261013_f011_habilitacion.sql` (copia desde F-002) |
| Sin fuente oficial para monto ni catálogo de conceptos | Campos manuales validados (decisión aprobada) |
| Contradicción total/parcial en el DOCX | Modalidad seleccionable (decisión aprobada) |
| Sin módulo de solicitudes de cesantías | El documento se genera directo desde Certificados, sin solicitud previa |

## Archivos

### Backend (nuevos/modificados)
- `Back/app/Services/CesantiasWithdrawalService.php` (nuevo, sin retiro asociado)
- `Back/app/Services/CertificateRenderer.php` (`cesantiasWithdrawalBlocks` + `cesantiasAuthorizationPhrase`)
- `Back/app/Http/Controllers/Api/CertificateController.php` (3 endpoints cesantias + `cesantiasRules`)
- `Back/routes/api.php` (3 rutas cesantias antes de `{formatKey}`)
- `Back/tests/Feature/CesantiasWithdrawalApiTest.php` (nuevo, 8 pruebas)
- `Back/tests/Unit/CertificateRendererTest.php` (+2 pruebas F-011)

### Frontend
- `Front/src/app/core/services/contracting.service.ts` (+3 métodos cesantias)
- `Front/src/app/features/contracting/contracting-certificates.component.ts` (tab F-011, tabla sin columna de retiro, modalidad/concepto/monto, `generateCesantias`, descarga con nombre F-011)

### BD (pendiente de ejecución manual en DEV)
- `BD/20261013_f011_habilitacion.sql` (idempotente: renderizador, habilitación, firmantes desde F-002, verificación)

## Evidencia de pruebas (2026-10-14)

- `CesantiasWithdrawalApiTest`: **8 passed (98 assertions)** — catálogo, generación, modalidad total, validación, monto cero rechazado, fondo faltante, descarga PDF.
- `CertificateRendererTest`: **15 passed (672 assertions)** (13 previas + 2 F-011).
- `CertificateApiTest` (F-002): **22 passed**. `RetirementChecklistApiTest` (F-004): **8 passed**. `ResignationAcceptanceApiTest` (F-005): **11 passed**.
- `npm run build`: **exitoso**.
- `npm test`: no ejecutado (requiere @vitest/browser-playwright no disponible en el entorno).

## Revisiones BMAD

- **Técnica:** servicio de solo lectura sin Eloquent y sin dependencia de retiro; renderer reutiliza encabezado, marca de agua, firma, control y paginación; rutas cesantias antes de `{formatKey}`; frontend reutiliza señales, vista previa y descarga del mismo contexto confirmado; doble firma (empleador + trabajador) secuencial por limitación vertical del motor.
- **Casos límite:** empleado inexistente (404), fondo faltante (422), modalidad inválida (422), concepto vacío/extenso/HTML (422), monto cero/negativo/no numérico/3 decimales (422), formato deshabilitado (404), descarga con nombre F-011.
- **Cobertura:** catálogo, generación, validación triple, autorización, descarga PDF, renderizado por modalidad, regresión F-002/F-004/F-005 completa.

## Riesgos / pendientes

- El script SQL debe ejecutarse manualmente en DEV (con `SET SQL_SAFE_UPDATES = 0` si el safe mode bloquea); sin eso el tab muestra "No hay cartas de cesantías disponibles".
- Validación visual del PDF con datos reales pendiente en DEV (comparar contra el DOCX oficial).

## Validación manual en DEV

1. Ejecutar `BD/20261013_f011_habilitacion.sql` en DEV y verificar `FIRMANTES_JSON`.
2. Ir a `/admin/contracting/employees/{id}/certificates` → tab **F-011**.
3. Con empleado con fondo de cesantías: elegir modalidad, concepto y monto → **Generar** → verificar vista previa.
4. **Descargar PDF** → verificar destinatario (fondo), ASUNTO según modalidad, datos, monto en cifra, doble firma, marca de agua, paginación.
5. Sin fondo registrado → error claro de `fondo_cesantias`; monto `0` → 422.
