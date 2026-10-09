# PRD – Generación documental parametrizada de Talento Humano

## 1. Problema y oportunidad

BBF SisAdmin evidencia la gestión operativa de personas y eventos laborales en varios módulos: empleados, contratación, capacitaciones, novedades, dotaciones, retiros y gestión documental. El levantamiento funcional realizado con el cliente identificó una familia de documentos oficiales de Talento Humano que se repite en forma estructural, pero que hoy se resuelven de manera fragmentada, manual o dependiente de plantillas aisladas.

El problema funcional principal no es la existencia de documentos aislados, sino la ausencia de una capacidad reutilizable para generar documentos oficiales a partir de información ya disponible en el sistema, agregando solo los datos transaccionales o complementarios que cada documento requiere. Como consecuencia, se presentan riesgos de:

- digitación duplicada de datos del empleado, empresa y contrato;
- inconsistencias entre la información operativa y el documento emitido;
- construcción manual de cartas, certificados y comprobantes;
- plantillas independientes difíciles de mantener y actualizar;
- baja trazabilidad sobre qué versión, qué empleado y qué parámetros se usaron;
- mayor exposición a errores formales y a documentos incompletos.

El cliente entregó un conjunto de documentos oficiales cuyo contenido comparte estructura, datos y lógica documental. Esto permite formalizar una capacidad orientada a un patrón basado en:

- Tipo documental
- Plantilla
- Parámetros
- Fuente de información
- Generación

Esta capacidad no debe redefinir ni reemplazar los procesos de contratación, retiro, capacitación o novedades; por el contrario, debe consumir la información generada por esos procesos para producir documentos oficiales de forma consistente, segura y trazable.

## 2. Objetivo

Definir una capacidad reutilizable dentro de BBF SisAdmin para generar documentos oficiales de Talento Humano mediante una lógica común de tipo documental, plantilla y parámetros, utilizando información existente del sistema y solicitando únicamente los datos adicionales requeridos por cada documento.

El objetivo funcional es minimizar la manualidad y la duplicación, manteniendo:

- formato oficial;
- código documental;
- versión;
- trazabilidad;
- consistencia de datos;
- control de acceso;
- cumplimiento de los requisitos del cliente en los formatos entregados.

## 3. Alcance

### 3.1 Alcance funcional de esta primera implementación

Se incorpora como primera versión la generación documental para los siguientes formatos oficiales entregados por el cliente:

1. BBTH-F-002 – Certificado laboral a colaborador activo.
2. BBTH-F-003 – Certificado laboral de retiro a colaborador.
3. BBTH-F-004 – Check list de retiro entregado a excolaborador.
4. BBTH-F-005 – Carta de aceptación de renuncia.
5. BBTH-F-011 – Carta retiro de cesantías para vivienda/reparaciones locativas.
6. BBTH-F-012 – Retiro de cesantías por finalización de contrato.
7. BBTH-F-013 – Carta de compromiso evaluativo.
8. BBTH-F-015 – Carta de notificación de no renovación de contrato.

Se considera que estos ocho formatos son el universo documental inicial de esta capacidad.

### 3.2 Alcance funcional incluido

- Definición de un catálogo inicial de tipos documentales por código y evento origen.
- Identificación de la estructura documental compartida.
- Mapeo funcional de variables conceptuales a fuentes de información del sistema.
- Reutilización de parámetros entre documentos.
- Validación de requisitos de información antes de generar el documento.
- Solicitud de datos faltantes solo cuando sean específicos del documento o del evento.
- Previsualización funcional antes de generar el documento.
- Registro de la generación para trazabilidad.
- Consulta posterior del documento generado y sus metadatos básicos.
- Control de acceso por permisos y roles.

### 3.3 Alcance funcional del tipo documental

El alcance funcional para la primera implementación se orienta a una arquitectura de conceptos:

- Tipo documental: categoría funcional del documento oficial.
- Plantilla: definición formal del documento con estructura, secciones y reglas.
- Parámetros: variables de contenido que la plantilla necesita completar.
- Fuente de información: origen de cada parámetro (empresa, empleado, contrato, retiro, capacitación/evaluación, información ingresada al generar, o no disponible).
- Generación: proceso de composición del documento final con los datos validados.

Este enfoque permite reutilizar la estructura documental y evitar que cada documento se desarrolle como un caso aislado.

## 4. Fuera de alcance

Las siguientes capacidades no forman parte de la primera implementación en este PRD, salvo que exista evidencia explícita previa de requerimiento y validación del cliente:

- firma electrónica o firma digital certificada;
- firma digital legalmente vinculante;
- envío automático por correo electrónico;
- envío automático por WhatsApp o canales de mensajería;
- integración con sistemas externos de nómina, seguridad social, correos o firmas;
- aprobaciones electrónicas con flujo de firmas múltiples en línea;
- gestión de firmas o sellos de entidad externa;
- firma biométrica o autenticación con criptografía;
- generación de documentos no contemplados en los ocho formatos iniciales;
- redefinición del flujo operativo de retiros, contrataciones, capacitaciones u otras áreas;
- automatización de decisiones laborales que no existan como flujo actual del sistema;
- definición del formato final de salida del documento (por ejemplo PDF, DOCX o impresión) sin validación explícita del Product Owner.

Se deja explícito que la generación documental debe consumir la información existente de los módulos de negocio, no reconfigurar ni reemplazar el comportamiento actual de esos módulos.

## 5. Actores

### 5.1 Actores principales

- Talento Humano: usuario responsable de la gestión documental operativa y de la validación de la información del empleado o del evento.
- Administradores del sistema: usuarios con capacidad de configurar plantillas, parámetros, versiones y control documental, de acuerdo con los permisos vigentes.
- Empleado: actor involucrado solo cuando funcionalmente corresponda, por ejemplo para revisión de información propia o para entrega de datos específicos de un documento asociado.
- Otros roles de negocio: cualquier perfil que el sistema actual ya soporte para consulta o gestión documental, siempre que exista evidencia de permisos y flujo operativo vigente.

### 5.2 Principio de rol y permisos

La autorización debe seguir el modelo ya evidenciado en BBF SisAdmin: acceso efectivo por combinación de usuario → roles → permisos → capacidades. No se asumirá un conjunto fijo de perfiles cerrados sin evidencia funcional.

## 6. Catálogo inicial de tipos documentales

| Código | Documento | Módulo origen | Evento que permite generarlo |
|---|---|---|---|
| BBTH-F-002 | Certificado laboral a colaborador activo | Empleados / Contratación | Colaborador activo con información contractual válida |
| BBTH-F-003 | Certificado laboral de retiro a colaborador | Empleados / Retiro | Cierre o retiro del empleado |
| BBTH-F-004 | Check list de retiro entregado a excolaborador | Retiro | Proceso de retiro y entrega documental |
| BBTH-F-005 | Carta de aceptación de renuncia | Retiro / Novedades | Renuncia formal presentada por empleado |
| BBTH-F-011 | Carta retiro de cesantías para vivienda/reparaciones locativas | Retiro / Seguridad social | Solicitud de retiro de cesantías con destino específico |
| BBTH-F-012 | Retiro de cesantías por finalización de contrato | Retiro / Contrato | Fin de contrato laboral |
| BBTH-F-013 | Carta de compromiso evaluativo | Capacitación / Evaluación / Novedades | Compromiso por evaluación o mejora de desempeño |
| BBTH-F-015 | Carta de notificación de no renovación de contrato | Contratación / Empleado | Finalización de contrato sin renovación |

> Nota: este catálogo es inicial y funcional. Se asume que el nombre formal del proceso, la denominación del módulo origen y la exactitud del evento pueden requerir validación con el cliente en el GAP final.

## 7. Matriz documento × parámetro

La tabla siguiente resume el conjunto funcional de parámetros esperados para los documentos iniciales. El objetivo es identificar qué información es reutilizable, qué es automática y qué debe solicitarse al momento de la generación. La fuente se clasifica como:

- Empresa/configuración
- Empleado
- Contrato
- Retiro
- Capacitación/evaluación
- Información ingresada al generar
- No disponible actualmente

| Documento | Parámetro | Obligatorio | Fuente | Automático/Manual | Observaciones |
|---|---|---:|---|---|---|
| F-002 | Nombre del empleado | Sí | Empleado | Automático | Base para cabecera y cuerpo |
| F-002 | Tipo y número de documento | Sí | Empleado | Automático | Si el dato está disponible |
| F-002 | Cargo | Sí | Empleado / Contrato | Automático | Debe corresponder al rol o cargo actual |
| F-002 | Fecha de ingreso | Sí | Contrato | Automático | Requerida en el certificado |
| F-002 | Tipo de contrato | Sí | Contrato | Automático | Requerida en la mayoría de variantes |
| F-002 | Salario | Sí / Condicional | Contrato | Automático | Solo cuando la variante así lo requiera |
| F-002 | EPS / ARL / pensión / caja de compensación | Condicional | Empresa/configuración o empleado | Automático | Depende de la variante del documento |
| F-002 | Razón social de la empresa | Sí | Empresa/configuración | Automático | Cabecera institucional |
| F-002 | NIT | Sí | Empresa/configuración | Automático |
| F-002 | Ciudad / lugar | Sí | Empresa/configuración | Automático | Fecha y lugar de expedición |
| F-002 | Fecha de generación | Sí | Sistema | Automático | Fecha del documento |
| F-002 | Funciones o responsabilidades | Condicional | Empleado / Contrato / configuración | Manual o automático | Variante con funciones |
| F-003 | Nombre del empleado | Sí | Empleado | Automático |
| F-003 | Documento del empleado | Sí | Empleado | Automático |
| F-003 | Cargo | Sí | Empleado / Contrato | Automático |
| F-003 | Fecha de ingreso | Sí | Contrato | Automático |
| F-003 | Fecha de retiro | Sí | Retiro | Automático |
| F-003 | Motivo de retiro | Sí | Retiro / Novedad | Automático | Si se tiene registro formal |
| F-003 | Tipo de retiro | Sí | Retiro | Automático |
| F-003 | Empresa | Sí | Empresa/configuración | Automático |
| F-003 | Fecha de generación | Sí | Sistema | Automático |
| F-004 | Datos del empleado retirado | Sí | Empleado | Automático |
| F-004 | Fecha de retiro | Sí | Retiro | Automático |
| F-004 | Entrega de elementos / comprobantes | Sí | Información ingresada al generar | Manual | Por checklist operativo |
| F-004 | Responsable de entrega | Sí | Información ingresada al generar | Manual | Debe ser validado según flujo |
| F-004 | Observaciones | Condicional | Información ingresada al generar | Manual |
| F-005 | Nombre del empleado | Sí | Empleado | Automático |
| F-005 | Documento del empleado | Sí | Empleado | Automático |
| F-005 | Fecha de renuncia | Sí | Retiro / Novedad | Automático | Si el evento está registrado |
| F-005 | Tipo de renuncia | Sí | Retiro / Novedad | Automático | Si aplica |
| F-005 | Motivo de renuncia | Sí | Retiro / Novedad | Automático | Si está en el proceso |
| F-005 | Cargo / dependencia | Sí | Empleado / Contrato | Automático |
| F-005 | Fecha de aceptación | Sí | Información ingresada al generar | Manual | Dado que puede requerir validación |
| F-011 | Nombre del empleado | Sí | Empleado | Automático |
| F-011 | Documento del empleado | Sí | Empleado | Automático |
| F-011 | Fecha de retiro | Sí | Retiro | Automático |
| F-011 | Fondo / entidad | Sí | Información ingresada al generar | Manual | Requerido para cesantías |
| F-011 | Motivo del retiro | Sí | Retiro / Información ingresada al generar | Automático / Manual | Según el origen real del caso |
| F-011 | Concepto | Sí | Información ingresada al generar | Manual |
| F-011 | Monto solicitado | Sí | Información ingresada al generar | Manual |
| F-011 | Destinación | Sí | Información ingresada al generar | Manual |
| F-011 | Confirmación / autorizaciones | Sí | Información ingresada al generar | Manual |
| F-012 | Nombre del empleado | Sí | Empleado | Automático |
| F-012 | Documento del empleado | Sí | Empleado | Automático |
| F-012 | Fecha de retiro o fin de contrato | Sí | Retiro / Contrato | Automático |
| F-012 | Fondo / entidad | Sí | Información ingresada al generar | Manual |
| F-012 | Monto / saldo | Condicional | Información ingresada al generar / sistema | Manual o automático | Si existe registro en proceso |
| F-012 | Motivo de finalización | Sí | Retiro / Contrato | Automático |
| F-013 | Nombre del empleado | Sí | Empleado | Automático |
| F-013 | Documento del empleado | Sí | Empleado | Automático |
| F-013 | Cargo | Sí | Empleado / Contrato | Automático |
| F-013 | Fecha de evaluación | Sí | Capacitación/evaluación | Automático | Si el evento está registrado |
| F-013 | Resultado de evaluación | Sí | Capacitación/evaluación | Automático |
| F-013 | Medidas correctivas | Sí | Capacitación/evaluación | Automático / Manual |
| F-013 | Objetivos / compromisos | Sí | Capacitación/evaluación | Manual o automático |
| F-013 | Plazos | Sí | Capacitación/evaluación | Manual o automático |
| F-015 | Nombre del empleado | Sí | Empleado | Automático |
| F-015 | Documento del empleado | Sí | Empleado | Automático |
| F-015 | Cargo | Sí | Empleado / Contrato | Automático |
| F-015 | Fecha de vencimiento contractual | Sí | Contrato | Automático | Si está disponible |
| F-015 | Motivo de no renovación | Sí | Contrato / Novedad | Automático | Si el proceso configurado lo soporta |
| F-015 | Fecha de notificación | Sí | Información ingresada al generar | Manual | Requiere validación según historial |
| F-015 | Persona remitente / firmante | Sí | Empresa/configuración / sistema | Automático | Debe resolverse desde configuraciones de firmantes |

> Nota: la matriz es funcional y no define implementación técnica; la columna “No disponible actualmente” se usa cuando el dato parece requerido pero no existe evidencia de que BBF SisAdmin lo capture hoy.

## 8. Matriz de reutilización

La siguiente tabla identifica los parámetros con mayor reutilización entre los tipos documentales analizados. Esto es clave para definir un conjunto mínimo de datos documentales compartidos.

| Parámetro | Documentos donde aparece | Reutilización | Observación |
|---|---|---|---|
| Nombre del empleado | F-002, F-003, F-004, F-005, F-011, F-012, F-013, F-015 | Muy alta | Base común para la mayoría de los documentos |
| Tipo y número de documento | F-002, F-003, F-005, F-011, F-012, F-013, F-015 | Alta | Requiere validación de disponibilidad real |
| Cargo | F-002, F-003, F-005, F-013, F-015 | Alta | Debe venir del empleado o del contrato vigente |
| Fecha de ingreso | F-002, F-003 | Media | Importante para certificados laborales |
| Tipo de contrato | F-002, F-015 | Media | Reutilizable entre documentos de contratación y retiro |
| Salario / remuneración | F-002 | Baja | Solo aplica a variantes específicas |
| Fecha de retiro | F-003, F-004, F-011, F-012 | Alta | Documento de cierre y cesantías |
| Motivo de retiro | F-003, F-005, F-011, F-012, F-015 | Alta | Reutilizable y depende del registro del evento |
| Fecha de vencimiento contractual | F-015 | Media | Requiere comparación con datos del contrato |
| Empresa / razón social | F-002, F-003 | Media | Encabezado institucional común |
| NIT | F-002, F-003 | Media | Parte de la información institucional |
| Fecha de generación | F-002, F-003 | Media | Reutilizable en todos los documentos del tipo oficial |
| Resultado de evaluación | F-013 | Baja | Documento específico de evaluación |
| Objetivos / compromisos | F-013 | Baja | Documento específico |
| Fondo / entidad / concepto / monto | F-011, F-012 | Media | Se repite en cesantías y requiere dato adicional |

La conclusión funcional es que existe una capa de “datos documentales base” y otra capa de “datos transaccionales específicos”. La primera debe obtenerse de fuentes comunes; la segunda debe ser solicitada para las plantillas que la requieran.

## 9. Flujo de generación

Se define el flujo funcional esperado para la generación documental, con una adaptación mínima respecto al planteamiento original para respetar la realidad operacional del sistema:

1. Seleccionar tipo documental.
2. Seleccionar empleado cuando el documento esté asociado a una persona.
3. Consultar información existente del empleado, contrato, retiro, capacitación/evaluación o empresa.
4. Validar condiciones del documento y requisitos de información.
5. Solicitar únicamente información faltante o específica del documento.
6. Previsualizar el documento con datos reales y parámetros temporales.
7. Generar el documento solo si cumple validaciones.
8. Registrar la generación con metadatos mínimos de trazabilidad.
9. Permitir consulta posterior del documento generado y su historial.

### 9.1 Evaluación del flujo

Este flujo es funcionalmente sólido y coherente con la intención de reutilización. Sin embargo, debe adaptarse a la realidad del sistema actual en dos aspectos:

- no todos los documentos están asociados a una persona directamente (existen casos documentales institucionales o dependientes de terceros);
- algunos documentos requieren validación de condiciones de negocio adicionales antes de generarse, por ejemplo, que exista un evento de retiro, contrato o evaluación vigentes.

Por ello, el flujo del producto debe incluir una etapa de validación de condiciones previas antes de la generación final.

### 9.2 Regla funcional central

No se debe generar silenciosamente un documento incompleto. Cuando falte información relevante, el sistema debe advertir explícitamente qué dato falta, de dónde debería provenir y si la documentación no puede emitirse en su estado actual.

## 10. Validaciones

El sistema debe validar el estado del documento antes de generar el contenido final. Las validaciones funcionales esperadas son:

### 10.1 Falta información obligatoria del empleado

- Se debe impedir la generación si no existe suficiente información del empleado para completar los datos requeridos por la plantilla.
- El sistema debe indicar qué dato falta: nombre, documento, cargo, lugar de expedición, etc.
- El origen esperado debe indicarse: empleado, contrato, empresa o información faltante por ingresar.

### 10.2 Falta información contractual

- Si el tipo documental requiere datos del contrato, la generación debe detenerse si no hay información contractual válida.
- Esto aplica a cargo, fecha de ingreso, tipo de contrato, salario, fecha de vencimiento o motivos de cierre.

### 10.3 Falta información del retiro

- Los documentos de retiro, cesantías, renuncia y notificación deben validar la existencia del evento de retiro o cierre de contrato antes de generar.
- Si el proceso no está registrado o no está completo, el sistema debe reportar claramente la condición faltante.

### 10.4 Plantilla requiere parámetros adicionales

- Se debe solicitar solo los campos de entrada no cubiertos por los módulos actuales.
- El sistema debe distinguir entre parámetros que se completan automáticamente y parámetros que requieren captura manual por el usuario.
- Debe mostrarse claramente la razón de cada campo adicional.

### 10.5 Empleado no cumple condiciones para generar determinado documento

- Si el empleado no cumple la condición para ese tipo documental, el sistema debe bloquear la generación y mostrar el requisito no cumplido.
- Ejemplos: documento no aplicable a empleado activo, no se puede emitir certificado de retiro si no existe causal de retiro registrada, o no se puede generar carta de no renovación si no hay contrato vigente o término contractual.

### 10.6 Regla general

La regla general esperada es:

“No generar silenciosamente documentos incompletos.”

Esto implica que todo documento que no cuente con la información mínima requerida debe quedar en estado de bloqueo o prevención, con una descripción clara de la información faltante.

## 11. Variantes documentales

### 11.1 Análisis funcional de BBTH-F-002

El documento BBTH-F-002 presenta una situación funcional clave: el archivo recibido incluye diferentes variantes de certificado laboral, por ejemplo:

- certificado con funciones;
- certificado con contrato, salario y entidades de seguridad social;
- posible variante escolar o informativa;
- variantes con diferencias en la forma de describir las entidades de seguridad social o el contenido de las funciones.

Esto evidencia que el documento no es necesariamente un único texto fijo, sino un conjunto de variaciones funcionales.

### 11.2 Alternativas funcionalmente posibles

Se deben considerar tres opciones, que no deben resolverse arbitrariamente sin validación del cliente:

#### Opción A: Un tipo documental con variantes

- Un mismo tipo documental, BBTH-F-002, permite varias variantes.
- La selección de la variante depende del caso concreto o del contexto operativo.
- Esto favorece reutilización y controla el tipo documental a nivel conceptual.

#### Opción B: Diferentes tipos documentales

- BBTH-F-002 podría corresponder a varios tipos funcionales distintos, por ejemplo:
  - certificado laboral general;
  - certificado laboral con funciones;
  - certificado laboral con salario;
  - certificado laboral con afiliaciones.
- Esto simplifica la estructura de plantillas, pero aumenta la cantidad de tipos en el catálogo.

#### Opción C: Una plantilla configurable

- Existe un mismo tipo documental con una plantilla base que se adapta por configuración de secciones, variables y condiciones.
- Esta opción es la más reutilizable desde un punto de vista funcional, pero requiere reglas claras de personalización y validación.

### 11.3 Decisión recomendada preliminar

La opción más alineada con el enfoque de reutilización es considerar que BBTH-F-002 puede corresponder a un tipo documental con variantes o a una plantilla configurable, siempre que la variación sea funcionalmente sustentada por condiciones del caso y no por texto manual libre. Sin embargo, esta decisión debe validarse con el cliente porque la documentación entregada no permite asegurar si las variantes son meramente editoriales o si representan tipos documentales distintos.

### 11.4 GAP identificado

Se registra como GAP explícito que no se puede determinar todavía si:

- las variantes son versiones de una misma plantilla,
- representan diferentes documentos bajo el mismo código,
- o implican distintas reglas de negocio y validación.

## 12. Firmantes

### 12.1 Problema identificado

Los documentos oficiales presentan inconsistencia funcional en cuanto a las personas que firman. Se observa que algunos documentos incluyen nombres, cargos o responsables administrativos que pueden no ser permanentes ni necesariamente únicos para todas las plantillas. Esto pide un manejo formal de firmantes, no una replicación manual en cada plantilla.

### 12.2 Requisito funcional propuesto

Se debe soportar una entidad funcional de “firmante” asociada a la estructura documental, con la capacidad de mantener información centralizada, reutilizable y actualizable sin modificar cada plantilla individualmente.

Los datos funcionales asociados al firmante deben incluir, como mínimo:

- nombre;
- cargo;
- área o dependencia;
- teléfono;
- correo de contacto, cuando aplique;
- representante legal, cuando el documento lo requiera;
- responsable administrativo o de proceso, cuando corresponda;
- vigencia del firmante dentro del documento.

### 12.3 Reglas funcionales recomendadas

- Los firmantes deben mantenerse en configuración centralizada del sistema.
- La plantilla solo debe referenciar el identificador o rol del firmante, no copiar el nombre en cada documento.
- El sistema debe permitir distinguir entre firmante responsable del documento y aprobación administrativa del contenido.
- El documento generado debe registrar el firmante utilizado en esa versión y en ese momento.

### 12.4 GAP

No se puede asumir que los nombres actuales que aparecen en los formatos recibidos sean definitivos ni permanentes. El PRD reconoce la necesidad de validar con el cliente quiénes son los firmantes oficiales y cómo se gestionan en la entidad.

## 13. Control documental

La gestión documental requiere distinguir entre dos niveles de control:

1. Versión de la plantilla
2. Documento generado para un empleado o evento

### 13.1 En la plantilla

La plantilla documental debe contar con metadatos funcionales mínimos, entre otros:

- código documental;
- nombre de la plantilla;
- versión de la plantilla;
- vigencia de la plantilla;
- fecha de publicación o actualización;
- elaborado por;
- revisado por;
- aprobado por;
- motivo de revisión;
- estado de la plantilla (activa, inactiva, en revisión, histórico).

### 13.2 En el documento generado

Cada documento generado para un empleado o evento debe conservar la trazabilidad de:

- tipo documental;
- plantilla aplicada;
- versión exacta de la plantilla;
- fecha y hora de generación;
- empleado o sujeto del documento;
- usuario que generó el documento;
- parámetros utilizados;
- facturación o documento final asociado;
- estado de la generación.

### 13.3 Diferenciación funcional clave

- Versión de la plantilla: corresponde al control interno del diseño del documento.
- Documento generado: corresponde al resultado emitido para un caso concreto, con la plantilla vigencia y metadatos específicos.

La versión de la plantilla no debe confundirse con la versión o instancia del documento generado.

## 14. Histórico y trazabilidad

El sistema debe registrar, al menos, la siguiente información para cada documento generado:

- tipo documental;
- plantilla asociada;
- versión de la plantilla utilizada;
- empleado o sujeto del documento;
- usuario generador;
- fecha y hora de generación;
- evento o proceso asociado (contrato, retiro, evaluación, renuncia, etc.);
- parámetros utilizados al generar el documento;
- documento final generado;
- estado del documento (borrador, generado, consultado, descargado, anulado si aplica);
- observaciones o razón de generación si la aplica.

No se define aún el diseño físico de almacenamiento, pero sí la necesidad funcional de tener una historia clara de cada generación para auditoría, consulta y respaldo documental.

## 15. Permisos

La generación documental debe respetar el modelo de permisos vigente del sistema. Las acciones funcionales necesarias incluyen:

- consultar plantillas documentales;
- generar documentos;
- consultar documentos generados;
- descargar documentos generados;
- consultar histórico/trazabilidad cuando el rol lo permita;
- administrar firmantes y metadatos documentales, si aplica;
- administrar plantillas y configuración solo si el Product Owner confirma que este alcance entra en la primera versión.

No se asume por defecto que un usuario del sistema pueda crear, editar o eliminar plantillas desde la aplicación. Esa capacidad requiere validación explícita del negocio y no debe asumirse solo porque exista un mecanismo parametrizado.

Es requisito que las operaciones estén sujetos a autorización por roles y permisos, no a disponibilidad lógica del frontend por sí sola.

## 16. Requerimientos funcionales

### RF-DOC-001
El sistema debe permitir definir y consultar un catálogo inicial de tipos documentales con su código, nombre, origen funcional y evento que lo habilita.

### RF-DOC-002
El sistema debe permitir asociar una plantilla a un tipo documental y mantener su versión, vigencia, estado y control documental.

### RF-DOC-003
El sistema debe resolver automáticamente los parámetros provenientes de la empresa, el empleado, el contrato, el retiro, la capacitación/evaluación o eventos asociados, cuando exista información disponible.

### RF-DOC-004
El sistema debe solicitar únicamente los parámetros faltantes que no puedan obtenerse del sistema o que sean específicos del documento a generar.

### RF-DOC-005
El sistema debe validar antes de generar que existan los datos mínimos requeridos por el documento y bloquear la generación cuando falten datos obligatorios.

### RF-DOC-006
El sistema debe permitir previsualizar el documento antes de su generación definitiva, mostrando los datos que se van a incluir.

### RF-DOC-007
El sistema debe generar un documento oficial solo si cumple las validaciones de negocio y de contenido mínimas del tipo documental seleccionado.

### RF-DOC-008
El sistema debe registrar la generación del documento con su tipo, plantilla, versión, empleado, usuario generador, fecha/hora y parámetros utilizados.

### RF-DOC-009
El sistema debe permitir consultar y descargar los documentos generados de acuerdo con los permisos del usuario.

### RF-DOC-010
El sistema debe mantener un control de firmantes y metadatos documentales separados de la lógica de contenido de la plantilla.

### RF-DOC-011
El sistema debe distinguir claramente entre la versión de la plantilla y la generación del documento para un caso concreto.

### RF-DOC-012
El sistema debe impedir la creación de documentos incompletos o inconsistentes, mostrando claramente qué información falta y de dónde debería originarse.

## 17. Reglas de negocio

### RN-DOC-001
Un documento solo puede generarse si el tipo documental habilitado y la plantilla vigente están disponibles y cumplen las condiciones del caso. En caso de información faltante o de condiciones no cumplidas, el sistema debe bloquear la generación y advertir el problema.

### RN-DOC-002
La información documental debe provenir de las fuentes autorizadas y vigentes del sistema: empresa/configuración, empleado, contrato, retiro, capacitación/evaluación o captura específica del usuario. No se debe duplicar información sin necesidad ni reemplazar la lógica de negocio existente.

### RN-DOC-003
La versión de la plantilla y la instancia del documento generado deben conservarse como elementos distintos para garantizar trazabilidad y control de revisiones.

### RN-DOC-004
Los datos de firmantes y datos de control documental deben mantenerse fuera del contenido fijo de la plantilla para facilitar mantenimiento y actualización sin afectar cada documento individual.

## 18. Criterios de aceptación

### 18.1 Generación con datos completos

- Dado un tipo documental disponible con la plantilla vigente y los datos requeridos del empleado, contrato o evento.
- Cuando el usuario selecciona el tipo documental y confirma la generación.
- Entonces el sistema genera el documento y registra la trazabilidad correspondiente.

### 18.2 Generación con información faltante

- Dado un documento que requiere información obligatoria no disponible en el sistema.
- Cuando el usuario intenta generarlo.
- Entonces el sistema bloquea la generación y muestra claramente qué información falta, qué tipo de dato es y de dónde debe provenir.

### 18.3 Generación de documento con parámetros adicionales

- Dado un tipo documental que exige datos específicos no presentes en registros operativos.
- Cuando la plantilla necesita esos parámetros.
- Entonces el sistema solicita únicamente esos parámetros y los incorpora al documento final una vez validados.

### 18.4 Consulta posterior

- Dado que un documento ya fue generado.
- Cuando el usuario consultado tiene permisos para ver documentos.
- Entonces puede consultar la información del documento, la versión de plantilla, el empleado y la trazabilidad de generación.

### 18.5 Plantilla en revisión o no vigente

- Dado una plantilla documental en estado inactivo, histórica o en revisión.
- Cuando se intenta usarla para generación.
- Entonces el sistema debe impedir su uso y mostrar el motivo según su estado documental.

## 19. Requerimientos no funcionales

### Seguridad
- La generación documental debe respetar el modelo de autenticación y autorización vigente del sistema.
- Los documentos generados y sus metadatos deben estar protegidos por permisos adecuados.

### Autorización
- Las operaciones de consulta, generación, gestión y administración de plantillas/documentos deben estar ligadas a roles y permisos explícitos.

### Trazabilidad
- Cada generación debe conservar la relación con la plantilla, la versión, el usuario y el caso asociado.

### Integridad
- El sistema no debe permitir la generación de documentos incompletos o con datos inconsistentes.
- La validación de datos debe ocurrir antes de generar el documento final.

### Manejo de documentos
- El sistema debe mantener el documento generado y sus datos asociados de manera consultable y descargable cuando corresponda.

### Rendimiento razonable
- La carga de datos del empleado, empresa y evento para la previsualización debe ser eficiente y no depender de consultas repetitivas o costosas.

## 20. GAP y decisiones pendientes

| GAP | Pregunta | Impacto | Responsable de validar |
|---|---|---|---|
| Nombre oficial del proceso de generación documental | ¿Se denomina “Gestión documental”, “Documentos y certificados”, o existe otra clasificación oficial? | Alta | Product Owner / Cliente |
| Versiones documentales | ¿Cada plantilla tiene versión formal por documento, por proceso o por tipo documental? | Alta | Product Owner / Cliente |
| Firmantes oficiales | ¿Quiénes son los firmantes definitivos de cada documento? | Alta | RRHH / Dirección / Product Owner |
| Variantes de BBTH-F-002 | ¿La diferencia entre variantes corresponde a un mismo documento con múltiples casos o a distintos tipos documentales? | Alta | Product Owner / Cliente |
| Campos obligatorios | ¿Qué campos son estrictamente obligatorios en cada documento y bajo qué condiciones? | Alta | RRHH / Product Owner |
| Formato final esperado | ¿Los documentos deben emitirse como texto editable, PDF, impresión o versión digital con firma? | Alta | Product Owner / Cliente |
| Origen de datos no evidenciados | ¿Existen campos de seguridad social, contrato o retiro no visibles en el sistema actual y que no se han documentado? | Media | Analista funcional / Cliente |
| Responsables de aprobación | ¿La revisión y aprobación documental es responsabilidad de Talento Humano, administración o dirección? | Media | Product Owner / Cliente |
| F-004 checklist operacional | ¿El checklist requiere aprobación de entrega, responsable o evidencia física? | Media | RRHH / Proceso operativo |
| Datos de cesantías | ¿El fondo, monto, concepto y destinación son datos del proceso o se ingresan manualmente al momento de la generación? | Media | Product Owner / Cliente |
| Registro de documentación histórica | ¿Se necesita almacenar solo el documento generado o también el historial completo de edición y revisión de la plantilla? | Media | Product Owner / Cliente |
| Validación de nuevo documento | ¿Se requiere aprobación del documento antes de su primer uso en producción? | Media | Product Owner / Cliente |

## 21. Historias / épicas

### Épica 1: Catálogo y control documental
- Definición de tipos documentales iniciales.
- Control de plantillas y sus versiones.
- Control de vigencia, estados y metadatos básicos de documentación.

### Épica 2: Mapeo de parámetros y fuentes de información
- Identificación de variables documentales reutilizables.
- Mapeo funcional de cada parámetro a su fuente de origen.
- Clarificación de datos faltantes o no disponibles en el sistema actual.

### Épica 3: Generación documental con validaciones
- Selección de tipo documental y empleado.
- Consulta de información existente.
- Validación de requisitos mínimos y bloqueo ante información faltante.
- Solicitud de parámetros adicionales específicos.
- Previsualización y generación.

### Épica 4: Trazabilidad y consulta
- Registro de cada generación.
- Consulta histórica de documentos emitidos.
- Descarga y seguimiento documental.
- Asociación con el proceso o evento que lo originó.

### Épica 5: Seguridad y permisos
- Control de acceso por roles y permisos.
- Restricción de administración de plantillas y documentos según perfil.
- Consulta y generación según competencia funcional.

### Épica 6: Firmantes y revisiones
- Mantenimiento centralizado de firmantes.
- Diferenciación entre firma responsable, aprobación y revisión.
- Inclusión de información de contacto y cargo en el documento según corresponda.

## Auditoría funcional previa a validación PO

| ID | Hallazgo | Estado | Evidencia | Acción |
|---|---|---|---|---|
| AUD-01 | La estructura funcional propuesta como Tipo documental → Plantilla → Parámetros → Fuente de información → Generación es coherente con el enfoque de reutilización y no se convierte en arquitectura técnica cerrada. | ✅ Confirmado por AS-IS / documento fuente. | El levantamiento funcional del proyecto y el análisis AS-IS identifican módulos con procesos ya existentes y una base documental compartida; el PRD mantiene la idea conceptual sin cerrar decisiones de diseño. | Mantener como enfoque funcional base del PRD. |
| AUD-02 | La capacidad debe reutilizar procesos existentes de empleados, contratación, capacitaciones, novedades y retiros, sin reescribir sus reglas. | ✅ Confirmado por AS-IS / documento fuente. | El inventario AS-IS documenta que esos módulos existen y se usan como origen documental. | Mantener el alcance en términos de consumo de procesos y no de redefinición. |
| AUD-03 | La separación entre datos automáticos, transaccionales y manuales está bien planteada. | ✅ Confirmado por AS-IS / documento fuente. | La matriz documento × parámetro y la matriz de reutilización distingue claramente información del sistema, del evento y de captura adicional. | Mantener y usar como criterio para validación funcional. |
| AUD-04 | El PRD evita afirmar que los campos existen en BD si no están confirmados. | ✅ Confirmado por AS-IS / documento fuente. | El documento usa “No disponible actualmente” y GAP para campos no evidenciados. | Mantener esta restricción. |
| AUD-05 | La variante de BBTH-F-002 requiere validación del Product Owner; no puede cerrarse aún como tipo, variante o plantilla configurable. | ⚠️ Requiere validación del Product Owner. | La documentación entregada presenta diferencias entre versiones del mismo certificado, pero no hay evidencia suficiente para decidir la clasificación funcional definitiva. | Dejar explícitamente pendiente y no cerrar la decisión. |
| AUD-06 | Los firmantes no deben asumirse como nombres permanentes inamovibles del sistema. | ⚠️ Requiere validación del Product Owner. | El PRD reconoce que nombres actuales pueden ser inconsistentes y no definitivos; la gestión de firmantes debe quedar como configuración funcional. | Mantener como requisito funcional, sin decidir aún su almacenamiento técnico. |
| AUD-07 | La separación entre tipo documental, plantilla, versión de plantilla, documento generado y generación es correcta. | ✅ Confirmado por AS-IS / documento fuente. | El PRD distingue claramente control documental del documento emitido y mantiene la trazabilidad funcional sin introducir diseño técnico. | Mantener la separación funcional. |
| AUD-08 | El histórico de generación se describe como trazabilidad funcional y no como diseño físico. | ✅ Confirmado por AS-IS / documento fuente. | El documento menciona metadatos, usuario, evento, fecha y parámetros, pero no define tablas, SP, storage ni endpoints. | Mantener sin entrar en diseño técnico. |
| AUD-09 | Los permisos propuestos son coherentes con el esquema actual de usuarios, roles y permisos. | ✅ Confirmado por AS-IS / documento fuente. | El sistema actual se basa en usuario → roles → permisos → capacidades, tal como se refleja en la documentación AS-IS. | Mantener la restricción de permisos sin inventar códigos nuevos. |
| AUD-10 | El formato de salida final no está definido por la evidencia disponible. | ⚠️ Requiere validación del Product Owner. | No existe evidencia inequívoca en los documentos entregados ni en la documentación AS-IS que determine si se requieren PDF, DOCX, impresión o cualquier otro formato. | Convertirlo en GAP y no asumirlo como requisito obligatorio en esta etapa. |
| AUD-11 | La administración de plantillas no queda asumida como requisito obligatorio de la primera versión. | ⚠️ Requiere validación del Product Owner. | El PRD menciona administración como posible alcance, pero no lo define como funcionalidad necesaria sin confirmación. | Mantenerlo como decisión pendiente y como posible alcance posterior. |
| AUD-12 | Existen datos que son funcionalmente necesarios, pero no están confirmados como campos actuales del sistema. | ⚠️ Requiere validación del Product Owner. | Casos como lugar de expedición, firmante, datos de seguridad social y ciertos valores de cesantías aparecen como requeridos o condicionales, pero no siempre como evidencia AS-IS. | Continuar registrándolos como GAP. |

## Decisiones que requieren Product Owner

### Bloqueantes
1. Definir si BBTH-F-002 corresponde a un solo tipo documental con variantes, a varios tipos documentales distintos o a una plantilla configurable con condiciones de contenido.
2. Confirmar la denominación oficial del proceso de gestión documental dentro de BBF SisAdmin.
3. Confirmar quiénes son los firmantes oficiales de cada documento y quién administra la información de firmantes.
4. Confirmar si el formato final de salida del documento debe ser PDF, DOCX, impresión o alguna otra salida no especificada.
5. Confirmar si la administración de plantillas va dentro del alcance inicial o se deja como funcionalidad posterior.

### Importantes
1. Determinar qué campos son obligatorios en cada documento y bajo qué condiciones del evento o del empleado.
2. Confirmar si el F-004 es un checklist de entrega operativa con evidencia física o solo una hoja de control documental.
3. Definir si los datos de cesantías (fondo, motivo, concepto, monto, destinación) se registran en el proceso actual o se capturan al generar el documento.
4. Confirmar si los datos de seguridad social y remuneración deben presentarse siempre en el certificado laboral o solo en algunas variantes.
5. Definir si la trazabilidad debe incluir sólo documento generado o también versión histórica de la plantilla y sus cambios.

### No bloqueantes
1. Definir la complejidad de la previsualización funcional para casos excepcionales.
2. Definir si se habilita carga masiva o automatización de plantillas en una etapa posterior.
3. Refinar la lista de metadatos documentales para administración más allá de la primera versión del producto.

## 22. Preguntas para validación con Product Owner

### Bloqueante
1. ¿Cuál es la denominación oficial del proceso que debe albergar esta capacidad: gestión documental, certificados, cartas oficiales o documentación laboral?
2. ¿Los documentos entregados representan un catálogo oficial definitivo para la primera entrega o solo un conjunto inicial que puede expandirse? 
3. ¿Qué perfil/rol formal debe poder generar documentos y qué perfil puede administrarlos o revisarlos?
4. ¿Las variantes observadas en BBTH-F-002 corresponden a un mismo tipo documental con variantes o a tipos documentales distintos?
5. ¿Qué firmantes deben aparecer formalmente en cada documento y quién debe administrarlos en el sistema?
6. ¿El sistema necesita conservar el documento generado solo como resultado final, o también debe registrar el historial completo de cambios de la plantilla y de la generación?

### Importante
1. ¿El documento F-004 debe ser un checklist con evidencia de entregas reales o solo un formulario de control documental?
2. ¿Los datos de cesantías (fondo, motivo, concepto, monto, destinación) se registran en el proceso actual o deben ingresarse al momento de la generación?
3. ¿Los datos de seguridad social y remuneración deben mostrarse siempre en el certificado laboral o solo en variantes seleccionadas?
4. ¿Se requiere trazabilidad por empleado y por proceso de negocio, o basta con historial documental por documento generado?
5. ¿Debe existir control de versiones de las plantillas además de sus estados de activación e inactivación?

### Mejora futura
1. ¿Se espera permitir generación massiva de varios documentos para una misma persona o evento?
2. ¿Se requiere permitir la edición manual del texto final después de la previsualización para casos excepcionales?
3. ¿Se desea integrar esta capacidad con otros módulos de gestión documental y archivo en una etapa posterior?
4. ¿Se contempla la posibilidad de plantilla parametrizada por área o por país/ciudad dentro de la misma organización?

## Estado del PRD

REQUIERE CORRECCIONES ANTES DE VALIDACIÓN PO

---

El presente PRD se entrega como base funcional para análisis, validación y posterior diseño técnico por parte del Arquitecto BMAD. No se define implementación técnica ni diseño de BD en este documento, de acuerdo con las restricciones del alcance actual.
