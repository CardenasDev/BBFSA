# Barro Blanco Farms - Sistema Administrativo

Frontend standalone desarrollado con Angular 22 para consumir la API Laravel ubicada en `../Back`.

## Requisitos

- Node.js 22 o superior
- Backend disponible en `http://localhost/BBF%20SisAdmin/Back/public/api`

## Desarrollo

```bash
npm install
npm start
```

La pantalla de acceso queda disponible en `http://localhost:4200/login`.

El entorno local consume directamente `http://localhost/BBF%20SisAdmin/Back/public/api`, configurado exclusivamente en `src/environments/environment.ts`.

## Verificación

```bash
npm run build
npm test
```

La compilación de producción reemplaza la URL de la API por `/api`.
