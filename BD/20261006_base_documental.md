# Ejecución de la base documental

Script: `20261006_base_documental.sql`.

## Objetos

- Tabla `bbf_documento_formatos`.
- `SP_BBF_DOCUMENTO_FORMATOS_LISTAR(contexto, fecha)`.
- `SP_BBF_DOCUMENTO_FORMATO_OBTENER(clave, variante, fecha)`.

No crea registros de certificados emitidos ni inserta datos institucionales o de plantillas. El catálogo queda vacío. Los parámetros compartidos se mantienen en `bbf_parametros_sistema`, mediante los SP existentes.

## Cómo ejecutar

En un cliente SQL compatible con `DELIMITER`, seleccionar la BD de pruebas correcta y ejecutar el archivo completo. No lleva `USE` porque los nombres de BD varían entre ambientes.

Con el cliente de línea de comandos, abrir una sesión (la contraseña se pide sin escribirla en el comando):

```powershell
& 'C:\xampp\mysql\bin\mysql.exe' -h HOST -u USUARIO -p --database=BASE_DESTINO
```

Dentro del cliente:

```sql
SELECT DATABASE();
SOURCE C:/D/Repo/BBFSA/BD/20261006_base_documental.sql;
```

La instalación requiere CREATE, CREATE ROUTINE, ALTER ROUTINE y permisos de consumo. El usuario que invoque los SP requiere EXECUTE, SELECT y CREATE TEMPORARY TABLES: son `SQL SECURITY INVOKER`. La autorización funcional permanece en backend.

Cada consulta materializa una copia temporal privada de las filas del catálogo, la valida y devuelve esa misma copia. Se elimina al terminar o ante error; no persiste certificados ni modifica datos del catálogo. Los nombres `tmp_bbf_doc_formatos_lista` y `tmp_bbf_doc_formato_detalle` están reservados para estas rutinas dentro de la conexión.

## Reejecución y mantenimiento

La tabla usa `IF NOT EXISTS` y conserva sus filas. Los dos SP se reemplazan con `DROP PROCEDURE IF EXISTS` y `CREATE PROCEDURE`; ejecutar durante una ventana sin llamadas concurrentes. Si se otorgaron permisos específicos sobre esos SP, comprobarlos y reotorgarlos tras el reemplazo.

Si la tabla ya existía, comparar `SHOW CREATE TABLE bbf_documento_formatos` con el script antes de ejecutarlo. El script no adapta esquemas incompatibles. DDL tiene commits implícitos; una transacción externa no permite deshacer el conjunto.

Guardar claves funcionales, variantes y contextos en mayúsculas y sin espacios periféricos. El código impreso no es una identidad única: F-015 también aparece en el catálogo contractual existente. Una misma clave/variante debe conservar su contexto entre revisiones.

La vigencia incluye ambas fechas extremas. Al sustituir una versión, cerrar la anterior el día previo al inicio de la nueva. Los SP detectan superposiciones al consultar; la tabla no impide todos los intervalos superpuestos al insertar directamente.

Cada fila empieza con `HABILITADO_GENERACION=0`. Habilitarla solo tras confirmar metadatos y disponer de su renderizador. La BD comprueba una clave de renderizador no vacía; el backend debe comprobar que esa clave está implementada.

JSON válido no garantiza estructura de negocio. Convención propuesta:

- `CONTROL_DOCUMENTAL_JSON`: objeto con elaboró, revisó, aprobó y motivo de revisión.
- `FIRMANTES_JSON`: arreglo ordenado de referencias a códigos de parámetros o funciones como EMPLEADO/SUPERVISOR_EVENTO.
- `CONFIG_CAMPOS_JSON`: objeto de campos adicionales por variante; no SQL ni código ejecutable.

Antes de consumir estos JSON, definir y validar su estructura en backend. No usar datos maestros editables recibidos del cliente como identidad, salario o contrato certificado.

La fecha es obligatoria en ambos SP. Enviar desde backend la fecha de negocio America/Bogota; no depender de la zona horaria del servidor SQL. Un contexto nulo o vacío lista todos los contextos. Ausencia de formato en detalle y ambigüedad producen SQLSTATE 45000.

## Verificación esperada

Al ejecutarlo en una BD vacía, se crea una tabla y dos SP; la llamada final de listado devuelve cero filas. La reejecución conserva las filas existentes. Probar además: fechas límite, filas inactivas/deshabilitadas, fecha nula, contexto inválido, variante inexistente, JSON inválido y vigencias superpuestas.

No se incluyen semillas oficiales: están pendientes las variantes F-002, versión F-004, firmantes/contactos y la colisión del código F-015.

Validación realizada: 24 comprobaciones correctas en una instancia temporal aislada de MariaDB 10.4.32, incluyendo reejecución con conservación de filas. La instancia fue apagada. No se ejecutó en la BD del proyecto; el export de referencia evidencia MariaDB 10.11.
