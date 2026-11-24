# Frizalia móvil

Aplicación Flutter para clientes. Consume productos, categorías, autenticación, solicitudes e historial del backend Frizalia.

## Ejecutar

El backend debe estar activo en el puerto 3000, conectado a `frizalia_demo_db`, con `/api/auth` habilitado y `JWT_SECRET` configurado. Registra una cuenta cliente desde la app; la cuenta técnica del SQL no puede iniciar sesión.

- Android Emulator: `http://10.0.2.2:3000/api`.
- iOS Simulator y escritorio local: `http://localhost:3000/api`.
- Teléfono físico: usa la IP LAN del equipo que ejecuta el backend.

```sh
flutter run --dart-define=API_BASE_URL=http://192.168.1.20:3000/api
```

Sustituye la IP de ejemplo por la del equipo y conecta ambos dispositivos a la misma red. HTTP y tráfico cleartext están habilitados para desarrollo local; no publiques la app así, usa HTTPS en producción.

## Catálogo

El SQL crea categorías, pero no productos. Registra productos desde el panel web; solo los disponibles con stock mayor que cero se muestran en el móvil.
