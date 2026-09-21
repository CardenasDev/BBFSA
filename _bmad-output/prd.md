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

El negocio requiere un sistema administrativo que centralice la gestión de talento, nómina operativa y documentación laboral que acompaña el ciclo de la persona dentro de la organización. El sistema actual resuelve la necesidad de registrar aspirantes, aprobarlos para contratación, crear empleados, controlar documentación, manejar entregas, realizar seguimientos periódicos y cerrar procesos de retiro. Aunque el producto ya está en operación, la base funcional muestra áreas de madurez distinta: algunas áreas están consolidadas y otras aún dependen de catalogación, novedad o procedimientos no formalizados.

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

### Alcance no comprobado como módulo formal
- Llamados de atención
- Suspensiones
- Solicitudes internas
- Gestión de incapacidades como proceso independiente
- Política documental centralizada y externa

## 6. Estado Brownfield

El sistema es Brownfield porque:

- Ya existe un contexto funcional operativoreal.
- Fondo de negocio ya definido y parcialmente implementado.
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

### 7.4 Usuario del sistema (generico)
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

### 8.2 Módulos parcialmente implementados

| Módulo | Estado | Observación |
|---|---|---|
| Incapacidades | PARCIAL | Se manejan como novedad o seguimiento, no como módulo autónomo dedicado |
| Permisos/licencias | PARCIAL | Corresponden a novedades o eventos registrados en flujo general |
| Documentación laboral | PARCIAL | Existente por procesos, pero sin política y estructura documental centralizada clara |
| Trazabilidad operativa | PARCIAL | Existe auditoría, pero no está estandarizada transversalmente |

### 8.3 Módulos no encontrados como funcionalidad formal

| Módulo | Estado |
|---|---|
| Llamados de atención | NO ENCONTRADO |
| Suspensiones | NO ENCONTRADO |
| Solicitudes internas | NO ENCONTRADO |
| Flujo independiente de incapacidades | NO ENCONTRADO como módulo completo |

### 8.4 Modelo funcional central
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

### 9.3 Requerimientos pendientes de decisión
- Definir modelo de solicitud interna y aprobación.
- Definir si las incapacidades son procesos con seguimiento médico, fechas, documentación y acciones de retorno.
- Definir flujo operativo para suspensiones y llamados de atención.
- Definir explícitamente políticas de notificaciones masivas o personalizadas.

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
| Llamados de atención | NO ENCONTRADO | No hay módulo ni rutas dedicadas | PLANIFICADO / pendiente |
| Suspensiones | NO ENCONTRADO | No hay evidencia funcional | PLANIFICADO / pendiente |
| Solicitudes internas | NO ENCONTRADO | No hay evidencia de módulo | PENDIENTE DE DEFINICIÓN |

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
- Tareas y sesiones
- Participantes
- Asistencia
- Evaluación y resultados
- Cartas de compromiso
- Seguimiento de compromisos y alertas

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
- Certificado o documento de retiro
- Documentos asociados
- Entrevista y cierre de procesos

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
| RF-LLA-001 | Llamados de atención | Gestión disciplinaria | RRHH / Admin | PLANIFICADO |
| RF-SUS-001 | Suspensiones | Control disciplinario y seguimiento | RRHH / Admin | PLANIFICADO |
| RF-SOL-001 | Solicitudes internas | Trámite interno de solicitudes y aprobación | Usuario / RRHH | PENDIENTE DE DEFINICIÓN |

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

- Aspirantes: documentos de vida, identidad y soporte de contratación.
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

### FUERA DE ALCANCE ACTUAL
- Llamados de atención formalizado como módulo independiente.
- Suspensiones disciplinarias con flujo y documentos propios.
- Solicitudes internas como flujo administrativo con aprobación y trazabilidad documental específica.
- Política de almacenamiento documental externa o cloud.
- Integración con sistemas externos no documentados en repositorio.
- Microservicios o arquitectura distribuida.

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

- Modelo de incapacidades con flujo, documentos, certifcados y estados.
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
| Llamados de atención | PLANIFICADO / NO ENCONTRADO | Requerimientos | Pendiente de validación |
| Suspensiones | PLANIFICADO / NO ENCONTRADO | Requerimientos | Pendiente de validación |
| Solicitudes internas | PENDIENTE DE DEFINICIÓN | Requerimientos | Definición funcional faltante |
| Retiro laboral | IMPLEMENTADO | Código/API | Mejorar cierre documental |

## 29. Resumen de cierre para BMAD

El PRD de BBF SisAdmin se sustenta en evidencia real del código, no en supuestos de negocio. A partir de este documento, la siguiente etapa del flujo BMAD debería ser la definición de epics y stories para evolución del producto, priorizando:

1. Formalización de aspirantes y contratación.
2. Consolidación de la entidad empleado.
3. Mejoramiento del modelo de dotación y herramientas.
4. Módulos pendientes de incapacidad, permisos, sanciones y solicitudes internas.
5. Gobernanza documental y trazabilidad.

