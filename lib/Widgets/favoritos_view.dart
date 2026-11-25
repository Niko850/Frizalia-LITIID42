import 'package:flutter/material.dart';
import 'package:frizalia/Models/producto.dart';
import 'package:frizalia/Utils/app_colors.dart';

class FavoritosView extends StatelessWidget {
  const FavoritosView({
    super.key,
    required this.catalogo,
    required this.frecuenciaPedidos,
    required this.isLoading,
    required this.onAgregar,
    required this.onExplorar,
    this.favoritosManuales = const {},
    this.onToggleFavorito,
  });

  final List<Producto> catalogo;
  final Map<String, int> frecuenciaPedidos;
  final bool isLoading;
  final void Function(Producto producto) onAgregar;
  final VoidCallback onExplorar;

  // Opcionales para mantener compatibilidad si HomeScreen los sigue pasando
  final Set<String> favoritosManuales;
  final void Function(String nombreProducto)? onToggleFavorito;

  Producto? _buscarProductoEnCatalogo(String nombre) {
    final limpio = nombre.trim().toLowerCase();
    if (limpio.isEmpty) return null;

    for (final p in catalogo) {
      if (p.nombre.trim().toLowerCase() == limpio) {
        return p;
      }
    }

    // Si viene con tamaño/toppings (ej. "Helado de fresa - Mediano - ..."),
    // intenta encontrar el producto base en el catálogo.
    final base = limpio.split(' - ').first.trim();
    if (base.isNotEmpty) {
      for (final p in catalogo) {
        final pNombre = p.nombre.trim().toLowerCase();
        if (pNombre == base || limpio.startsWith(pNombre)) {
          return p;
        }
      }
    }

    return null;
  }

  Producto _construirProductoRespaldo(String nombre, Producto? base) {
    return Producto(
      id: base?.id ?? nombre.hashCode.abs(),
      nombre: nombre,
      descripcion: base?.descripcion ?? '',
      categoria: base?.categoria ?? 'Favoritos',
      precio: base?.precio ?? 0.0,
      stock: base?.stock ?? 99,
      imagen: base?.imagen ?? '🍦',
      imagenUrl: base?.imagenUrl,
    );
  }

  @override
  Widget build(BuildContext context) {
    final masPedidos = frecuenciaPedidos.entries
        .where((entry) => entry.value >= 2)
        .toList();

    masPedidos.sort((a, b) {
      final cmp = b.value.compareTo(a.value);
      if (cmp != 0) return cmp;
      return a.key.compareTo(b.key);
    });

    if (isLoading && masPedidos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (masPedidos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.local_fire_department_outlined,
                size: 58,
                color: AppColors.rosaFuerte,
              ),
              const SizedBox(height: 14),
              const Text(
                'Aún no tienes productos con 2 o más pedidos',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.texto,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Cuando repitas un producto al menos 2 veces, aparecerá aquí.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.gris),
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: onExplorar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.rosaFuerte,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Explorar productos'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
      children: [
        const Text(
          'Favoritos',
          style: TextStyle(
            color: AppColors.texto,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Productos pedidos 2 o más veces',
          style: TextStyle(color: AppColors.gris, fontSize: 13.5),
        ),
        const SizedBox(height: 16),
        ...masPedidos.map((entry) {
          final nombre = entry.key;
          final vecesPedido = entry.value;
          final productoMatch = _buscarProductoEnCatalogo(nombre);
          final productoParaCarrito = _construirProductoRespaldo(
            nombre,
            productoMatch,
          );

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borde),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.rosaSuave,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.icecream_outlined,
                    color: AppColors.rosaFuerte,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombre,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.texto,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pedido $vecesPedido veces',
                        style: const TextStyle(
                          color: AppColors.gris,
                          fontSize: 12.5,
                        ),
                      ),
                      if (productoMatch != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '\$${productoMatch.precio.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AppColors.texto,
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Agregar al carrito',
                  onPressed: () => onAgregar(productoParaCarrito),
                  icon: const Icon(
                    Icons.add_shopping_cart_rounded,
                    color: AppColors.rosaFuerte,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}