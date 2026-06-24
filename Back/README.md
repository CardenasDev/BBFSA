# BBF SisAdmin API

API REST en Laravel 12 para el sistema administrativo de Barro Blanco Farms. Toda la lógica de persistencia consume los procedimientos `SP_BBF_*`; no se usa Eloquent ni SQL directo contra tablas.

## Requisitos e instalación

- PHP 8.2 o superior con `pdo_mysql`, `mbstring`, `openssl` y `fileinfo`.
- MySQL con la base `BBF_ADMINISTRATIVO` y sus procedimientos instalados.
- Composer 2.

```bash
composer install
copy .env.example .env
php artisan key:generate
```

Configure las credenciales MySQL y genere un secreto JWT de al menos 32 caracteres:

```bash
php -r "echo bin2hex(random_bytes(32));"
php artisan serve
```

En producción, `APP_DEBUG=false`, `JWT_SECRET` debe ser distinto por entorno y `CORS_ALLOWED_ORIGINS` debe contener una lista separada por comas de orígenes explícitos. Nunca use `*`.

## Bootstrap del primer administrador

Antes de crear usuarios desde la API, configure las credenciales iniciales en `.env`:

```dotenv
BBF_ADMIN_EMAIL=admin@barroblancofarms.com.co
BBF_ADMIN_USERNAME=admin
BBF_ADMIN_PASSWORD=una-clave-segura
```

Ejecute manualmente:

```bash
php artisan bbf:bootstrap-admin
```

El comando es idempotente: asegura el usuario `ADMIN` local, el rol `SUPER_ADMIN`, sus permisos y las asociaciones sin duplicarlos. Si el usuario ya existe, no reemplaza su contraseña. En ambiente local, las variables ausentes usan `admin@barroblancofarms.com.co`, `admin` y `abc123*` con una advertencia; cambie esa contraseña en el primer acceso. Fuera del ambiente local, las tres variables son obligatorias y no hay valores por defecto.

## Formato

Las respuestas usan siempre JSON:

```json
{"success":true,"message":"Operación exitosa","data":{}}
```

Los errores siguen la forma:

```json
{"success":false,"message":"Descripción del error","errors":{}}
```

## Autenticación

### Login

```http
POST /api/auth/login
Content-Type: application/json

{
  "usuario": "admin@barroblancofarms.com.co",
  "password": "clave"
}
```

La respuesta incluye `access_token`, `refresh_token`, `expires_in`, `usuario`, `roles`, `permisos` y `requiere_cambio_password`. Envíe el access token en `Authorization: Bearer <token>`.

### Renovar y cerrar sesión

```http
POST /api/auth/refresh
Content-Type: application/json

{"refresh_token":"token-de-64-caracteres"}
```

El refresh token se rota en cada renovación y en MySQL solo se almacena su hash SHA-256.

```http
POST /api/auth/logout
Authorization: Bearer <access_token>

POST /api/auth/logout-all
Authorization: Bearer <access_token>

GET /api/auth/me
Authorization: Bearer <access_token>
```

### Cambiar contraseña

```http
POST /api/auth/change-password
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "current_password": "ClaveAnterior1",
  "password": "ClaveNueva2",
  "password_confirmation": "ClaveNueva2"
}
```

## Usuarios, roles y permisos

```http
GET /api/users?estado=ACTIVO&tipo_usuario=ADMIN&buscar=ana
GET /api/users/1
GET /api/users/1/roles
GET /api/users/1/permissions
GET /api/catalogs/document-types?solo_activos=true
GET /api/catalogs/areas?solo_activos=true
GET /api/catalogs/positions?solo_activos=true
GET /api/catalogs/contract-types?solo_activos=true
GET /api/employees/by-document/1234567890
GET /api/roles?solo_activos=1
GET /api/permissions?solo_activos=1&modulo=USUARIOS
```

```http
POST /api/users
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "numero_documento_empleado": "1234567890",
  "nombre_usuario": "ana",
  "correo": "ana@barroblancofarms.com.co",
  "password": "Temporal123",
  "tipo_usuario": "EMPLEADO",
  "tipo_autenticacion": "LOCAL",
  "requiere_cambio_password": true,
  "correo_verificado": true
}
```

Para `tipo_usuario` igual a `EMPLEADO`, `numero_documento_empleado` es obligatorio y se resuelve internamente contra `BBF_EMPLEADOS.ID_EMPLEADO`. Para `ADMIN` y `PERSONAL_AUTORIZADO` puede omitirse.

### Catalogos

```http
GET /api/catalogs/document-types?solo_activos=true
GET /api/catalogs/areas?solo_activos=true
GET /api/catalogs/positions?solo_activos=true
GET /api/catalogs/contract-types?solo_activos=true
Authorization: Bearer <access_token>
```

Respuesta:

```json
{
  "success": true,
  "message": "Tipos de documento consultados correctamente",
  "data": [
    {
      "id_tipo_documento": 1,
      "nombre": "Cedula de ciudadania",
      "activo": true
    }
  ]
}
```

Las respuestas de areas, cargos y tipos de contrato usan el mismo formato y retornan `descripcion` junto a `nombre` y `activo`.

```http
PATCH /api/users/1/status
Content-Type: application/json

{"estado":"INACTIVO"}

POST /api/users/1/roles
Content-Type: application/json

{"id_rol":2}

DELETE /api/users/1/roles/2
```

Todos requieren Bearer token. Los códigos exigidos por las rutas son `USUARIOS_LISTAR`, `USUARIOS_VER`, `USUARIOS_CREAR`, `USUARIOS_CAMBIAR_ESTADO`, `USUARIOS_ASIGNAR_ROL`, `USUARIOS_QUITAR_ROL`, `USUARIOS_VER_ROLES`, `USUARIOS_VER_PERMISOS`, `ROLES_LISTAR` y `PERMISOS_LISTAR`; deben existir con esos valores en `BBF_PERMISOS.CODIGO` y estar asignados al rol correspondiente.

## Arquitectura

- `app/Repositories`: capa de persistencia ordinaria que ejecuta `CALL SP_BBF_*`.
- `bbf:bootstrap-admin`: bootstrap excepcional; usa SP para usuarios, roles y asociaciones. Asegura permisos directamente por `CODIGO` porque no existe `SP_BBF_PERMISOS_CREAR`.
- `app/Services`: reglas de autenticación, usuarios, tokens y auditoría.
- `app/Http/Requests`: validación de entrada.
- `auth.jwt`: valida firma y expiración del access token.
- `permission`: compara los códigos del JWT con el permiso requerido.

Los eventos de login, logout, contraseña, creación/estado de usuarios y roles se registran mediante `SP_BBF_LOG_AUDITORIA_CREAR`.

## OpenAPI

La documentación OpenAPI 3.1 se genera con `dedoc/scramble`. Al ejecutar el backend con `php artisan serve` está disponible en:

- Interfaz interactiva: `http://127.0.0.1:8000/docs/api`
- Documento JSON: `http://127.0.0.1:8000/docs/api.json`
- Health check: `http://127.0.0.1:8000/api/health`

La interfaz incluye el esquema HTTP Bearer `bearerAuth`. En **Authorize**, ingrese únicamente el access token JWT retornado por `/api/auth/login`.

Comandos de documentación:

```bash
php artisan scramble:analyze
php artisan scramble:export
php artisan scramble:clear
php artisan scramble:cache
```

`scramble:export` actualiza `api.json`. La UI genera el documento dinámicamente en ambiente local; después de cambios puede usarse `scramble:clear` para invalidar la caché. En otros ambientes, el acceso a la documentación permanece bloqueado salvo que se defina explícitamente el gate `viewApiDocs`.
