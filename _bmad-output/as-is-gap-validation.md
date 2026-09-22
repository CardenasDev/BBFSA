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

1. El cambio automático de estado del empleado por novedad o incapacidad queda fuera del alcance actual del proyecto; no existe automatización, pero sí existe registro manual por RRHH. Esta regla quedó confirmada por Product Owner y no se considera GAP funcional.
2. El flujo formal de retiro y el cambio de estado del empleado son procesos relacionados, pero independientes. Completar o finalizar un retiro no cambia automáticamente el estado laboral, y el estado puede cambiarse sin completar el flujo de retiro. Esta regla quedó confirmada por Product Owner y no se considera GAP funcional.
3. Las notificaciones existen y cumplen un propósito operativo real dentro del alcance AS-IS actual; la validación funcional confirma la gestión interna de alertas, sin asumir que el inventario completo de disparadores está formalizado como catálogo universal.
4. La firma de contratos se soporta como registro documental del contrato firmado; no es firma digital técnica ni validación legal del archivo.
5. El auto-servicio del empleado existe dentro del alcance real del proyecto, aunque no como portal integral universal.
6. Los casos de llamados de atención, suspensiones disciplinarias y otras extensiones operativas se cubren como registro dentro de novedades y decisión manual RRHH, no como módulos separados. Esta regla quedó confirmada funcionalmente por Product Owner.
7. La nómina y la integración externa quedan fuera del alcance implementado y se consideran evoluciones futuras.
8. La obligatoriedad documental del retiro existe como AS-IS actual, pero la empresa reconoce como oportunidad futura la posibilidad de flexibilizarla según el caso, sin convertirlo en comportamiento actual del sistema.

## 5. Matriz de gaps AS-IS

| ID | Área | Estado | Fuente de validación | Evidencia real | Conclusión |
| --- | --- | --- | --- | --- | --- |
| GAP-001 | Cambio de estado laboral por novedad o incapacidad | CERRADO POR VALIDACIÓN PO | TÉCNICA | `SP_BBF_NOVEDAD_CREAR` y `SP_BBF_INCAPACIDAD_CREAR` registran información; `SP_BBF_EMPLEADOS_CAMBIAR_ESTADO` existe como flujo separado y manual. No se observa llamada automática desde novedad/incapacidad al cambio de estado. | Product Owner confirma que la incapacidad y la novedad no deben modificar automáticamente el estado del empleado; la acción, si procede, debe ejecutarse manualmente por RRHH o usuario autorizado. |
| GAP-002 | Incapacidad como trigger de baja, suspensión o inactividad | CERRADO POR VALIDACIÓN PO | TÉCNICA | `SP_BBF_INCAPACIDAD_CREAR` crea un registro válido de incapacidad; no se observa actualización automática de `bbf_empleados.ESTADO_EMPLEADO`. | La incapacidad es un registro operativo/laboral independiente y no debe tratarse como trigger automático de baja, suspensión o inactividad. |
| GAP-003 | Notificaciones generadas por negocio | Implementado dentro del alcance real del proyecto | MIXTA | `NotificationController`, `NotificationService` y `NotificationRepository` soportan sincronización, listado, resumen, lectura, archivo y resolución. La validación funcional confirma que existen alertas operativas internas reales con flujo de consumo y cierre, sin asumir un catálogo universal de todos los disparadores del negocio. | El sistema genera y gestiona notificaciones funcionales dentro del alcance real AS-IS; la ausencia de un inventario completo de disparadores no invalida la capacidad operativa ya implementada. |
| GAP-004 | Firma digital de contratos | Implementado dentro del alcance real del proyecto | TÉCNICA | `ContractingController::signContract` y `ContractingService::signContract()` registran el contrato firmado y sus metadatos de archivo/URL; la BD guarda documentos asociados a empleado/contrato. No se observa validación criptográfica ni autenticidad digital. | El proyecto contempla registro documental del contrato firmado, no firma digital real. La validación de autenticidad del archivo queda fuera del alcance del sistema. |
| GAP-005 | Portal completo del empleado | Implementado dentro del alcance real del proyecto | MIXTA | `Front/src/app/app.routes.ts` incluye módulos de auto-servicio como `my-sizes`, `my-deliveries`, `my-tool-deliveries` y `trainings/my-records`. | Existe un self-service funcional del empleado, pero no un portal integral universal de toda la experiencia del empleado. |
| GAP-006 | Llamados de atención | Implementado dentro del flujo de novedades | FUNCIONAL | No existe un módulo independiente, pero se registran incidencias relevantes dentro del flujo de novedades y decisiones de RRHH. | El proyecto no contempla un módulo separado de llamados de atención; la funcionalidad está cubierta como registro dentro de novedades. |
| GAP-007 | Suspensiones disciplinarias | Implementado dentro del flujo de novedades | FUNCIONAL | No hay módulo disciplinario independiente; sin embargo, la información de incidentes o situaciones relevantes se puede registrar dentro de novedades y decidir la acción manualmente. | La suspensión no es un flujo separado, sino un registro y decisión RRHH dentro del marco de novedades. |
| GAP-008 | Nómina operativa | Fuera del alcance actual | TÉCNICA | No existen rutas, servicios ni procedimientos dedicados a nómina; la solución actual no muestra liquidación ni pagos. | La nómina no está implementada en la versión actual y se considera un alcance futuro pendiente de requisitos. |
| GAP-009 | Integración externa no documentada | No evidenciado | TÉCNICA | La API observada no expone endpoints ni servicios claramente orientados a integración con terceros. | No hay evidencia de integración externa ni flujo técnico de interoperabilidad. |
| GAP-010 | Gestión de retiros con cambio de estado de empleado | CERRADO POR VALIDACIÓN PO | TÉCNICA | `RetirementRepository::finalize()` y `SP_BBF_RETIROS_FINALIZAR` gestionan cierre del proceso de retiro; el cambio de estado del empleado se realiza por flujo separado y no está automatizado con el retiro. | Product Owner confirma que el retiro y el cambio de estado del empleado son procesos relacionados, pero independientes; completar/finalizar el retiro no cambia automáticamente el estado del empleado. |
| GAP-011 | Flexibilidad de obligatoriedad documental en retiros | OPORTUNIDAD FUTURA / TO-BE | FUNCIONAL | El flujo formal de retiro exige determinada información y documentación en el AS-IS actual. RRHH puede no disponer de toda la documentación en algunos casos, y la empresa identifica como necesidad futura permitir mayor flexibilidad de obligatoriedad. | Situación actual: el proceso formal de retiro exige información y documentación determinadas. Dificultad operativa: algunos retiros pueden no contar con toda la documentación. Necesidad futura: permitir que la obligatoriedad pueda flexibilizarse conforme al caso, tipo o motivo de retiro, sin convertir esto en comportamiento AS-IS actual. |

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

Product Owner confirma la regla funcional: la incapacidad no debe modificar automáticamente el estado del empleado. Esa separación es intencional y no debe clasificarse como GAP.

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

### 6.3 Notificaciones operativas: flujo real validado dentro del alcance AS-IS

La evidencia real muestra gestión de notificaciones:

- `Back/routes/api.php`: prefijo `notifications`
- `Back/app/Http/Controllers/Api/NotificationController.php`
- `Back/app/Services/NotificationService.php`
- `Back/app/Repositories/NotificationRepository.php`
- `SP_BBF_NOTIFICACIONES_SINCRONIZAR` y procedimientos de gestión asociada en `03 . Entregas/QAExport260921.sql`

Las operaciones visibles son: sincronización, resumen, listado, lectura, archivo y resolución.

La validación funcional confirma que este flujo es real y operativo dentro del alcance del sistema existente: no es un módulo ficticio ni una interfaz vacía, y sí forma parte del uso diario de RRHH y usuarios con permisos. La diferencia importante es que el alcance AS-IS actual no exige demostrar un catálogo universal de disparadores para considerar esta capacidad implementada.

Conclusión: el consumo y la gestión de notificaciones están implementados y validados; lo que no se presume es una cobertura universal o automática de todos los eventos del negocio sin evidencia específica.

### 6.4 Retiro formal y cambio de estado: procesos independientes

Product Owner confirma la regla funcional: el flujo formal de retiro y el cambio de estado del empleado son procesos relacionados, pero independientes. El cambio de estado puede ejecutarse sin esperar a que se complete el módulo de retiro, y la finalización del retiro no cambia automáticamente el estado laboral del empleado.

La entrevista de retiro y el certificado laboral no actúan como bloqueadores del cambio de estado del empleado. Ambos forman parte del proceso formal de salida y de la trazabilidad documental, pero no son requisito funcional para la salida operativa.

### 6.5 Flexibilidad documental del retiro: oportunidad futura

La documentación actual del retiro exige un conjunto específico de información y documentos, y esa obligación opera como AS-IS del flujo formal. Sin embargo, Product Owner señala una necesidad futura: permitir mayor flexibilidad en la obligatoriedad documental según el tipo o motivo de retiro, porque RRHH puede no contar con toda la información en ciertos casos.

Esta necesidad se registra como oportunidad futura y no se incorpora como comportamiento AS-IS del sistema actual.

### 6.6 Contratación: documento asociado, no firma digital certificada

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
