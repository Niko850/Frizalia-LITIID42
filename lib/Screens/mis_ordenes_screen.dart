import 'package:flutter/material.dart';
import 'package:frizalia/Services/api_service.dart';
import 'package:frizalia/Utils/app_colors.dart';

class MisOrdenesScreen extends StatelessWidget {
  const MisOrdenesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: ApiService.instance.obtenerMisSolicitudes(),
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
          ],
        ),
      ),
    );
  }

  Widget _contenido(List<Map<String, dynamic>> solicitudes) {
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

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      itemCount: solicitudes.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _TarjetaOrden(solicitud: solicitudes[index]);
      },
    );
  }
}

class _TarjetaOrden extends StatefulWidget {
  const _TarjetaOrden({required this.solicitud});

  final Map<String, dynamic> solicitud;

  @override
  State<_TarjetaOrden> createState() => _TarjetaOrdenState();
}

class _TarjetaOrdenState extends State<_TarjetaOrden> {
  bool _expandido = false;

  @override
  Widget build(BuildContext context) {
    final solicitud = widget.solicitud;
    final detalles = (solicitud['productos'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();

    final estado = '${solicitud['estado'] ?? 'PENDIENTE'}';
    final folio =
        '${solicitud['folio'] ?? 'FRZ-${solicitud['id_solicitud']}'}';

    final fecha = DateTime.tryParse(
      '${solicitud['fecha_solicitud'] ?? ''}',
    );
    final fechaTexto = fecha == null
        ? 'Fecha no disponible'
        : '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';

    final tituloRaw =
        '${solicitud['titulo'] ?? solicitud['nombre_pedido'] ?? ''}'.trim();
    final tituloPedido = tituloRaw.isNotEmpty
        ? tituloRaw
        : 'Pedido · $fechaTexto';

    final resumenProductos = detalles.isEmpty
        ? 'Solicitud de recogida'
        : detalles
            .map((item) {
              final nombre = item['nombre_producto'] ?? 'Producto';
              final cant = int.tryParse('${item['cantidad'] ?? 1}') ?? 1;
              return cant > 1 ? '$cant× $nombre' : '$nombre';
            })
            .join(', ');

    final total = double.tryParse('${solicitud['total'] ?? 0}') ?? 0;

    final estadoColor = switch (estado) {
      'LISTA' => AppColors.amarilloSuave,
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
          // Folio + Estado
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
                    fontSize: 16,
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

          // Título del pedido + Fecha + Botón desplegable
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
                          tituloPedido,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.texto,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
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
                        if (!_expandido) ...[
                          const SizedBox(height: 4),
                          Text(
                            resumenProductos,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.texto,
                              fontSize: 13,
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

          // Lista desplegable de productos
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _ListaProductosDesplegada(detalles: detalles),
            crossFadeState: _expandido
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: AppColors.borde),
          ),

          // Total
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
    return switch (estado) {
      'PENDIENTE' => 'Pendiente',
      'ACEPTADA' => 'Aceptada',
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

  final List<Map<String, dynamic>> detalles;

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
            final item = detalles[i];
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