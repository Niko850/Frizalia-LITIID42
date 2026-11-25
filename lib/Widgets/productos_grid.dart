import 'package:flutter/material.dart';
import 'package:frizalia/Models/producto.dart';
import 'package:frizalia/Utils/app_colors.dart';
import 'package:frizalia/Widgets/estado_vacio.dart';

class ProductosGrid extends StatefulWidget {
  final List<Producto> productos;
  final Function(Producto) onAgregar;
  final bool isLoading;
  final String? error;
  final VoidCallback? onRetry;

  const ProductosGrid({
    super.key,
    required this.productos,
    required this.onAgregar,
    this.isLoading = false,
    this.error,
    this.onRetry,
  });

  @override
  State<ProductosGrid> createState() => _ProductosGridState();
}

class _ProductosGridState extends State<ProductosGrid> {
  Future<void> _seleccionarAguaNatural(Producto producto) async {
    final seleccionado = await showDialog<Producto>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Selecciona el tamaño'),
          content: SizedBox(
            width: 300,
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(
                        dialogContext,
                        producto.copyWith(
                          nombre: '${producto.nombre} · Mediano',
                          precio: 43,
                        ),
                      );
                    },
                    child: _tamanoCard(
                      'VASO MEDIANO',
                      '\$43.00',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(
                        dialogContext,
                        producto.copyWith(
                          nombre: '${producto.nombre} - Grande',
                          precio: 60,
                        ),
                      );
                    },
                    child: _tamanoCard(
                      'VASO GRANDE',
                      '\$60.00',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (seleccionado != null) {
      widget.onAgregar(seleccionado);
    }
  }

  Widget _tamanoCard(String titulo, String precio) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borde),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.texto,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          const Icon(Icons.local_drink, size: 38),
          const SizedBox(height: 8),
          Text(
            precio,
            style: const TextStyle(
              color: AppColors.rosaFuerte,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _seleccionarHelado(Producto producto) async {
    String tamano = 'Pequeño';
    int precioTamano = 20;
    final toppingsSeleccionados = <String>{};

    final seleccionado = await showDialog<Producto>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            double calcularPrecio() {
              final extras = toppingsSeleccionados.length > 1
                  ? toppingsSeleccionados.length - 1
                  : 0;
              return precioTamano + (extras * 5.0);
            }

            return AlertDialog(
              title: const Text('Personaliza tu helado'),
              content: SizedBox(
                width: 360,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TAMAÑO',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.texto,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          for (final opcion in const [
                            ('Pequeño', 20),
                            ('Mediano', 25),
                            ('Grande', 28),
                          ])
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: InkWell(
                                  onTap: () {
                                    setDialogState(() {
                                      tamano = opcion.$1;
                                      precioTamano = opcion.$2;
                                    });
                                  },
                                  child: Container(
                                    height: 105,
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: tamano == opcion.$1
                                          ? AppColors.rosaSuave
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: tamano == opcion.$1
                                            ? AppColors.rosaFuerte
                                            : AppColors.borde,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          opcion.$1.toUpperCase(),
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        const Icon(Icons.icecream, size: 28),
                                        Text(
                                          '\$${opcion.$2}',
                                          style: const TextStyle(
                                            color: AppColors.rosaFuerte,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'TOPPINGS',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.texto,
                        ),
                      ),
                      const Text(
                        'Un topping sin costo adicional',
                        style: TextStyle(fontSize: 12, color: AppColors.gris),
                      ),
                      const SizedBox(height: 8),
                      for (final topping in const [
                        'Chispas de chocolate',
                        'Chispas de colores',
                        'Jarabe de chocolate',
                        'Jarabe de fresa',
                      ])
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          activeColor: AppColors.rosaFuerte,
                          title: Text(topping),
                          subtitle: Text(
                            toppingsSeleccionados.length < 2 &&
                                    toppingsSeleccionados.contains(topping)
                                ? 'Incluido'
                                : '',
                            style: const TextStyle(
                              color: AppColors.rosaFuerte,
                              fontSize: 11,
                            ),
                          ),
                          value: toppingsSeleccionados.contains(topping),
                          onChanged: (seleccionado) {
                            setDialogState(() {
                              if (seleccionado == true) {
                                toppingsSeleccionados.add(topping);
                              } else {
                                toppingsSeleccionados.remove(topping);
                              }
                            });
                          },
                        ),
                      const SizedBox(height: 8),
                      Text(
                        'Total: \$${calcularPrecio().toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    final toppings = toppingsSeleccionados.isEmpty
                        ? ''
                        : ' - ${toppingsSeleccionados.join(', ')}';
                    Navigator.pop(
                      dialogContext,
                      producto.copyWith(
                        nombre:
                            '${producto.nombre} - $tamano$toppings',
                        precio: calcularPrecio(),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.rosaFuerte,
                  ),
                  child: const Text('Agregar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (seleccionado != null) {
      widget.onAgregar(seleccionado);
    }
  }

  Widget _contenidoImagenProducto(Producto producto) {
    if (producto.imagenUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.network(
          producto.imagenUrl!,
          width: double.infinity,
          height: 115,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _iconoProducto(producto),
        ),
      );
    }

    return _iconoProducto(producto);
  }

  Widget _iconoProducto(Producto producto) {
    final nombre = producto.nombre.toLowerCase();
    String emoji;

    if (nombre.contains('fresa')) {
      emoji = '🍓';
    } else if (nombre.contains('mango')) {
      emoji = '🥭';
    } else if (nombre.contains('coco')) {
      emoji = '🥥';
    } else if (nombre.contains('limón') || nombre.contains('limon')) {
      emoji = '🍋';
    } else if (nombre.contains('vainilla')) {
      emoji = '🍦';
    } else if (nombre.contains('chocomenta') || nombre.contains('menta')) {
      emoji = '🌿';
    } else if (nombre.contains('chocolate') || nombre.contains('chocomenta')) {
      emoji = '🍫';
    } else if (nombre.contains('napolitano')) {
      emoji = '🍨';
    } else if (nombre.contains('capuchino') || nombre.contains('café') || nombre.contains('cafe')) {
      emoji = '☕';
    } else if (nombre.contains('horchata')) {
      emoji = '🌾';
    } else if (nombre.contains('pitahaya')) {
      emoji = '🌸';
    } else if (nombre.contains('uva')) {
      emoji = '🍇';
    } else if (nombre.contains('piña') || nombre.contains('pina')) {
      emoji = '🍍';
    } else if (producto.categoria == 'Aguas Naturales') {
      emoji = '🥤';
    } else if (producto.categoria == 'Paletas') {
      emoji = '🍡';
    } else {
      emoji = '🍦';
    }

    return Text(
      emoji,
      style: const TextStyle(fontSize: 58),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.productos.isEmpty && widget.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (widget.productos.isEmpty && widget.error != null) {
      return Column(
        children: [
          EstadoVacioWidget(
            icono: Icons.wifi_off_outlined,
            titulo: 'No se pudo cargar el catálogo',
            descripcion: widget.error!,
          ),
          if (widget.onRetry != null)
            TextButton.icon(
              onPressed: widget.onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
        ],
      );
    }

    if (widget.productos.isEmpty) {
      return const EstadoVacioWidget(
        icono: Icons.icecream_outlined,
        titulo: '0 productos disponibles',
        descripcion: 'Todavía no hay productos registrados.',
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.productos.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 255,
      ),
      itemBuilder: (context, index) {
        final producto = widget.productos[index];

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borde),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 115,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: index.isEven
                      ? AppColors.rosaSuave
                      : AppColors.amarilloSuave,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: _contenidoImagenProducto(producto),
              ),

              const SizedBox(height: 10),

              Text(
                producto.nombre,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.texto,
                ),
              ),

              Text(
                producto.descripcion,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.gris, fontSize: 12),
              ),

              const Spacer(),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    producto.categoria == 'Aguas Naturales'
                        ? 'Desde \$43.00'
                        : producto.categoria == 'Helados'
                            ? 'Desde \$20.00'
                            : '\$${producto.precio.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  InkWell(
                    onTap: () {
                      if (producto.categoria == 'Aguas Naturales') {
                        _seleccionarAguaNatural(producto);
                      } else if (producto.categoria == 'Helados') {
                        _seleccionarHelado(producto);
                      } else {
                        widget.onAgregar(producto);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: AppColors.amarillo,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.add),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
