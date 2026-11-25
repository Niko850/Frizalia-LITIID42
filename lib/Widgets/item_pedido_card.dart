import 'package:flutter/material.dart';
import 'package:frizalia/Models/producto.dart';
import 'package:frizalia/Utils/app_colors.dart';
import 'package:frizalia/Widgets/editar_producto_pedido_sheet.dart';

class ItemPedidoCard extends StatelessWidget {
  const ItemPedidoCard({
    super.key,
    required this.producto,
    required this.cantidad,
    required this.info,
    required this.precioUnitario,
    required this.precioToppingExtra,
    required this.onDisminuir,
    required this.onAumentar,
    this.onEditar,
  });

  final Producto producto;
  final int cantidad;
  final DetallePersonalizacionPedido info;
  final double precioUnitario;
  final double precioToppingExtra;
  final VoidCallback onDisminuir;
  final VoidCallback onAumentar;
  final VoidCallback? onEditar;

  @override
  Widget build(BuildContext context) {
    final puedeEditar = info.esAgua || info.esHeladoPersonalizable;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: puedeEditar ? onEditar : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borde),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  ? Text(producto.imagen, style: const TextStyle(fontSize: 27))
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        producto.imagenUrl!,
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Text(
                          producto.imagen,
                          style: const TextStyle(fontSize: 27),
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    producto.nombre,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.texto,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\$${precioUnitario.toStringAsFixed(2)} c/u',
                    style: const TextStyle(color: AppColors.gris, fontSize: 12),
                  ),
                  if (!info.esAgua && info.toppings.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.fondo,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.borde),
                      ),
                      child: Column(
                        children: List.generate(info.toppings.length, (tIdx) {
                          final esIncluido = tIdx == 0;
                          final costoTop = esIncluido ? 0.0 : precioToppingExtra;
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: tIdx == info.toppings.length - 1 ? 0 : 2,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '• ${info.toppings[tIdx]}',
                                    style: const TextStyle(
                                      color: AppColors.texto,
                                      fontSize: 11.5,
                                    ),
                                  ),
                                ),
                                Text(
                                  esIncluido
                                      ? 'Incluido'
                                      : '+\$${costoTop.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: esIncluido
                                        ? AppColors.rosaFuerte
                                        : AppColors.texto,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                  if (puedeEditar) ...[
                    const SizedBox(height: 4),
                    Text(
                      info.esAgua
                          ? 'Toca para cambiar tamaño'
                          : 'Toca para editar tamaño o toppings',
                      style: const TextStyle(
                        color: AppColors.rosaFuerte,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Container(
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.fondo,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 30,
                          height: 30,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: onDisminuir,
                            icon: const Icon(Icons.remove, size: 16),
                            color: AppColors.rosaFuerte,
                          ),
                        ),
                        SizedBox(
                          width: 28,
                          child: Text(
                            '$cantidad',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(
                          width: 30,
                          height: 30,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: onAumentar,
                            icon: const Icon(Icons.add, size: 16),
                            color: AppColors.rosaFuerte,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '\$${(precioUnitario * cantidad).toStringAsFixed(2)}',
              style: const TextStyle(
                color: AppColors.texto,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}