import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:frizalia/Models/producto.dart';

class ApiService {
  ApiService._();

  static final ApiService instance = ApiService._();
  static const _configuredUrl = String.fromEnvironment('API_BASE_URL');

  String? _token;
  Map<String, dynamic>? usuario;

  String get baseUrl {
    if (_configuredUrl.isNotEmpty) {
      return _configuredUrl.trim().replaceFirst(RegExp(r'/+$'), '');
    }

    if (kIsWeb) return 'http://127.0.0.1:3000/api';

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:3000/api';
      case TargetPlatform.iOS:
        return 'http://127.0.0.1:3000/api';
      default:
        return 'http://127.0.0.1:3000/api';
    }
  }

  Map<String, String> get _headers => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  Future<dynamic> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    late final Uri uri;
    try {
      uri = Uri.parse('$baseUrl$path');
      if (!uri.hasScheme || uri.host.isEmpty) {
        throw const FormatException();
      }
    } on FormatException {
      throw Exception(
        'La URL de la API no es válida. Configura API_BASE_URL con una dirección completa.',
      );
    }

    final encodedBody = body == null ? null : jsonEncode(body);
    late final http.Response response;

    try {
      switch (method) {
        case 'POST':
          response = await http
              .post(uri, headers: _headers, body: encodedBody)
              .timeout(const Duration(seconds: 20));
        default:
          response = await http
              .get(uri, headers: _headers)
              .timeout(const Duration(seconds: 20));
      }
    } on TimeoutException {
      throw Exception(
        'La API tardó demasiado en responder. Verifica que el servidor esté activo.',
      );
    } on Exception {
      throw Exception(
        'No se pudo conectar con Frizalia en $baseUrl. Verifica la URL y que el servidor esté activo.',
      );
    }

    dynamic data;
    if (response.body.isNotEmpty) {
      try {
        data = jsonDecode(response.body);
      } on FormatException {
        throw Exception('La API respondió con un formato no válido.');
      }
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String mensaje = 'La solicitud no pudo completarse.';
      if (data is Map<String, dynamic>) {
        mensaje = data['mensaje'] as String? ??
            data['error'] as String? ??
            mensaje;
      }
      if (response.statusCode == 401) {
        cerrarSesion();
      }
      throw Exception(mensaje);
    }

    return data;
  }

  Future<List<Producto>> obtenerProductos() async {
    final data = await _request('GET', '/productos');
    if (data is! List) return [];

    return data
        .whereType<Map<String, dynamic>>()
        .where((producto) {
          final disponible = producto['disponible'];
          final stock = int.tryParse('${producto['stock'] ?? 0}') ?? 0;
          return (disponible == 1 || disponible == true) && stock > 0;
        })
        .map(Producto.fromJson)
        .toList();
  }

  Future<List<String>> obtenerCategorias() async {
    final data = await _request('GET', '/categorias/activas');
    if (data is! List) return [];

    final categorias = data
        .whereType<Map<String, dynamic>>()
        .map((categoria) => categoria['nombre'])
        .whereType<String>()
        .map((nombre) => nombre == 'Nieves' ? 'Helados' : nombre)
        .toSet()
        .toList();

    if (!categorias.contains('Aguas Naturales')) {
      categorias.add('Aguas Naturales');
    }

    return categorias;
  }

  Future<void> iniciarSesion({
    required String correo,
    required String password,
  }) async {
    final data = await _request(
      'POST',
      '/auth/login',
      body: {'correo': correo, 'password': password},
    );
    if (data is! Map<String, dynamic> || data['token'] is! String) {
      throw Exception('La respuesta de autenticación no es válida.');
    }
    _token = data['token'] as String;
    usuario = data['usuario'] as Map<String, dynamic>?;
  }

  Future<void> registrarCliente({
    required String nombre,
    required String correo,
    required String password,
    String? telefono,
  }) async {
    await _request(
      'POST',
      '/auth/registro',
      body: {
        'nombre': nombre,
        'correo': correo,
        'password': password,
        if (telefono != null && telefono.isNotEmpty) 'telefono': telefono,
      },
    );
    await iniciarSesion(correo: correo, password: password);
  }

  Future<Map<String, dynamic>> crearSolicitud({
    required List<Producto> productos,
    required Map<int, int> cantidades,
    required int minutosLlegada,
  }) async {
    final data = await _request(
      'POST',
      '/solicitudes',
      body: {
        'minutos_llegada': minutosLlegada,
        'productos': [
          for (final producto in productos)
            {
              'id_producto': producto.id,
              'cantidad': cantidades[producto.id] ?? 0,
              'nombre_producto': producto.nombre,
              'precio_unitario': producto.precio,
            },
        ],
      },
    );
    if (data is! Map<String, dynamic>) {
      throw Exception('La respuesta de solicitud no es válida.');
    }
    return data;
  }

  Future<List<Map<String, dynamic>>> obtenerMisSolicitudes() async {
    final data = await _request('GET', '/solicitudes/mis-pedidos');
    if (data is! Map<String, dynamic> || data['solicitudes'] is! List) {
      return [];
    }
    return (data['solicitudes'] as List)
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  Future<void> actualizarTiempoLlegada({
    required int idSolicitud,
    required int minutosLlegada,
  }) async {
    await _request(
      'POST',
      '/solicitudes/$idSolicitud/tiempo-llegada',
      body: {'minutos_llegada': minutosLlegada},
    );
  }

  Future<void> cancelarSolicitud({required int idSolicitud}) async {
    await _request('POST', '/solicitudes/$idSolicitud/cancelar');
  }

  void cerrarSesion() {
    _token = null;
    usuario = null;
  }
}