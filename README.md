# Frizalia móvil

Aplicación Flutter para clientes. Consume productos, categorías, autenticación, solicitudes e historial del backend Frizalia.

## Ejecutar

### 1. Iniciar la API incluida

```sh
cd server
npm start
```

La API escucha en `0.0.0.0:3000` y almacena los datos locales en `server/data.json`. Los datos iniciales incluyen categorías y productos disponibles. Puedes definir otro puerto y secreto JWT:

```sh
$env:PORT="3000"
$env:JWT_SECRET="cambia-este-secreto"
npm start
```

### 2. Ejecutar Flutter

- Android Emulator: `http://10.0.2.2:3000/api`.
- iOS Simulator, web y escritorio local: `http://127.0.0.1:3000/api`.
- Teléfono físico: usa la IP LAN del equipo que ejecuta el backend.

```sh
flutter run --dart-define=API_BASE_URL=http://192.168.1.20:3000/api
```

Sustituye la IP de ejemplo por la del equipo y conecta ambos dispositivos a la misma red. HTTP y tráfico cleartext están habilitados para desarrollo local; no publiques la app así, usa HTTPS en producción.

## Catálogo

La API incluida crea automáticamente categorías y productos iniciales. Solo los productos disponibles con stock mayor que cero se muestran en el móvil. Los cambios de stock se conservan en `server/data.json`.
