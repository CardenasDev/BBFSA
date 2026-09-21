# PRD AS-IS – BBF SisAdmin

## 1. Objetivo del documento

Este documento describe únicamente el estado funcional verificado del sistema actual en desarrollo. El contenido se restringe a lo que existe en:

- `Front/`
- `Back/`
- `BD/`
- rutas reales de Laravel;
- controladores reales;
- servicios reales;
- repositorios reales;
- requests y validaciones reales;
- middleware real;
- tablas y procedimientos almacenados reales.

No se incluyen requisitos futuros, recomendaciones, TO-BE ni funcionalidad inferida.

## 2. Modelo real de seguridad y autorización

### 2.1 Entidad de seguridad real

La entidad base del sistema es el usuario autenticado. La autenticación real se implementa mediante JWT y refresh token en `Back/routes/api.php` y `Back/app/Http/Middleware/JwtAuthenticate.php`.

Evidencia:
- `Back/routes/api.php`: grupo `auth` con `login`, `refresh`, `logout`, `me`, `change-password`.
- `Back/app/Services/AuthService.php`: genera tokens con claims `roles` y `permisos`.
- `Back/app/Http/Middleware/EnsurePermission.php`: valida permisos desde `jwt['permisos']`.

### 2.2 Modelo de autorización real

El sistema no se basa en un actor rígido único. La evidencia confirma un modelo basado en:

1. `bbf_usuarios` — usuario.
2. `bbf_usuario_roles` — relación usuario-rol.
3. `bbf_roles` — rol configurable.
4. `bbf_rol_permisos` — relación rol-permiso.
5. `bbf_permisos` — permiso.

Evidencia BD:
- `BD/2608241Dev.sql`: `CREATE TABLE bbf_permisos`, `bbf_rol_permisos`, `bbf_roles`, `bbf_usuario_roles`, `bbf_usuarios`.

Evidencia código:
- `Back/app/Repositories/UserRepository.php`:
  - `roles(int $userId)` -> `SP_BBF_USUARIO_OBTENER_ROLES`
  - `permissions(int $userId)` -> `SP_BBF_USUARIO_OBTENER_PERMISOS`
  - `assignRole(int $userId, int $roleId)` -> `SP_BBF_USUARIO_ROLES_ASIGNAR`
  - `removeRole(int $userId, int $roleId)` -> `SP_BBF_USUARIO_ROLES_QUITAR`
- `Back/app/Repositories/RoleRepository.php`:
  - `permissions(bool $onlyActive, ?string $module)` -> `SP_BBF_PERMISOS_LISTAR`
  - `roleHasCriticalAdminPermissions` consulta `bbf_rol_permisos` + `bbf_permisos`
- `Back/app/Http/Controllers/Api/RoleController.php`:
  - `rolePermissions(int $id)`
  - `assignPermission(...)`
  - `removePermission(...)`
  - `permissions(Request $request)`
- `Back/app/Http/Middleware/EnsurePermission.php`:
  - valida `array_intersect($required, $permissions)`.

Conclusión:
- los usuarios se asocian a roles;
- los roles tienen permisos;
- los permisos definen el acceso efectivo;
- las capacidades del usuario dependen del conjunto de permisos asignados a sus roles.

No existe evidencia suficiente para afirmar un conjunto fijo de perfiles funcionales rígidos. Lo que sí existe es un modelo abierto y configurable de autorización por permisos.

### 2.3 Perfiles funcionales observados

Los perfiles funcionales observados no son roles fijos del sistema, sino combinaciones de permisos reales que se asignan a un rol. La evidencia de permisos reales aparece en `Back/routes/api.php`, por ejemplo:

- `CAPACITACIONES_VER`
- `CAPACITACIONES_ADMINISTRAR`
- `NOVEDADES_VER`
- `NOVEDADES_CREAR`
- `NOVEDADES_EDITAR`
- `NOVEDADES_CAMBIAR_ESTADO`
- `NOTIFICACIONES_VER`
- `NOTIFICACIONES_GESTIONAR`
- `RETIROS_VER`
- `RETIROS_CREAR`
- `DOTACIONES_MIS_TALLAS_VER`
- `HERRAMIENTAS_MIS_ENTREGAS_VER`
- `USUARIOS_CREAR`
- `USUARIOS_EDITAR`
- `ROLES_CREAR`
- `ROLES_EDITAR`

Por lo tanto, el documento debe describir "usuario con permisos administrativos" o "usuario con permisos de consulta propia", no "Administrador" como un perfil fijo sin evidencia.

## 3. Alcance funcional real AS-IS

### 3.1 Módulos comprobados

Los módulos con flujo funcional ejecutable y evidencia técnica en código y rutas son:

- autenticación JWT;
- usuarios;
- roles;
- permisos;
- aspirantes;
- empleados;
- contratación;
- dotación;
- herramientas;
- devoluciones;
- capacitación;
- novedades;
- notificaciones;
- retiros;
- administración de parámetros y catálogos.

Evidencia principal: `Back/routes/api.php`.

### 3.2 Módulos no evidenciados como módulo independiente

Estos conceptos pueden aparecer como funcionalidades, pero no cuentan con un módulo independiente y verificable:

- llamados de atención como módulo independiente;
- suspensiones como módulo disciplinario independiente;
- solicitudes internas;
- portal completo del empleado;
- nómina operativa como módulo funcional implementado;
- integración externa no documentada.

## 4. Flujos y capacidades verificadas

### 4.1 Autenticación y sesión

Evidencia:
- `Back/routes/api.php` — `Route::prefix('auth')`
- `Back/app/Http/Controllers/Api/AuthController.php`
- `Back/app/Services/AuthService.php`
- `Back/app/Http/Middleware/JwtAuthenticate.php`
- `BD/2608241Dev.sql` — `bbf_usuario_sesiones`

Capacidades reales:
- `POST /api/auth/login`
- `POST /api/auth/refresh`
- `POST /api/auth/logout`
- `GET /api/auth/me`
- `POST /api/auth/change-password`

### 4.2 Usuarios, roles y permisos

Evidencia:
- `Back/routes/api.php` — rutas `users`, `roles`, `permissions`
- `Back/app/Http/Controllers/Api/UserController.php`
- `Back/app/Http/Controllers/Api/RoleController.php`
- `Back/app/Repositories/UserRepository.php`
- `Back/app/Repositories/RoleRepository.php`
- `BD/2608241Dev.sql` — `bbf_usuarios`, `bbf_roles`, `bbf_permisos`, `bbf_usuario_roles`, `bbf_rol_permisos`

Capacidades reales:
- listado de usuarios;
- creación de usuarios;
- actualización de usuarios;
- cambio de estado de usuarios;
- asignación y retiro de roles por usuario;
- consulta de roles y permisos del usuario;
- listado de roles;
- cambio de estado del rol;
- listado de permisos;
- asignación y retiro de permisos por rol.

### 4.3 Aspirantes

Evidencia:
- `Back/routes/api.php` — `Route::prefix('applicants')`
- `Back/app/Http/Controllers/Api/ApplicantController.php`

Capacidades reales:
- `GET /api/applicants`
- `POST /api/applicants`
- `GET /api/applicants/{applicantId}`
- `PUT /api/applicants/{applicantId}`
- `PATCH /api/applicants/{applicantId}/status`
- `POST /api/applicants/{applicantId}/approve-contracting`
- `POST /api/applicants/{applicantId}/convert-to-employee`

### 4.4 Empleados

Evidencia:
- `Back/routes/api.php` — rutas `employees`
- `Back/app/Http/Controllers/Api/EmployeeController.php`
- `Back/app/Http/Requests/EmployeeStatus.php`
- `BD/2608241Dev.sql` — tablas relacionadas a empleados y estados

Capacidades reales:
- listado de empleados;
- búsqueda por documento;
- creación de empleado;
- actualización de empleado;
- carga de fotografía;
- cambio de estado laboral;
- eliminación lógica o física según flujo del controller.

### 4.5 Contratación

Evidencia:
- `Back/routes/api.php` — `Route::prefix('contracting')`
- `Back/app/Http/Controllers/Api/ContractingController.php`
- `Back/resources/views/contracts/pdf/`

Capacidades reales:
- listado de empleados para contratación;
- listado de plantillas de contrato;
- consulta de datos de generación de contrato;
- creación y actualización de contrato;
- firma de contrato;
- gestión de documentos, seguridad social y exámenes médicos.

### 4.6 Dotación

Evidencia:
- `Back/routes/api.php` — `Route::prefix('dotations')`
- `Back/app/Http/Controllers/Api/DotationController.php`
- `Front/src/app/app.routes.ts` — rutas `dotations/my-sizes`, `dotations/my-deliveries`

Capacidades reales:
- consulta de tipos, tallas, artículos, combinaciones, catálogos;
- consulta de mis tallas; `GET /api/dotations/my-sizes`
- guardado de mi talla; `POST /api/dotations/my-sizes`
- consulta de mis entregas; `GET /api/dotations/my-deliveries`
- entregas administrativas y confirmación;
- historial de dotación por empleado.

### 4.7 Herramientas y devoluciones

Evidencia:
- `Back/routes/api.php` — `tools`, `tool-deliveries`, `returns`
- `Back/app/Http/Controllers/Api/ToolController.php`
- `Back/app/Http/Controllers/Api/ReturnController.php`
- `Back/app/Http/Controllers/Api/MyToolDeliveryController.php`

Capacidades reales:
- gestión de herramientas;
- entrega de herramientas;
- confirmación de entrega;
- consulta de mis entregas de herramientas; `GET /api/my-tool-deliveries`
- devoluciones y confirmación de devolución.

### 4.8 Capacitación

Evidencia:
- `Back/routes/api.php` — `Route::prefix('trainings')`
- `Back/app/Http/Controllers/Api/TrainingController.php`
- `Front/src/app/app.routes.ts` — `trainings/my-records`

Capacidades reales:
- tareas de capacitación;
- sesiones;
- participantes;
- asistencia;
- evaluaciones;
- resultados;
- confirmación por empleado y por RRHH;
- compromisos de capacitación;
- consulta de mis registros; `GET /api/trainings/my/records`.

### 4.9 Novedades, permisos, llamados, suspensiones e incapacidades

Evidencia:
- `Back/routes/api.php` — `Route::prefix('novelties')`
- `Back/app/Http/Controllers/Api/NoveltyController.php`
- `Back/app/Repositories/NoveltyRepository.php`
- `Back/app/Http/Requests/SaveNoveltyRequest.php`
- `Back/app/Http/Requests/SaveDisabilityRequest.php`
- `Back/app/Services/NoveltyService.php`
- `BD/2608241Dev.sql` — `bbf_tipos_novedad`

El controller expone esta funcionalidad real:

- `types()` — catálogo de tipos de novedad.
- `index()` — listado filtrable de novedades.
- `show()` — detalle con soportes e historial.
- `store()` — comentario exacto: "Registrar permiso, llamado o suspensión.".
- `storeDisability()` — registrar incapacidad.
- `update()` — actualizar novedad general.
- `updateDisability()` — actualizar incapacidad.
- `status()` — validar, cerrar o anular.
- `addEvidence()` — agregar soporte documental.
- `disabilityTracking()` — consultar seguimiento.
- `saveDisabilityTracking()` — guardar seguimiento.
- `exportDisabilityTracking()` — exportar CSV.

Esto demuestra que:

- existe funcionalidad real de novedad general;
- existe funcionalidad real para permisos, llamados de atención y suspensiones dentro de `Novedades`;
- existe funcionalidad real de incapacidad dentro de `Novedades`;
- no existe un módulo independiente de llamados de atención, suspensiones o incapacidades como entidad separada.

### 4.10 Notificaciones

Evidencia:
- `Back/routes/api.php` — `Route::prefix('notifications')`
- `Back/app/Http/Controllers/Api/NotificationController.php`
- `Front/src/app/features/notifications/notifications.component.ts`
- `Front/src/app/core/services/notification.service.ts`

Capacidades reales:
- `GET /api/notifications/summary`
- `GET /api/notifications`
- `PATCH /api/notifications/{id}/read`
- `PATCH /api/notifications/{id}/archive`
- `PATCH /api/notifications/{id}/resolve`

### 4.11 Retiro

Evidencia:
- `Back/routes/api.php` — `Route::prefix('retirements')`
- `Back/app/Http/Controllers/Api/RetirementController.php`

Capacidades reales:
- `GET /api/retirements/reasons`
- `GET /api/retirements/document-types`
- `GET /api/retirements`
- `POST /api/retirements`
- `GET /api/retirements/{id}`
- `GET /api/retirements/{id}/certificate`
- `PATCH /api/retirements/{id}/activities`
- `PUT /api/retirements/{id}/interview`
- `POST /api/retirements/{id}/documents`
- `POST /api/retirements/{id}/finalize`
- `POST /api/retirements/{id}/cancel`

## 5. Reglas de negocio y estados verificables

### 5.1 Estados de empleado

Evidencia exacta:
- `Back/app/Http/Requests/EmployeeStatus.php`
- `Back/app/Repositories/EmployeeRepository.php` y `Back/app/Services/EmployeeService.php`
- `BD/2608241Dev.sql` — `bbf_empleados` y validadores de estado

Estados presentes en la validación real:
- `ACTIVO`
- `RETIRADO`
- `SUSPENDIDO`
- `INCAPACITADO`
- `EN_PROCESO_RETIRO`

Estos estados existen, pero no equivalen automáticamente a un módulo disciplinario completo ni a una política de retiro totalmente separada. La evidencia técnica es la validación del estado del empleado y el uso del mismo en el flujo de novedades.

### 5.2 Tipo de novedad

Evidencia exacta:
- `BD/2608241Dev.sql`: `bbf_tipos_novedad` con columnas `CODIGO`, `NOMBRE`, `REQUIERE_FECHA_FIN`, `REQUIERE_SOPORTE`, `ES_INCAPACIDAD`, `ACTIVO`.
- `Back/app/Repositories/ParametersRepository.php`: `saveNoveltyType(...)`
- `Back/app/Services/ParameterService.php`: mapeo de `es_incapacidad`

Esto confirma que la clasificación de novedades es configurable y que existe un tipo marcado como `ES_INCAPACIDAD`.

## 6. Clasificación final de procesos conflictivos

### 6.1 Llamados de atención

Evidencia real:
- `Back/app/Http/Controllers/Api/NoveltyController.php`: comentario exacto en `store()` — "Registrar permiso, llamado o suspensión."
- `Back/routes/api.php`: `POST /api/novelties` requiere `NOVEDADES_CREAR`.
- `Back/app/Repositories/NoveltyRepository.php`: `create(array $d, int $user)` invoca `SP_BBF_NOVEDAD_CREAR`.

Clasificación final:
- Funcionalidad: IMPLEMENTADO dentro de `Novedades`.
- Módulo independiente: NO EVIDENCIADO.

### 6.2 Suspensiones

Evidencia real:
- `Back/app/Http/Controllers/Api/NoveltyController.php`: `store()` incluye suspensión dentro del mismo flujo.
- `Back/app/Http/Requests/EmployeeStatus.php`: `SUSPENDIDO` como estado de empleado.
- `BD/2608241Dev.sql`: `bbf_tipos_novedad` y validación de tipo de novedad.

Clasificación final:
- Funcionalidad real dentro del módulo de novedades: IMPLEMENTADO.
- Proceso disciplinario independiente: NO EVIDENCIADO.

### 6.3 Incapacidades

Evidencia real:
- `Back/app/Http/Controllers/Api/NoveltyController.php`:
  - `storeDisability()`
  - `updateDisability()`
  - `disabilityTracking()`
  - `saveDisabilityTracking()`
  - `exportDisabilityTracking()`
- `Back/app/Repositories/NoveltyRepository.php`:
  - `createDisability()` -> `SP_BBF_INCAPACIDAD_CREAR`
  - `updateDisability()` -> `SP_BBF_INCAPACIDAD_ACTUALIZAR`
  - `disabilityTracking()` -> `SP_BBF_INCAPACIDAD_SEGUIMIENTO_OBTENER`
  - `saveDisabilityTracking()` -> `SP_BBF_INCAPACIDAD_SEGUIMIENTO_GUARDAR`
  - `listDisabilityTracking()` -> `SP_BBF_INCAPACIDADES_SEGUIMIENTO_LISTAR`
- `BD/2608241Dev.sql`: `bbf_tipos_novedad` con `ES_INCAPACIDAD`.

Clasificación final:
- Funcionalidad de incapacidad dentro de `Novedades`: IMPLEMENTADO.
- Módulo independiente de incapacidad: NO EVIDENCIADO.

## 7. Matriz funcional final

| Capacidad | Estado | Evidencia |
|---|---|---|
| Autenticación JWT | IMPLEMENTADO | `Back/routes/api.php`, `Back/app/Services/AuthService.php`, `Back/app/Http/Middleware/JwtAuthenticate.php` |
| Usuarios | IMPLEMENTADO | `Back/app/Http/Controllers/Api/UserController.php`, `Back/app/Repositories/UserRepository.php` |
| Roles | IMPLEMENTADO | `Back/app/Http/Controllers/Api/RoleController.php`, `Back/app/Repositories/RoleRepository.php` |
| Permisos | IMPLEMENTADO | `Back/app/Http/Middleware/EnsurePermission.php`, `Back/app/Repositories/PermissionRepository.php` |
| Aspirantes | IMPLEMENTADO | `Back/routes/api.php`, `Back/app/Http/Controllers/Api/ApplicantController.php` |
| Empleados | IMPLEMENTADO | `Back/app/Http/Controllers/Api/EmployeeController.php` |
| Contratación | IMPLEMENTADO | `Back/app/Http/Controllers/Api/ContractingController.php` |
| Dotación | IMPLEMENTADO | `Back/app/Http/Controllers/Api/DotationController.php` |
| Herramientas | IMPLEMENTADO | `Back/app/Http/Controllers/Api/ToolController.php` |
| Devoluciones | IMPLEMENTADO | `Back/app/Http/Controllers/Api/ReturnController.php` |
| Capacitación | IMPLEMENTADO | `Back/app/Http/Controllers/Api/TrainingController.php` |
| Novedades generales | IMPLEMENTADO | `Back/app/Http/Controllers/Api/NoveltyController.php` |
| Permisos/llamados/suspensiones dentro de novedades | IMPLEMENTADO | `NoveltyController::store()` y `SP_BBF_NOVEDAD_CREAR` |
| Incapacidad dentro de novedades | IMPLEMENTADO | `NoveltyController::storeDisability()`, `updateDisability()`, `disabilityTracking()` |
| Notificaciones | IMPLEMENTADO | `Back/app/Http/Controllers/Api/NotificationController.php` |
| Retiro | IMPLEMENTADO | `Back/app/Http/Controllers/Api/RetirementController.php` |
| Autoservicio del empleado | PARCIAL | `Back/app/Http/Controllers/Api/MyToolDeliveryController.php`, rutas `my-*` |
| Módulo independiente de llamados de atención | NO EVIDENCIADO | sin controller, ruta ni flujo específico independiente |
| Módulo independiente de suspensiones | NO EVIDENCIADO | solo evidencia en novedad + estado del empleado |
| Módulo independiente de incapacidad | NO EVIDENCIADO | existe flujo funcional dentro de novedades |
| Solicitudes internas | NO EVIDENCIADO | sin controller ni endpoints dedicados |
| Nómina operativa | NO EVIDENCIADO | sin evidencia funcional confirmada en código/BD |

## 8. Documentos y archivos reales

### 8.1 Tipos de documentos gestionados

El sistema gestiona documentos y soportes dentro de varios flujos, pero la evidencia real debe describirse por operación concreta, no por una generalización no comprobada.

Operaciones comprobadas:
- `POST /api/applicants/{applicantId}/documents` — registro de documentos de aspirante.
- `POST /api/contracting/employees/{employeeId}/documents` — registro de documentación contractual.
- `POST /api/retirements/{id}/documents` — carga de documentos de retiro.
- `POST /api/novelties/{id}/evidence` — soporte de novedad.
- `POST /api/novelties/disabilities` — creación de incapacidad con documentación asociada.
- `Back/public/uploads` — almacenamiento de archivos físicos.

No existe evidencia suficiente para afirmar una política formal de gestión documental general más allá de la operación puntual por módulo.

### 8.2 Generación de documentos

Se verifica lo siguiente:
- `Back/resources/views/contracts/pdf/` — plantillas de contrato.
- `Back/app/Http/Controllers/Api/ContractingController.php` — generación de documentos contractuales.
- `Back/app/Http/Controllers/Api/RetirementController.php` — endpoint `GET /api/retirements/{id}/certificate`.
- `NoveltyController::exportDisabilityTracking()` — exportación CSV de seguimiento de incapacidad.

No se puede afirmar que el sistema genere otros documentos sin código específico que lo demuestre.

## 9. Modelo real de actores y permisos

### 9.1 Entidad de usuario

El sistema usa la entidad `Usuario` autenticado, con estado y permisos efectivos asociados a su perfil.

Evidencia:
- `BD/2608241Dev.sql` — `bbf_usuarios`
- `Back/app/Repositories/UserRepository.php`
- `Back/app/Services/AuthService.php`

### 9.2 Método real de acceso

El acceso efectivo se resuelve por permisos y no por un conjunto rígido de perfiles de negocio. La validación real ocurre en `EnsurePermission::handle()`:

- obtiene `jwt['permisos']` del token;
- compara con `$required` de la ruta;
- devuelve `403` si no hay intersección.

Esto demuestra que el sistema autoriza por permisos reales asignados al rol del usuario.

### 9.3 Perfil funcional observado

Ejemplos de perfiles funcionales observados por permisos reales, no como roles estáticos:

- usuario con permisos de administración de usuarios;
- usuario con permisos de gestión de RRHH;
- usuario con permisos de consulta propia;
- usuario con permisos de capacitación;
- usuario con permisos de dotación y herramientas;
- usuario con permisos de novedades y seguimiento.

Estos perfiles se derivan de permisos reales del sistema y no de nombres de rol fijos obligatorios.

## 10. Conclusión AS-IS

BBF SisAdmin en su estado actual implementa un conjunto real de funcionalidad de RRHH y administración interna. La evidencia técnica confirma módulos de autenticación, usuarios, roles, permisos, aspirantes, empleados, contratación, dotación, herramientas, devoluciones, capacitación, novedades, notificaciones y retiros.

La distinción clave es que varios subprocesos no existen como módulos independientes. En cambio, aparecen como funcionalidades ejecutables dentro del módulo de Novedades o como capacidades específicas del empleado. Esto incluye permisos, llamados de atención, suspensiones e incapacidades. La lógica real del sistema se demuestra por rutas, middleware, controllers, repositories, requests y tablas/Stored Procedures; por ese motivo, el documento AS-IS debe describir la funcionalidad efectivamente implementada y no extrapolarla a módulos no comprobados.
