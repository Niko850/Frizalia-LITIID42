import 'package:frizalia/Models/producto.dart';

class ProductoService {
  final List<Producto> productos;
  final Map<int, int> seleccionados;

  ProductoService({
    required this.productos,
    required this.seleccionados,
  });

  List<Producto> disponibles() {
    return productos.where((p) => p.stock > 0).toList();
  }

  List<Producto> filtrados({
    required String categoria,
    required String busqueda,
  }) {
    return disponibles().where((p) {
      final coincideCategoria =
          categoria == 'Todos' ||
          p.categoria == categoria;

      final coincideBusqueda =
          p.nombre.toLowerCase().contains(
                busqueda.toLowerCase(),
              ) ||
          p.categoria.toLowerCase().contains(
                busqueda.toLowerCase(),
              );

      return coincideCategoria &&
          coincideBusqueda;
    }).toList();
  }

  List<Producto> seleccionadosLista() {
    return productos.where(
      (p) => (seleccionados[p.id] ?? 0) > 0,
    ).toList();
  }

  int totalUnidades() {
    return seleccionados.values.fold(
      0,
      (suma, cantidad) => suma + cantidad,
    );
  }

  double totalCompra() {
    double suma = 0;

    for (final producto in seleccionadosLista()) {
      suma +=
          producto.precio *
          (seleccionados[producto.id] ?? 0);
    }

    return suma;
  }

  bool agregarProducto(Producto producto) {
    final actual =
        seleccionados[producto.id] ?? 0;

    if (actual >= producto.stock) {
      return false;
    }

    seleccionados[producto.id] = actual + 1;
    return true;
  }

  void cambiarCantidad(
    Producto producto,
    int cambio,
  ) {
    final actual =
        seleccionados[producto.id] ?? 0;

    final nuevaCantidad = actual + cambio;

    if (nuevaCantidad <= 0) {
      seleccionados.remove(producto.id);
    } else if (nuevaCantidad <= producto.stock) {
      seleccionados[producto.id] =
          nuevaCantidad;
    }
  }

  void eliminarProducto(int id) {
    seleccionados.remove(id);
  }

  void vaciarLista() {
    seleccionados.clear();
  }
}