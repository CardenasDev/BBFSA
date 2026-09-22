# BBF SISADMIN – PHASE 1 AS-IS BASELINE

## 1. Propósito

Este documento establece la baseline funcional y técnica validada de la Fase 1 del proyecto BBF SisAdmin. Su objetivo es consolidar el alcance AS-IS realmente implementado, manteniendo la separación entre:

- funcionalidad efectivamente existente;
- gaps reales de la Fase 1;
- oportunidades futuras / TO-BE;
- decisiones de negocio confirmadas por Product Owner.

No es un documento de diseño ni de Fase 2. No incorpora nuevos requisitos ni automatismos no evidenciados en el repositorio.

## 2. Alcance de Fase 1

La Fase 1 comprende la funcionalidad ya implementada y validada en el repositorio actual, con evidencia técnica en frontend, backend, rutas, servicios, repositorios, procedimientos almacenados y documentación AS-IS existente.

### Alcance funcional real implementado
- Autenticación y sesión
- Usuarios, roles y permisos
- Aspirantes
- Empleados
- Contratación
- Carga masiva
- Dotación
- Herramientas
- Devoluciones
- Capacitación
- Novedades
- Retiro
- Notificaciones internas operativas
- Parámetros y catálogos
- Documentos operativos

### Alcance no incluido como Fase 1
- Nómina operativa
- Integración externa no evidenciada
- Portal universal del empleado
- Canales externos de notificación no implementados: correo, SMS, WhatsApp, push
- Automatismos no soportados por evidencia técnica o validación funcional

## 3. Inventario de flujos

| ID | Flujo | Estado implementación | Validación PO | Observaciones |
|---|---|---|---|---|
| F-001 | Autenticación y sesión | IMPLEMENTADO | SI | JWT, refresh, logout, sesión, permisos y cambio de contraseña. |
| F-002 | Usuarios, roles y permisos | IMPLEMENTADO | SI | Modelo basado en usuario → roles → permisos → capacidades, no en perfiles rígidos únicos. |
| F-003 | Aspirantes | IMPLEMENTADO | SI | Carga, seguimiento y conversión a empleado dentro del alcance real del sistema. |
| F-004 | Empleados | IMPLEMENTADO | SI | Consulta, edición, foto, estados y administración laboral. |
| F-005 | Contratación | IMPLEMENTADO | SI | Perfil, contrato, documentos, seguridad social y exámenes. |
| F-006 | Carga masiva | IMPLEMENTADO | SI | Carga de empleados y datos operativos por archivo masivo. |
| F-007 | Dotación | IMPLEMENTADO | SI | Mis tallas, entregas y soporte de dotación operativa. |
| F-008 | Herramientas | IMPLEMENTADO | SI | Entrega y devolución de herramientas con trazabilidad. |
| F-009 | Devoluciones | IMPLEMENTADO | SI | Solicitudes y confirmación de devoluciones. |
| F-010 | Capacitación | IMPLEMENTADO | SI | Catálogo, sesiones, evaluaciones, participantes y compromisos. |
| F-011 | Novedades | IMPLEMENTADO | SI | Incluye permisos, llamados de atención, suspensiones e incapacidades. No cambia automáticamente el estado del empleado. |
| F-012 | Retiro | IMPLEMENTADO | SI | Proceso formal independiente del cambio de estado del empleado. |
| F-013 | Notificaciones | IMPLEMENTADO dentro del alcance AS-IS | SI | Notificaciones internas del sistema: sincronización, resumen, listado, lectura, archivo y resolución. |
| F-014 | Parámetros y catálogos | IMPLEMENTADO | SI | Configuración operativa compartida por módulos. |
| F-015 | Documentos operativos | IMPLEMENTADO | SI | Gestión documental asociada a distintos flujos del sistema. |

## 4. Reglas funcionales críticas

Estas reglas deben mantenerse como límites del AS-IS de Fase 1 para evitar interpretaciones incorrectas:

### 4.1 Permisos vs roles
- El sistema no se basa en un conjunto rígido de perfiles únicos.
- La autorización efectiva se resuelve por usuario → roles → permisos → capacidades.
- Los roles son configurables; la seguridad real está en los permisos.

### 4.2 Incapacidad vs estado del empleado
- La incapacidad es un registro operativo y especializado dentro del módulo de novedades.
- La incapacidad no cambia automáticamente el estado del empleado.
- El cambio de estado debe ejecutarse de forma separada y explícita por RRHH o usuario autorizado.

### 4.3 Retiro vs estado del empleado
- El flujo formal de retiro y el cambio de estado del empleado son procesos relacionados, pero independientes.
- Finalizar el retiro no cambia automáticamente el estado del empleado.
- El cambio de estado puede ejecutarse sin completar previamente el expediente del retiro.
- La entrevista de retiro y el certificado laboral no bloquean el cambio de estado del empleado.

### 4.4 Procesos manuales intencionales
- Muchas decisiones operativas se resuelven manualmente por RRHH o por usuarios autorizados.
- La falta de automatización no equivale a defecto funcional si la evidencia demuestra que el proceso es intencional y manual.

### 4.5 Notificaciones internas
- El alcance AS-IS validado es el de notificaciones internas del sistema.
- La sincronización genera alertas desde condiciones reales del negocio.
- Las notificaciones pueden dejar de aplicarse por resolución explícita del usuario o porque la condición del negocio ya no se cumple.
- No se debe asumir un alcance externo (correo, SMS, WhatsApp, push) como parte de la Fase 1 si no hay evidencia de ello.

### 4.6 Firma documental vs firma digital
- La firma de contrato existente es un registro documental del documento firmado.
- El sistema no evidencia firma digital criptográfica ni e-signature legal o técnica.
- La gestión documental del contrato firmado es real; la firma digital no lo es.

## 5. GAPs de Fase 1

### GAPs abiertos reales
No se identifican GAPs abiertos reales de Fase 1 que requieran cierre funcional dentro del alcance actual, siempre que se mantenga la regla de no inventar automatismos ni extender el alcance más allá de la evidencia.

### GAPs cerrados
- Cambio de estado laboral por novedad o incapacidad: cerrado por validación PO.
- Incapacidad como trigger de baja, suspensión o inactividad: cerrado por validación PO.
- Gestión de retiros con cambio de estado de empleado: cerrado por validación PO.
- Firma documental de contrato vs firma digital: aclarado y cerrado como alcance real.
- Notificaciones internas del sistema: validado dentro del alcance AS-IS.

### Reclasificados como TO-BE
- Flexibilización de obligatoriedad documental en retiros.
- Mayor cobertura de canales de notificación externos.
- Posibles mejoras de personalización y reglas de disparo si son requeridas en una evolución posterior.

## 6. Oportunidades futuras

Las oportunidades futuras se registran como TO-BE y no como fallas del AS-IS de Fase 1.

- flexibilizar la obligatoriedad documental para ciertos retiros;
- ampliar la cobertura de notificaciones a canales externos;
- ampliar el catálogo de disparadores de notificaciones si se define un negocio más completo;
- revisar la necesidad de automatismos más exigentes en estados y alertas, solo si existe un requerimiento formal posterior.

No se diseñan soluciones en este documento.

## 7. Arquitectura de referencia

La arquitectura de referencia de la Fase 1 es la que ya queda documentada en architecture.md y se mantiene alineada con la validación funcional reciente.

Se mantiene como punto de referencia:
- Frontend Angular 22
- Backend Laravel 12
- MySQL con procedimientos almacenados SP_BBF_*
- JWT y validación de permisos en backend
- repositorios invocando procedimientos almacenados
- gestión documental en uploads
- separación entre flujo operativo y cambio de estado laboral

No se reescribe la arquitectura; solo se confirma que sigue siendo válida para Fase 1.

## 8. Documentación fuente

La baseline de Fase 1 debe leerse junto con:

- prd-as-is.md
- architecture.md
- as-is-gap-validation.md
- as-is-functional-flow-inventory.md
- AGENTS.md
- README.md
- artefactos reales de _bmad-output relacionados con validación AS-IS

## 9. Estado de cierre

La Fase 1 puede considerarse:

AS-IS DOCUMENTALMENTE CERRADO

No quedan pendientes funcionales de nivel AS-IS dentro del alcance realmente validado. Los únicos elementos pendientes pertenecen explícitamente a evolución futura y no deben reinterpretarse como fallas de la Fase 1.

## 10. Punto de partida para evolución

Futuras ampliaciones, nuevas reglas de negocio, nuevos canales o automatismos deben tratarse como:

TO-BE / FASE 2

y no como correcciones del AS-IS de la Fase 1.
