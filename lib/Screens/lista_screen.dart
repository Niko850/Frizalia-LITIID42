import 'package:flutter/material.dart';
import 'package:frizalia/Models/producto.dart';
import 'package:frizalia/Utils/app_colors.dart';

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
  static const List<_OpcionTamano> _tamanos = [
    _OpcionTamano(nombre: 'Pequeño', precio: 20.0),
    _OpcionTamano(nombre: 'Mediano', precio: 25.0),
    _OpcionTamano(nombre: 'Grande', precio: 28.0),
  ];

  static const List<String> _toppingsDisponibles = [
    'Chispas de chocolate',
    'Chispas de colores',
    'Jarabe de chocolate',
    'Jarabe de fresa',
  ];

  _DetallePersonalizacion _parsearProducto(Producto p) {
    final partes = p.nombre.split(' - ').map((e) => e.trim()).toList();
    if (partes.length < 2) {
      return const _DetallePersonalizacion(
        nombreBase: '',
        tamano: null,
        toppings: [],
        esPersonalizable: false,
      ).copyWith(nombreBase: p.nombre);
    }

    final base = partes.first;
    String? tamanoEncontrado;
    final toppingsEncontrados = <String>[];

    for (var i = 1; i < partes.length; i++) {
      final seg = partes[i];
      final coincideTamano = _tamanos.any(
        (t) => t.nombre.toLowerCase() == seg.toLowerCase(),
      );
      if (coincideTamano && tamanoEncontrado == null) {
        tamanoEncontrado = seg;
      } else {
        final subToppings = seg
            .split(',')
            .map((t) => t.trim())
            .where((t) => t.isNotEmpty);
        toppingsEncontrados.addAll(subToppings);
      }
    }

    final esHelado = base.toLowerCase().contains('helado') ||
        tamanoEncontrado != null ||
        toppingsEncontrados.isNotEmpty;

    return _DetallePersonalizacion(
      nombreBase: base,
      tamano: tamanoEncontrado,
      toppings: toppingsEncontrados,
      esPersonalizable: esHelado,
    );
  }

  double _calcularPrecioUnitario(Producto p, _DetallePersonalizacion info) {
    if (!info.esPersonalizable) return p.precio;

    double precioBase = p.precio;
    if (info.tamano != null) {
      for (final t in _tamanos) {
        if (t.nombre.toLowerCase() == info.tamano!.toLowerCase()) {
          precioBase = t.precio;
          break;
        }
      }
    }

    final extras = info.toppings.length > 1
        ? (info.toppings.length - 1) * widget.precioToppingExtra
        : 0.0;
    return precioBase + extras;
  }

  Future<void> _editarPersonalizacion(
    int index,
    Producto producto,
    _DetallePersonalizacion actual,
  ) async {
    String tamanoSel = actual.tamano ?? 'Pequeño';
    for (final t in _tamanos) {
      if (t.nombre.toLowerCase() == tamanoSel.toLowerCase()) {
        tamanoSel = t.nombre;
        break;
      }
    }

    final seleccionadosToppings = <String>{};
    for (final t in actual.toppings) {
      String match = t;
      for (final disp in _toppingsDisponibles) {
        if (disp.toLowerCase() == t.toLowerCase()) {
          match = disp;
          break;
        }
      }
      seleccionadosToppings.add(match);
    }

    final guardar = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF6E6EB),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            double precioTamano = 20.0;
            for (final t in _tamanos) {
              if (t.nombre == tamanoSel) {
                precioTamano = t.precio;
                break;
              }
            }
            final numExtras = seleccionadosToppings.length > 1
                ? seleccionadosToppings.length - 1
                : 0;
            final totalEditado =
                precioTamano + (numExtras * widget.precioToppingExtra);

            return Padding(
              padding: EdgeInsets.fromLTRB(
                22,
                18,
                22,
                22 + MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Personaliza tu helado',
                      style: TextStyle(
                        color: AppColors.texto,
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'TAMAÑO',
                      style: TextStyle(
                        color: AppColors.texto,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: _tamanos.map((op) {
                        final activa = tamanoSel == op.nombre;
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: op.nombre == 'Grande' ? 0 : 8,
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () =>
                                  setSheetState(() => tamanoSel = op.nombre),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: activa
                                        ? AppColors.rosaFuerte
                                        : AppColors.borde,
                                    width: activa ? 2 : 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      op.nombre.toUpperCase(),
                                      style: const TextStyle(
                                        color: AppColors.texto,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    const Icon(
                                      Icons.icecream,
                                      size: 20,
                                      color: AppColors.texto,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '\$${op.precio.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        color: AppColors.rosaFuerte,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'TOPPINGS',
                      style: TextStyle(
                        color: AppColors.texto,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Un topping sin costo adicional · Extra +\$${widget.precioToppingExtra.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: AppColors.gris,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._toppingsDisponibles.map((top) {
                      final marcado = seleccionadosToppings.contains(top);
                      final listaMarcados = seleccionadosToppings.toList();
                      final indiceEnLista = listaMarcados.indexOf(top);
                      final esIncluido = marcado && indiceEnLista == 0;
                      final esExtra = marcado && indiceEnLista > 0;

                      return CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        activeColor: AppColors.rosaFuerte,
                        value: marcado,
                        onChanged: (val) {
                          setSheetState(() {
                            if (val == true) {
                              seleccionadosToppings.add(top);
                            } else {
                              seleccionadosToppings.remove(top);
                            }
                          });
                        },
                        title: Text(
                          top,
                          style: const TextStyle(
                            color: AppColors.texto,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: marcado
                            ? Text(
                                esIncluido
                                    ? 'Incluido'
                                    : esExtra
                                        ? '+\$${widget.precioToppingExtra.toStringAsFixed(2)} extra'
                                        : '',
                                style: TextStyle(
                                  color: esIncluido
                                      ? AppColors.rosaFuerte
                                      : AppColors.gris,
                                  fontSize: 12,
                                  fontWeight: esIncluido
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              )
                            : null,
                      );
                    }),
                    const SizedBox(height: 8),
                    Text(
                      'Total: \$${totalEditado.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: AppColors.texto,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(sheetCtx, false),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(color: AppColors.rosaFuerte),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(sheetCtx, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.rosaFuerte,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: const Text('Guardar cambios'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (guardar != true || !mounted) return;

    double precioTamano = 20.0;
    for (final t in _tamanos) {
      if (t.nombre == tamanoSel) {
        precioTamano = t.precio;
        break;
      }
    }
    final toppingsFinales = seleccionadosToppings.toList();
    final numExtras =
        toppingsFinales.length > 1 ? toppingsFinales.length - 1 : 0;
    final nuevoPrecio =
        precioTamano + (numExtras * widget.precioToppingExtra);

    final partesNombre = <String>[actual.nombreBase, tamanoSel];
    if (toppingsFinales.isNotEmpty) {
      partesNombre.add(toppingsFinales.join(', '));
    }
    final nuevoNombre = partesNombre.join(' - ');

    final actualizado = producto.copyWith(
      nombre: nuevoNombre,
      precio: nuevoPrecio,
    );

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
      final info = _parsearProducto(p);
      totalCalculado += _calcularPrecioUnitario(p, info) * cant;
    }
    final totalMostrar =
        widget.productos.isEmpty ? widget.subtotal : totalCalculado;

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
                          final info = _parsearProducto(producto);
                          final precioUnit =
                              _calcularPrecioUnitario(producto, info);

                          return InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: info.esPersonalizable
                                ? () => _editarPersonalizacion(
                                    index,
                                    producto,
                                    info,
                                  )
                                : null,
                            child: Container(
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
                                        ? Text(
                                            producto.imagen,
                                            style:
                                                const TextStyle(fontSize: 27),
                                          )
                                        : ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: Image.network(
                                              producto.imagenUrl!,
                                              width: 52,
                                              height: 52,
                                              fit: BoxFit.cover,
                                              errorBuilder: (c, e, s) => Text(
                                                producto.imagen,
                                                style: const TextStyle(
                                                  fontSize: 27,
                                                ),
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
                                          '\$${precioUnit.toStringAsFixed(2)} c/u',
                                          style: const TextStyle(
                                            color: AppColors.gris,
                                            fontSize: 12,
                                          ),
                                        ),
                                        if (info.toppings.isNotEmpty) ...[
                                          const SizedBox(height: 6),
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.fondo,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color: AppColors.borde,
                                              ),
                                            ),
                                            child: Column(
                                              children: List.generate(
                                                info.toppings.length,
                                                (tIdx) {
                                                  final topNombre =
                                                      info.toppings[tIdx];
                                                  final esIncluido = tIdx == 0;
                                                  final costoTop = esIncluido
                                                      ? 0.0
                                                      : widget
                                                            .precioToppingExtra;

                                                  return Padding(
                                                    padding: EdgeInsets.only(
                                                      bottom: tIdx ==
                                                              info.toppings
                                                                      .length -
                                                                  1
                                                          ? 0
                                                          : 2,
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            '• $topNombre',
                                                            style:
                                                                const TextStyle(
                                                              color: AppColors
                                                                  .texto,
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
                                                                ? AppColors
                                                                    .rosaFuerte
                                                                : AppColors
                                                                    .texto,
                                                            fontSize: 11.5,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                        if (info.esPersonalizable) ...[
                                          const SizedBox(height: 4),
                                          const Text(
                                            'Toca para editar tamaño o toppings',
                                            style: TextStyle(
                                              color: AppColors.rosaFuerte,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 6),
                                        _controlCantidad(
                                          cantidad: cantidad,
                                          onDisminuir: () =>
                                              widget.onDisminuir(producto),
                                          onAumentar: () =>
                                              widget.onAumentar(producto),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '\$${(precioUnit * cantidad).toStringAsFixed(2)}',
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
                  child: _filaTotal(
                    'Total del pedido',
                    totalMostrar,
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
            onPressed: widget.onBuscar,
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

class _OpcionTamano {
  const _OpcionTamano({required this.nombre, required this.precio});

  final String nombre;
  final double precio;
}

class _DetallePersonalizacion {
  const _DetallePersonalizacion({
    required this.nombreBase,
    required this.tamano,
    required this.toppings,
    required this.esPersonalizable,
  });

  final String nombreBase;
  final String? tamano;
  final List<String> toppings;
  final bool esPersonalizable;

  _DetallePersonalizacion copyWith({
    String? nombreBase,
    String? tamano,
    List<String>? toppings,
    bool? esPersonalizable,
  }) {
    return _DetallePersonalizacion(
      nombreBase: nombreBase ?? this.nombreBase,
      tamano: tamano ?? this.tamano,
      toppings: toppings ?? this.toppings,
      esPersonalizable: esPersonalizable ?? this.esPersonalizable,
    );
  }
}