import 'package:flutter/material.dart';
import 'package:frizalia/Utils/app_colors.dart';

class CategoriasWidget extends StatelessWidget {
  final String categoriaSeleccionada;
  final List<String> categorias;
  final Function(String) onCategoriaSeleccionada;

  const CategoriasWidget({
    super.key,
    required this.categoriaSeleccionada,
    this.categorias = const [
      'Paletas',
      'Helados',
      'Aguas Naturales',
      'Pasteles',
      'Bebidas',
      'Otros',
    ],
    required this.onCategoriaSeleccionada,
  });

  @override
  Widget build(BuildContext context) {
    final nombres = ['Todos', ...categorias];
    final emojis = nombres.map((nombre) {
      switch (nombre.toLowerCase()) {
        case 'paletas':
          return '🍭';
        case 'helados':
          return '🍨';
        case 'aguas naturales':
          return '🥤';
        case 'bebidas':
          return '🥤';
        case 'pasteles':
          return '🍰';
        case 'otros':
          return '🍪';
        default:
          return '🍦';
      }
    }).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < nombres.length; i++)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: ChoiceChip(
                label: Text('${emojis[i]}  ${nombres[i]}'),
                selected: categoriaSeleccionada == nombres[i],
                selectedColor: AppColors.rosa,
                backgroundColor: Colors.white,
                showCheckmark: false,
                onSelected: (_) {
                  onCategoriaSeleccionada(nombres[i]);
                },
              ),
            ),
        ],
      ),
    );
  }
}
