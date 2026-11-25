import 'package:flutter/material.dart';
import 'package:frizalia/Models/producto.dart';
import 'package:frizalia/Utils/app_colors.dart';

class OpcionTamanoPedido {
  const OpcionTamanoPedido({required this.nombre, required this.precio});
  final String nombre;
  final double precio;
}

class DetallePersonalizacionPedido {
  const DetallePersonalizacionPedido({
    required this.nombreBase,
    required this.tamano,
    required this.toppings,
    required this.esAgua,
    required this.esHeladoPersonalizable,
  });

  final String nombreBase;
  final String? tamano;
  final List<String> toppings;
  final bool esAgua;
  final bool esHeladoPersonalizable;
}

class EditorPedidoHelper {
  static const List<OpcionTamanoPedido> tamanosHelado = [
    OpcionTamanoPedido(nombre: 'Pequeño', precio: 20.0),
    OpcionTamanoPedido(nombre: 'Mediano', precio: 25.0),
    OpcionTamanoPedido(nombre: 'Grande', precio: 28.0),
  ];

  static const List<OpcionTamanoPedido> tamanosAgua = [
    OpcionTamanoPedido(nombre: 'Vaso Mediano', precio: 43.0),
    OpcionTamanoPedido(nombre: 'Vaso Grande', precio: 60.0),
  ];

  static const List<String> toppingsDisponibles = [
    'Chispas de chocolate',
    'Chispas de colores',
    'Jarabe de chocolate',
    'Jarabe de fresa',
  ];

  static bool esAguaOBebida(Producto p, String nombreBase, String? tamano) {
    final texto =
        '${p.categoria} ${p.nombre} $nombreBase ${tamano ?? ''}'.toLowerCase();
    return texto.contains('agua') ||
        texto.contains('bebida') ||
        texto.contains('vaso');
  }

  static DetallePersonalizacionPedido parsear(Producto p) {
    final partes = p.nombre.split(' - ').map((e) => e.trim()).toList();
    if (partes.length < 2) {
      return DetallePersonalizacionPedido(
        nombreBase: p.nombre,
        tamano: null,
        toppings: const [],
        esAgua: esAguaOBebida(p, p.nombre, null),
        esHeladoPersonalizable: false,
      );
    }

    final base = partes.first;
    String? tamanoEncontrado;
    final toppingsEncontrados = <String>[];

    for (var i = 1; i < partes.length; i++) {
      final seg = partes[i];
      final coincideHelado = tamanosHelado.any(
        (t) => t.nombre.toLowerCase() == seg.toLowerCase(),
      );
      final coincideAgua = tamanosAgua.any(
        (t) =>
            t.nombre.toLowerCase() == seg.toLowerCase() ||
            ((seg.toLowerCase() == 'mediano' ||
                    seg.toLowerCase() == 'grande') &&
                esAguaOBebida(p, base, seg)),
      );

      if ((coincideHelado || coincideAgua) && tamanoEncontrado == null) {
        tamanoEncontrado = seg;
      } else {
        toppingsEncontrados.addAll(
          seg.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty),
        );
      }
    }

    final esAgua = esAguaOBebida(p, base, tamanoEncontrado);
    final esHelado = !esAgua &&
        (base.toLowerCase().contains('helado') ||
            tamanoEncontrado != null ||
            toppingsEncontrados.isNotEmpty);

    return DetallePersonalizacionPedido(
      nombreBase: base,
      tamano: tamanoEncontrado,
      toppings: esAgua ? const [] : toppingsEncontrados,
      esAgua: esAgua,
      esHeladoPersonalizable: esHelado,
    );
  }

  static double precioUnitario(
    Producto p,
    DetallePersonalizacionPedido info, {
    double precioToppingExtra = 5.0,
  }) {
    if (info.esAgua) {
      if (info.tamano != null) {
        final tLower = info.tamano!.toLowerCase();
        if (tLower.contains('grande')) return 60.0;
        if (tLower.contains('mediano')) return 43.0;
      }
      return p.precio > 0 ? p.precio : 43.0;
    }
    if (!info.esHeladoPersonalizable) return p.precio;

    double base = p.precio;
    if (info.tamano != null) {
      for (final t in tamanosHelado) {
        if (t.nombre.toLowerCase() == info.tamano!.toLowerCase()) {
          base = t.precio;
          break;
        }
      }
    }
    final extras = info.toppings.length > 1
        ? (info.toppings.length - 1) * precioToppingExtra
        : 0.0;
    return base + extras;
  }

  static Future<Producto?> abrirEditor(
    BuildContext context, {
    required Producto producto,
    required DetallePersonalizacionPedido actual,
    double precioToppingExtra = 5.0,
  }) async {
    if (actual.esAgua) {
      return _mostrarSheetAgua(context, producto, actual);
    }
    if (actual.esHeladoPersonalizable) {
      return _mostrarSheetHelado(
        context,
        producto,
        actual,
        precioToppingExtra,
      );
    }
    return null;
  }

  static Future<Producto?> _mostrarSheetAgua(
    BuildContext context,
    Producto producto,
    DetallePersonalizacionPedido actual,
  ) async {
    String tamanoSel =
        (actual.tamano != null && actual.tamano!.toLowerCase().contains('grande'))
            ? 'Vaso Grande'
            : 'Vaso Mediano';

    final elegido = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF6E6EB),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Selecciona el tamaño',
                style: TextStyle(
                  color: AppColors.texto,
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: tamanosAgua.map((op) {
                  final activa = tamanoSel == op.nombre;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: op.nombre == 'Vaso Grande' ? 0 : 12,
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => setSheetState(() => tamanoSel = op.nombre),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
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
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppColors.texto,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Icon(
                                Icons.local_drink_rounded,
                                size: 28,
                                color: AppColors.texto,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '\$${op.precio.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: AppColors.rosaFuerte,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
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
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(sheetCtx),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: AppColors.rosaFuerte),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(sheetCtx, tamanoSel),
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
      ),
    );

    if (elegido == null) return null;
    final precio = elegido == 'Vaso Grande' ? 60.0 : 43.0;
    return producto.copyWith(
      nombre: '${actual.nombreBase} - $elegido',
      precio: precio,
    );
  }

  static Future<Producto?> _mostrarSheetHelado(
    BuildContext context,
    Producto producto,
    DetallePersonalizacionPedido actual,
    double precioToppingExtra,
  ) async {
    String tamanoSel = actual.tamano ?? 'Pequeño';
    for (final t in tamanosHelado) {
      if (t.nombre.toLowerCase() == tamanoSel.toLowerCase()) {
        tamanoSel = t.nombre;
        break;
      }
    }

    final seleccionadosToppings = <String>{};
    for (final t in actual.toppings) {
      String match = t;
      for (final disp in toppingsDisponibles) {
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
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          double precioTamano = 20.0;
          for (final t in tamanosHelado) {
            if (t.nombre == tamanoSel) {
              precioTamano = t.precio;
              break;
            }
          }
          final numExtras = seleccionadosToppings.length > 1
              ? seleccionadosToppings.length - 1
              : 0;
          final totalEditado =
              precioTamano + (numExtras * precioToppingExtra);

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
                    children: tamanosHelado.map((op) {
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
                    'Un topping sin costo adicional · Extra +\$${precioToppingExtra.toStringAsFixed(2)}',
                    style: const TextStyle(color: AppColors.gris, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  ...toppingsDisponibles.map((top) {
                    final marcado = seleccionadosToppings.contains(top);
                    final idx = seleccionadosToppings.toList().indexOf(top);
                    final esIncluido = marcado && idx == 0;
                    final esExtra = marcado && idx > 0;

                    return CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      activeColor: AppColors.rosaFuerte,
                      value: marcado,
                      onChanged: (val) => setSheetState(() {
                        if (val == true) {
                          seleccionadosToppings.add(top);
                        } else {
                          seleccionadosToppings.remove(top);
                        }
                      }),
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
                                      ? '+\$${precioToppingExtra.toStringAsFixed(2)} extra'
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
      ),
    );

    if (guardar != true) return null;

    double precioTamano = 20.0;
    for (final t in tamanosHelado) {
      if (t.nombre == tamanoSel) {
        precioTamano = t.precio;
        break;
      }
    }
    final toppingsFinales = seleccionadosToppings.toList();
    final numExtras =
        toppingsFinales.length > 1 ? toppingsFinales.length - 1 : 0;
    final nuevoPrecio = precioTamano + (numExtras * precioToppingExtra);

    final partesNombre = <String>[actual.nombreBase, tamanoSel];
    if (toppingsFinales.isNotEmpty) {
      partesNombre.add(toppingsFinales.join(', '));
    }

    return producto.copyWith(
      nombre: partesNombre.join(' - '),
      precio: nuevoPrecio,
    );
  }
}