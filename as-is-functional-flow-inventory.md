# Mapa de Flujos Funcionales AS-IS para Validación

## Objetivo
Este documento consolida el inventario funcional AS-IS del sistema BBF SisAdmin con base exclusiva en la evidencia real del repositorio: frontend, backend, rutas, controladores, servicios, repositorios, permisos, procedimientos y tablas relevantes. No se diseñan nuevas funcionalidades ni se interpretan expectativas del PRD como funcionalidad existente.

## Alcance de esta revisión
Se toma como base la evidencia técnica real de:
- `Back/routes/api.php`
- `Back/app/Http/Controllers/Api/*`
- `Back/app/Services/*`
- `Back/app/Repositories/*`
- `Front/src/app/app.routes.ts`
- `BD/*.sql`
- documentación de contexto AS-IS existente como referencia, no como fuente única de verdad funcional

## Clasificación de hallazgos usada
- IMPLEMENTADO: existe evidencia técnica suficiente.
- PARCIALMENTE IMPLEMENTADO: existe parte del flujo, pero falta una pieza relevante o no está completamente trazada.
- DOCUMENTADO PERO NO EVIDENCIADO: aparece en documentación, pero no se encuentra respaldo real en código/BD.
- IMPLEMENTADO PERO NO DOCUMENTADO: existe en el sistema y no está bien reflejado en la documentación AS-IS.
- REQUIERE VALIDACIÓN FUNCIONAL: el código muestra varias posibilidades y requiere confirmación del negocio.

## Matriz maestra de flujos funcionales AS-IS

| ID | Módulo | Flujo | Estado | Evidencia | Confianza | Requiere validación |
|---|---|---|---|---|---|---|
| F-001 | Seguridad | Autenticación y sesión | IMPLEMENTADO | `AuthController`, `AuthService`, `JwtAuthenticate`, `routes/api.php` | ALTO | NO |
| F-002 | Seguridad | Usuarios, roles y permisos | IMPLEMENTADO | `UserController`, `RoleController`, `UserRepository`, `RoleRepository`, SQL `bbf_usuarios`, `bbf_roles`, `bbf_permisos` | ALTO | NO |
| F-003 | Aspirantes | Carga, seguimiento y conversión a empleado | IMPLEMENTADO | `ApplicantController`, rutas `applicants`, `app.routes.ts` | ALTO | NO |
| F-004 | Empleados | Gestión de empleado, foto, estado y consulta | IMPLEMENTADO | `EmployeeController`, `EmployeeRepository`, rutas `employees` | ALTO | NO |
| F-005 | Contratación | Perfil, contrato, seguridad social, exámenes, documentos | IMPLEMENTADO | `ContractingController`, rutas `contracting`, `contracting` en Angular | ALTO | NO |
| F-006 | Carga masiva | Importación masiva de empleados | IMPLEMENTADO | `BulkLoadEmployeeController`, `bulk-load/employees` | ALTO | NO |
| F-007 | Dotación | Mis tallas y entregas | IMPLEMENTADO | `DotationController`, rutas `dotations/my-sizes`, `my-deliveries`, `deliveries` | ALTO | NO |
| F-008 | Herramientas | Entrega y confirmación de herramientas | IMPLEMENTADO | `ToolController`, `MyToolDeliveryController`, rutas `tools`, `tool-deliveries`, `my-tool-deliveries` | ALTO | NO |
| F-009 | Devoluciones | Solicitud y confirmación de devoluciones | IMPLEMENTADO | `ReturnController`, rutas `returns` | ALTO | NO |
| F-010 | Capacitación | Catálogo, sesiones, participantes, evaluaciones, compromisos | IMPLEMENTADO | `TrainingController`, rutas `trainings` | ALTO | NO |
| F-011 | Novedades | Registro, soporte, seguimiento, tipos dentro del módulo y tratamiento especializado de incapacidad | IMPLEMENTADO | `NoveltyController`, rutas `novelties` | ALTO | NO |
| F-012 | Retiro | Solicitud, entrevista, documentos, finalización y trazabilidad operativa del proceso de salida | IMPLEMENTADO | `RetirementController`, rutas `retirements` | ALTO | NO |
| F-013 | Notificaciones | Resumen, lectura, archivo, resolución y sincronización de alertas operativas | IMPLEMENTADO | `NotificationController`, `NotificationService`, `NotificationRepository`, `SP_BBF_NOTIFICACIONES_SINCRONIZAR`, rutas `notifications` | ALTO | NO |
| F-014 | Parámetros y catálogos | Administración de entidades y valores operativos | IMPLEMENTADO | `ParametersController`, `CatalogController`, rutas `parameters` y `catalogs` | ALTO | NO |
| F-015 | Documentos operativos | Carga y gestión documental por flujo | IMPLEMENTADO | `ApplicantController`, `ContractingController`, `uploads`, servicios de documentos | ALTO | NO |

## Hallazgos de clasificación

### IMPLEMENTADO
Se confirma por código y rutas en backend/frontend que existen los flujos de autenticación, usuarios, roles, permisos, aspirantes, empleados, contratación, dotación, herramientas, devoluciones, capacitaciones, novedades, retiros, parámetros y documentos operativos.

### IMPLEMENTADO (alcance real verificado)
El flujo de notificaciones está validado como capacidad funcional real del sistema: existe sincronización de alertas, resumen de pendientes, listado, lectura, archivo y resolución de notificaciones por usuario autenticado. La evidencia demuestra gestión operativa real de alertas internas, con soporte técnico en `NotificationRepository::synchronize()` y en los SP `SP_BBF_NOTIFICACIONES_SINCRONIZAR`, `SP_BBF_NOTIFICACIONES_LISTAR`, `SP_BBF_NOTIFICACIONES_RESUMEN`, `SP_BBF_NOTIFICACION_MARCAR_LEIDA`, `SP_BBF_NOTIFICACION_ARCHIVAR` y `SP_BBF_NOTIFICACION_RESOLVER`.

La validación del Product Owner confirma que la funcionalidad AS-IS relevante es la gestión real de notificaciones internas del sistema, no un portal universal de alertas externas ni un inventario completo de todos los disparadores del negocio. Por eso, el flujo se reconoce como implementado dentro del alcance actual, sin inventar automatismos no evidenciados.

### DOCUMENTADO PERO NO EVIDENCIADO
No se identifican módulos funcionales reales con documentación detallada y ausencia total de implementación, siempre que se limite el análisis al alcance actual del repositorio. Sí existe documentación de alcance y contexto, pero no un conjunto de módulos no existentes.

### IMPLEMENTADO PERO NO DOCUMENTADO
Existe evidencia de auto-servicio, gestión documental y parametrización funcional que no siempre está descrita explícitamente en la documentación AS-IS revisada. Sin embargo, estas capacidades deben tratarse como transversales o subflujos, no como flujos independientes de la misma magnitud que un módulo funcional completo.

### REQUIERE VALIDACIÓN FUNCIONAL
Los casos que requieren confirmación del Product Owner siguen siendo los relacionados con:
- alcance real de “self-service” del empleado frente a un portal universal;
- validación puntual de si la obligatoriedad documental del retiro puede flexibilizarse por tipo de salida o motivo, sin afectar el AS-IS actual.

F-011 quedó validado funcionalmente con el Product Owner: permisos, llamados de atención y suspensiones forman parte del módulo `Novedades`, y la incapacidad conserva tratamiento especializado sin modificar automáticamente el estado del empleado.

F-012 quedó validado funcionalmente con el Product Owner: el estado del empleado puede cambiar de forma separada del flujo formal de retiro, la entrevista y el certificado no bloquean ese cambio, y el cierre del retiro no implica cambio automático del estado laboral.

F-013 quedó validado funcionalmente con el Product Owner: la gestión de notificaciones es real y operativa dentro del alcance AS-IS actual, con sincronización de alertas y capacidades de lectura, archivo y resolución; no se requiere asumir automatización global ni canales externos no evidenciados.

### Capacidades transversales que no se cuentan como flujos independientes
- Auto-servicio del empleado: se valida como capacidad funcional transversal dentro de dotación, herramientas y capacitación, no como un módulo nuevo e independiente.
- Gestión documental operativa: es soporte documental de múltiples módulos (aspirantes, contratación, retiros, novedades), no un flujo funcional autónomo de primer nivel.
- Parametrización de catálogos: es una capacidad de configuración transversal que habilita varios módulos, no un flujo funcional independiente del negocio.

---

## F-001 – Autenticación y sesión

### Objetivo
Permitir que un usuario identificado acceda a la aplicación y obtenga una sesión válida, con tokens y permisos asociados.

### Actor(es)
- Usuario del sistema
- RRHH/administrador cuando gestiona credenciales y cambios de contraseña

### Precondiciones
- El usuario existe en `bbf_usuarios`.
- Tiene asignados roles y permisos válidos.
- El sistema conoce la clave JWT y su configuración de refresh token.

### Disparador
- Inicio de sesión del usuario con credenciales válidas.

### Flujo principal AS-IS
1. El usuario llama a `POST /api/auth/login`.
2. `AuthController` delega la autenticación a `AuthService`.
3. El backend valida credenciales, genera JWT, refresh token y claims con `roles` y `permisos`.
4. El frontend guarda tokens y metadatos en `localStorage` y los reutiliza para las llamadas posteriores.
5. La sesión autenticada se valida por `auth.jwt`.
6. El usuario puede consultar su perfil con `GET /api/auth/me`.
7. En caso de token vencido o no autorizado, el cliente puede refrescar la sesión con `POST /api/auth/refresh`.
8. El usuario puede cerrar sesión con `POST /api/auth/logout`.
9. Puede cambiar contraseña con `POST /api/auth/change-password`.

### Decisiones del usuario
- Elegir autenticar con credenciales válidas.
- Resolver un cambio de contraseña cuando el sistema lo exige.
- Determinar si reinicia sesión tras expiración o refresh.

### Estados involucrados
- Usuario autenticado
- Usuario sin sesión
- Sesión expirada/renovada
- Contraseña pendiente de cambio

### Permisos involucrados
- No aplica a permisos explícitos del flujo, pero sí se validan claims de `roles` y `permisos` en la sesión.

### Backend involucrado
- `Back/routes/api.php`
- `Back/app/Http/Controllers/Api/AuthController.php`
- `Back/app/Services/AuthService.php`
- `Back/app/Http/Middleware/JwtAuthenticate.php`
- `Back/app/Http/Middleware/EnsurePermission.php`

### Persistencia
- `bbf_usuarios`
- `bbf_usuario_sesiones` o equivalentes en la BD
- refresh tokens con manejo de hash o sesión

### Resultado del flujo
- El usuario queda autenticado y autorizado para acceder a rutas según sus permisos.

### Evidencia
- `Back/routes/api.php` (prefijo `auth`)
- `Back/app/Services/AuthService.php`
- `Back/app/Http/Middleware/EnsurePermission.php`
- `Back/config/jwt.php`

### Nivel de confianza
ALTO

### Preguntas para validación
- ¿La política de cambio obligatorio de contraseña es siempre de negocio o aplica solo a ciertos perfiles?
- ¿La sesión del usuario se considera válida únicamente por JWT o también por validación de sesión activa en BD?

---

## F-002 – Usuarios, roles y permisos

### Objetivo
Administrar la identidad del usuario, su asociación a roles y la autorización efectiva a través de permisos/capacidades.

### Actor(es)
- Administrador de seguridad o RRHH con permisos
- Usuario final para consulta de su perfil y permisos

### Precondiciones
- Existen usuarios, roles y permisos en el sistema.
- El usuario ejecutor tiene permiso para administrar usuarios o consultar permisos.

### Disparador
- Alta, actualización, cambio de estado, asignación o retiro de roles/permisos.

### Flujo principal AS-IS
1. Se listan o consultan usuarios mediante `GET /api/users` y `GET /api/users/{id}`.
2. Se crea o actualiza un usuario con `POST /api/users` y `PATCH /api/users/{id}`.
3. Se cambia el estado del usuario con `PATCH /api/users/{id}/estado`.
4. Se asignan roles con `POST /api/users/{id}/roles`.
5. Se eliminan roles con `DELETE /api/users/{id}/roles/{roleId}`.
6. Se consultan roles y permisos del usuario con `GET /api/users/{id}/roles` y `GET /api/users/{id}/permissions`.
7. Se administran roles con `GET /api/roles`, `POST /api/roles`, `PATCH /api/roles/{id}/estado`, `DELETE /api/roles/{id}`.
8. Se gestionan permisos de un rol con `GET /api/roles/{id}/permissions`, `POST /api/roles/{id}/permissions` y `DELETE /api/roles/{id}/permissions/{permissionId}`.
9. El backend valida permisos reales con `EnsurePermission` y no solo con el rol nominal.

### Decisiones del usuario
- Qué usuario recibe qué rol.
- Qué permisos se habilitan para cada rol.
- Qué usuario tiene acceso a qué módulos y operaciones.

### Estados involucrados
- Usuario activo/inactivo
- Rol activo/inactivo
- Permiso asignado/no asignado

### Permisos involucrados
- `USUARIOS_*`
- `ROLES_*`
- `PERMISOS_LISTAR`
- permisos específicos por módulo aplicados en la ruta

### Backend involucrado
- `Back/app/Http/Controllers/Api/UserController.php`
- `Back/app/Http/Controllers/Api/RoleController.php`
- `Back/app/Repositories/UserRepository.php`
- `Back/app/Repositories/RoleRepository.php`
- `Back/app/Http/Middleware/EnsurePermission.php`

### Persistencia
- `bbf_usuarios`
- `bbf_usuario_roles`
- `bbf_roles`
- `bbf_rol_permisos`
- `bbf_permisos`
- `SP_BBF_USUARIO_OBTENER_ROLES`
- `SP_BBF_USUARIO_OBTENER_PERMISOS`
- `SP_BBF_USUARIO_ROLES_ASIGNAR`
- `SP_BBF_USUARIO_ROLES_QUITAR`

### Resultado del flujo
- El acceso efectivo del usuario queda determinado por la combinación de sus roles y permisos.

### Evidencia
- `Back/routes/api.php`
- `Back/app/Repositories/UserRepository.php`
- `Back/app/Repositories/RoleRepository.php`
- `BD/2608241Dev.sql`

### Nivel de confianza
ALTO

### Preguntas para validación
- ¿El cambio de estado del usuario se usa siempre como un control de acceso o también como control operativo?
- ¿Existen perfiles fijos de negocio que el cliente espera documentar y no solo permisos configurables?

---

## F-003 – Aspirantes

### Objetivo
Registrar, consultar y evolucionar la información de aspirantes hasta su aprobación para contratación o conversión a empleado.

### Actor(es)
- RRHH
- Reclutador/gestor de talento
- Usuario autorizado con permisos de aspirantes

### Precondiciones
- Existe un aspirante con datos básicos cargados.
- Se cuenta con documentos, estados y permisos de seguimiento habilitados.

### Disparador
- Alta de un aspirante o cambio de estado del mismo.

### Flujo principal AS-IS
1. Se consulta el listado de aspirantes con `GET /api/applicants`.
2. Se registra un aspirante con `POST /api/applicants`.
3. Se consulta el detalle `GET /api/applicants/{applicantId}`.
4. Se actualiza con `PUT /api/applicants/{applicantId}`.
5. Se cambia el estado con `PATCH /api/applicants/{applicantId}/status`.
6. Se aprueba para contratación con `POST /api/applicants/{applicantId}/approve-contracting`.
7. Se registran documentos y historial documental del aspirante.
8. El aspirante puede convertirse en empleado con `POST /api/applicants/{applicantId}/convert-to-employee`.

### Decisiones del usuario
- Aprobar, rechazar o mover al aspirante por estado.
- Decidir si continúa al enfoque de contratación o se convierte en empleado.
- Cargar documentos y soportes del proceso.

### Estados involucrados
- Aspirante activo
- Estado de proceso
- Aprobado para contratación
- Convertido a empleado

### Permisos involucrados
- `ASPIRANTES_VER`
- `ASPIRANTES_CREAR`
- `ASPIRANTES_EDITAR`
- `ASPIRANTES_CAMBIAR_ESTADO`
- `ASPIRANTES_APROBAR_CONTRATACION`
- `ASPIRANTES_DOCUMENTOS_VER`
- `ASPIRANTES_DOCUMENTOS_SUBIR`
- `ASPIRANTES_CONVERTIR_EMPLEADO`

### Backend involucrado
- `Back/app/Http/Controllers/Api/ApplicantController.php`
- `Back/app/Services/ApplicantService.php` (si existe en la capa real del proyecto)
- `Back/app/Repositories/ApplicantRepository.php` (si aplica según la implementacion real)

### Persistencia
- Tablas y SP relacionadas con aspirantes, documentos y cambio de estado
- `applicants` y registros de documentos asociados

### Resultado del flujo
- El aspirante queda en un estado operativo de contratación o en convertibilidad a empleado.

### Evidencia
- `Back/routes/api.php` (prefijo `applicants`)
- `Front/src/app/app.routes.ts` (`/admin/applicants`, `/admin/applicants/:applicantId`)

### Nivel de confianza
ALTO

### Preguntas para validación
- ¿La conversión a empleado es un paso manual de RRHH o se valida también con una aprobación automática por cumplimiento de requisitos?
- ¿Existe una diferencia de negocio entre “aprobado para contratación” y “convertido a empleado” que el cliente quiera reflejar explícitamente?

---

## F-004 – Empleados

### Objetivo
Mantener y consultar la ficha del empleado, su estado laboral y la información asociada a la operación del trabajador.

### Actor(es)
- RRHH
- Administrador de personal
- Usuarios con permisos de empleados

### Precondiciones
- El empleado ya existe o proviene de un proceso de contratación/aspirante.
- El usuario tiene permisos para consultar o editar empleados.

### Disparador
- Alta, consulta, edición o cambio de estado de un empleado.

### Flujo principal AS-IS
1. Se listan empleados con `GET /api/employees`.
2. Se consulta un empleado por ID o documento con `GET /api/employees/{id}` y `/api/employees/by-document/{document}`.
3. Se crea un registro con `POST /api/employees`.
4. Se sube foto con `POST /api/employees/{id}/photo`.
5. Se actualiza la ficha con `PATCH /api/employees/{id}`.
6. Se cambia el estado con `PATCH /api/employees/{id}/estado`.
7. Se elimina o desactiva según la lógica del controller.

### Decisiones del usuario
- Qué datos se registran en la ficha.
- Qué estado laboral corresponde al empleado en cada momento.
- Si una situación operativa requiere un cambio de estado manual.

### Estados involucrados
- Activo
- Retirado
- Suspendido
- Incapacitado
- En proceso de retiro
- otros estados definidos según la base de datos y catálogo de validación

### Permisos involucrados
- `EMPLEADOS_LISTAR`
- `EMPLEADOS_VER`
- `EMPLEADOS_CREAR`
- `EMPLEADOS_EDITAR`
- `EMPLEADOS_CAMBIAR_ESTADO`
- `EMPLEADOS_ELIMINAR`

### Backend involucrado
- `Back/app/Http/Controllers/Api/EmployeeController.php`
- `Back/app/Repositories/EmployeeRepository.php`
- `Back/app/Http/Requests/EmployeeStatus.php`

### Persistencia
- `bbf_empleados`
- `SP_BBF_EMPLEADOS_CAMBIAR_ESTADO`
- `SP_BBF_EMPLEADOS_*` según la implementación real del repositorio

### Resultado del flujo
- La ficha del empleado permanece actualizada, con su estado laboral y documentos asociados.

### Evidencia
- `Back/routes/api.php`
- `Front/src/app/app.routes.ts` (`/admin/employees`)
- `BD/2608241Dev.sql` y SP de empleados

### Nivel de confianza
ALTO

### Preguntas para validación
- ¿El cambio de estado del empleado se hace solo de forma manual por RRHH o también por otros roles con permisos?
- ¿Los estados reales del negocio coinciden con los valores que el código permite?

---

## F-005 – Contratación

### Objetivo
Gestionar el perfil de contratación, la generación de contratos, seguridad social, exámenes médicos, documentos y registro del contrato firmado.

### Actor(es)
- RRHH
- Usuario autorizado de contratación
- Empleado o solicitante según la operación

### Precondiciones
- Existe empleado o perfil de contratación activo.
- Existen parámetros de contrato, salario mínimo, tipos de documento y plantillas.

### Disparador
- Apertura de un proceso de contratación o tramitación de contrato para un empleado.

### Flujo principal AS-IS
1. Se listan empleados de contratación con `GET /api/contracting/employees`.
2. Se consulta la información y parámetros de generación con `GET /api/contracting/contracts/{employeeContractId}/generation-data`.
3. Se crea o actualiza el contrato con `POST /api/contracting/employees/{employeeId}/contracts` y `PUT .../{employeeContractId}`.
4. Se firma el contrato con `POST /api/contracting/contracts/{employeeContractId}/sign`.
5. Se revisan o registran documentos del empleado con rutas de documentos asociados.
6. Se gestionan seguridad social y exámenes médicos.
7. El contrato y documentos pueden descargarse o consultarse con permisos de lectura.

### Decisiones del usuario
- Elegir contrato, plantilla y parámetros legales/operativos.
- Marcar el contrato como firmado y registrar la evidencia documental.
- Validar seguridad social, exámenes médicos y documentos pendientes.

### Estados involucrados
- Perfil abierto/actualizado
- Contrato generado
- Contrato firmado
- Exámenes médicos registrados
- Seguridad social asociada

### Permisos involucrados
- `CONTRATACION_VER`
- `CONTRATACION_CREAR`
- `CONTRATACION_EDITAR`
- `CONTRATACION_ELIMINAR`
- `CONTRATACION_HISTORIAL_VER`
- `CONTRATACION_SEGURIDAD_SOCIAL_VER`
- `CONTRATACION_SEGURIDAD_SOCIAL_EDITAR`
- `CONTRATACION_EXAMENES_VER`
- `CONTRATACION_EXAMENES_CREAR`
- `CONTRATACION_DOCUMENTOS_VER`
- `CONTRATACION_DOCUMENTOS_SUBIR`
- `CONTRATACION_ALERTAS_VER`

### Backend involucrado
- `Back/app/Http/Controllers/Api/ContractingController.php`
- `Back/app/Services/ContractingService.php`
- `Back/app/Repositories/ContractingRepository.php`
- `Back/resources/views/contracts/pdf/`

### Persistencia
- tablas de contratos, perfil, documentos, seguridad social, exámenes médicos
- rutas de archivo en `Back/public/uploads`
- metadatos del documento firmado asociado al contrato

### Resultado del flujo
- El empleado queda documentado y con contratación registrada, con evidencia de documento firmado según el alcance actual.

### Evidencia
- `Back/routes/api.php` (prefijo `contracting`)
- `Front/src/app/app.routes.ts` (`/admin/contracting/...`)
- `Back/resources/views/contracts/pdf/`
- `Back/public/uploads`

### Nivel de confianza
ALTO

### Preguntas para validación
- ¿La “firma de contrato” del sistema se usa como registro documental o se espera una validación de firma digital legal en un flujo posterior?
- ¿La firma del contrato se exige siempre para completar la contratación o solo se registra en ciertos casos?

---

## F-006 – Carga masiva de empleados

### Objetivo
Importar información masiva de empleados y validar el archivo previo a la carga.

### Actor(es)
- RRHH o administrador de personal
- Usuario con permisos de empleados

### Precondiciones
- Existe plantilla de importación.
- El archivo cumple el formato esperado.
- El usuario tiene permisos de lectura/validación y carga.

### Disparador
- Solicitud de carga masiva desde UI o endpoint específico.

### Flujo principal AS-IS
1. Se solicita la plantilla con `GET /api/bulk-load/employees/template`.
2. Se envía el archivo para validación con `POST /api/bulk-load/employees/validate`.
3. Si pasa validación, se ejecuta la importación con `POST /api/bulk-load/employees/import`.

### Decisiones del usuario
- Cargar un archivo correcto respecto al formato.
- Repetir validación si aparecen inconsistencias.
- Confirmar la importación final.

### Estados involucrados
- Plantilla disponible
- Archivo validado
- Archivo rechazado
- Importación ejecutada

### Permisos involucrados
- `EMPLEADOS_VER`
- `EMPLEADOS_CREAR`

### Backend involucrado
- `Back/app/Http/Controllers/Api/BulkLoadEmployeeController.php`
- `Back/routes/api.php`

### Persistencia
- importación de empleados en tablas relacionadas con empleado y datos básicos

### Resultado del flujo
- Se incorpora información masiva a empleados sin necesidad de capturar registro por registro.

### Evidencia
- `Back/routes/api.php`
- `Front/src/app/app.routes.ts` (`/admin/bulk-load`) 

### Nivel de confianza
ALTO

### Preguntas para validación
- ¿La carga masiva tiene reglas de negocio particulares por área o por tipo de empleado?
- ¿El archivo se valida exclusivamente en formato o también en reglas de negocio y consistencia?

---

## F-007 – Dotación: mis tallas y entregas

### Objetivo
Permitir a un empleado registrar sus tallas y consultar su historial de dotación, así como gestionar entregas y confirmaciones por parte del RRHH.

### Actor(es)
- Empleado
- RRHH o administrador de dotación

### Precondiciones
- Existe catálogo de tipos, tamaños, artículos y combinaciones de dotación.
- El empleado tiene acceso a su información personal de dotación.

### Disparador
- Solicitud de registro de talla o entrega de dotación.

### Flujo principal AS-IS
1. El empleado consulta sus tallas con `GET /api/dotations/my-sizes`.
2. Guarda sus medidas o preferencias con `POST /api/dotations/my-sizes`.
3. Consulta entregas propias con `GET /api/dotations/my-deliveries`.
4. RRHH consulta empleados o entregas con rutas administrativas.
5. Se crean entregas con `POST /api/dotations/deliveries`.
6. Se prepara la entrega con `POST /api/deliveries/{deliveryId}/prepare`.
7. Se confirma la recepción con `POST /api/dotations/deliveries/{deliveryId}/confirm` o por RRHH con `confirm-by-hr`.
8. Se revisan evidencias y detalles asociados.

### Decisiones del usuario
- Qué tallas o artículos se registran.
- Si la entrega se confirma por el empleado o por RRHH.
- Si se reemplaza o elimina evidencia de entrega.

### Estados involucrados
- Talla registrada
- Entrega preparada
- Entrega confirmada
- Entrega con evidencia
- Entrega eliminada o anulada según la lógica del sistema

### Permisos involucrados
- `DOTACIONES_CATALOGOS_VER`
- `DOTACIONES_MIS_TALLAS_VER`
- `DOTACIONES_MIS_TALLAS_EDITAR`
- `DOTACIONES_MIS_ENTREGAS_VER`
- `DOTACIONES_MIS_ENTREGAS_CONFIRMAR`
- `DOTACIONES_ADMIN_VER`
- `DOTACIONES_EMPLEADO_VER`
- `DOTACIONES_ENTREGAS_CREAR`
- `DOTACIONES_ENTREGAS_VER`
- `DOTACIONES_ENTREGAS_ELIMINAR`

### Backend involucrado
- `Back/app/Http/Controllers/Api/DotationController.php`
- `Back/app/Services/DotationService.php`
- `Back/app/Repositories/DotationRepository.php`

### Persistencia
- `bbf_dotaciones_*` o procedimientos vinculados a dotación
- entregas, evidencias y tallas registradas por empleado

### Resultado del flujo
- El empleado cuenta con su información de talla y la organización registra la entrega documental de dotación y su confirmación.

### Evidencia
- `Back/routes/api.php` (prefijo `dotations`)
- `Front/src/app/app.routes.ts` (`dotations/my-sizes`, `my-deliveries`, `deliveries`)

### Nivel de confianza
ALTO

### Preguntas para validación
- ¿La confirmación de entrega es siempre obligatoria por parte del empleado o también puede quedar como proceso RRHH?
- ¿Las evidencias de entrega son opcionales o requeridas en todo caso?

---

## F-008 – Herramientas y entregas de herramientas

### Objetivo
Gestionar el inventario de herramientas, su entrega y la confirmación por parte del empleado responsable.

### Actor(es)
- RRHH/administrador de herramientas
- Empleado receptor

### Precondiciones
- Existen herramientas disponibles y un catálogo de detalle.
- El usuario tiene permisos para administrar o confirmar entregas.

### Disparador
- Registro o entrega de una herramienta a un empleado.

### Flujo principal AS-IS
1. Se consulta el listado de herramientas con `GET /api/tools`.
2. Se registra una herramienta o se actualiza con `POST /api/tools` y `PUT /api/tools/{id}`.
3. Se crea una entrega con `POST /api/tool-deliveries`.
4. Se consulta una entrega concreta con `GET /api/tool-deliveries/{id}`.
5. Se confirma la entrega con `POST /api/tool-deliveries/{id}/confirm`.
6. El empleado puede consultar sus entregas con `GET /api/my-tool-deliveries` y confirmar `POST /api/my-tool-deliveries/{id}/confirm`.

### Decisiones del usuario
- Qué herramientas se entregan.
- Qué responsable confirma la entrega.
- Qué actúa como mantenimiento o retiro de entregas.

### Estados involucrados
- Herramienta registrada
- Entrega creada
- Entrega confirmada
- Entrega eliminada o anulada según operación

### Permisos involucrados
- `HERRAMIENTAS_LISTAR`
- `HERRAMIENTAS_CREAR`
- `HERRAMIENTAS_EDITAR`
- `HERRAMIENTAS_ENTREGAR`
- `HERRAMIENTAS_CONFIRMAR`
- `HERRAMIENTAS_ELIMINAR`
- `HERRAMIENTAS_MIS_ENTREGAS_VER`

### Backend involucrado
- `Back/app/Http/Controllers/Api/ToolController.php`
- `Back/app/Http/Controllers/Api/MyToolDeliveryController.php`

### Persistencia
- tablas de herramientas y entregas de herramientas
- registros de confirmación y evidencia de entrega

### Resultado del flujo
- Se deja trazado el control de herramientas asignadas a cada empleado y la confirmación de recepción.

### Evidencia
- `Back/routes/api.php` (prefijos `tools`, `tool-deliveries`, `my-tool-deliveries`)
- `Front/src/app/app.routes.ts` (`/admin/tools`, `/admin/tool-deliveries`, `/admin/my-tool-deliveries`)

### Nivel de confianza
ALTO

### Preguntas para validación
- ¿La confirmación de herramientas por parte del empleado es obligatoria siempre o depende de un proceso específico?
- ¿La eliminación o anulación de entregas tiene un flujo documental explícito en el negocio?

---

## F-009 – Devoluciones

### Objetivo
Registrar devolución de materiales, herramientas o elementos asignados y generar la confirmación del cierre del proceso.

### Actor(es)
- Empleado
- RRHH o administrador

### Precondiciones
- Hay elementos disponibles o entregados que pueden devolverse.
- El usuario tiene permiso para crear o confirmar devoluciones.

### Disparador
- Solicitud de devolución de un material o herramienta.

### Flujo principal AS-IS
1. Se consultan elementos disponibles para devolución con `GET /api/returns/available`.
2. Se recorre el listado de devoluciones con `GET /api/returns`.
3. Se crea una devolución con `POST /api/returns`.
4. Se consulta el detalle con `GET /api/returns/{id}`.
5. Se confirma la devolución con `POST /api/returns/{id}/confirm`.
6. Se puede anular la devolución con `POST /api/returns/{id}/cancel`.

### Decisiones del usuario
- Elegir qué elementos se devuelven.
- Confirmar que la devolución fue realizada.
- Cancelar la devolución si no aplica o se corrige la solicitud.

### Estados involucrados
- Disponible para devolución
- Solicitud creada
- Devolución confirmada
- Devolución cancelada

### Permisos involucrados
- `DEVOLUCIONES_CREAR`
- `DEVOLUCIONES_VER`
- `DEVOLUCIONES_CONFIRMAR`
- `DEVOLUCIONES_ANULAR`

### Backend involucrado
- `Back/app/Http/Controllers/Api/ReturnController.php`
- `Back/app/Services/ReturnService.php`
- `Back/app/Repositories/ReturnRepository.php`

### Persistencia
- tablas de devoluciones y elementos devueltos

### Resultado del flujo
- La organización puede cerrar la entrega física/operativa de un bien y mantener trazabilidad documental.

### Evidencia
- `Back/routes/api.php` (prefijo `returns`)
- `Front/src/app/app.routes.ts` (`/admin/returns`)

### Nivel de confianza
ALTO

### Preguntas para validación
- ¿La devolución siempre representa la salida de un activo de dotación o también puede aplicarse a instrumentos o documentos?
- ¿El proceso es de tipo manual con evidencia o se exige un registro automatizado en más de un sistema?

---

## F-010 – Capacitación

### Objetivo
Gestionar catalogación de capacitaciones, sesiones, participantes, evaluaciones, confirmaciones y compromisos de cumplimiento.

### Actor(es)
- RRHH o administrador de formación
- Empleado participante
- Usuario con permisos de capacitación

### Precondiciones
- Existen tareas, sesiones o cursos programados.
- Los participantes tienen permisos para consultar su historial y/o confirmar cumplimiento.

### Disparador
- Programación, asignación, evaluación o confirmación de capacitación.

### Flujo principal AS-IS
1. Se consulta el catálogo o listado de capacitaciones con `GET /api/trainings` y `GET /api/trainings/tasks`.
2. Se crea o edita una capacitación con `POST /api/trainings` y `PATCH`/`save` según implementación.
3. Se crean sesiones con `POST /api/trainings/sessions`.
4. Se consultan sesiones y detalles con `GET /api/trainings/sessions/{sessionId}`.
5. Se agregan participantes y se registran asistencias con `PATCH /api/participants/{participantId}/attendance`.
6. Se evaluan resultados con `POST /api/trainings/evaluations` y `POST /api/trainings/results`.
7. Se confirman asistencias con `POST /api/participants/{participantId}/confirm` o confirmación de RRHH.
8. El empleado puede consultar sus registros con `GET /api/trainings/my/records`.
9. Se gestionan alertas y compromisos de cumplimiento.

### Decisiones del usuario
- Qué persona asiste o no asistió.
- Qué evaluación se registra.
- Qué compromiso de cumplimiento se ejecuta.

### Estados involucrados
- Sesión creada
- Participante registrado
- Asistencia confirmada
- Evaluación registrada
- Compromiso generado o actualizado

### Permisos involucrados
- `CAPACITACIONES_VER`
- `CAPACITACIONES_ADMINISTRAR`
- `CAPACITACIONES_IMPORTAR`
- `CAPACITACIONES_EVALUAR`
- `CAPACITACIONES_CONFIRMAR`
- `CAPACITACIONES_MIS_REGISTROS_VER`
- `CAPACITACIONES_COMPROMISOS`

### Backend involucrado
- `Back/app/Http/Controllers/Api/TrainingController.php`
- `Back/app/Services/TrainingService.php`
- `Back/app/Repositories/TrainingRepository.php`

### Persistencia
- sesiones, participantes, evaluaciones, compromisos y registros de asistencia

### Resultado del flujo
- Queda trazado el cumplimiento y seguimiento de capacitaciones del empleado.

### Evidencia
- `Back/routes/api.php` (prefijo `trainings`)
- `Front/src/app/app.routes.ts` (`/admin/trainings`, `/admin/trainings/my-records`)

### Nivel de confianza
ALTO

### Preguntas para validación
- ¿La confirmación del empleado es siempre vinculante para cerrar la capacitación o puede quedar como registro no obligatorio?
- ¿Los compromisos de cumplimiento tienen un proceso de supervisión y cierre distinto del registro de asistencia?

---

## F-011 – Novedades

### Objetivo
Registrar hechos relevantes del empleado dentro del módulo de `Novedades`, incluyendo permisos, llamados de atención, suspensiones e incapacidades. La incapacidad se trata como un flujo especializado por sus datos adicionales y su seguimiento, pero sin modificar automáticamente el estado del empleado.

### Actor(es)
- RRHH
- Usuarios con permisos de novedades
- Empleado involucrado

### Precondiciones
- Existe empleado y tipo de novedad definido.
- El usuario tiene permisos para crear o modificar novedades.
- El tipo de novedad puede requerir soporte documental o no, según el caso y sin obligación universal.

### Disparador
- Registro de una novedad asociada a un empleado.
- Registro de una incapacidad como subtipo especializado dentro del mismo módulo.

### Flujo principal AS-IS
1. Se consultan tipos de novedades con `GET /api/novelties/types`.
2. Se listan novedades con `GET /api/novelties`.
3. Se crea una novedad general con `POST /api/novelties`.
4. Se registra una incapacidad con `POST /api/novelties/disabilities`.
5. Se consulta seguimiento de discapacidad con `GET /api/novelties/{id}/disability-tracking`.
6. Se guarda seguimiento con `PUT /api/novelties/{id}/disability-tracking`.
7. Se modifica la novedad con `PUT /api/novelties/{id}`.
8. Se cambia el estado de la novedad con `PATCH /api/novelties/{id}/status`.
9. Se agregan soportes con `POST /api/novelties/{id}/evidence` cuando corresponde.
10. Se exporta seguimiento por incapacidades cuando aplica.

### Decisiones del usuario
- Qué tipo de novedad se registra.
- Si acompaña la novedad con soporte o evidencia documental, según el caso.
- Si la operación requiere dejar el registro y decidir otra acción manual de RRHH, sin automatizar el cambio de estado del empleado.

### Estados involucrados
- Novedad creada
- Novedad en revisión
- Novedad aprobada o cerrada
- Incapacidad registrada
- Seguimiento activo o finalizado

### Permisos involucrados
- `NOVEDADES_VER`
- `NOVEDADES_CREAR`
- `NOVEDADES_EDITAR`
- `NOVEDADES_CAMBIAR_ESTADO`
- `NOVEDADES_SOPORTES`

### Backend involucrado
- `Back/app/Http/Controllers/Api/NoveltyController.php`
- `Back/app/Services/NoveltyService.php`
- `Back/app/Repositories/NoveltyRepository.php`

### Persistencia
- tablas de novedades, incapacidades, soporte y seguimiento
- `SP_BBF_NOVEDAD_CREAR`
- `SP_BBF_INCAPACIDAD_CREAR`
- `SP_BBF_NOVEDAD_CAMBIAR_ESTADO`

### Resultado del flujo
- La organización deja un registro operativo de la novedad/incapacidad y su evolución. El cambio de estado del empleado no se dispara automáticamente al registrar una incapacidad ni al registrar una novedad general; esa acción sigue siendo manual y separada.

### Evidencia
- `Back/routes/api.php` (prefijo `novelties`)
- `Front/src/app/app.routes.ts` (`/admin/novelties`)
- `BD/2608241Dev.sql` / `SP_BBF_*` de novedades e incapacidades

### Nivel de confianza
ALTO

### Estado funcional validado por Product Owner
- `F-011 – Novedades` se considera `IMPLEMENTADO` y con `VALIDACIÓN FUNCIONAL COMPLETADA`.
- Permisos, llamados de atención y suspensiones forman parte del módulo `Novedades` y no requieren módulos funcionales independientes.
- La incapacidad conserva un tratamiento especializado y no obliga a cambiar automáticamente el estado del empleado.
- La evidencia no es obligatoria para todas las novedades; se admite cuando corresponde, pero no como requisito universal.
- No quedan pendientes funcionales de F-011.

---

## F-012 – Retiro

### Objetivo
Gestionar el ciclo formal de retiro del empleado, manteniendo información, trazabilidad, actividades, documentos y cierre del proceso de salida. El flujo de retiro es independiente del cambio de estado laboral del empleado.

### Actor(es)
- RRHH
- Empleado
- Usuario con permisos de retiros

### Precondiciones
- Existe proceso de retiro asociado a un empleado.
- El usuario tiene permisos para operar sobre retiro.
- La obligatoriedad documental es del AS-IS actual y puede requerir información adicional según el caso.

### Disparador
- Inicio del proceso de retiro del empleado.

### Flujo principal AS-IS
1. Se consultan motivos y tipos de documentos de retiro con `GET /api/retirements/reasons` y `/document-types`.
2. Se listan retiros con `GET /api/retirements`.
3. Se crea un retiro con `POST /api/retirements`.
4. Se consulta detalle con `GET /api/retirements/{id}`.
5. Se gestionan actividades con `PATCH /api/retirements/{id}/activities`.
6. Se registra entrevista con `PUT /api/retirements/{id}/interview`.
7. Se suben documentos con `POST /api/retirements/{id}/documents`.
8. Se genera certificado cuando aplica con `GET /api/retirements/{id}/certificate`.
9. Se finaliza el proceso con `POST /api/retirements/{id}/finalize`.
10. Se puede cancelar con `POST /api/retirements/{id}/cancel`.

### Decisiones del usuario
- Determinar si se finaliza o cancela el retiro.
- Decidir si el estado del empleado cambia o permanece según la operación manual de RRHH.
- Revisar la entrevista, certificados asociados y documentos requeridos por el flujo formal.
- La entrevista y el certificado no bloquean la salida operativa del empleado ni el cambio de estado laboral.

### Estados involucrados
- Retiro en trámite
- Retiro con entrevista
- Retiro con documentos
- Retiro finalizado
- Retiro cancelado

### Permisos involucrados
- `RETIROS_VER`
- `RETIROS_CREAR`
- `RETIROS_EDITAR`
- `RETIROS_DOCUMENTOS`
- `RETIROS_ENTREVISTA`
- `RETIROS_CERTIFICADO_GENERAR`
- `RETIROS_FINALIZAR`
- `RETIROS_CANCELAR`

### Backend involucrado
- `Back/app/Http/Controllers/Api/RetirementController.php`
- `Back/app/Services/RetirementService.php`
- `Back/app/Repositories/RetirementRepository.php`

### Persistencia
- tablas de retiros, motivos, entrevista, documentos y cierre de proceso
- `SP_BBF_RETIROS_*` u equivalentes del repositorio

### Resultado del flujo
- Se mantiene un registro documental y operativo del retiro, con la posibilidad de cerrarlo y generar la certificación asociada. El cambio de estado del empleado es una decisión independiente y manual; completar o finalizar el retiro no lo modifica automáticamente.

### Evidencia
- `Back/routes/api.php` (prefijo `retirements`)
- `Front/src/app/app.routes.ts` (`/admin/retirements`)
- `BD/*.sql` con procedimientos y tablas de retiros

### Nivel de confianza
ALTO

### Estado funcional validado por Product Owner
- `F-012 – Retiro` se considera `IMPLEMENTADO` y con `VALIDACIÓN FUNCIONAL COMPLETADA`.
- El flujo formal de retiro es independiente del cambio de estado del empleado.
- El cambio de estado puede ejecutarse sin completar el módulo formal de retiro.
- La entrevista de retiro y el certificado laboral no son requisitos de bloqueo para cambiar el estado del empleado.
- La obligatoriedad documental del retiro existe como condición AS-IS actual, pero no debe interpretarse como requisito técnico para un cambio de estado laboral.
- No quedan pendientes funcionales de F-012.

---

## F-013 – Notificaciones

### Objetivo
Gestionar la visualización, lectura, archivo y resolución de alertas operativas visibles por el usuario autenticado.

### Actor(es)
- Usuarios con permisos de notificaciones
- RRHH o responsables de gestión operativa

### Precondiciones
- Existen registros de notificaciones para el usuario autenticado.
- El usuario tiene permisos de visualización y gestión.
- La sincronización del sistema ha generado o actualizado las notificaciones según la regla vigente del proceso.

### Disparador
- Consulta del panel de notificaciones o acción del usuario sobre una notificación existente.
- La generación de la alerta puede surgir desde sincronización operativa de una condición de negocio o proceso asociado.

### Flujo principal AS-IS
1. Se sincronizan notificaciones con `NotificationRepository::synchronize()`.
2. Se consulta el resumen con `GET /api/notifications/summary`.
3. Se listan notificaciones con `GET /api/notifications`.
4. Se marcan como leídas con `PATCH /api/notifications/{id}/read`.
5. Se archivan con `PATCH /api/notifications/{id}/archive`.
6. Se resuelven con `PATCH /api/notifications/{id}/resolve` cuando el usuario tiene el permiso apropiado.

### Decisiones del usuario
- Revisar y filtrar alertas relevantes.
- Resolver o archivar una notificación según el criterio operativo.

### Estados involucrados
- Notificación activa
- Leída
- Archivada
- Resuelta

### Permisos involucrados
- `NOTIFICACIONES_VER`
- `NOTIFICACIONES_GESTIONAR`

### Backend involucrado
- `Back/app/Http/Controllers/Api/NotificationController.php`
- `Back/app/Services/NotificationService.php`
- `Back/app/Repositories/NotificationRepository.php`
- procedimientos `SP_BBF_NOTIFICACIONES_SINCRONIZAR`, `SP_BBF_NOTIFICACIONES_LISTAR`, `SP_BBF_NOTIFICACIONES_RESUMEN`, `SP_BBF_NOTIFICACION_MARCAR_LEIDA`, `SP_BBF_NOTIFICACION_ARCHIVAR`, `SP_BBF_NOTIFICACION_RESOLVER`

### Persistencia
- registros de notificaciones y estados de lectura/archivo/resolución
- sincronización en `NotificationRepository::synchronize()`

### Resultado del flujo
- El usuario puede consultar, gestionar y cerrar visualmente las alertas operativas asignadas a su sesión.

### Evidencia
- `Back/routes/api.php` (prefijo `notifications`)
- `Front/src/app/app.routes.ts` (`/admin/notifications`)
- `Back/app/Http/Controllers/Api/NotificationController.php`
- `Back/app/Repositories/NotificationRepository.php`
- `03 . Entregas/QAExport260921.sql` con `SP_BBF_NOTIFICACIONES_SINCRONIZAR` y la lógica de creación/resolución manual

### Nivel de confianza
ALTO

### Estado funcional validado por Product Owner
- `F-013 – Notificaciones` se considera `IMPLEMENTADO` y con `VALIDACIÓN FUNCIONAL COMPLETADA` dentro del alcance real AS-IS.
- El sistema soporta la gestión de alertas internas operativas y la resolución del usuario autenticado.
- No se debe interpretar este flujo como un portal universal de notificaciones externas ni como un inventario completo de todos los disparadores del negocio sin evidencia específica.
- La funcionalidad implementada queda validada como gestión real de notificaciones del sistema, no como automatización no documentada del total del negocio.

### Clasificación auditada
IMPLEMENTADO

La evidencia demuestra la gestión real de notificaciones por usuario, con sincronización, resumen, lectura, archivo y resolución dentro del alcance funcional actual y validado por Product Owner.

---

## F-014 – Parámetros y catálogos administrativos

### Objetivo
Mantener listados y configuraciones operativas compartidas por el sistema: departamentos, municipios, áreas, posiciones, tipos de documento, tipos de contrato, documentos laborales, seguridad social, exámenes médicos, tipos de novedad, normativas y parámetros del sistema.

### Actor(es)
- Administrador del sistema
- RRHH
- Usuarios con permisos de parametrización

### Precondiciones
- Existen las entidades y permisos requeridos para crear o consultar parámetros.

### Disparador
- Consulta o administración de catálogos y dominios.

### Flujo principal AS-IS
1. Se consultan catálogos con ruta `catalogs/*` u `parameters/*`.
2. Se editan registros con `post`/`put` específicos.
3. Se actualizan parámetros del sistema por dominio.

### Decisiones del usuario
- Definir o ajustar valores del catálogo que usan otros flujos. 

### Estados involucrados
- Parámetro activo/inactivo
- Registro actualizado

### Permisos involucrados
- `PARAMETROS_VER`
- `PARAMETROS_ADMINISTRAR`
- permisos de módulos específicos para cada catálogo

### Backend involucrado
- `Back/app/Http/Controllers/Api/CatalogController.php`
- `Back/app/Http/Controllers/Api/ParametersController.php`

### Persistencia
- catálogos de negocio y parámetros del sistema, según tablas y SP del esquema

### Resultado del flujo
- Los demás módulos usan valores normalizados del sistema y no requieren hardcoding de referencia operativa.

### Evidencia
- `Back/routes/api.php` (secciones `catalogs` y `parameters`)
- `Back/app/Http/Controllers/Api/ParametersController.php`

### Nivel de confianza
ALTO

### Preguntas para validación
- ¿Existen catálogos administrados por negocio que no están visibles como parámetros del sistema y que deben confirmarse manualmente?

---

## F-015 – Gestión documental operativa

### Objetivo
Recoger, asociar y mantener documentos generados por distintos flujos: aspirantes, empleados, contrataciones, incapacidades, retiros y entregas.

### Actor(es)
- RRHH
- Usuario responsable del proceso
- Empleado según el caso

### Precondiciones
- Existe un flujo que genera o requiere un documento.
- El documento debe ser cargado o referenciado por una ruta pública/relativa.

### Disparador
- Carga de documento por parte del usuario o proceso operativo.

### Flujo principal AS-IS
1. Se carga un archivo al servidor en `Back/public/uploads`.
2. Se persiste la ruta relativa asociada a un registro de negocio.
3. Se consulta o descarga el documento por su ID o por la entidad relacionada.
4. Se actualiza o elimina el documento si el proceso lo requiere.

### Decisiones del usuario
- Qué archivo se adjunta y a qué flujo pertenece.
- Si debe reemplazarse o eliminarse un documento asociado.

### Estados involucrados
- Documento cargado
- Documento asociado
- Documento actualizado
- Documento descargado o eliminado

### Permisos involucrados
- Dependiendo del flujo: `ASPIRANTES_DOCUMENTOS_*`, `CONTRATACION_DOCUMENTOS_*`, `RETIROS_DOCUMENTOS`, `NOVEDADES_SOPORTES`, etc.

### Backend involucrado
- `ApplicantController`
- `ContractingController`
- `NoveltyController`
- `RetirementController`
- servicios de documentos y almacenamiento físico en `Back/public/uploads`

### Persistencia
- rutas de archivos en base de datos
- tablas relacionadas a cada entidad operativa

### Resultado del flujo
- Existe evidencia documental del proceso, con trazabilidad en la entidad que lo originó.

### Evidencia
- `Back/public/uploads`
- `Back/app/Services/*`
- `Back/routes/api.php` con endpoints de documentos asociados

### Nivel de confianza
ALTO

### Preguntas para validación
- ¿La gestión documental está pensada como evidencia operativa únicamente o también como soporte legal/contractual de un archivo oficial?

---

## Orden recomendado de validación con Product Owner

1. F-001 – Autenticación y sesión
   - Es la base de acceso de todo el sistema y define quién puede ejecutar cada flujo.
2. F-002 – Usuarios, roles y permisos
   - Delimita la estructura de autorización efectiva y permite entender los permisos reales del negocio.
3. F-004 – Empleados
   - Es el centro operativo del sistema y punto de referencia para casi todos los demás módulos.
4. F-003 – Aspirantes
   - Es la puerta de entrada al ciclo de ingreso/contratación y precede al empleado.
5. F-005 – Contratación
   - Se enfoca en la formalización del vínculo laboral y la documentación relacionada.
6. F-007 – Dotación
   - Es un flujo operativo concreto y muy visible del empleado.
7. F-008 – Herramientas
   - Complementa la dotación y refuerza la trazabilidad del empleado.
8. F-010 – Capacitación
   - Tiene alta relevancia operativa y de cumplimiento.
9. F-011 – Novedades
   - Es un flujo operativamente sensible porque registra decisiones y estados no necesariamente automatizados.
10. F-012 – Retiro
   - Tiene dependencias de empleado, documentación, cierre operativo y validación de estado.
11. F-009 – Devoluciones
   - Es más específico y suele revisarse después del ciclo de dotación/herramientas.
12. F-013 – Notificaciones
   - Requiere validación de origen y regla de negocio antes de considerarlo un proceso totalmente entendido.
13. F-014 – Parámetros y catálogos
   - Es un soporte de configuración compartido por los demás módulos.
14. F-015 – Gestión documental operativa
   - Se complementa con los demás flujos y se revisa mejor al final como soporte transversales.

## Contradicciones detectadas y evidencia de diferencia

1. El código y la documentación AS-IS coinciden en que existe una gestión operativa de novedades e incapacidades, pero no existe automatización del cambio de estado del empleado como consecuencia directa del registro. La evidencia real exige separar “registro del hecho” de “cambio de estado administrativo”.
2. El sistema soporta la firma de contrato como gestión documental del contrato firmado, pero no se evidencia firma digital legal ni validación criptográfica real.
3. El sistema cuenta con auto-servicio funcional (mis tallas, mis entregas, mis registros de capacitación), pero no evidencia un portal universal completo del empleado.
4. Los permisos y roles son configurables y efectivos, no rígidos por perfiles fijos; el negocio debe validarse como combinación real de permisos y no como perfil único.
5. La notificación existe como mecanismo operativo, pero no aparece completamente trazado el origen exacto y la regla de disparo para cada alerta.

## Conclusión funcional
La evidencia real del repositorio confirma un sistema Brownfield con flujos operativos ya implantados y protegidos por JWT + permisos. El inventario AS-IS del presente documento no añade funcionalidad nueva ni interpreta requisitos faltantes; solo documenta los procesos observados y deja para validación funcional los puntos donde la intención del negocio debe confirmarse con el Product Owner.

## Estado de validación del documento
- Documento creado: SI
- Código modificado: NO
- BD modificada: NO
- Documentación AS-IS existente modificada: NO
- Listo para validación flujo por flujo con Product Owner: SI
