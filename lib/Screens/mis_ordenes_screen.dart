import 'package:flutter/material.dart';

class MisOrdenesScreen extends StatelessWidget {
  const MisOrdenesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productos = [
      {
        'numero': '#1042',
        'titulo': 'Helado de chocolate',
        'fecha': '14 nov 2026',
        'estado': 'Listo',
        'precio': '\$ 45.00',
        'color': const Color(0xFFFCE4EC),
        'icon': Icons.icecream_rounded,
      },
      {
        'numero': '#1087',
        'titulo': 'Paleta de limón',
        'fecha': '22 nov 2026',
        'estado': 'Enviado',
        'precio': '\$ 30.00',
        'color': const Color(0xFFFFF9C4),
        'icon': Icons.local_drink_rounded,
      },
      {
        'numero': '#1105',
        'titulo': 'Agua de horchata',
        'fecha': '24 nov 2026',
        'estado': 'Preparando',
        'precio': '\$ 25.00',
        'color': const Color(0xFFE8E0FF),
        'icon': Icons.soup_kitchen_rounded,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2D2522)),
        ),
        title: const Text(
          'Paletería Frizalia',
          style: TextStyle(
            color: Color(0xFF2D2522),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: ListView.separated(
            itemCount: productos.length,
            separatorBuilder: (_, _) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final producto = productos[index];
              final statusColor = producto['estado'] == 'Listo'
                  ? const Color(0xFFD7F5E5)
                  : producto['estado'] == 'Enviado'
                      ? const Color(0xFFE8E0FF)
                      : const Color(0xFFFFF2C8);

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          producto['numero'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D2522),
                            fontSize: 16,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            producto['estado'] as String,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2D2522),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: producto['color'] as Color,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            producto['icon'] as IconData,
                            color: const Color(0xFFC2185B),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                producto['titulo'] as String,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D2522),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Pedido el ${producto['fecha']}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF8D827D),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF8D827D),
                          ),
                        ),
                        Text(
                          producto['precio'] as String,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D2522),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
