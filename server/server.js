import http from 'node:http';
import crypto from 'node:crypto';
import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const DATA_FILE = path.join(__dirname, 'data.json');
const PORT = Number(process.env.PORT || 3000);
const JWT_SECRET = process.env.JWT_SECRET || 'frizalia-local-development-secret';

const seedData = {
  usuarios: [],
  categorias: [
    { id_categoria: 1, nombre: 'Helados', activa: true },
    { id_categoria: 2, nombre: 'Paletas', activa: true },
    { id_categoria: 3, nombre: 'Aguas Naturales', activa: true },
  ],
  productos: [
    { id_producto: 1, nombre: 'Helado de fresa', descripcion: 'Frutal y cremosa', categoria: 'Helados', categoria_id: 1, precio: 35, stock: 20, disponible: true, imagen: '🍓' },
    { id_producto: 2, nombre: 'Helado de mango', descripcion: 'Con mango natural', categoria: 'Helados', categoria_id: 1, precio: 35, stock: 18, disponible: true, imagen: '🥭' },
    { id_producto: 3, nombre: 'Paleta de coco', descripcion: 'Coco con leche', categoria: 'Paletas', categoria_id: 2, precio: 28, stock: 30, disponible: true, imagen: '🥥' },
    { id_producto: 4, nombre: 'Paleta de limón', descripcion: 'Refrescante y ácida', categoria: 'Paletas', categoria_id: 2, precio: 25, stock: 25, disponible: true, imagen: '🍋' },
    { id_producto: 5, nombre: 'Helado de vainilla', descripcion: 'Clásico cremoso', categoria: 'Helados', categoria_id: 1, precio: 42, stock: 15, disponible: true, imagen: '🍦' },
    { id_producto: 6, nombre: 'Helado de chocolate', descripcion: 'Chocolate intenso', categoria: 'Helados', categoria_id: 1, precio: 45, stock: 12, disponible: true, imagen: '🍫' },
    { id_producto: 7, nombre: 'Agua de Horchata', descripcion: 'Tradicional y refrescante', categoria: 'Aguas Naturales', categoria_id: 3, precio: 25, stock: 20, disponible: true, imagen: '🌾' },
    { id_producto: 8, nombre: 'Agua de Fresa', descripcion: 'Natural y frutal', categoria: 'Aguas Naturales', categoria_id: 3, precio: 25, stock: 20, disponible: true, imagen: '🍓' },
    { id_producto: 9, nombre: 'Agua de Mango', descripcion: 'Natural y tropical', categoria: 'Aguas Naturales', categoria_id: 3, precio: 25, stock: 20, disponible: true, imagen: '🥭' },
    { id_producto: 10, nombre: 'Agua de Limón', descripcion: 'Natural y refrescante', categoria: 'Aguas Naturales', categoria_id: 3, precio: 25, stock: 20, disponible: true, imagen: '🍋' },
    { id_producto: 11, nombre: 'Agua de Pitahaya', descripcion: 'Natural y exótica', categoria: 'Aguas Naturales', categoria_id: 3, precio: 25, stock: 20, disponible: true, imagen: '🌸' },
    { id_producto: 12, nombre: 'Agua de Coco', descripcion: 'Natural y cremosa', categoria: 'Aguas Naturales', categoria_id: 3, precio: 25, stock: 20, disponible: true, imagen: '🥥' },
    { id_producto: 13, nombre: 'Helado de chocomenta', descripcion: 'Chocolate con menta refrescante', categoria: 'Helados', categoria_id: 1, precio: 42, stock: 15, disponible: true, imagen: '🍫' },
    { id_producto: 14, nombre: 'Helado de limón', descripcion: 'Cremoso y cítrico', categoria: 'Helados', categoria_id: 1, precio: 42, stock: 15, disponible: true, imagen: '🍋' },
    { id_producto: 15, nombre: 'Helado napolitano', descripcion: 'Chocolate, vainilla y fresa', categoria: 'Helados', categoria_id: 1, precio: 42, stock: 15, disponible: true, imagen: '🍨' },
    { id_producto: 16, nombre: 'Helado de capuchino', descripcion: 'Café cremoso con aroma intenso', categoria: 'Helados', categoria_id: 1, precio: 42, stock: 15, disponible: true, imagen: '☕' },
    { id_producto: 17, nombre: 'Paleta de uva', descripcion: 'Dulce y refrescante', categoria: 'Paletas', categoria_id: 2, precio: 28, stock: 20, disponible: true, imagen: '🍇' },
    { id_producto: 18, nombre: 'Paleta de fresa', descripcion: 'Fresa natural y cremosa', categoria: 'Paletas', categoria_id: 2, precio: 28, stock: 20, disponible: true, imagen: '🍓' },
    { id_producto: 19, nombre: 'Paleta de piña', descripcion: 'Tropical y refrescante', categoria: 'Paletas', categoria_id: 2, precio: 28, stock: 20, disponible: true, imagen: '🍍' },
  ],
  solicitudes: [],
};

function normalizarTextoGuardado(value) {
  if (typeof value === 'string') {
    return value.replace(/\s*Â·\s*/g, ' - ').replace(/\s*·\s*/g, ' - ');
  }
  if (Array.isArray(value)) {
    return value.map(normalizarTextoGuardado);
  }
  if (value && typeof value === 'object') {
    for (const [key, child] of Object.entries(value)) {
      value[key] = normalizarTextoGuardado(child);
    }
  }
  return value;
}

async function loadData() {
  try {
    const raw = await fs.readFile(DATA_FILE, 'utf8');
    const loaded = JSON.parse(raw);
    const normalized = normalizarTextoGuardado(loaded);
    if (JSON.stringify(normalized) !== raw) {
      await fs.writeFile(DATA_FILE, JSON.stringify(normalized, null, 2));
    }
    return normalized;
  } catch (error) {
    if (error.code !== 'ENOENT') throw error;
    await fs.writeFile(DATA_FILE, JSON.stringify(seedData, null, 2));
    return structuredClone(seedData);
  }
}

let data = await loadData();

async function saveData() {
  await fs.writeFile(DATA_FILE, JSON.stringify(data, null, 2));
}

function send(res, status, payload) {
  const body = JSON.stringify(payload);
  res.writeHead(status, {
    'Content-Type': 'application/json; charset=utf-8',
    'Content-Length': Buffer.byteLength(body),
  });
  res.end(body);
}

function base64Url(value) {
  return Buffer.from(value).toString('base64url');
}

function signToken(payload) {
  const header = base64Url(JSON.stringify({ alg: 'HS256', typ: 'JWT' }));
  const body = base64Url(JSON.stringify({ ...payload, exp: Math.floor(Date.now() / 1000) + 60 * 60 * 24 * 7 }));
  const signature = crypto.createHmac('sha256', JWT_SECRET).update(`${header}.${body}`).digest('base64url');
  return `${header}.${body}.${signature}`;
}

function verifyToken(token) {
  try {
    const [header, body, signature] = token.split('.');
    const expected = crypto.createHmac('sha256', JWT_SECRET).update(`${header}.${body}`).digest('base64url');
    if (!crypto.timingSafeEqual(Buffer.from(signature), Buffer.from(expected))) return null;
    const payload = JSON.parse(Buffer.from(body, 'base64url').toString('utf8'));
    if (payload.exp && payload.exp < Math.floor(Date.now() / 1000)) return null;
    return payload;
  } catch {
    return null;
  }
}

function hashPassword(password) {
  const salt = crypto.randomBytes(16).toString('hex');
  const hash = crypto.scryptSync(password, salt, 64).toString('hex');
  return `${salt}:${hash}`;
}

function verifyPassword(password, stored) {
  const [salt, expected] = stored.split(':');
  if (!salt || !expected) return false;
  const actual = crypto.scryptSync(password, salt, 64).toString('hex');
  return crypto.timingSafeEqual(Buffer.from(actual, 'hex'), Buffer.from(expected, 'hex'));
}

async function readJson(req) {
  let raw = '';
  for await (const chunk of req) raw += chunk;
  if (!raw) return {};
  try {
    return JSON.parse(raw);
  } catch {
    throw { status: 400, mensaje: 'El cuerpo de la solicitud no es JSON válido.' };
  }
}

function userPublic(user) {
  return { id_usuario: user.id_usuario, nombre: user.nombre, correo: user.correo, telefono: user.telefono || null };
}

function auth(req, res) {
  const authorization = req.headers.authorization || '';
  const token = authorization.startsWith('Bearer ') ? authorization.slice(7) : '';
  const payload = token ? verifyToken(token) : null;
  if (!payload) {
    send(res, 401, { mensaje: 'Tu sesión no es válida. Inicia sesión nuevamente.' });
    return null;
  }
  const user = data.usuarios.find((item) => item.id_usuario === payload.id_usuario);
  if (!user) {
    send(res, 401, { mensaje: 'La cuenta ya no existe.' });
    return null;
  }
  return user;
}

const server = http.createServer(async (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Headers', 'Authorization, Content-Type, Accept');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Vary', 'Origin');

  if (req.method === 'OPTIONS') {
    res.writeHead(204);
    res.end();
    return;
  }

  const url = new URL(req.url, `http://${req.headers.host || 'localhost'}`);
  const pathName = url.pathname.replace(/\/$/, '') || '/';

  try {
    if (req.method === 'GET' && pathName === '/api/health') {
      send(res, 200, { ok: true, servicio: 'Frizalia API', version: '1.0.0' });
      return;
    }

    if (req.method === 'GET' && pathName === '/api/productos') {
      const productos = data.productos.filter((producto) => producto.disponible && producto.stock > 0);
      send(res, 200, productos);
      return;
    }

    if (req.method === 'GET' && pathName === '/api/categorias/activas') {
      send(res, 200, data.categorias.filter((categoria) => categoria.activa));
      return;
    }

    if (req.method === 'POST' && pathName === '/api/auth/registro') {
      const body = await readJson(req);
      const nombre = String(body.nombre || '').trim();
      const correo = String(body.correo || '').trim().toLowerCase();
      const password = String(body.password || '');
      const telefono = String(body.telefono || '').trim();
      if (!nombre || !correo || !password) {
        send(res, 400, { mensaje: 'Nombre, correo y contraseña son obligatorios.' });
        return;
      }
      if (!/^\S+@\S+\.\S+$/.test(correo)) {
        send(res, 400, { mensaje: 'Ingresa un correo electrónico válido.' });
        return;
      }
      if (password.length < 6) {
        send(res, 400, { mensaje: 'La contraseña debe tener al menos 6 caracteres.' });
        return;
      }
      if (data.usuarios.some((user) => user.correo === correo)) {
        send(res, 409, { mensaje: 'Ya existe una cuenta con este correo.' });
        return;
      }
      const user = { id_usuario: data.usuarios.length ? Math.max(...data.usuarios.map((item) => item.id_usuario)) + 1 : 1, nombre, correo, telefono, password_hash: hashPassword(password) };
      data.usuarios.push(user);
      await saveData();
      send(res, 201, { mensaje: 'Cuenta creada correctamente.', usuario: userPublic(user) });
      return;
    }

    if (req.method === 'POST' && pathName === '/api/auth/login') {
      const body = await readJson(req);
      const correo = String(body.correo || '').trim().toLowerCase();
      const password = String(body.password || '');
      const user = data.usuarios.find((item) => item.correo === correo);
      if (!user || !verifyPassword(password, user.password_hash)) {
        send(res, 401, { mensaje: 'Correo o contraseña incorrectos.' });
        return;
      }
      send(res, 200, { token: signToken({ id_usuario: user.id_usuario }), usuario: userPublic(user) });
      return;
    }

    if (req.method === 'POST' && pathName === '/api/solicitudes') {
      const user = auth(req, res);
      if (!user) return;
      const body = await readJson(req);
      const minutosLlegada = Number(body.minutos_llegada);
      if (!Number.isInteger(minutosLlegada) || minutosLlegada < 5 || minutosLlegada > 240) {
        send(res, 400, { mensaje: 'Los minutos de llegada deben estar entre 5 y 240.' });
        return;
      }
      const productos = Array.isArray(body.productos) ? body.productos : [];
      if (!productos.length) {
        send(res, 400, { mensaje: 'Agrega al menos un producto a la solicitud.' });
        return;
      }

      const detalles = [];
      for (const item of productos) {
        const id = Number(item.id_producto);
        const cantidad = Number(item.cantidad);
        if (!Number.isInteger(cantidad) || cantidad < 1) {
          send(res, 400, { mensaje: 'La cantidad de cada producto debe ser mayor a cero.' });
          return;
        }
        const producto = data.productos.find((candidate) => candidate.id_producto === id);
        if (!producto || !producto.disponible) {
          send(res, 404, { mensaje: 'Uno de los productos ya no está disponible.' });
          return;
        }
        if (producto.stock < cantidad) {
          send(res, 409, { mensaje: `Solo quedan ${producto.stock} unidades de ${producto.nombre}.` });
          return;
        }
        const esAguaNatural = producto.categoria === 'Aguas Naturales';
        const esHelado = producto.categoria === 'Helados';
        const precioSolicitado = Number(item.precio_unitario);
        let precioUnitario = producto.precio;

        if (esAguaNatural && (precioSolicitado === 43 || precioSolicitado === 60)) {
          precioUnitario = precioSolicitado;
        } else if (esHelado) {
          const tamanoValido = typeof item.nombre_producto === 'string' &&
            (item.nombre_producto.includes('Pequeño') ||
              item.nombre_producto.includes('Mediano') ||
              item.nombre_producto.includes('Grande'));
          const base = item.nombre_producto.includes('Pequeño')
            ? 20
            : item.nombre_producto.includes('Mediano')
              ? 25
              : 28;
          const baseValida = precioSolicitado >= base &&
            ((precioSolicitado - base) % 5 === 0);
          if (tamanoValido && baseValida) {
            precioUnitario = precioSolicitado;
          }
        }
        const nombrePersonalizado = typeof item.nombre_producto === 'string' && item.nombre_producto.trim();
        const nombreProducto = (esAguaNatural || esHelado) && nombrePersonalizado
          ? nombrePersonalizado
          : producto.nombre;
        detalles.push({ id_producto: id, nombre_producto: nombreProducto, cantidad, precio_unitario: precioUnitario, subtotal: precioUnitario * cantidad });
      }

      for (const detalle of detalles) {
        const producto = data.productos.find((candidate) => candidate.id_producto === detalle.id_producto);
        producto.stock -= detalle.cantidad;
      }

      const total = detalles.reduce((sum, detalle) => sum + detalle.subtotal, 0);
      const id = data.solicitudes.length ? Math.max(...data.solicitudes.map((item) => item.id_solicitud)) + 1 : 1;
      const solicitud = { id_solicitud: id, folio: `FRZ-${String(id).padStart(6, '0')}`, id_usuario: user.id_usuario, estado: 'PENDIENTE', fecha_solicitud: new Date().toISOString(), minutos_llegada: minutosLlegada, productos: detalles, total };
      data.solicitudes.unshift(solicitud);
      await saveData();
      send(res, 201, solicitud);
      return;
    }

    if (req.method === 'GET' && pathName === '/api/solicitudes/mis-pedidos') {
      const user = auth(req, res);
      if (!user) return;
      const solicitudes = data.solicitudes.filter((solicitud) => solicitud.id_usuario === user.id_usuario);
      send(res, 200, { solicitudes });
      return;
    }

    const tiempoLlegadaMatch = req.method === 'POST'
      ? pathName.match(/^\/api\/solicitudes\/(\d+)\/tiempo-llegada$/)
      : null;
    if (tiempoLlegadaMatch) {
      const user = auth(req, res);
      if (!user) return;
      const idSolicitud = Number(tiempoLlegadaMatch[1]);
      const solicitud = data.solicitudes.find((item) =>
        item.id_solicitud === idSolicitud && item.id_usuario === user.id_usuario
      );
      if (!solicitud) {
        send(res, 404, { mensaje: 'No se encontró el pedido.' });
        return;
      }
      if (['ACEPTADA', 'ACEPTADO', 'EN_PREPARACION', 'LISTA', 'ENTREGADA', 'RECHAZADA', 'CANCELADA'].includes(solicitud.estado)) {
        send(res, 409, { mensaje: 'El tiempo ya no puede modificarse en este estado.' });
        return;
      }
      const body = await readJson(req);
      const minutosLlegada = Number(body.minutos_llegada);
      if (!Number.isInteger(minutosLlegada) || minutosLlegada < 1 || minutosLlegada > 180) {
        send(res, 400, { mensaje: 'El tiempo debe estar entre 1 y 180 minutos.' });
        return;
      }
      solicitud.minutos_llegada = minutosLlegada;
      await saveData();
      send(res, 200, solicitud);
      return;
    }

    const cancelarMatch = req.method === 'POST'
      ? pathName.match(/^\/api\/solicitudes\/(\d+)\/cancelar$/)
      : null;
    if (cancelarMatch) {
      const user = auth(req, res);
      if (!user) return;
      const idSolicitud = Number(cancelarMatch[1]);
      const solicitud = data.solicitudes.find((item) =>
        item.id_solicitud === idSolicitud && item.id_usuario === user.id_usuario
      );
      if (!solicitud) {
        send(res, 404, { mensaje: 'No se encontró el pedido.' });
        return;
      }
      if (['ACEPTADA', 'ACEPTADO', 'EN_PREPARACION', 'LISTA', 'ENTREGADA', 'RECHAZADA', 'CANCELADA'].includes(solicitud.estado)) {
        send(res, 409, { mensaje: 'Este pedido ya no puede cancelarse.' });
        return;
      }
      solicitud.estado = 'CANCELADA';
      for (const detalle of solicitud.productos || []) {
        const producto = data.productos.find((item) => item.id_producto === Number(detalle.id_producto));
        if (producto) producto.stock += Number(detalle.cantidad) || 0;
      }
      await saveData();
      send(res, 200, solicitud);
      return;
    }

    send(res, 404, { mensaje: 'Ruta no encontrada.' });
  } catch (error) {
    if (error && error.status) {
      send(res, error.status, { mensaje: error.mensaje });
      return;
    }
    console.error(error);
    send(res, 500, { mensaje: 'Ocurrió un error interno en la API.' });
  }
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`Frizalia API disponible en http://127.0.0.1:${PORT}/api`);
  console.log(`Escuchando en todas las interfaces; productos: ${data.productos.length}`);
});
