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
  final Future<String> Function(int minutosLlegada) onSolicitar;

  const ListaScreen({
    super.key,
    required this.productos,
    required this.cantidades,
    required this.subtotal,
    required this.onDisminuir,
    required this.onAumentar,
    required this.onBuscar,
    required this.onSolicitar,
  });

  @override
  Widget build(BuildContext context) {
    final totalUnidades = cantidades.values.fold<int>(
      0,
      (sum, quantity) => sum + quantity,
    );

    return Scaffold(
      backgroundColor: AppColors.fondo,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.texto,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Mi pedido',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.borde),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${productos.length} ${productos.length == 1 ? 'producto' : 'productos'} · $totalUnidades unidades',
                style: const TextStyle(
                  color: AppColors.gris,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: productos.isEmpty
                    ? _listaVacia()
                    : ListView.separated(
                        padding: EdgeInsets.zero,
                        itemCount: productos.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final producto = productos[index];
                          final cantidad = cantidades[producto.id] ?? 0;

                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.borde),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: AppColors.rosaSuave,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: producto.imagenUrl == null
                                      ? Text(
                                          producto.imagen,
                                          style: const TextStyle(fontSize: 27),
                                        )
                                      : ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Image.network(
                                            producto.imagenUrl!,
                                            width: 52,
                                            height: 52,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, _, _) => Text(
                                              producto.imagen,
                                              style:
                                                  const TextStyle(fontSize: 27),
                                            ),
                                          ),
                                        ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        producto.nombre,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: AppColors.texto,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '\$${producto.precio.toStringAsFixed(2)} c/u',
                                        style: const TextStyle(
                                          color: AppColors.gris,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      _controlCantidad(
                                        cantidad: cantidad,
                                        onDisminuir: () =>
                                            onDisminuir(producto),
                                        onAumentar: () =>
                                            onAumentar(producto),
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
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              if (productos.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borde),
                  ),
                  child: _filaTotal(
                    'Total del pedido',
                    subtotal,
                    destacado: true,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: () => _solicitarRecogida(context),
                    icon: const Icon(Icons.shopping_bag_outlined, size: 20),
                    label: const Text('Solicitar recogida'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.rosaFuerte,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
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

  Future<void> _solicitarRecogida(BuildContext context) async {
    final minutosController = TextEditingController(text: '20');
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          icon: const Icon(
            Icons.shopping_bag_outlined,
            color: AppColors.rosaFuerte,
          ),
          title: const Text('Solicitar recogida'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('¿En cuántos minutos llegarás?'),
              const SizedBox(height: 12),
              TextField(
                controller: minutosController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  suffixText: 'min',
                  helperText: 'Elige entre 1 y 180 minutos',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                final minutos = int.tryParse(minutosController.text);
                if (minutos == null || minutos < 1 || minutos > 180) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ingresa un tiempo de 1 a 180 minutos.'),
                    ),
                  );
                  return;
                }
                setDialogState(() {});
                try {
                  final folio = await onSolicitar(minutos);
                  if (!context.mounted) return;
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Solicitud $folio registrada correctamente.',
                      ),
                    ),
                  );
                } catch (error) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        error.toString().replaceFirst('Exception: ', ''),
                      ),
                    ),
                  );
                }
              },
              child: const Text('Enviar solicitud'),
            ),
          ],
        ),
      ),
    );
    minutosController.dispose();
  }
}
