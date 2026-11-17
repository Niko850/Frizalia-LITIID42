import 'package:flutter/material.dart';
import 'package:frizalia/Models/producto.dart';
import 'package:frizalia/Utils/app_colors.dart';

class ListaScreen extends StatelessWidget {
  final List<Producto> productos;
  final Map<int, int> cantidades;
  final double subtotal;
  final ValueChanged<Producto> onDisminuir;
  final ValueChanged<Producto> onAumentar;
  final VoidCallback onBuscar;

  const ListaScreen({
    super.key,
    required this.productos,
    required this.cantidades,
    required this.subtotal,
    required this.onDisminuir,
    required this.onAumentar,
    required this.onBuscar,
  });

  @override
  Widget build(BuildContext context) {
    final iva = subtotal * 0.16;
    final total = subtotal + iva;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'FRIZALIA GELATERÍA',
              style: TextStyle(
                color: AppColors.rosaFuerte,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Mi lista',
              style: TextStyle(
                fontSize: 29,
                fontWeight: FontWeight.bold,
                color: AppColors.texto,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${productos.length} ${productos.length == 1 ? 'producto' : 'productos'} · ${cantidades.values.fold<int>(0, (sum, quantity) => sum + quantity)} unidades',
              style: const TextStyle(color: AppColors.gris),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: productos.isEmpty
                  ? _listaVacia()
                  : ListView.separated(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: productos.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final producto = productos[index];
                        final cantidad = cantidades[producto.id] ?? 0;
                        final fondo = index.isEven
                            ? AppColors.rosaSuave
                            : AppColors.amarilloSuave;

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.borde),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 62,
                                height: 62,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: fondo,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Text(
                                  producto.imagen,
                                  style: const TextStyle(fontSize: 32),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      producto.nombre,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: AppColors.texto,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '\$${producto.precio.toStringAsFixed(2)} c/u',
                                      style: const TextStyle(
                                        color: AppColors.gris,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    _controlCantidad(
                                      cantidad: cantidad,
                                      onDisminuir: () => onDisminuir(producto),
                                      onAumentar: () => onAumentar(producto),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '\$${(producto.precio * cantidad).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: AppColors.texto,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            if (productos.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.borde),
                ),
                child: Column(
                  children: [
                    _filaTotal('Subtotal', subtotal),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'IVA',
                          style: TextStyle(color: AppColors.gris),
                        ),
                        Text(
                          '+16%  \$${iva.toStringAsFixed(2)}',
                          style: const TextStyle(color: AppColors.gris),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 1, color: AppColors.borde),
                    ),
                    _filaTotal('Total', total, destacado: true),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  onPressed: () => _mostrarPago(context, total),
                  icon: const Icon(Icons.point_of_sale_outlined),
                  label: const Text('Proceder al pago en caja'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.rosaFuerte,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _listaVacia() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: const BoxDecoration(
              color: AppColors.rosaSuave,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_basket_outlined,
              size: 42,
              color: AppColors.rosaFuerte,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Tu lista está vacía',
            style: TextStyle(
              color: AppColors.texto,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Agrega tus sabores favoritos para comenzar.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.gris),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: onBuscar,
            icon: const Icon(Icons.search),
            label: const Text('Explorar productos'),
          ),
        ],
      ),
    );
  }

  Widget _controlCantidad({
    required int cantidad,
    required VoidCallback onDisminuir,
    required VoidCallback onAumentar,
  }) {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: AppColors.fondo,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _botonCantidad(Icons.remove, onDisminuir),
          SizedBox(
            width: 28,
            child: Text(
              '$cantidad',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          _botonCantidad(Icons.add, onAumentar),
        ],
      ),
    );
  }

  Widget _botonCantidad(IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: 30,
      height: 30,
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        color: AppColors.rosaFuerte,
        tooltip: icon == Icons.add ? 'Aumentar cantidad' : 'Disminuir cantidad',
      ),
    );
  }

  Widget _filaTotal(
    String etiqueta,
    double cantidad, {
    bool destacado = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          etiqueta,
          style: TextStyle(
            color: destacado ? AppColors.texto : AppColors.gris,
            fontWeight: destacado ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          '\$${cantidad.toStringAsFixed(2)}',
          style: TextStyle(
            color: AppColors.texto,
            fontWeight: FontWeight.bold,
            fontSize: destacado ? 17 : 14,
          ),
        ),
      ],
    );
  }

  void _mostrarPago(BuildContext context, double total) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.point_of_sale_outlined,
          color: AppColors.rosaFuerte,
        ),
        title: const Text('Pago en caja'),
        content: Text(
          'Presenta esta lista en caja. El total a pagar es \$${total.toStringAsFixed(2)}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}
