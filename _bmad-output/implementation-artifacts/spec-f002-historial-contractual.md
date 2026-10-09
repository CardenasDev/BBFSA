---
title: 'Tercera variante F-002 con contrato actual y salario'
type: 'feature'
created: '2026-10-09'
status: 'implemented'
route: 'dispatch'
baseline_commit: '2b52aa3f43bd9f3045b4a2f1bb197caf95e14701'
review_loop_iteration: 0
context: []
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** F-002 ofrece un certificado de funciones y otro de salario/afiliaciones, pero no una variante que certifique el contrato actual y salario con la fecha de inicio de labores suministrada por el usuario autorizado.

**Approach:** Agregar `HISTORIAL_CONTRACTUAL` como tercera variante independiente. El backend obtiene únicamente los datos del contrato actual y salario base desde fuentes oficiales; la fecha de inicio de labores la suministra el frontend, se valida en backend y se imprime como fecha oficial aunque difiera de la registrada en el empleado. No listar contratos anteriores. No alterar GENERAL ni SALARIO_AFILIACIONES y mantener la nueva variante deshabilitada en el catálogo.

## Boundaries & Constraints

**Always:** Usar el permiso y patrón de autorización existentes; empleado y contrato actual deben corresponder; obtener del backend tipo, fechas, cargo, duración y salario del contrato actual; salario base en letras y cifras sin auxilios; aceptar del frontend una fecha de vinculación que se imprimirá como fecha oficial aunque difiera de `FECHA_INGRESO`, validando formato, fecha real y que no sea futura. La fecha suministrada se limita a esta generación y no se persiste. Señalar datos oficiales obligatorios faltantes con error accionable. Reutilizar `SalaryTextFormatter` y el motor PDF. Registrar identidad/renderizador propios con código institucional `BBTH-F-002`, generación inicialmente deshabilitada.

**Never:** Copiar datos del documento de referencia; listar o inferir contratos anteriores; afirmar continuidad histórica; incluir afiliaciones, solidaridad o retención; aceptar del frontend el salario u otros datos contractuales; inventar tipos, fechas, duraciones, cargos o salarios; cambiar GENERAL o SALARIO_AFILIACIONES; modificar el DOCX, ejecutar SQL, intervenir QA/PROD o crear commit.

## I/O & Edge-Case Matrix

| Escenario | Entrada / Estado | Resultado esperado | Manejo de error |
|----------|--------------|---------------------------|----------------|
| Certificado actual | Empleado activo y contrato actual válido con datos requeridos; usuario autorizado suministra inicio de labores | Vista previa y PDF presentan fecha suministrada, datos contractuales actuales y salario base coincidente en letras y cifras | N/A |
| Fecha inválida | Fecha vacía, mal formada, inexistente o futura | No se genera ni se confirma vista previa | Error controlado 422 |
| Sin contrato actual | No se puede identificar contrato ACTIVO y vigente del empleado | No se genera certificado | Error controlado 422 |
| Datos oficiales insuficientes | Falta salario, tipo, cargo o fechas contractuales requeridas | No generar afirmaciones incompletas; respuesta identifica campo faltante | Error controlado 422 |
| Regresión | Selección GENERAL o SALARIO_AFILIACIONES | Conservar validación, cuerpo, vista previa y PDF existentes | N/A |

</frozen-after-approval>

## Code Map

- `Back/app/Repositories/ContractingRepository.php::listContracts` llama `SP_BBF_CONTRATACION_CONTRATOS_LISTAR`, que entrega los contratos existentes ordenados por inicio descendente; usarlo para validar cuál es el contrato actual según el estado y vigencia.
- `Back/app/Repositories/ContractingRepository.php::getContractGenerationData` obtiene los datos oficiales de un contrato explícito; `CertificateService` ya valida pertenencia, estado y vigencia.
- `BD/2608241Dev.sql` define `bbf_empleado_contratos` con tipo, cargo, fechas, `DURACION_MESES`, salario y estado. El contrato actual se distingue entre los registros `ACTIVO` vigentes; no inferir historia previa.
- `BD/2608241Dev.sql::SP_BBF_CONTRATACION_CONTRATO_CREAR` establece `FECHA_INGRESO` solo si era nula. Se confirmó con el usuario que la fecha que se imprimirá como inicio de labores la suministrará el frontend y podrá diferir de ese dato.
- `Back/app/Services/CertificateService.php` valida empleado/contrato/formato, compone contexto oficial, resuelve firmantes y configuración; ampliar sin cambiar las dos variantes existentes.
- `Back/app/Services/CertificateRenderer.php` reutiliza encabezado, marca de agua, firma, control documental y paginación; añadir un cuerpo específico por variante.
- `Back/app/Services/SalaryTextFormatter.php` contiene el conversor vigente a reutilizar.
- `Back/app/Repositories/CertificateRepository.php` obtiene variantes del catálogo; el patrón de registro deshabilitado está en `BD/20261009_f002_salario_afiliaciones.sql`.
- `Front/src/app/features/contracting/contracting-certificates.component.ts` selecciona variante, consulta vista previa, gestiona solicitudes fuera de orden y descarga el contexto confirmado.
- Pruebas existentes: `Back/tests/Feature/CertificateApiTest.php`, `Back/tests/Unit/CertificateRendererTest.php`, `Front/src/app/features/contracting/contracting-certificates.component.spec.ts`.

## Tasks & Acceptance

**Execution:**
- [x] Backend: aceptar la fecha de inicio de labores suministrada para esta solicitud, validarla y no persistirla; validar que el ID corresponde al contrato actual vigente del empleado y proyectar los datos oficiales necesarios.
- [x] PDF: incluir identificación, fecha suministrada, datos del contrato actual disponibles y salario base en letras/cifras; conservar plantilla y paginación institucional.
- [x] Frontend: mostrar la opción del catálogo y un campo de fecha; enviar fecha/variante/contrato a vista previa y descarga bajo el mismo contexto confirmado; conservar las dos variantes actuales.
- [x] `BD/20261009_f002_historial_contractual.sql`: crear registro idempotente y deshabilitado con renderizador propio, verificación y sin cambios destructivos; no ejecutar.
- [x] Pruebas: cubrir selección, fecha válida/inválida/futura, contrato actual/vencido/ajeno, datos faltantes, importes, autorización, PDFs/paginación y regresión de variantes existentes.
- [x] Documentar fuentes, decisión de alcance, script y validación manual en DEV.

**Acceptance Criteria:**
- Given la variante está seleccionada, when el usuario autorizado suministra fecha válida y consulta/descarga, then ambos resultados corresponden al mismo empleado, contrato actual y fecha confirmados.
- Given la fecha suministrada difiere de `FECHA_INGRESO`, when se emite el certificado, then se imprime la fecha suministrada tal como se autorizó y no se altera la base de datos.
- Given el usuario selecciona otro contrato, when solicita la variante, then solo se permite el contrato actual activo y vigente.
- Given falta un dato obligatorio, when se solicita generación, then el sistema identifica el faltante y no produce un certificado incompleto.
- Given se elige GENERAL o SALARIO_AFILIACIONES, when se consulta o descarga, then su contenido y reglas permanecen inalterados.

## Implementation Notes

Decisión funcional confirmada por el usuario: no listar contratos anteriores; usar el contrato actual para tipo, duración, fechas, cargo y salario; el usuario suministra desde frontend la fecha de inicio de labores que aparecerá en el certificado, incluso si difiere de la fecha de ingreso registrada. No persistir ese dato.

## Spec Change Log

- 2026-10-09: Implementación completada. Backend, frontend y SQL creados. Pruebas de certificados aprobadas (32/32). Build frontend exitoso.

## Review Triage Log

### Revisión Técnica (2026-10-09)
- **CertificateService.php**: Integridad verificada. BOM eliminado. Lógica HISTORIAL_CONTRACTUAL correctamente implementada sin afectar variantes existentes.
- **CertificateRenderer.php**: Caso HISTORIAL_CONTRACTUAL añadido con datos contractuales, salario y fecha suministrada.
- **CertificateController.php**: Reglas actualizadas para aceptar HISTORIAL_CONTRACTUAL y fecha_inicio_labores.
- **ContractingRepository.php**: No requiere cambios. Métodos existentes reutilizados.
- **CertificateRepository.php**: No requiere cambios. Métodos existentes reutilizados.
- **Frontend**: Componente y servicio actualizados para soportar la tercera variante.
- **SQL**: Script idempotente creado siguiendo patrón de SALARIO_AFILIACIONES.

### Revisión de Casos Límite (2026-10-09)
- Fecha futura: Validada en backend (422)
- Fecha inválida: Validada en backend (422)
- Contrato no vigente: Validado en backend (422)
- Contrato ajeno al empleado: Validado en backend (404)
- Datos faltantes: Validados en backend (422 con campo específico)
- Fecha suministrada diferente de FECHA_INGRESO: Aceptada y utilizada en certificado

### Revisión de Cobertura de Pruebas (2026-10-09)
- CertificateApiTest: 22/22 aprobadas
- CertificateRendererTest: 10/10 aprobadas
- Total: 32/32 aprobadas (912 aserciones)
- Regresión variantes existentes: Verificada

## Verification

**Commands:**
- PHPUnit de certificados y renderizador -- esperado: pruebas de las tres variantes y regresión aprobadas.
- Pruebas focalizadas Angular y build -- esperado: selección/vista previa/descarga consistentes y build exitoso.
- Revisión estática del SQL -- esperado: idempotente, no destructivo, deshabilitado; no ejecutarlo.

**Execution Evidence (2026-10-09):**

Backend:
- `php artisan test --filter=CertificateApiTest`: **22 passed (272 assertions)**
- `php artisan test --filter=CertificateRendererTest`: **10 passed (640 assertions)**
- Total pruebas certificados: **32 passed (912 assertions)**
- Regresión variantes GENERAL y SALARIO_AFILIACIONES: **APROBADA**

Frontend:
- `npm run build`: **EXITOSO** (9.424s, 1.50 MB total)
- `npm test`: **NO EJECUTADO** - requiere configuración de navegador headless (@vitest/browser-playwright) no disponible en el entorno

Pre-existing failures (no relacionados con F-002):
- `ContractingApiTest`: 4 fallos por mocks de SP no configurados en pruebas ajenas
- `DotationApiTest`: 3 fallos por diferencias en rutas y validaciones
- `ToolApiTest`: 1 fallo por limpieza de archivos
- `AuthApiTest`: 1 fallo por diferencias en rutas esperadas

**Manual checks (if no CLI):**
- Verificar texto y paginación de los PDF generados con datos ficticios, incluidos cargo, tipo, fechas y cadenas extensas.
