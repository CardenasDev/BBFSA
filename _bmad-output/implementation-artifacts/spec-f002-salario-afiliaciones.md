---
title: 'Segunda plantilla F-002 con salario y afiliaciones'
type: 'feature'
created: '2026-10-09'
status: 'done'
baseline_commit: '067a9c1b9ae92f2dbdda79661e9496bd04232335'
route: 'dispatch'
review_loop_iteration: 0
context: []
---

<frozen-after-approval>

## Intent

Añadir la segunda plantilla del Word F-002, identificada por la imagen del usuario: identificación, ingreso, cargo, tipo de contrato, salario mensual en letras y cifra, afiliaciones y firmante. Reutilizar la consulta oficial, autorización y descarga PDF del certificado de funciones, que sigue disponible. Ambas son variantes del certificado laboral activo, no un F-003 ni una historia contractual.

## Boundaries & Constraints

Siempre: empleado ACTIVO, contrato propio ACTIVO y vigente, JWT y CONTRATACION_VER. Consultar fuentes oficiales mediante SP existentes. Fecha de expedición única America/Bogota. Empresa, firmantes y metadatos institucionales configurados. Misma cabecera, logo, marca de agua, control documental y paginación del renderer corregido. Datos de salario y afiliaciones del empleado seleccionado, sin reemplazarlos por ejemplos.

Nunca: copiar personas, salario, entidades o fechas del Word; asumir «No aplica» porque falta un campo; modificar el certificado de funciones para exigir salario o afiliaciones; ejecutar cambios de BD sin autorización; guardar emisiones, calcular nómina, modificar estados ni redactar historia de contratos. No exigir cláusula de funciones para esta variante.

Decisión del usuario: fondo de solidaridad y retención en la fuente se suministran en campos del frontend al generar. Ambos son obligatorios para SALARIO_AFILIACIONES; se transmiten al backend, se validan y se incluyen en su PDF sin persistir en contrato, afiliaciones ni registros de emisiones. Permitir «No aplica» únicamente cuando lo escriba explícitamente el usuario. No afectan GENERAL.

## I/O & Edge-Case Matrix

| Caso | Entrada | Resultado |
|---|---|---|
| Primera variante | Sin parámetro variante | GENERAL existente, mismo contenido y validaciones |
| Segunda variante completa | variante SALARIO_AFILIACIONES, contrato propio vigente | Datos y PDF con salario y afiliaciones; sin funciones |
| Variante desconocida o deshabilitada | Variante no soportada/vigente | Error explícito; no sustituir por GENERAL |
| Contrato ajeno/empleado inexistente | Identificadores inválidos | 404 sin revelar salario ajeno |
| Empleado o contrato no vigente | Estado/fechas inválidos | 422 antes de generar |
| Salario o tipo ausente | Datos del contrato incompletos | 422 con campo faltante |
| Afiliación incompleta | EPS/ARL/pensión/caja ausente | 422 indicando qué dato completar |
| Texto extenso | Nombres/cargo/entidades largos | Ajuste de líneas y páginas reales sin pérdida |
| Sin acceso | Sin JWT o permiso | 401/403 antes de consultar fuentes |
| Campos suministrados vacíos | Solidaridad o retención omitida/vacía | 422 con errores de campo; frontend pide completarlos |
| Campos suministrados completos | Textos explícitos válidos | Misma información en vista de datos y PDF; ninguna escritura en BD |

</frozen-after-approval>

## Code Map

- `Back/app/Repositories/CertificateRepository.php`: `getFormat` recibe variante, con GENERAL como valor predeterminado.
- `Back/app/Services/CertificateService.php`: validaciones comunes y consultas de empleado/contrato; separar requisitos de cada variante.
- `Back/app/Repositories/ContractingRepository.php`: getContractGenerationData y getSocialSecurity existentes.
- `BD/2608241Dev.sql`: SP contractual devuelve tipo_contrato y salario_base DECIMAL(12,2); SP de seguridad social devuelve eps, arl, fondo_pension, caja_compensacion. Referencia de fuentes; no editar este dump.
- `BD/20261006_base_documental.sql`: catálogo y SP admiten CLAVE_FORMATO + VARIANTE; no requieren tablas ni SP nuevos.
- `Back/app/Services/CertificateRenderer.php`: reutilizar infraestructura de PDF y elegir cuerpo según variante validada.
- `Front/src/app/features/contracting/contracting-certificates.component.ts`: distingue las variantes y conserva formato, contrato y declaraciones confirmadas entre consulta y descarga; ignora resultados y errores de consultas obsoletas.

## Tasks & Acceptance

- [x] `Back/app/Repositories/CertificateRepository.php`, `Back/app/Http/Controllers/Api/CertificateController.php`, `Back/app/Services/CertificateService.php`: transportar y validar variante opcional; consultar requisitos del cuerpo elegido, mantener seguridad y GENERAL compatible. Validar solidaridad/retención como textos obligatorios, sin HTML ni saltos de línea y longitud máxima 200 caracteres; nunca consultarles un valor predeterminado.
- [x] `Back/app/Services/SalaryTextFormatter.php`: conversión determinista del salario decimal a pesos colombianos en letras y cifra; sin redondeos binarios silenciosos ni dependencias de intl.
- [x] `Back/app/Services/CertificateRenderer.php`: segundo cuerpo con párrafo de tipo/salario y lista de afiliaciones, conservando diseño común y firma.
- [x] `Front/src/app/core/services/contracting.service.ts`, `Front/src/app/features/contracting/contracting-certificates.component.ts`: pasar variante y distinguir ambas filas; mostrar solidaridad/retención únicamente al generar la segunda. Conservar selección y valores utilizados durante generación y descarga; invalidar los datos consultados si cambian para no mostrar un PDF diferente del contexto confirmado. No guardar inputs en almacenamiento del navegador.
- [x] `BD/20261009_f002_salario_afiliaciones.sql`: entregar script reejecutable y acotado para registrar la nueva variante con metadata institucional verificada. No ejecutarlo automáticamente ni alterar GENERAL; no inventar firmantes.
- [x] `Back/tests/Unit/SalaryTextFormatterTest.php`, `Back/tests/Unit/CertificateRendererTest.php`, `Back/tests/Feature/CertificateApiTest.php`, `Front/src/app/features/contracting/contracting-certificates.component.spec.ts`: pruebas de variantes, datos incompletos, pertenencia, salario decimal y descarga correcta.

Given ambas variantes habilitadas, when se elige salario/afiliaciones, then no se descarga el cuerpo de funciones. Given GENERAL, when se genera, then conserva su comportamiento anterior. Given salario 1750905.00, when se representa, then cifra y letras corresponden al mismo valor exacto. Given faltantes, when se genera, then aparecen errores accionables y no un certificado con información inventada.

## Implementation Notes

Investigación completada en Front, Back y BD. No hay fuente de solidaridad/retención ni conversor general de salario en letras. Se reutiliza el contexto común; salario base del contrato seleccionado, sin sumar auxilio ni deducciones. Los nombres de entidades vienen de la afiliación registrada, no de los catálogos como defaults. Huella estimada: siete archivos productivos, un script SQL y cuatro archivos de pruebas. Las fechas distintas del ejemplo se reemplazan por una única fecha del backend.

Para los campos declarados por el usuario, añadir POST de datos y descarga en las mismas rutas del controlador y aplicar idéntico middleware; usar cuerpo JSON para no exponer esos valores en URLs/historial. Conservar GET existentes para GENERAL. Los valores del front nunca pueden reemplazar salario, identidad, cargo ni nombres de entidades consultados del backend.

## Verification

- PHPUnit de certificados, renderer y salario: regresión GENERAL, errores y segunda variante.
- Build Angular y prueba del componente: selección por clave + variante y descarga del PDF correspondiente.
- PDFs ficticios de referencia: extraer texto para comprobar salario/letras/entidades; renderizar e inspeccionar todas las páginas, incluyendo cadenas largas y saltos de página. No exponer datos reales en artefactos de prueba.
- Revisar script SQL sin ejecutar ni habilitar automáticamente la generación en la BD del usuario.

## Revisión y cierre técnico

Se recuperó `output/f002-verification/verification.md` y `deferred-work.md`, pero no había informes detallados de revisores, agentes activos ni resultados adicionales recuperables en el historial. Las revisiones funcional, de casos límite y de cobertura se completaron directamente sobre el diff y sus callers. La revisión ciega independiente anterior no puede ser atestiguada ni recreada retrospectivamente en esta sesión.

- **Calidad funcional y técnica:** GENERAL conserva GET y su cuerpo de funciones; SALARIO_AFILIACIONES usa POST, datos oficiales, el permiso CONTRATACION_VER y un renderizador diferenciado. Contrato ajeno y formato no habilitado se rechazan; salario base no incorpora auxilio; las declaraciones no se persisten. Hallazgo corregido: el `finalize` y el error de una consulta antigua podían alterar el estado de una consulta más reciente.
- **Casos límite:** se verificaron importes decimales hasta el máximo soportado, afiliaciones y campos declarados incompletos/inválidos, cambio de variante con respuestas fuera de orden, invalidación de vista previa, conservación de los parámetros confirmados en descarga y paginación larga. Las pruebas ahora cubren explícitamente la concurrencia.
- **Cobertura:** PHPUnit verifica ambas variantes, fuentes oficiales, faltantes, autorización, PDF y ausencia de funciones en la segunda. Angular verifica la serialización GET/POST y el aislamiento de solicitudes obsoletas. Se agregaron aserciones para las cuatro afiliaciones y para no sumar auxilio.
- Hallazgo de regresión corregido en `ContractingApiTest`: el inventario esperado de rutas no incluía los POST nuevos de certificados. Las otras cuatro fallas de esa clase siguen siendo fallas externas de mocks para procedimientos de perfil/contrato y limpieza de archivo; no se modificaron esos flujos.

## Review Triage Log

| # | Veredicto | Ruta | Hallazgo y evidencia |
|---|---|---|---|
| 1 | medium, patch | `Front/src/app/features/contracting/contracting-certificates.component.ts` | Una respuesta/error tardía podía limpiar `generating` o mostrar error obsoleto. Se condicionan `finalize` y error a `contextRevision`; la prueba de componente fuerza respuestas desordenadas. |
| 2 | low, patch | `Front/src/app/core/services/contracting.service.spec.ts` | Las pruebas del componente mockeaban el servicio y no probaban que las declaraciones y variante llegaran en el cuerpo POST. Se añadió verificación HTTP para GENERAL GET, variante POST, descarga PDF y cuerpo declarado. |
| 3 | medium, patch | `Back/tests/Feature/ContractingApiTest.php` | El inventario de rutas esperado no incluía los dos endpoints POST añadidos por F-002. Se actualizó la expectativa y el test de rutas ahora pasa. |

## Verificación ejecutada al cierre

- `cd Back; php artisan test --filter='Certificate|SalaryTextFormatter|contracting_routes_are_registered'`: **35 pruebas y 925 aserciones aprobadas**.
- `cd Back; vendor/bin/pint --test tests/Feature/CertificateApiTest.php tests/Unit/SalaryTextFormatterTest.php`: aprobado.
- Prueba Angular aislada para `contracting-certificates.component.spec.ts` y `contracting.service.spec.ts`: **2 archivos, 7 pruebas aprobadas**. Se usó un `tsconfig` temporal para excluir el spec ajeno de exámenes médicos y se retiró al terminar.
- Suite general Angular: bloqueada por TS2339, `createExam` inexistente en `contracting-medical-exams.component.spec.ts:95` y `:110`; ese módulo no se cambió.
- `npm.cmd run build`, `npm.cmd run build:qa`, `npm.cmd run build:prod`: aprobados. La compilación PROD conserva advertencias de presupuesto CSS en dos componentes de contratos, ajenas a F-002.
- PDFs ficticios existentes: extracción PDF.js verifica el de una página y el de tres páginas, cifras/letras, las cuatro afiliaciones, firma, ausencia de funciones y marcadores finales de entidades. Las cuatro páginas renderizadas fueron inspeccionadas visualmente.
- `php artisan test --filter=ContractingApiTest`: 12 aprobadas, 4 fallidas por mocks preexistentes de procedimientos de expedición/salario mínimo y una expectativa de limpieza de archivo; el test de rutas añadido para F-002 pasa.
- `BD/20261009_f002_salario_afiliaciones.sql`: inspeccionado; **no ejecutado**. No se consultó ni modificó ninguna BD.

## Despliegue preparado

Los únicos archivos de runtime que corresponden a F-002 son:

- Back: `Back/app/Http/Controllers/Api/CertificateController.php`, `Back/app/Repositories/CertificateRepository.php`, `Back/app/Services/CertificateRenderer.php`, `Back/app/Services/CertificateService.php`, `Back/app/Services/SalaryTextFormatter.php` (nuevo), `Back/routes/api.php`.
- Front: `Front/src/app/core/services/contracting.service.ts`, `Front/src/app/features/contracting/contracting-certificates.component.ts`.
- Base de datos: `BD/20261009_f002_salario_afiliaciones.sql`.
- Sin nuevas dependencias ni configuraciones de aplicación requeridas. Los endpoints conservan JWT y CONTRATACION_VER; el cliente de la segunda variante usa JSON POST.

Prerequisito BD: la tabla debe existir según `BD/20261006_base_documental.sql`, y debe haber exactamente una fila GENERAL activa/habilitada/vigente que cumpla las condiciones del insert y tenga referencias institucionales válidas. El operador requiere SELECT e INSERT en `bbf_documento_formatos`. El script inserta solo `SALARIO_AFILIACIONES`, copia metadatos institucionales y deja `HABILITADO_GENERACION=0`. Si no hay fuente única verificada o ya existe la variante, no actualiza nada. No contiene DROP, DELETE ni UPDATE; la tabla y los SP existentes no se alteran.

QA: revisar `SHOW CREATE TABLE`, BD destino, fila GENERAL y firmantes; aplicar el script solo con aprobación DBA, confirmar la fila nueva y su flag deshabilitado, desplegar Back y luego `npm run build:qa` al servidor frontend. Comprobar URL API/CORS/JWT del ambiente. La variante solo aparecerá al habilitarse; para probar la emisión se requiere autorización institucional explícita.

PROD: repetir las mismas precondiciones y validación después de aprobar QA; respaldar metadatos, aplicar el script una sola vez, revisar resultado sin asumir inserción y desplegar Back + `npm run build:prod` coordinadamente. Mantener la variante deshabilitada hasta la habilitación institucional explícita. La fila se necesita en cada ambiente donde se quiera publicar la variante; no ejecutarla si aún no hay aprobación.

Reversión, solo si se confirmó que la fila fue creada por este script, permanece intacta y no está referenciada/en uso: consultar y registrar su `ID_DOCUMENTO_FORMATO`; si está habilitada, deshabilitar esa misma fila con autorización; luego eliminarla con un `DELETE` filtrado simultáneamente por ese ID, `CLAVE_FORMATO='CERTIFICADO_LABORAL_ACTIVO'`, `VARIANTE='SALARIO_AFILIACIONES'` y `CLAVE_RENDERIZADOR='certificado-laboral-activo-salario-afiliaciones'`. No borrar tabla ni SP. Si metadatos institucionales fueron editados o hay emisiones/usos, detener la reversión y conservar la evidencia para una decisión autorizada.

## Estado

**APROBADO CON OBSERVACIONES**, técnicamente. Quedan la suite Angular general ajena al alcance, cuatro fallas preexistentes de `ContractingApiTest`, la falta de evidencia recuperable de una revisión ciega independiente, la validación/autorización institucional del control documental y firmantes, y el despliegue/habilitación de catálogo en QA/PROD. Este cierre no declara aceptación funcional del cliente.
