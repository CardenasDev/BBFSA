# AS-IS GAP VALIDATION – BBF SisAdmin

## 1. Objetivo

Este documento valida, con evidencia real del código, qué aspectos del PRD AS-IS están implementados, parcialmente implementados o no evidenciados en el sistema actual.

No se propone diseño ni requisitos nuevos. La validación se limita a comparar la evidencia técnica real de:

- `Back/routes/api.php`
- `Back/app/Http/Controllers/Api/*`
- `Back/app/Services/*`
- `Back/app/Repositories/*`
- `BD/*.sql`
- `Front/src/app/app.routes.ts`

## 2. Criterio de validación

Se usa la siguiente clasificación:

- Implementado: existe flujo real, ruta y capa de negocio/DB que lo respalda y está dentro del alcance funcional definido del proyecto.
- Implementado dentro del alcance real del proyecto: existe funcionalidad real, pero no como módulo independiente ni como automatización global; cumple el alcance real de la solución actual.
- Parcialmente implementado: existe funcionalidad real, pero falta trazabilidad completa, catalogación de disparadores o automatización del comportamiento esperado.
- Fuera del alcance actual: no existe soporte técnico indicado en la versión actual, pero sí se reconoce como evolución futura o requisito no levantado.
- No evidenciado: no aparece un flujo, ruta, servicio, repositorio ni procedimiento que lo respalde en el código actual.

## 3. Fuente de validación

Se etiqueta cada gap con una de estas fuentes:

- TÉCNICA: Confirmado mediante código, endpoint, SP, tabla o configuración.
- FUNCIONAL: Confirmado directamente por usuario/negocio durante la revisión.
- MIXTA: La implementación fue verificada técnicamente y el comportamiento/alcance fue confirmado por usuario/negocio.

La fuente de validación se usa para diferenciar lo que está respaldado por evidencia técnica de lo que solo se ha corroborado con criterio de negocio o con validación cruzada entre ambos.

## 4. Resumen ejecutivo

La base funcional actual sí tiene cobertura real en módulos clave como autenticación, usuarios, roles/permisos, empleados, contratación, dotación, herramientas, devoluciones, capacitaciones, novedades, retiros y notificaciones operativas.

La diferencia clave con el PRD AS-IS es que varios conceptos no deben evaluarse como “falta” si el proyecto no los contempla como módulos independientes ni automatizados. En este análisis se concluye lo siguiente:

1. El cambio automático de estado del empleado por novedad o incapacidad queda fuera del alcance actual del proyecto; no existe automatización, pero sí existe registro manual por RRHH.
2. Las notificaciones existen y cumplen un propósito operativo, pero falta documentar el inventario completo de disparadores y reglas.
3. La firma de contratos se soporta como registro documental del contrato firmado; no es firma digital técnica ni validación legal del archivo.
4. El auto-servicio del empleado existe dentro del alcance real del proyecto, aunque no como portal integral universal.
5. Los casos de llamados de atención, suspensiones disciplinarias y otras extensiones operativas se cubren como registro dentro de novedades y decisión manual RRHH, no como módulos separados.
6. La nómina y la integración externa quedan fuera del alcance implementado y se consideran evoluciones futuras.

## 5. Matriz de gaps AS-IS

| ID | Área | Estado | Fuente de validación | Evidencia real | Conclusión |
| --- | --- | --- | --- | --- | --- |
| GAP-001 | Cambio de estado laboral por novedad o incapacidad | Fuera del alcance actual | TÉCNICA | `SP_BBF_NOVEDAD_CREAR` y `SP_BBF_INCAPACIDAD_CREAR` registran información; `SP_BBF_EMPLEADOS_CAMBIAR_ESTADO` existe como flujo separado y manual. No se observa llamada automática desde novedad/incapacidad al cambio de estado. | El sistema permite registrar la novedad o la incapacidad y también cambiar el estado del empleado de forma explícita, pero no existe automatización de ese vínculo en la versión actual. |
| GAP-002 | Incapacidad como trigger de baja, suspensión o inactividad | Fuera del alcance actual | TÉCNICA | `SP_BBF_INCAPACIDAD_CREAR` crea un registro válido de incapacidad; no se observa actualización automática de `bbf_empleados.ESTADO_EMPLEADO`. | La incapacidad se registra como información operativa, pero no es un trigger automático del estado laboral del empleado en este alcance actual. |
| GAP-003 | Notificaciones generadas por negocio | Parcialmente implementado | MIXTA | `NotificationController`, `NotificationService` y `NotificationRepository` soportan listado, resumen, lectura, archivo y resolución. Existen alertas orientadas a RRHH y priorización de tareas, pero no se ha validado el inventario completo de disparadores ni reglas. | El sistema genera notificaciones funcionales, pero falta documentar completamente qué procesos las disparan y bajo qué reglas. |
| GAP-004 | Firma digital de contratos | Implementado dentro del alcance real del proyecto | TÉCNICA | `ContractingController::signContract` y `ContractingService::signContract()` registran el contrato firmado y sus metadatos de archivo/URL; la BD guarda documentos asociados a empleado/contrato. No se observa validación criptográfica ni autenticidad digital. | El proyecto contempla registro documental del contrato firmado, no firma digital real. La validación de autenticidad del archivo queda fuera del alcance del sistema. |
| GAP-005 | Portal completo del empleado | Implementado dentro del alcance real del proyecto | MIXTA | `Front/src/app/app.routes.ts` incluye módulos de auto-servicio como `my-sizes`, `my-deliveries`, `my-tool-deliveries` y `trainings/my-records`. | Existe un self-service funcional del empleado, pero no un portal integral universal de toda la experiencia del empleado. |
| GAP-006 | Llamados de atención | Implementado dentro del flujo de novedades | FUNCIONAL | No existe un módulo independiente, pero se registran incidencias relevantes dentro del flujo de novedades y decisiones de RRHH. | El proyecto no contempla un módulo separado de llamados de atención; la funcionalidad está cubierta como registro dentro de novedades. |
| GAP-007 | Suspensiones disciplinarias | Implementado dentro del flujo de novedades | FUNCIONAL | No hay módulo disciplinario independiente; sin embargo, la información de incidentes o situaciones relevantes se puede registrar dentro de novedades y decidir la acción manualmente. | La suspensión no es un flujo separado, sino un registro y decisión RRHH dentro del marco de novedades. |
| GAP-008 | Nómina operativa | Fuera del alcance actual | TÉCNICA | No existen rutas, servicios ni procedimientos dedicados a nómina; la solución actual no muestra liquidación ni pagos. | La nómina no está implementada en la versión actual y se considera un alcance futuro pendiente de requisitos. |
| GAP-009 | Integración externa no documentada | No evidenciado | TÉCNICA | La API observada no expone endpoints ni servicios claramente orientados a integración con terceros. | No hay evidencia de integración externa ni flujo técnico de interoperabilidad. |
| GAP-010 | Gestión de retiros con cambio de estado de empleado | Parcialmente implementado | TÉCNICA | `RetirementRepository::finalize()` y `SP_BBF_RETIROS_FINALIZAR` gestionan cierre del proceso de retiro; el cambio de estado del empleado se realiza por flujo separado y no está automatizado con el retiro. | El proceso de retiro existe, pero la actualización del estado del empleado queda como decisión manual del usuario responsable del proceso. |

## 6. Hallazgos clave de evidencia

### 6.1 Estado laboral real y separación de responsabilidades

La evidencia más clara es que el cambio de estado del empleado está concentrado en la ruta y el SP específicos:

- `Back/routes/api.php`: `Route::patch('employees/{id}/estado', [EmployeeController::class, 'changeStatus'])`
- `Back/app/Http/Controllers/Api/EmployeeController.php`: método `changeStatus(...)`
- `Back/app/Repositories/EmployeeRepository.php`: `changeStatus()`
- `BD/2608241Dev.sql`: `SP_BBF_EMPLEADOS_CAMBIAR_ESTADO`

El procedimiento actual actualiza únicamente la tabla `bbf_empleados`, con validación de valores permitidos: `ACTIVO`, `RETIRADO`, `SUSPENDIDO`, `INCAPACITADO`, `EN_PROCESO_RETIRO`.

Conclusión: el cambio de estado laboral es una acción explícita y separada del registro de una novedad.

### 6.2 Novedades e incapacidades registran hechos, no mutan el empleado automáticamente

Las rutas de novedad e incapacidad existen y están protegidas por permisos:

- `Back/routes/api.php`: `Route::prefix('novelties')`
- `Back/app/Http/Controllers/Api/NoveltyController.php`
- `Back/app/Services/NoveltyService.php`
- `Back/app/Repositories/NoveltyRepository.php`

Las SP relevantes son:

- `SP_BBF_NOVEDAD_CREAR`
- `SP_BBF_INCAPACIDAD_CREAR`
- `SP_BBF_NOVEDAD_CAMBIAR_ESTADO`

La lógica de esas SPs crea registros en `bbf_novedades_empleado` y/o `bbf_incapacidades`, y cambia estado de la novedad, pero no se observa actualización del empleado en `bbf_empleados` dentro del mismo flujo.

Conclusión: la novedad es un evento registrado, no la fuente de un cambio automático de estado laboral.

### 6.3 Notificaciones operativas sí existen, pero su origen no está verificado

La evidencia real muestra gestión de notificaciones:

- `Back/routes/api.php`: prefijo `notifications`
- `Back/app/Http/Controllers/Api/NotificationController.php`
- `Back/app/Services/NotificationService.php`
- `Back/app/Repositories/NotificationRepository.php`

Las operaciones visibles son: listado, resumen, lectura, archivo y resolución.

Sin embargo, la cadena que crea la notificación desde un evento de negocio no aparece claramente en los servicios principales revisados.

Conclusión: está implementado el consumo y gestión de notificaciones, pero no se evidencia la fuente/producción generalizada.

### 6.4 Contratación: documento asociado, no firma digital certificada

La evidencia real de contratación incluye:

- `Back/routes/api.php`: prefijo `contracting`
- `Back/app/Http/Controllers/Api/ContractingController.php`
- `Back/app/Services/ContractingService.php`
- `Back/app/Repositories/ContractingRepository.php`

El flujo `signContract()` guarda el contrato firmado como documento asociado, con ruta/URL y metadata del archivo. No se observa implementación de firma digital con validación criptográfica de terceros ni componente de e-signature.

Conclusión: la funcionalidad es real como registro de contrato firmado, no como firma digital legal/criptográfica.

## 7. Conclusión final AS-IS

La solución actual tiene un conjunto sólido de módulos funcionales reales, especialmente en seguridad, empleados, novedad, dotación, herramientas, retiros, capacitaciones y contratación documental.

La diferencia clave es que el proyecto no debe evaluarse solo como módulos independientes; también debe valorarse el alcance real del sistema en vigor. En ese marco, la validación concluye lo siguiente:

- la novedad e incapacidad se registran como información funcional, pero no disparan automáticamente cambios de estado del empleado;
- la notificación existe como mecanismo operativo para RRHH y priorización, aunque falta documentar completa y trazablemente sus disparadores;
- la firma del contrato está implementada como registro documental del contrato firmado, no como firma digital técnica;
- el empleado tiene un self-service funcional dentro del alcance del proyecto, aunque no es un portal integral universal;
- Los conceptos de llamados de atención y suspensiones disciplinarias no cuentan con un módulo técnico independiente en la versión actual; su tratamiento se realiza dentro del flujo de novedades y decisiones manuales de RRHH.
- La nómina y la integración externa no tienen soporte técnico en la versión actual y quedan fuera del alcance implementado del proyecto.
- el flujo de retiro existe y se puede ejecutar, pero la decisión del cambio de estado del empleado queda en manos del usuario responsable y no está automatizada por el sistema.

En consecuencia, la validación AS-IS concluye que la solución está en un estado funcional real y operativo para el alcance actual del proyecto, con varios comportamientos bien delimitados como procesos manuales o evoluciones futuras, y sin inventar automatismos que no están implementados.
