import 'package:frizalia/Models/producto.dart';

class CarritoCache {
  CarritoCache._();

  static final CarritoCache instance = CarritoCache._();

  final Map<String, Map<int, int>> _cantidadesPorCorreo = {};
  final Map<String, List<Producto>> _personalizadosPorCorreo = {};

  Map<int, int> _ultimoCantidades = {};
  List<Producto> _ultimoPersonalizados = [];

  String _clave(String correo) {
    final limpio = correo.trim().toLowerCase();
    return limpio.isEmpty ? '_default_' : limpio;
  }

  void guardarEstado({
    required String correo,
    required Map<int, int> cantidades,
    required List<Producto> itemsPersonalizados,
  }) {
    final k = _clave(correo);
    final copiaCantidades = <int, int>{};
    cantidades.forEach((id, cant) {
      if (cant > 0) copiaCantidades[id] = cant;
    });

    final copiaPersonalizados = itemsPersonalizados
        .where((p) => (copiaCantidades[p.id] ?? 0) > 0)
        .toList();

    _cantidadesPorCorreo[k] = copiaCantidades;
    _personalizadosPorCorreo[k] = copiaPersonalizados;

    _ultimoCantidades = Map<int, int>.from(copiaCantidades);
    _ultimoPersonalizados = List<Producto>.from(copiaPersonalizados);
  }

  Map<int, int> obtenerCantidades(String correo) {
    final k = _clave(correo);
    final guardadas = _cantidadesPorCorreo[k];
    if (guardadas != null && guardadas.isNotEmpty) {
      return Map<int, int>.from(guardadas);
    }
    return Map<int, int>.from(_ultimoCantidades);
  }

  List<Producto> obtenerPersonalizados(String correo) {
    final k = _clave(correo);
    final guardados = _personalizadosPorCorreo[k];
    if (guardados != null && guardados.isNotEmpty) {
      return List<Producto>.from(guardados);
    }
    return List<Producto>.from(_ultimoPersonalizados);
  }

  void limpiarEstado(String correo) {
    final k = _clave(correo);
    _cantidadesPorCorreo.remove(k);
    _personalizadosPorCorreo.remove(k);
    _ultimoCantidades.clear();
    _ultimoPersonalizados.clear();
  }
}