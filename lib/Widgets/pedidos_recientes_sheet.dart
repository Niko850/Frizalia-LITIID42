import 'package:flutter/material.dart';
import 'package:frizalia/Services/api_service.dart';
import 'package:frizalia/Utils/app_colors.dart';

Future<void> mostrarPedidosRecientesSheet({
  required BuildContext context,
  void Function(String mensaje)? onMensaje,
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.fondo,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (sheetContext) {
      return _PedidosRecientesContenido(onMensaje: onMensaje);
    },
  );
}

class _PedidosRecientesContenido extends StatefulWidget {
  const _PedidosRecientesContenido({this.onMensaje});

  final void Function(String mensaje)? onMensaje;

  @override
  State<_PedidosRecientesContenido> createState() =>
      _PedidosRecientesContenidoState();
}

class _PedidosRecientesContenidoState
    extends State<_PedidosRecientesContenido> {
  int _recargaKey = 0;

  void _notificar(String texto) {
    final cb = widget.onMensaje;
    if (cb != null) {
      cb(texto);
      return;
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
    }
  }

  bool _puedeGestionarAntesDeAceptar(String estado) {
    final normalizado = estado.trim().toUpperCase();
    return normalizado != 'ACEPTADA' &&
        normalizado != 'ACEPTADO' &&
        normalizado != 'EN_PREPARACION' &&
        normalizado != 'LISTA' &&
        normalizado != 'ENTREGADA' &&
        normalizado != 'RECHAZADA' &&
        normalizado != 'CANCELADA' &&
        normalizado != 'CANCELADO';
  }

  String _estadoLegible(String estado) {
    switch (estado.trim().toUpperCase()) {
      case 'PENDIENTE':
        return 'Pendiente';
      case 'ACEPTADA':
      case 'ACEPTADO':
        return 'Aceptado';
      case 'EN_PREPARACION':
        return 'En preparación';
      case 'LISTA':
        return 'Lista para recoger';
      case 'ENTREGADA':
        return 'Entregada';
      case 'RECHAZADA':
        return 'Rechazado';
      default:
        return estado;
    }
  }

  Future<void> _editarTiempo(int idSolicitud, int? minutosActuales) async {
    const opciones = [5, 10, 15, 20, 30];
    int seleccionado =
        opciones.contains(minutosActuales) ? minutosActuales! : 10;

    final elegido = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: const Text(
                '¿A cuántos minutos estás del local?',
                style: TextStyle(
                  color: AppColors.texto,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Avisaremos para que tu pedido esté listo cerca de tu llegada.',
                    style: TextStyle(color: AppColors.gris, fontSize: 13),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: opciones.map((min) {
                      final activa = seleccionado == min;
                      return ChoiceChip(
                        label: Text('$min min'),
                        selected: activa,
                        selectedColor: AppColors.rosaFuerte,
                        backgroundColor: AppColors.rosaSuave,
                        labelStyle: TextStyle(
                          color: activa ? Colors.white : AppColors.texto,
                          fontWeight: FontWeight.w600,
                        ),
                        onSelected: (_) {
                          setDialogState(() => seleccionado = min);
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text(
                    'Cerrar',
                    style: TextStyle(color: AppColors.gris),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(dialogContext, seleccionado),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.rosaFuerte,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Guardar tiempo'),
                ),
              ],
            );
          },
        );
      },
    );

    if (elegido == null || !mounted) return;

    try {
      await (ApiService.instance as dynamic).actualizarTiempoLlegada(
        idSolicitud: idSolicitud,
        minutosLlegada: elegido,
      );
      if (mounted) {
        _notificar('Tiempo actualizado: $elegido min del local');
        setState(() => _recargaKey++);
      }
    } catch (e) {
      if (mounted) {
        _notificar(
          'No se pudo actualizar el tiempo: ${e.toString().replaceFirst('Exception: ', '')}',
        );
      }
    }
  }

  Future<void> _cancelarPedido(int idSolicitud, String folio) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Cancelar pedido',
            style: TextStyle(
              color: AppColors.texto,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            '¿Seguro que deseas cancelar el pedido $folio? Esta acción no se puede deshacer.',
            style: const TextStyle(color: AppColors.gris, fontSize: 13.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text(
                'No, mantener',
                style: TextStyle(color: AppColors.gris),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD9385A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Sí, cancelar'),
            ),
          ],
        );
      },
    );

    if (confirmar != true || !mounted) return;

    try {
      await (ApiService.instance as dynamic).cancelarSolicitud(
        idSolicitud: idSolicitud,
      );
      if (mounted) {
        _notificar('Pedido $folio cancelado');
        setState(() => _recargaKey++);
      }
    } catch (e) {
      if (mounted) {
        _notificar(
          'No se pudo cancelar: ${e.toString().replaceFirst('Exception: ', '')}',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.68,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (innerContext, scrollController) {
        return FutureBuilder(
          key: ValueKey(_recargaKey),
          future: ApiService.instance.obtenerMisSolicitudes(),
          builder: (context, snapshot) {
            final activas = [];
            if (snapshot.hasData && snapshot.data is List) {
              for (final raw in (snapshot.data as List)) {
                if (raw is! Map) continue;
                final estado = '${raw['estado'] ?? ''}'.trim().toUpperCase();
                if (estado == 'CANCELADA' || estado == 'CANCELADO') {
                  continue;
                }
                activas.add(raw);
              }
            }

            Widget cuerpoLista;
            if (snapshot.connectionState == ConnectionState.waiting) {
              cuerpoLista = const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              cuerpoLista = Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    snapshot.error.toString().replaceFirst('Exception: ', ''),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.gris),
                  ),
                ),
              );
            } else if (activas.isEmpty) {
              cuerpoLista = const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'No tienes pedidos activos recientes.',
                    style: TextStyle(color: AppColors.gris),
                  ),
                ),
              );
            } else {
              cuerpoLista = ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                itemCount: activas.length,
                separatorBuilder: (ctx, idx) => const SizedBox(height: 12),
                itemBuilder: (ctx, index) {
                  final orden = activas[index] as Map;
                  final idSolicitud = int.tryParse(
                        '${orden['id_solicitud'] ?? orden['id'] ?? 0}',
                      ) ??
                      0;
                  final folio = '${orden['folio'] ?? 'FRZ-$idSolicitud'}';
                  final estado = '${orden['estado'] ?? 'PENDIENTE'}';
                  final total = double.tryParse('${orden['total'] ?? 0}') ?? 0;
                  final minutosLlegada = int.tryParse(
                    '${orden['minutos_llegada'] ?? orden['minutosLlegada'] ?? ''}',
                  );

                  final fecha = DateTime.tryParse(
                    '${orden['fecha_solicitud'] ?? ''}',
                  );
                  final fechaStr = fecha == null
                      ? ''
                      : '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';

                  final productosList = <String>[];
                  final rawProds = orden['productos'];
                  if (rawProds is List) {
                    for (final p in rawProds) {
                      if (p is! Map) continue;
                      final nom = '${p['nombre_producto'] ?? 'Producto'}';
                      final cant = int.tryParse('${p['cantidad'] ?? 1}') ?? 1;
                      productosList.add(cant > 1 ? '$cant× $nom' : nom);
                    }
                  }

                  final puedeGestionar = _puedeGestionarAntesDeAceptar(estado);

                  final estadoUpper = estado.trim().toUpperCase();
                  Color estadoColor = AppColors.rosaSuave;
                  if (estadoUpper == 'LISTA') {
                    estadoColor = AppColors.amarilloSuave;
                  } else if (estadoUpper == 'ACEPTADA' ||
                      estadoUpper == 'ACEPTADO') {
                    estadoColor = const Color(0xFFDFF5E7);
                  } else if (estadoUpper == 'RECHAZADA') {
                    estadoColor = const Color(0xFFFFE1E7);
                  }

                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borde),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              folio,
                              style: const TextStyle(
                                color: AppColors.texto,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: estadoColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                _estadoLegible(estado),
                                style: const TextStyle(
                                  color: AppColors.texto,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (minutosLlegada != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            'A $minutosLlegada min del local',
                            style: const TextStyle(
                              color: AppColors.rosaFuerte,
                              fontWeight: FontWeight.w600,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                        if (productosList.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            productosList.join(', '),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.texto,
                              fontSize: 13.5,
                            ),
                          ),
                        ],
                        if (puedeGestionar) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () =>
                                      _editarTiempo(idSolicitud, minutosLlegada),
                                  icon: const Icon(
                                    Icons.schedule_rounded,
                                    size: 16,
                                  ),
                                  label: Text(
                                    minutosLlegada != null
                                        ? '$minutosLlegada min'
                                        : 'Tiempo al local',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.texto,
                                    side: const BorderSide(
                                      color: AppColors.borde,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () =>
                                      _cancelarPedido(idSolicitud, folio),
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    size: 16,
                                  ),
                                  label: const Text(
                                    'Cancelar',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFFD9385A),
                                    side: const BorderSide(
                                      color: Color(0xFFFFC9D4),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              fechaStr.isEmpty ? 'Reciente' : fechaStr,
                              style: const TextStyle(
                                color: AppColors.gris,
                                fontSize: 12.5,
                              ),
                            ),
                            Text(
                              '\$${total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: AppColors.texto,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
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

            return Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borde,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Pedidos recientes',
                        style: TextStyle(
                          color: AppColors.texto,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: AppColors.gris,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.borde),
                Expanded(child: cuerpoLista),
              ],
            );
          },
        );
      },
    );
  }
}