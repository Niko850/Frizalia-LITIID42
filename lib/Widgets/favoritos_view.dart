import 'package:flutter/material.dart';
import 'package:frizalia/Models/producto.dart';
import 'package:frizalia/Utils/app_colors.dart';

class FavoritosView extends StatelessWidget {
  const FavoritosView({
    super.key,
    required this.catalogo,
    required this.frecuenciaPedidos,
    required this.favoritosManuales,
    required this.isLoading,
    required this.onToggleFavorito,
    required this.onAgregar,
    required this.onExplorar,
  });

  final List<Producto> catalogo;
  final Map<String, int> frecuenciaPedidos;
  final Set<String> favoritosManuales;
  final bool isLoading;
  final void Function(String nombreProducto) onToggleFavorito;
  final void Function(Producto producto) onAgregar;
  final VoidCallback onExplorar;

  @override
  Widget build(BuildContext context) {
    final nombresCandidatos = <String>{
      ...frecuenciaPedidos.keys,
      ...favoritosManuales,
    }.toList();

    nombresCandidatos.sort((a, b) {
      final freqA = frecuenciaPedidos[a] ?? 0;
      final freqB = frecuenciaPedidos[b] ?? 0;
      if (freqB != freqA) return freqB.compareTo(freqA);
      return a.compareTo(b);
    });

    if (isLoading && nombresCandidatos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (nombresCandidatos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.favorite_border_rounded,
                size: 58,
                color: AppColors.rosaFuerte,
              ),
              const SizedBox(height: 14),
              const Text(
                'Aún no tienes favoritos',
                style: TextStyle(
                  color: AppColors.texto,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Aquí aparecerán tus productos más pedidos y favoritos.',
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
          'Tus productos más pedidos',
          style: TextStyle(color: AppColors.gris, fontSize: 13.5),
        ),
        const SizedBox(height: 16),
        ...nombresCandidatos.map((nombre) {
          final vecesPedido = frecuenciaPedidos[nombre] ?? 0;
          final esFavoritoManual = favoritosManuales.contains(nombre);

          Producto? productoMatch;
          for (final p in catalogo) {
            if (p.nombre.toLowerCase() == nombre.toLowerCase()) {
              productoMatch = p;
              break;
            }
          }

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
                        productoMatch?.nombre ?? nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.texto,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        vecesPedido > 0
                            ? 'Pedido $vecesPedido ${vecesPedido == 1 ? 'vez' : 'veces'}'
                            : 'Marcado como favorito',
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
                  onPressed: () => onToggleFavorito(nombre),
                  icon: Icon(
                    esFavoritoManual || vecesPedido > 0
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: AppColors.rosaFuerte,
                  ),
                ),
                if (productoMatch != null)
                  IconButton(
                    onPressed: () => onAgregar(productoMatch!),
                    icon: const Icon(
                      Icons.add_shopping_cart_rounded,
                      color: AppColors.texto,
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