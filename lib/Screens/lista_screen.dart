import 'package:flutter/material.dart';
import 'package:frizalia/Models/producto.dart';
import 'package:frizalia/Utils/app_colors.dart';
import 'package:frizalia/Widgets/editar_producto_pedido_sheet.dart';
import 'package:frizalia/Widgets/item_pedido_card.dart';

class ListaScreen extends StatefulWidget {
  final List<Producto> productos;
  final Map<int, int> cantidades;
  final double subtotal;
  final ValueChanged<Producto> onDisminuir;
  final ValueChanged<Producto> onAumentar;
  final VoidCallback onBuscar;
  final Future<String> Function(int minutosLlegada) onSolicitar;
  final void Function(Producto anterior, Producto actualizado)?
      onActualizarProducto;
  final double precioToppingExtra;

  const ListaScreen({
    super.key,
    required this.productos,
    required this.cantidades,
    required this.subtotal,
    required this.onDisminuir,
    required this.onAumentar,
    required this.onBuscar,
    required this.onSolicitar,
    this.onActualizarProducto,
    this.precioToppingExtra = 5.0,
  });

  @override
  State<ListaScreen> createState() => _ListaScreenState();
}

class _ListaScreenState extends State<ListaScreen> {
  Future<void> _editarItem(
    int index,
    Producto producto,
    DetallePersonalizacionPedido info,
  ) async {
    final actualizado = await EditorPedidoHelper.abrirEditor(
      context,
      producto: producto,
      actual: info,
      precioToppingExtra: widget.precioToppingExtra,
    );
    if (actualizado == null || !mounted) return;

    setState(() {
      if (index >= 0 && index < widget.productos.length) {
        widget.productos[index] = actualizado;
      }
    });
    widget.onActualizarProducto?.call(producto, actualizado);
  }

  @override
  Widget build(BuildContext context) {
    final totalUnidades = widget.cantidades.values.fold<int>(
      0,
      (sum, quantity) => sum + quantity,
    );

    double totalCalculado = 0;
    for (final p in widget.productos) {
      final cant = widget.cantidades[p.id] ?? 0;
      if (cant <= 0) continue;
      final info = EditorPedidoHelper.parsear(p);
      totalCalculado += EditorPedidoHelper.precioUnitario(
            p,
            info,
            precioToppingExtra: widget.precioToppingExtra,
          ) *
          cant;
    }

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
                '${widget.productos.length} ${widget.productos.length == 1 ? 'producto' : 'productos'} · $totalUnidades unidades',
                style: const TextStyle(
                  color: AppColors.gris,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: widget.productos.isEmpty
                    ? _listaVacia()
                    : ListView.separated(
                        padding: EdgeInsets.zero,
                        itemCount: widget.productos.length,
                        separatorBuilder: (ctx, idx) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final producto = widget.productos[index];
                          final cantidad = widget.cantidades[producto.id] ?? 0;
                          final info = EditorPedidoHelper.parsear(producto);
                          final precioUnit = EditorPedidoHelper.precioUnitario(
                            producto,
                            info,
                            precioToppingExtra: widget.precioToppingExtra,
                          );

                          return ItemPedidoCard(
                            producto: producto,
                            cantidad: cantidad,
                            info: info,
                            precioUnitario: precioUnit,
                            precioToppingExtra: widget.precioToppingExtra,
                            onDisminuir: () => widget.onDisminuir(producto),
                            onAumentar: () => widget.onAumentar(producto),
                            onEditar: () => _editarItem(index, producto, info),
                          );
                        },
                      ),
              ),
              if (widget.productos.isNotEmpty) ...[
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total del pedido',
                        style: TextStyle(
                          color: AppColors.texto,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${totalCalculado.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.texto,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    ],
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
            onPressed: widget.onBuscar,
            icon: const Icon(Icons.search),
            label: const Text('Explorar productos'),
          ),
        ],
      ),
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
                  final folio = await widget.onSolicitar(minutos);
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