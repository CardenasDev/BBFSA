# PRD – BBF SisAdmin (Brownfield)

## 1. Resumen ejecutivo

BBF SisAdmin es un sistema administrativo ya existente para Barro Blanco Farms, orientado a la gestión del ciclo de vida laboral de la persona dentro de la organización: aspirante, contratación, empleado y retiro. El producto se encuentra implementado en un modelo Brownfield real: la lógica funcional y operativa ya existe en backend, frontend y base de datos, con un fuerte acoplamiento a procedimientos almacenados MySQL y permisos por rol.

La evidencia disponible en el repositorio confirma que el sistema ya soporta procesos clave de Recursos Humanos: autenticación, usuarios, roles, permisos, aspirantes, empleados, contratación, dotación, herramientas, devoluciones, capacitaciones, notificaciones, retiros y administración documental. Sin embargo, no todo el alcance levantado en requerimientos está implementado como módulo independiente. Existen varios procesos funcionales que aparecen como parte de obligaciones operativas más amplias, especialmente mediante novedades, y otros que aún no tienen evidencia de implementación real en código.

El PRD que se presenta no reemplaza la arquitectura técnica ni el diseño técnico; se centra en responder qué hace el producto y qué estado funcional tiene hoy. La arquitectura técnica ya queda documentada en `architecture.md`, y esta propuesta se apoya en ese documento, pero no lo duplica.

## 2. Contexto del producto

### 2.1 Naturaleza del producto
El sistema administra progresivamente el ciclo de vida de las personas relacionadas con la empresa:

Aspirante -> Proceso de contratación -> Empleado -> Gestión laboral -> Retiro

### 2.2 Estado del repositorio
El código del repositorio confirma una aplicación ya operativa, no una iniciativa greenfield. La estructura real incluye:

- Frontend Angular 22 en `Front/`
- Backend Laravel 12 en `Back/`
- Base de datos en MySQL con uso intensivo de procedimientos almacenados `SP_BBF_*`
- Autenticación con JWT y control de permisos por rol
- Gestión documental en `Back/public/uploads`

### 2.3 Naturaleza del dominio
La entidad funcional central del sistema es el empleado, pero esto no significa que el producto se reduzca a una sola tabla o módulo. La evidencia real demuestra que el empleado concentra el negocio operativo del sistema, con dependencias a contratación, dotación, herramientas, devoluciones, capacitaciones, novedades, documentos y retiro.

## 3. Problema que resuelve

El negocio requiere un sistema administrativo para gestionar el ciclo de vida de las personas vinculadas a Barro Blanco Farms, con foco en la entrada, contratación, permanencia, documentación y salida del empleado. El sistema actual resuelve la necesidad de registrar aspirantes, aprobarlos para contratación, crear empleados, controlar documentación, manejar entregas, realizar seguimientos periódicos y cerrar procesos de retiro. Aunque el producto ya está en operación, la base funcional muestra áreas de madurez distinta: algunas áreas están consolidadas y otras aún dependen de catalogación, novedad o procedimientos no formalizados.

## 4. Objetivos

### Objetivos actuales del producto
- Registrar personas como aspirantes e iniciar su evaluación.
- Aprobar y convertir aspirantes a empleados.
- Administrar la ficha de empleado y la documentación laboral.
- Gestionar contratación, contrato y seguimiento documental.
- Controlar dotación, tallas, entregas y devoluciones.
- Gestionar herramientas y entregas asociadas al empleado.
- Coordinar capacitaciones, resultados y compromisos.
- Mantener un histórico de novedades laboral y retiro.
- Controlar permisos de acceso y seguridad con roles y permisos.

### Objetivos pendientes de consolidar
- Definir de manera formal módulos de incapacidades, permisos, llamadas de atención y suspensiones como procesos propios.
- Consolidar una estrategia de gobernanza documental uniforme y más segura.
- Formalizar trazabilidad y metadatos de negocio más completos en áreas no centralizadas.

### Pendientes originales del levantamiento RRHH (15)
1. Lista completa de documentos requeridos para contratación.
2. Tipos de contrato manejados por la empresa.
3. Días de anticipación para notificación de vencimiento de contrato.
4. Formatos oficiales de: contrato, llamados de atención, suspensión, carta de compromiso, solicitudes y retiro.
5. Listado de dotaciones por cargo o área.
6. Listado de herramientas por cargo o área.
7. Campos exactos del Excel de incapacidades.
8. Campos exactos del Excel de capacitaciones.
9. Puntaje mínimo para aprobar capacitaciones.
10. Reglas de negocio para generar carta de compromiso.
11. Reglas para no renovación de contrato por bajo desempeño en capacitación.
12. Flujo de aprobación para permisos y solicitudes económicas.
13. Responsables de aprobar o rechazar solicitudes.
14. Documentos obligatorios durante el retiro.
15. Canales de notificación: sistema, correo, alerta interna y otro.

## 5. Alcance

### Alcance actual
Se demuestra alcance real en:

- Autenticación y seguridad JWT
- Usuarios, roles y permisos
- Aspirantes
- Empleados
- Contratación
- Dotación
- Herramientas
- Devoluciones
- Capacitación
- Notificaciones
- Retiro
- Novedades
- Administración de parámetros y catálogos

### Alcance con evidencia parcial y no consolidado como módulo formal
- Llamados de atención: funcionalidad real dentro de novedades, pero no como módulo disciplinario independiente.
- Suspensiones: funcionalidad real dentro de novedades y estado del empleado, pero no como proceso disciplinario completo.
- Solicitudes internas: no hay módulo consolidado; tipos esperados incluyen adelantos de vacaciones, prima y sueldo.
- Incapacidades: existe registro y seguimiento funcional, pero no evidencia de módulo independiente completo.
- Política documental centralizada y externa: pendiente de definición formal.

## 6. Estado Brownfield

El sistema es Brownfield porque:

- Ya existe un contexto funcional operativo real.
- El negocio ya está definido y parcialmente implementado.
- La arquitectura actual está documentada en `architecture.md` y confirmada por código.
- La funcionalidad no se está creando desde cero; se está reconstruyendo y formalizando a partir del AS-IS real.

## 7. Stakeholders / actores

### 7.1 Administrador
- Rol real identificado en la lógica de autenticación y configuración.
- Tiene acceso a gestión de usuarios, roles, permisos y administración del sistema.
- Puede crear, editar, asignar permisos, controlar roles y administrar procesos críticos.

### 7.2 Personal autorizado / RRHH administrativo
- Participa en procesos de aspirantes, empleados, contratación, dotación, capacitaciones, retiros y novedades.
- Tiene permisos específicos para crear, consultar y autorizar operaciones.
- Se valida por permisos y acceso a módulos.

### 7.3 Empleado
- Usuario del sistema con acceso a sus propios registros.
- Consulta sus entregas, tallas, capacitaciones, compromisos, novedades y perfil.
- No puede modificar procesos críticos sin permisos adicionales.

### 7.4 Usuario del sistema (genérico)
- Se usa en autenticación y JWT como entidad base con roles, permisos y sesión.
- Su acceso depende de permisos y del contexto del usuario autenticado.

## 8. Producto actual AS-IS

### 8.1 Funcionalidades implementadas en evidencia
La evidencia real del repositorio confirma los siguientes módulos con estado implementado:

| Módulo | Estado | Evidencia |
|---|---|---|
| Autenticación | IMPLEMENTADO | `Back/routes/api.php`, `AuthController`, JWT, refresh, logout |
| Usuarios | IMPLEMENTADO | `UserController`, rutas `/users`, permisos |
| Roles | IMPLEMENTADO | `RoleController`, `/roles`, `/roles/{id}/permissions` |
| Permisos | IMPLEMENTADO | RBAC en middleware, `permissionGuard` |
| Aspirantes | IMPLEMENTADO | `ApplicantController`, rutas `/applicants` |
| Empleados | IMPLEMENTADO | `EmployeeController`, `/employees` |
| Contratación | IMPLEMENTADO | `ContractingController`, templates y PDFs |
| Dotaciones | IMPLEMENTADO | `DotationController`, rutas `/dotations` |
| Herramientas | IMPLEMENTADO | `ToolController`, `/tools`, `/tool-deliveries` |
| Devoluciones | IMPLEMENTADO | `ReturnController`, `/returns` |
| Capacitación | IMPLEMENTADO | `TrainingController`, sesiones, evaluaciones, compromisos |
| Notificaciones | IMPLEMENTADO | `NotificationController`, `/notifications` |
| Retiro | IMPLEMENTADO | `RetirementController`, `/retirements` |
| Novedades | IMPLEMENTADO | `NoveltyController`, rutas `/novelties` |
| Autoservicio del empleado | PARCIAL | `my-tool-deliveries`, `dotations/my-sizes`, `dotations/my-deliveries`, `trainings/my/records` |

### 8.2 Verificación AS-IS del autoservicio del empleado
Existe un autoservicio funcional limitado, no un portal de empleado completo. La evidencia real muestra accesos específicos del empleado autenticado a:

- Mis entregas de herramientas: `MyToolDeliveryController` y rutas `/api/my-tool-deliveries`
- Mis tallas de dotación: `GET /api/dotations/my-sizes`, `POST /api/dotations/my-sizes`
- Mis entregas de dotación: `GET /api/dotations/my-deliveries`
- Mis registros de capacitación: `GET /api/trainings/my/records`

Esto confirma acceso limitado a información y procesos propios, pero no un módulo de autoservicio completo para permisos, incapacidades, solicitudes internas o retiro autocontenido.

### 8.3 Verificación AS-IS de novedades
`NoveltyController` es una evidencia clara de que las novedades son un módulo real del sistema. No es solo un registro informal. Permite:

- listar y consultar novedades
- registrar general, permiso, llamado o suspensión
- registrar incapacidad
- actualizar estados y soportes
- consultar seguimiento de incapacidad
- exportar seguimiento

La evidencia funcional sugiere que la novedad es el contenedor de eventos laborales más amplios, incluidos permisos, llamados, suspensiones e incapacidades. Por tanto, no se puede afirmar que esos subprocesos tengan un módulo independiente; sí existe un punto funcional común para administrarlos.

### 8.4 Verificación AS-IS de notificaciones
`NotificationController` confirma que la funcionalidad existe. El módulo permite:

- consultar una lista de notificaciones del usuario autenticado,
- consultar resumen del dashboard,
- marcar como leídas o archivadas,
- resolver una notificación para sus destinatarios,
- filtrar por permisos del usuario.

No obstante, el comportamiento de notificación está orientado a alertas operativas y dashboard del usuario, no a un motor documental completo de comunicaciones masivas o workflows de aprobación.

### 8.5 Verificación AS-IS del retiro
El retiro está implementado como proceso formal con múltiples etapas:

- razones de retiro y tipos de documento,
- creación del proceso de retiro,
- control de actividades pendientes,
- entrevista de retiro,
- documentos de retiro,
- finalización y cancelación.

La evidencia real en `RetirementController` contradice la idea de que el retiro no existe o sea solo un cierre administrativo sin flujo. Es un proceso implementado y con trazabilidad funcional.

### 8.6 Módulos parcialmente implementados

| Módulo | Estado | Observación |
|---|---|---|
| Incapacidades | PARCIAL | Se manejan como novedad o seguimiento, no como módulo autónomo dedicado |
| Permisos/licencias | PARCIAL | Corresponden a novedades o eventos registrados en flujo general |
| Documentación laboral | PARCIAL | Existente por procesos, pero sin política y estructura documental centralizada clara |
| Trazabilidad operativa | PARCIAL | Existe auditoría, pero no está estandarizada transversalmente |

### 8.7 Módulos con funcionalidad real pero no como proceso autónomo

| Módulo | Estado | AS-IS | TO-BE |
|---|---|---|---|
| Llamados de atención | PARCIAL | Gestionado dentro de `Novedades` y relacionado con eventos laborales/disciplinarios. | Formalizar flujo disciplinario, responsable, evidencia y seguimiento. |
| Suspensiones | PARCIAL | Gestionado dentro de `Novedades` y relacionado con estado del empleado. | Formalizar inicio, finalización, duración, motivo, soporte, apelación y plazo. |
| Solicitudes internas | PLANIFICADO | No existe módulo técnico consolidado; solo se documentan tipos del levantamiento original: adelanto de vacaciones, prima y sueldo. | Definir tipo, solicitud, estado, respuesta, trazabilidad y responsables. |
| Incapacidad completa | PARCIAL | Existe registro, fechas, diagnóstico, soporte y seguimiento funcional dentro de novedades. | Separar proceso independiente con historial, pago, documentación y cierre. |

> Importante: `Empleado.estado = INCAPACITADO` o `SUSPENDIDO` no equivale automáticamente a un módulo disciplinario o médico completo; evidencian un estado del empleado, no la existencia total del proceso de negocio.

### 8.8 Modelo funcional central
La evidencia confirma que el empleado es la entidad funcional central del sistema. No porque el prompt lo diga, sino porque el código, los permisos y los módulos están estructurados alrededor de la persona como eje de dotación, herramientas, capacitación, contratación, reintegro de documentos, roles, novedades y retiro.

## 9. Producto objetivo TO-BE

### 9.1 Objetivo del producto a futuro
El producto objetivo es consolidar la gestión de RRHH operativa como un sistema integral, con un flujo continuo y trazable desde aspirante hasta retiro, con procesos bien definidos y con gobernanza documental y de estado.

### 9.2 Mejoras detectadas necesarias
- Formalizar módulos de incapacidades, permisos y suspensiones como procesos de negocio definidos.
- Establecer un catálogo de estados más riguroso para novedades y salidas.
- Definir una estrategia documental con retención, clasificación y seguridad de archivos.
- Unificar o documentar claramente dónde termina la lógica de negocio en MySQL y dónde continúa en Laravel.
- Mejorar la trazabilidad para decisiones de aprobación, rechazo, atención y retiros laborales.

### 9.3 TO-BE funcional del módulo de incapacidades
- Definir incapacidad como proceso de negocio independiente, con identificación del empleado, diagnóstico, fechas, entidad responsable y documentos soporte.
- Incluir flujo de alta, seguimiento de días, pago, revisión y cierre del caso.
- Determinar obligaciones de notificación a RRHH y responsables de gestión.
- Definir estados de incapacidad y políticas de retorno a labores.
- Registrar evidencia documental y observaciones para auditoría y trazabilidad.

### 9.4 TO-BE funcional del módulo de permisos
- Establecer solicitud, aprobación y registro de permisos o licencias permitidos por tipo.
- Definir documento requerido, fechas, duración y responsable de aprobación.
- Diferenciar permiso y ausencia, con validación de solapamiento y cobertura funcional.
- Registrar impactos operativos y la obligación de informar a las áreas afectadas.

### 9.5 TO-BE funcional del módulo de llamados de atención
- Crear un registro disciplinario con responsable, motivo, evidencia y nivel de gravedad.
- Definir flujo de aviso, revisión y cierre del llamado de atención.
- Incluir evidencia documental y fecha de seguimiento.
- Vincular el evento con la persona, el proceso y el historial laboral.

### 9.6 TO-BE funcional del módulo de suspensiones
- Definir suspensión como evento disciplinario o administrativo con fechas, causa y responsable.
- Establecer estados de activa, levantada, vencida o anulada.
- Registrar impacto sobre salario, actividades y permisos vinculados.
- Definir reingreso o cierre del caso con revisión.
- Mantener el plazo de apelación de 5 días siguientes como requisito del levantamiento original, pendiente de validación formal.

### 9.7 TO-BE funcional del módulo de solicitudes internas
- Definir una solicitud formal con causa, solicitante, responsable, aprobación y resolución.
- Tipos esperados: adelanto de vacaciones, adelanto de prima y adelanto de sueldo.
- Especificar flujo completo: apertura, revisión, aprobación/rechazo, cierre y comunicación.
- Registrar carta de solicitud, carta de respuesta, fecha de respuesta, responsable y trazabilidad.
- Clasificar solicitudes por tipo y prioridad.

### 9.8 TO-BE funcional del módulo de notificaciones
- Consolidar alertas por criticidad, vencimiento, revisión y cumplimiento de procesos.
- Definir destinatarios, lectura, resolución y archivado de notificaciones.
- Mantener los eventos levantados originalmente: vencimiento próximo de contratos, evaluaciones pendientes, capacitación no aprobada, plazo de apelación de suspensión, aumento salarial (si se valida). 
- Separar el concepto de notificación de novedad, con reglas de generación y priorización.
- Mantener pendientes los canales: sistema, correo, alerta interna y otro, sin inventar un motor más amplio no aprobado.

### 9.9 TO-BE funcional del módulo de retiro
- Completar el flujo de retiro con actividades, entrevista, documentos y cierre formal.
- Definir estados de: en proceso, pendiente, finalizado, cancelado.
- Mantener explícitamente: fecha de retiro, motivo, carta de renuncia cuando aplique, aceptación, formato de entrega de documentos, certificado laboral, últimas tres planillas de seguridad social, documentos entregados y entrevista de retiro.
- Permitir revisión documental, actas y certificación.
- Mantener historial de decisiones, observaciones y cierre legal o administrativo.

### 9.10 Requerimientos propuestos / pendientes de validación
- PROPUESTA / PENDIENTE DE VALIDACIÓN: evaluar si el proceso de incapacidad debe incluir seguimiento de pago.
- PROPUESTA / PENDIENTE DE VALIDACIÓN: evaluar si la suspensión debe impactar el salario o la remuneración, según la normativa y el caso.
- PROPUESTA / PENDIENTE DE VALIDACIÓN: definir si las solicitudes internas requieren prioridad operativa o jerárquica.
- PROPUESTA / PENDIENTE DE VALIDACIÓN: definir la cobertura funcional por área, cargo o usuario para solicitudes, notificaciones y novedades.
- PROPUESTA / PENDIENTE DE VALIDACIÓN: evaluar comunicaciones externas o masivas, si el negocio las requiere y si se aprueba su alcance.
- PROPUESTA / PENDIENTE DE VALIDACIÓN: evaluar reglas para notificaciones automatizadas más allá del sistema actual.
- PENDIENTE DE DEFINICIÓN: puntaje mínimo de aprobación para capacitación, reglas exactas para carta de compromiso y condiciones de no renovación por bajo desempeño.

### 9.11 Requerimientos de capacitación que deben conservarse
- Capacitación, participantes, asistencia, evaluación, calificación, resultado y notificación de evaluación pendiente.
- Resultado no aprobado, carta de compromiso y seguimiento del compromiso.
- El puntaje mínimo, reglas exactas para carta de compromiso, reglas de no renovación contractual y campos del Excel existente permanecen como pendientes de definición.
- La decisión sobre importar, reemplazar o mantener el Excel de capacitaciones queda pendiente de validación.

## 10. Módulos funcionales

### 10.1 Matriz funcional real

| Módulo | Estado | Evidencia real | Pendientes |
|---|---|---|---|
| Autenticación | IMPLEMENTADO | JWT, login, refresh, logout, change-password | Consolidar política de sesión y auditoría |
| Usuarios | IMPLEMENTADO | `/api/users`, roles y permisos | Reforzar trazabilidad por actor |
| Aspirantes | IMPLEMENTADO | `/api/applicants`, estados, documentos y conversión | Refinar flujos de screening y aprobaciones |
| Contratación | IMPLEMENTADO | `/api/contracting`, PDFs, contratos y documentos | Mejorar validación y cierre de documentos por contrato |
| Empleados | IMPLEMENTADO | `/api/employees`, fichas, estados y documentos | Estrategia de historial más formal |
| Dotación | IMPLEMENTADO | `/api/dotations`, tallas, entregas, evidencias, historial | Estandarizar devoluciones parciales y reposiciones |
| Herramientas | IMPLEMENTADO | `/api/tools`, `/api/tool-deliveries` | Definir política de bajas y reemplazos |
| Devoluciones | IMPLEMENTADO | `/api/returns` | Definir devoluciones con incidentes y faltantes |
| Capacitación | IMPLEMENTADO | `/api/trainings` | Ampliar seguimiento de evaluación y resultados |
| Incapacidades | PARCIAL | Integrado bajo novedades y filtros | Formalizar proceso independiente |
| Permisos / licencias | PARCIAL | Bajo novedades y permisos de acceso | Definir estados y flujo explicito |
| Notificaciones | IMPLEMENTADO | `/api/notifications` | Mejorar personalización y cumplimiento |
| Retiro | IMPLEMENTADO | `/api/retirements` | Definir cierre documental más integral |
| Llamados de atención | PARCIAL | Gestionado dentro de `Novedades` y eventos de HR | Formalizar flujo disciplinario, responsable y evidencia |
| Suspensiones | PARCIAL | Gestionado dentro de `Novedades` y estado laboral del empleado | Definir duración, motivo, apelación y cierre |
| Solicitudes internas | PLANIFICADO | No existe módulo técnico consolidado; solo se documentan tipos del levantamiento original: adelanto de vacaciones, prima y sueldo | Definir flujo, responsables, respuesta y trazabilidad |

## 11. Flujos principales

### 11.1 Autenticación
- `POST /api/auth/login`
- `POST /api/auth/refresh`
- `POST /api/auth/logout`
- `GET /api/auth/me`
- `POST /api/auth/change-password`

### 11.2 Gestión de usuarios
- Roles RBAC
- Permisos asignados por rol
- Usuarios asociados a empleados cuando aplica
- Cambio de estado y reasignación de roles

### 11.3 Gestión de aspirantes
- Registro de aspirante
- Carga de documentos
- Cambio de estado (
  `REGISTRADO`, `EN_REVISION`, `APROBADO_CONTRATACION`, `RECHAZADO`, `CONVERTIDO_EMPLEADO`, `CANCELADO`)
- Aprobación para contratación
- Conversión a empleado

### 11.4 Gestión de empleados
- Creación y actualización de empleados
- Cambio de estado laboral
- Consulta por documento
- Carga de foto y documentos
- Relación con contrato y dotación

### 11.5 Contratación
- Selección del empleado o aspirante
- Datos contractuales
- Carga de tipo de contrato y tipo de cargo
- Plantillas PDF
- Impresión y visualización
- Gestión de documentos contractuales

### 11.6 Dotación
- Catálogo de tipos, artículos y tallas
- Registro de talla por empleado
- Asignación de dotación
- Confirmación por empleado / RRHH
- Historial de entregas y evidencia
- Devoluciones y reposición

### 11.7 Herramientas
- Catálogo por herramienta
- Entregas a empleados
- Confirmación
- Historial y devoluciones

### 11.8 Capacitación
- Tareas y sesiones de capacitación
- Participantes y control de asistencia
- Evaluación y calificación
- Resultado aprobado o no aprobado
- Notificación de evaluación pendiente
- Generación de carta de compromiso cuando aplica
- Seguimiento del compromiso y cierre del caso
- Importación o mantenimiento de la matriz Excel existente según definición del negocio
- Pendiente de definición: puntaje mínimo, reglas de carta de compromiso, no renovación por bajo desempeño y formato exacto del Excel

## 12. Estados y transiciones

### 12.1 Aspirantes
Estados existentes en la validación real:

| Estado | Significado | Transición posible |
|---|---|---|
| REGISTRADO | Aspirante creado y en captura inicial | EN_REVISION, CANCELADO |
| EN_REVISION | Revisión de perfil y documentos | APROBADO_CONTRATACION, RECHAZADO |
| APROBADO_CONTRATACION | Aprobado para iniciar contratación | CONVERTIDO_EMPLEADO, CANCELADO |
| RECHAZADO | No procede para contratación | no suele reabrirse sin nuevo flujo |
| CONVERTIDO_EMPLEADO | Se convierte en empleado | seguimiento laboral |
| CANCELADO | Aspirante cancelado | no aplica continuidad |

Fuente de validación: `Back/app/Http/Requests/ChangeApplicantStatusRequest.php`.

### 12.2 Empleados
Estados reales de empleado:

| Estado | Significado |
|---|---|
| ACTIVO | Empleado vigente |
| RETIRADO | Retiro formal |
| SUSPENDIDO | Suspensión temporal |
| INCAPACITADO | Incapacidad o descanso médico |
| EN_PROCESO_RETIRO | Retiro en curso |

Fuente: `Back/app/Http/Requests/EmployeeStatus.php`.

### 12.3 Contratos
Se observan plantillas de contrato en:

- `Back/resources/views/contracts/pdf/fijo.blade.php`
- `Back/resources/views/contracts/pdf/indefinido.blade.php`
- `Back/resources/views/contracts/pdf/obra-labor.blade.php`

Los tipos de contrato se manejan por catálogo (`bbf_tipos_contrato`) y por `tipo_cargo_contrato` con valores `ADMINISTRATIVO`, `OPERATIVO`, `OTRO`.

## 13. Documentos funcionales por proceso

### 13.1 Aspirantes
- Hoja de vida
- Documento de identidad
- Soportes de experiencia o residencia según flujo
- Documentos de soporte a la contratación

### 13.2 Empleados
- Fotografía
- Documentos laborales
- Seguridad social
- Exámenes médicos
- Contratos

### 13.3 Dotación
- Evidencias de entrega
- Historial por empleado
- Confirmaciones de recibo

### 13.4 Herramientas
- Evidencias de entrega / devolución
- Historial y confirmación

### 13.5 Capacitación
- Carta de compromiso
- Evaluación y resultados
- Evidencias de participación / asistencia

### 13.6 Retiro
- Fecha de retiro
- Motivo de retiro
- Carta de renuncia cuando aplique
- Aceptación de renuncia
- Formato de entrega de documentos
- Certificado laboral
- Últimas tres planillas de seguridad social
- Documentos entregados
- Entrevista de retiro
- Registro histórico del proceso y cierre administrativo

> El retiro ya está implementado como flujo, pero aún deben validarse detalles de formato, documentos obligatorios y políticas de cierre según el levantamiento original.

> El almacenamiento físico se documenta en `architecture.md` y no se replica aquí; el PRD se centra en el tipo de documento que el proceso exige.

## 14. Requisitos funcionales

### 14.1 Requerimientos identificados

| ID | Nombre | Descripción | Actor | Estado actual |
|---|---|---|---|---|
| RF-AUT-001 | Login con JWT | Autenticación segura con token e identidad del usuario | Usuario | IMPLEMENTADO |
| RF-AUT-002 | Refresh y cierre de sesión | Renovación y logout seguros | Usuario | IMPLEMENTADO |
| RF-USR-001 | Gestión de usuarios | Crear, consultar y actualizar usuarios | Admin / RRHH | IMPLEMENTADO |
| RF-USR-002 | Roles y permisos | Administración de permisos y asociación a roles | Admin | IMPLEMENTADO |
| RF-ASP-001 | Registro de aspirante | Alta de aspirantes | RRHH / Admin | IMPLEMENTADO |
| RF-ASP-002 | Cambio de estado del aspirante | Seguimiento de estados del proceso | RRHH / Admin | IMPLEMENTADO |
| RF-ASP-003 | Aprobación para contratación | Autorizar paso a contratación | RRHH / Admin | IMPLEMENTADO |
| RF-ASP-004 | Documentos de aspirante | Carga y administración de soportes | RRHH / Admin | IMPLEMENTADO |
| RF-CON-001 | Ficha de contratación | Datos funcionales del empleado al ingresar | RRHH / Admin | IMPLEMENTADO |
| RF-CON-002 | Generación de contrato | Emitir y visualizar contrato PDF | RRHH / Admin | IMPLEMENTADO |
| RF-CON-003 | Documentos y seguridad social | Gestión de contratos, documentos, exámenes y seguridad social | RRHH / Admin | IMPLEMENTADO |
| RF-EMP-001 | Gestión de empleados | Crear, consultar, actualizar y buscar empleado | RRHH / Admin | IMPLEMENTADO |
| RF-EMP-002 | Cambio de estado laboral | Suspensión, retiro, incapacidad y proceso de retiro | RRHH / Admin | IMPLEMENTADO |
| RF-DOT-001 | Catálogo y tallas | Manejo de dotación y talla por empleado | RRHH / Empleado | IMPLEMENTADO |
| RF-DOT-002 | Entregas y evidencias | Crear entrega, confirmar recepción y conservar historial | RRHH / Empleado | IMPLEMENTADO |
| RF-HER-001 | Catálogo y entregas de herramientas | Control de stock y entregas | RRHH / Empleado | IMPLEMENTADO |
| RF-DEV-001 | Devoluciones | Devolución de herramientas o dotación | RRHH / Empleado | IMPLEMENTADO |
| RF-CAP-001 | Gestión de capacitación | Sesiones, participantes, asistencia, evaluación | RRHH / Empleado | IMPLEMENTADO |
| RF-CAP-002 | Compromisos | Seguimiento y carta de compromiso | RRHH / Empleado | IMPLEMENTADO |
| RF-NOT-001 | Notificaciones | Resumen y visualización de notificaciones | Usuario | IMPLEMENTADO |
| RF-RET-001 | Retiro laboral | Proceso de retiro, actividades y documentos | RRHH / Admin | IMPLEMENTADO |
| RF-INC-001 | Incapacidades | Seguimiento de inasistencia por enfermedad | RRHH / Admin | PARCIAL |
| RF-PER-001 | Permisos y licencias | Solicitud y seguimiento de permisos | RRHH / Empleado | PARCIAL |
| RF-LLA-001 | Llamados de atención | Gestión disciplinaria | RRHH / Admin | PARCIAL |
| RF-SUS-001 | Suspensiones | Control disciplinario y seguimiento | RRHH / Admin | PARCIAL |
| RF-SOL-001 | Solicitudes internas | Trámite interno de solicitudes y aprobación | Usuario / RRHH | PLANIFICADO |

### 14.2 Trazabilidad sugerida
- Módulo: aspirantes, empleados, contratación, dotación, herramientas, capacitaciones, retirados, notificaciones.
- Pantallas: listas, detalles, formularios y perfiles del frontend.
- Endpoints: ruta API real en `Back/routes/api.php`.
- Base de datos: tablas `bbf_*` y procedimientos `SP_BBF_*`.
- Documentos: plantillas PDF y archivos de soporte en `Back/public/uploads`.

## 15. Reglas de negocio

| ID | Descripción | Módulo | Estado | Fuente |
|---|---|---|---|---|
| RN-ASP-001 | Un aspirante debe estar aprobado para iniciar contratación. | Aspirantes | IMPLEMENTADA | `ChangeApplicantStatusRequest`, API |
| RN-ASP-002 | Los estados del aspirante están restringidos a un catálogo definido. | Aspirantes | IMPLEMENTADA | `ChangeApplicantStatusRequest` |
| RN-ASP-003 | La conversión de aspirante a empleado debe realizarse con permisos explícitos. | Aspirantes | IMPLEMENTADA | `routes/api.php` |
| RN-EMP-001 | El empleado tiene un estado laboral definido y validado. | Empleados | IMPLEMENTADA | `EmployeeStatus.php` |
| RN-EMP-002 | El empleado puede cambiar de estado laboral y registrar fecha de retiro. | Empleados | IMPLEMENTADA | `ChangeEmployeeStatusRequest` |
| RN-CON-001 | El contrato requiere tipo de contrato y datos contractuales de la persona. | Contratación | IMPLEMENTADA | `CreateEmployeeContractRequest` |
| RN-CON-002 | El tipo de cargo del contrato acepta `ADMINISTRATIVO`, `OPERATIVO` u `OTRO`. | Contratación | IMPLEMENTADA | `CreateEmployeeContractRequest` |
| RN-DOT-001 | La dotación y las tallas se registran por empleado y por artículo. | Dotación | IMPLEMENTADA | `DotationController`/repositorios |
| RN-DOT-002 | La entrega de dotación requiere evidencia y confirmación de recepción. | Dotación | IMPLEMENTADA | `/dotations/deliveries` |
| RN-HER-001 | La entrega de herramientas está protegida por permisos específicos. | Herramientas | IMPLEMENTADA | `routes/api.php` |
| RN-HER-002 | Las devoluciones de herramientas tienen confirmación y anulación. | Herramientas / Devoluciones | IMPLEMENTADA | `/returns`, `/tool-deliveries` |
| RN-CAP-001 | La capacitación requiere sesión, participantes y control de asistencia. | Capacitación | IMPLEMENTADA | `/trainings` |
| RN-CAP-002 | La evaluación y el compromiso son módulos diferenciados dentro de la capacitación. | Capacitación | IMPLEMENTADA | `/trainings/evaluations`, `/commitments` |
| RN-SEC-001 | El acceso se valida por JWT y permisos en backend. | Seguridad | IMPLEMENTADA | middleware `auth.jwt`, `permission` |
| RN-SEC-002 | El usuario no puede acceder a rutas protegidas sin permisos explícitos. | Seguridad | IMPLEMENTADA | `permissionGuard` y `EnsurePermission` |
| RN-DOC-001 | Los documentos se almacenan físicamente y se registran con ruta pública. | Documentación | IMPLEMENTADA | `architecture.md`, servicios de archivos |
| RN-RET-001 | El retiro tiene flujo de actividades, entrevista y finalización. | Retiro | IMPLEMENTADA | `/retirements` |
| RN-NOV-001 | Las novedades agrupan eventos laborales no siempre autónomos. | Novedades | IMPLEMENTADA | `/novelties` |

## 16. Gestión documental funcional

El sistema usa documentación funcional asociada a los procesos principales:

- Aspirantes: hoja de vida, identidad y soporte de contratación.
- Empleados: horas, seguridad social, exámenes médicos, foto, documentos laborales.
- Contratación: contrato, plantillas PDF y firmas en documento impreso.
- Dotación: evidencia de entrega y historial de detalle.
- Herramientas: entregas y devoluciones.
- Capacitación: compromisos y evidencias.
- Retiro: documentos y certificado asociado.

No se observa una política formal de retención, clasificación, digitalización y custodio documental fuera del almacenamiento local. Esto se declara como pendiente de definición.

## 17. Requisitos no funcionales

### Seguridad
- JWT con expiración y refresh token
- Control de roles y permisos por middleware
- Validación de CORS
- Control de contraseña y seguridad de sesión

### Trazabilidad
- Auditoría en eventos de autenticación, usuarios y operaciones críticas
- Estado: parcialmente implementado y no homogéneo por módulo

### Privacidad
- Se refleja la gestión de datos personales y documentación, pero no hay una política formal declarada de retención y tratamiento
- Estado: PENDIENTE DE DEFINICIÓN

### Disponibilidad
- No se dispone de un SLA, métrica ni objetivo cuantificado en el repositorio
- Estado: PENDIENTE DE DEFINICIÓN

### Facilidad de uso
- ES funcional y orientado a flujos de RRHH con menús y permisos por persona
- Estado: IMPLEMENTADO a nivel operativo

### Integridad de información
- Se observa robustez por validaciones y procedimientos almacenados
- Riesgo: reglas duplicadas entre Laravel y MySQL

### Gestión documental
- Existe almacenamiento físico y referencias en BD
- Estado: PARCIAL, requiere política formal

## 18. Restricciones

- El sistema depende fuertemente del esquema MySQL existente y procedimientos `SP_BBF_*`.
- Los cambios de base de datos implican cambios de backend y de negocio.
- La documentación funcional no siempre está alineada con el alcance real.
- La estrategia documental local en `public/uploads` requiere coordinación de despliegue.
- La lógica de negocio se reparte entre Laravel y base de datos.

## 19. Dependencias

- Angular frontend para UX y seguridad de navegación.
- Laravel backend para seguridad real y lógica de negocio.
- MySQL / procedimientos almacenados para persistencia y lógica crítica.
- Archivos físicos para documentos e evidencias.
- Roles y permisos para acceso.
- Catálogos y parámetros del sistema.

## 20. Fuera de alcance actual

### A. NO IMPLEMENTADO COMPLETAMENTE EN AS-IS / PENDIENTE DE EVOLUCIÓN
- Llamados de atención como módulo disciplinario formal y autónomo.
- Suspensiones disciplinarias con flujo, documentos y apelación definidos.
- Solicitudes internas como flujo administrativo formal con aprobación y trazabilidad documental específica.
- Incapacidades como módulo formal y autónomo independiente de Novedades.

### B. FUERA DE ALCANCE DEL PRODUCTO ACTUAL
- Política de almacenamiento documental externa o cloud no aprobada.
- Integración con sistemas externos no definidos en el repositorio.
- Microservicios o arquitectura distribuida.
- Cambios de infraestructura no contemplados como requerimiento funcional del producto.

> No se incluyen dentro de fuera de alcance elementos que formen parte del TO-BE del producto; solo se catalogan los elementos que no cuentan con aprobación funcional ni alcance definido para el producto actual.

## 21. Riesgos funcionales

1. Dependencia crítica de procedimientos almacenados.
2. Duplicidad de lógica entre backend y BD.
3. Módulos de novedad usados como sustituto de flujos funcionales formales.
4. Archivos públicos sin política formal de retención.
5. Mapa de estados y permisos no homogéneo entre módulos.
6. Riesgo de inestabilidad en flujos de contratación si no se formaliza la relación con catálogo y documentos.

## 22. Supuestos

- La base de datos y procedimientos almacenados existentes son la fuente de verdad operativa.
- La documentación no es suficiente para declarar funciones inexistentes.
- El código representa la funcionalidad real y vigente.
- El producto continuará evolucionando a partir del AS-IS vigente.

## 23. Pendientes de definición

- Modelo de incapacidades con flujo, documentos, certificados y estados.
- Permisos y licencias con estado, aprobación y calendarización.
- Llamados de atención disciplinarios y suspensión formal.
- Solicitudes internas y su flujo de aprobación.
- Política documental de retención, acceso y ubicación.
- Notificaciones avanzadas y alertas personalizadas.
- Métricas de desempeño, SLA y capacidad disponible.

## 24. Matriz AS-IS / TO-BE

| Área | AS-IS | TO-BE |
|---|---|---|
| Aspirantes | Registro, documentos y estados funcionales | Mejorar gestión de screening y aprobación |
| Empleados | Ficha, estado, documentos y relación con contrato | Consolidar historial laboral y trazabilidad |
| Contratación | Contratos, PDF, documentos, exámenes, seguridad social | Formalizar flujos de aprobación y firma |
| Dotación | Alta, tallas, entregas, evidencia, historial | Definir reposición y devoluciones parciales con mayor control |
| Herramientas | Entregas y devolución operativa | Mejorar bajas, reemplazos y incidentes |
| Capacitación | Sesiones, resultados y compromiso | Definir supervisión y seguimiento con más indicadores |
| Novedades | Funcionalidad operativa para eventos no formales | Desagregar incapacidades, permisos y sanciones |
| Retiro | Proceso operativo real | Cerrar flujo documental y finalización más robusta |
| Seguridad | JWT + roles + permisos | Ajustar y documentar trazabilidad y políticas |

## 25. Criterios de éxito del producto

- La organización puede operar todo el ciclo de RRHH desde aspirante a retiro con trazabilidad suficiente.
- Los usuarios acceden por roles y permisos específicos.
- Los procesos más críticos están respaldados por documento y evidencia.
- La conversión aspirante -> empleado resulta consistente y verificable.
- La contratación, dotación, herramientas y capacitación no requieren procesos paralelos no controlados.
- El sistema dispone de una visión clara de pendientes funcionales para evolución.

## 26. Trazabilidad

| Requerimiento | Módulo | Vista / endpoint | Evidencia |
|---|---|---|---|
| RF-AUT-001 | Autenticación | `/api/auth/login`, `/api/auth/refresh` | `Back/routes/api.php` |
| RF-USR-002 | Usuarios / permisos | `/api/users`, `/api/roles`, `/api/permissions` | `Back/routes/api.php` |
| RF-ASP-001 | Aspirantes | `/api/applicants` | `ApplicantController` |
| RF-ASP-003 | Aspirantes / contratación | `/api/applicants/{id}/approve-contracting` | `Back/routes/api.php` |
| RF-CON-002 | Contratación | `/api/contracting/...` | `Front/src/app/app.routes.ts` |
| RF-EMP-001 | Empleados | `/api/employees` | `Back/routes/api.php` |
| RF-DOT-001 | Dotación | `/api/dotations` | `DotationController` |
| RF-HER-001 | Herramientas | `/api/tools`, `/api/tool-deliveries` | `Back/routes/api.php` |
| RF-CAP-001 | Capacitación | `/api/trainings` | `TrainingController` |
| RF-RET-001 | Retiro | `/api/retirements` | `RetirementController` |

## 27. Conclusiones

BBF SisAdmin ya es un sistema funcional y operativo, orientado principalmente a RRHH y administración interna del ciclo de vida del empleado. El producto actual resuelve la mayoría de los procesos críticos del dominio: ingreso, personal, contratación, dotación, herramientas, capacitación, documentación, notificaciones y retiro. Sin embargo, el alcance no está totalmente consolidado ni homogéneo: varios procesos funcionales aparecen tratados como novedades o tareas operativas más que como módulos dedicados y formalizados.

La ruta correcta para la evolución del producto no es iniciar de cero. Debe ser una formalización del AS-IS real, reforzando los flujos ya probados y cerrando los vacíos del dominio con validación de negocio y trazabilidad explícita.

## 28. Matriz funcional final

| Módulo | Estado | Evidencia | Pendientes |
|---|---|---|---|
| Autenticación | IMPLEMENTADO | Código/API/JWT | Reforzar auditoría y sesiones |
| Usuarios | IMPLEMENTADO | Código/API | Mejorar trazabilidad por usuario |
| Aspirantes | IMPLEMENTADO | Código/API/BD | Refinar estados y documentación |
| Contratación | IMPLEMENTADO | Código/API/PDF | Formalizar tipos y cierre documental |
| Empleados | IMPLEMENTADO | Código/API | Mejorar historial y vida laboral |
| Dotación | IMPLEMENTADO | Código/API | Reposiciones y devoluciones parciales |
| Herramientas | IMPLEMENTADO | Código/API | Dar mayor control a bajas y reemplazos |
| Devoluciones | IMPLEMENTADO | Código/API | Definir incidentes, faltantes y ausencia |
| Capacitación | IMPLEMENTADO | Código/API | Seguimiento más analítico |
| Notificaciones | IMPLEMENTADO | Código/API | Personalización y alertas |
| Incapacidades | PARCIAL | Novedades y seguimiento | Formalizar módulo independiente |
| Permisos / licencias | PARCIAL | Novedades y permisos de acceso | Definir flujo y documentación |
| Llamados de atención | PARCIAL | `Novedades` + estado del empleado | Formalizar flujo disciplinario |
| Suspensiones | PARCIAL | `Novedades` + estado del empleado | Definir plazo de apelación y cierre |
| Solicitudes internas | PLANIFICADO | Tipos esperados del levantamiento original, pero sin módulo técnico evidenciado | Definir aprobación y responsables |
| Retiro laboral | IMPLEMENTADO | Código/API | Mejorar cierre documental |

## 29. Resumen de cierre para BMAD

El PRD de BBF SisAdmin se sustenta en evidencia real del código, no en supuestos de negocio. A partir de este documento, la siguiente etapa del flujo BMAD debería ser la definición de epics y stories para evolución del producto, priorizando:

1. Formalización de aspirantes y contratación.
2. Consolidación de la entidad empleado.
3. Mejoramiento del modelo de dotación y herramientas.
4. Módulos pendientes de incapacidad, permisos, sanciones y solicitudes internas.
5. Gobernanza documental y trazabilidad.

