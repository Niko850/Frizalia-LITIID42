import 'package:flutter/material.dart';
import 'package:frizalia/Services/api_service.dart';
import 'package:frizalia/Utils/app_colors.dart';

class MisOrdenesScreen extends StatefulWidget {
  const MisOrdenesScreen({super.key});

  @override
  State<MisOrdenesScreen> createState() => _MisOrdenesScreenState();
}

class _MisOrdenesScreenState extends State<MisOrdenesScreen> {
  late Future<List<dynamic>> _futureSolicitudes;

  @override
  void initState() {
    super.initState();
    _futureSolicitudes = _cargarSolicitudes();
  }

  Future<List<dynamic>> _cargarSolicitudes() async {
    final res = await ApiService.instance.obtenerMisSolicitudes();
    return List<dynamic>.from(res);
  }

  Future<void> _recargarSolicitudes() async {
    setState(() {
      _futureSolicitudes = _cargarSolicitudes();
    });
    await _futureSolicitudes;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _futureSolicitudes,
      builder: (context, snapshot) {
        return Scaffold(
          backgroundColor: AppColors.fondo,
          appBar: AppBar(
            backgroundColor: AppColors.fondo,
            foregroundColor: AppColors.texto,
            elevation: 0,
            title: const Text('Mis órdenes'),
          ),
          body: switch (snapshot.connectionState) {
            ConnectionState.waiting => const Center(
              child: CircularProgressIndicator(),
            ),
            _ when snapshot.hasError => _error(snapshot.error),
            _ => _contenido(snapshot.data ?? []),
          },
        );
      },
    );
  }

  Widget _error(Object? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_outlined,
              size: 48,
              color: AppColors.rosaFuerte,
            ),
            const SizedBox(height: 12),
            Text(
              error.toString().replaceFirst('Exception: ', ''),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.gris),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _recargarSolicitudes,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contenido(List<dynamic> solicitudes) {
    if (solicitudes.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 58,
                color: AppColors.rosa,
              ),
              SizedBox(height: 14),
              Text(
                'Aún no tienes solicitudes',
                style: TextStyle(
                  color: AppColors.texto,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Tus pedidos aparecerán aquí.',
                style: TextStyle(color: AppColors.gris),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _recargarSolicitudes,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        itemCount: solicitudes.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = solicitudes[index];
          final mapa = item is Map
              ? Map<String, dynamic>.from(item)
              : <String, dynamic>{};
          return _TarjetaOrden(
            solicitud: mapa,
            onActualizado: _recargarSolicitudes,
          );
        },
      ),
    );
  }
}

class _TarjetaOrden extends StatefulWidget {
  const _TarjetaOrden({
    required this.solicitud,
    required this.onActualizado,
  });

  final Map<String, dynamic> solicitud;
  final Future<void> Function() onActualizado;

  @override
  State<_TarjetaOrden> createState() => _TarjetaOrdenState();
}

class _TarjetaOrdenState extends State<_TarjetaOrden> {
  bool _expandido = false;
  bool _procesando = false;

  bool _puedeGestionarAntesDeAceptar(String estado) {
    final normalizado = estado.trim().toUpperCase();
    return normalizado != 'ACEPTADA' &&
        normalizado != 'ACEPTADO' &&
        normalizado != 'EN_PREPARACION' &&
        normalizado != 'LISTA' &&
        normalizado != 'ENTREGADA' &&
        normalizado != 'RECHAZADA' &&
        normalizado != 'CANCELADA';
  }

  String _construirTituloAmigable(List<dynamic> detalles, String fechaTexto) {
    if (detalles.isEmpty) {
      return 'Tu visita al local · $fechaTexto';
    }
    final primero = detalles.first is Map ? detalles.first as Map : const {};
    final primerProducto = '${primero['nombre_producto'] ?? 'tu antojo'}'.trim();
    if (detalles.length == 1) {
      return 'Tu pedido de $primerProducto';
    }
    final restantes = detalles.length - 1;
    return 'Tu pedido de $primerProducto y $restantes ${restantes == 1 ? 'más' : 'más'}';
  }

  Future<void> _mostrarSelectorTiempoLlegada(
    int idSolicitud,
    int? minutosActuales,
  ) async {
    const opciones = [5, 10, 15, 20, 30];
    int seleccionado = opciones.contains(minutosActuales)
        ? minutosActuales!
        : 10;

    final elegido = await showDialog<int>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
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
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cerrar',
                    style: TextStyle(color: AppColors.gris),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, seleccionado),
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

    setState(() => _procesando = true);
    try {
      await (ApiService.instance as dynamic).actualizarTiempoLlegada(
        idSolicitud: idSolicitud,
        minutosLlegada: elegido,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tiempo actualizado: $elegido min del local')),
        );
        await widget.onActualizado();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No se pudo actualizar el tiempo: ${e.toString().replaceFirst('Exception: ', '')}',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _procesando = false);
    }
  }

  Future<void> _confirmarCancelarPedido(int idSolicitud, String folio) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
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
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'No, mantener',
                style: TextStyle(color: AppColors.gris),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
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

    setState(() => _procesando = true);
    try {
      await (ApiService.instance as dynamic).cancelarSolicitud(
        idSolicitud: idSolicitud,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pedido $folio cancelado')),
        );
        await widget.onActualizado();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No se pudo cancelar: ${e.toString().replaceFirst('Exception: ', '')}',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _procesando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final solicitud = widget.solicitud;
    final detalles = solicitud['productos'] is List
        ? List<dynamic>.from(solicitud['productos'] as List)
        : <dynamic>[];

    final idSolicitud =
        int.tryParse('${solicitud['id_solicitud'] ?? solicitud['id'] ?? 0}') ??
        0;
    final estado = '${solicitud['estado'] ?? 'PENDIENTE'}';
    final folio =
        '${solicitud['folio'] ?? 'FRZ-${idSolicitud.toString().padLeft(6, '0')}'}';

    final fecha = DateTime.tryParse(
      '${solicitud['fecha_solicitud'] ?? ''}',
    );
    final fechaTexto = fecha == null
        ? 'Fecha no disponible'
        : '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';

    final tituloAmigable = _construirTituloAmigable(detalles, fechaTexto);

    final minutosLlegada = int.tryParse(
      '${solicitud['minutos_llegada'] ?? solicitud['minutosLlegada'] ?? ''}',
    );

    final resumenProductos = detalles.isEmpty
        ? 'Sin productos listados'
        : detalles
            .map((item) {
              final m = item is Map ? item : const {};
              final nombre = m['nombre_producto'] ?? 'Producto';
              final cant = int.tryParse('${m['cantidad'] ?? 1}') ?? 1;
              return cant > 1 ? '$cant× $nombre' : '$nombre';
            })
            .join(', ');

    final total = double.tryParse('${solicitud['total'] ?? 0}') ?? 0;

    final puedeGestionar = _puedeGestionarAntesDeAceptar(estado);

    final estadoColor = switch (estado.toUpperCase()) {
      'LISTA' => AppColors.amarilloSuave,
      'ACEPTADA' || 'ACEPTADO' => const Color(0xFFDFF5E7),
      'RECHAZADA' || 'CANCELADA' => const Color(0xFFFFE1E7),
      _ => AppColors.rosaSuave,
    };

    return Container(
      padding: const EdgeInsets.all(16),
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
              Expanded(
                child: Text(
                  folio,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.texto,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
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
          const SizedBox(height: 12),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: detalles.isEmpty
                ? null
                : () => setState(() => _expandido = !_expandido),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
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
                          tituloAmigable,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.texto,
                            fontWeight: FontWeight.bold,
                            fontSize: 15.5,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Fecha: $fechaTexto · ${detalles.length} ${detalles.length == 1 ? 'producto' : 'productos'}',
                          style: const TextStyle(
                            color: AppColors.gris,
                            fontSize: 12.5,
                          ),
                        ),
                        if (minutosLlegada != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            'A $minutosLlegada min del local',
                            style: const TextStyle(
                              color: AppColors.rosaFuerte,
                              fontWeight: FontWeight.w600,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                        if (!_expandido && detalles.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            resumenProductos,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.gris,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (detalles.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Icon(
                      _expandido
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: AppColors.rosaFuerte,
                    ),
                  ],
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _ListaProductosDesplegada(detalles: detalles),
            crossFadeState: _expandido
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
          if (puedeGestionar) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _procesando
                        ? null
                        : () => _mostrarSelectorTiempoLlegada(
                            idSolicitud,
                            minutosLlegada,
                          ),
                    icon: const Icon(Icons.schedule_rounded, size: 17),
                    label: Text(
                      minutosLlegada != null
                          ? '$minutosLlegada min del local'
                          : 'Tiempo al local',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.texto,
                      side: const BorderSide(color: AppColors.borde),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _procesando
                        ? null
                        : () => _confirmarCancelarPedido(idSolicitud, folio),
                    icon: const Icon(Icons.close_rounded, size: 17),
                    label: const Text(
                      'Cancelar pedido',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFD9385A),
                      side: const BorderSide(color: Color(0xFFFFC9D4)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: AppColors.borde),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total del pedido',
                style: TextStyle(color: AppColors.gris),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AppColors.texto,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _estadoLegible(String estado) {
    return switch (estado.toUpperCase()) {
      'PENDIENTE' => 'Pendiente',
      'ACEPTADA' || 'ACEPTADO' => 'Aceptada',
      'EN_PREPARACION' => 'En preparación',
      'LISTA' => 'Lista para recoger',
      'ENTREGADA' => 'Entregada',
      'RECHAZADA' => 'Rechazada',
      'CANCELADA' => 'Cancelada',
      _ => estado,
    };
  }
}

class _ListaProductosDesplegada extends StatelessWidget {
  const _ListaProductosDesplegada({required this.detalles});

  final List<dynamic> detalles;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.fondo,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Productos ordenados',
            style: TextStyle(
              color: AppColors.gris,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          ...List.generate(detalles.length, (i) {
            final raw = detalles[i];
            final item = raw is Map ? raw : const {};
            final nombre = '${item['nombre_producto'] ?? 'Producto'}';
            final cantidad = int.tryParse('${item['cantidad'] ?? 1}') ?? 1;
            final precioUnitario =
                double.tryParse(
                  '${item['precio_unitario'] ?? item['precio'] ?? 0}',
                ) ??
                0;
            final subtotal =
                double.tryParse('${item['subtotal'] ?? ''}') ??
                (precioUnitario * cantidad);
            final nota = '${item['notas'] ?? item['observaciones'] ?? ''}'
                .trim();

            return Padding(
              padding: EdgeInsets.only(
                bottom: i == detalles.length - 1 ? 0 : 10,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.rosaSuave,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${cantidad}x',
                      style: const TextStyle(
                        color: AppColors.rosaFuerte,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nombre,
                          style: const TextStyle(
                            color: AppColors.texto,
                            fontWeight: FontWeight.w600,
                            fontSize: 13.5,
                          ),
                        ),
                        if (nota.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            nota,
                            style: const TextStyle(
                              color: AppColors.gris,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '\$${subtotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppColors.texto,
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}