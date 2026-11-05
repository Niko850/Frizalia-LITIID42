import 'package:flutter/material.dart';
import 'package:frizalia/Utils/app_colors.dart';

class CategoriasWidget extends StatelessWidget {
  final String categoriaSeleccionada;
  final Function(String) onCategoriaSeleccionada;

  const CategoriasWidget({
    super.key,
    required this.categoriaSeleccionada,
    required this.onCategoriaSeleccionada,
  });

  @override
  Widget build(BuildContext context) {
    const nombres = [
      'Todos',
      'Paletas',
      'Helados',
      'Aguas Naturales',
      'Refrigerios',
    ];

    const emojis = [
      '🍦',
      '🍭',
      '🍨',
      '🥤',
      '🍪',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < nombres.length; i++)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: ChoiceChip(
                label: Text(
                  '${emojis[i]}  ${nombres[i]}',
                ),
                selected:
                    categoriaSeleccionada ==
                    nombres[i],
                selectedColor: AppColors.rosa,
                backgroundColor: Colors.white,
                showCheckmark: false,
                onSelected: (_) {
                  onCategoriaSeleccionada(
                    nombres[i],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}