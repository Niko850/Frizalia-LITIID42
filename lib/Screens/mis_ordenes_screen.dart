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
        final solicitud = solicitudes[index];
        final detalles = (solicitud['productos'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .toList();
        final nombreProducto = detalles.isEmpty
            ? 'Solicitud de recogida'
            : '${detalles.first['nombre_producto'] ?? 'Producto'}';
        final estado = '${solicitud['estado'] ?? 'PENDIENTE'}';
        final folio =
            '${solicitud['folio'] ?? 'FRZ-${solicitud['id_solicitud']}'}';
        final fecha = DateTime.tryParse(
          '${solicitud['fecha_solicitud'] ?? ''}',
        );
        final fechaTexto = fecha == null
            ? 'Fecha no disponible'
            : '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
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
              const SizedBox(height: 14),
              Row(
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
                          nombreProducto,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.texto,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          detalles.length > 1
                              ? '+ ${detalles.length - 1} productos · $fechaTexto'
                              : 'Pedido el $fechaTexto',
                          style: const TextStyle(
                            color: AppColors.gris,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
      },
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
