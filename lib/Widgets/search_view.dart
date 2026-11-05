import 'package:flutter/material.dart';
import 'package:frizalia/Utils/app_colors.dart';
import 'package:frizalia/Widgets/categorias_widget.dart';

class SearchView extends StatelessWidget {
  final String categoria;
  final int resultados;
  final Widget productosGrid;

  final Function(String) onBuscar;
  final Function(String) onCategoriaSeleccionada;

  const SearchView({
    super.key,
    required this.categoria,
    required this.resultados,
    required this.productosGrid,
    required this.onBuscar,
    required this.onCategoriaSeleccionada,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(22),
      children: [
        const Text(
          'Buscar productos',
          style: TextStyle(
            fontSize: 29,
            fontWeight: FontWeight.bold,
            color: AppColors.texto,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Encuentra tus paletas, helados y aguas naturales favoritas.',
          style: TextStyle(
            color: AppColors.gris,
          ),
        ),

        const SizedBox(height: 25),

        TextField(
          onChanged: onBuscar,
          decoration: InputDecoration(
            hintText: 'Nombre o categoría...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,

            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(17),
              borderSide:
                  const BorderSide(
                color: Color(0xFFF1DFE8),
              ),
            ),

            enabledBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(17),
              borderSide:
                  const BorderSide(
                color: Color(0xFFF1DFE8),
              ),
            ),
          ),
        ),

        const SizedBox(height: 25),

        CategoriasWidget(
          categoriaSeleccionada: categoria,
          onCategoriaSeleccionada:
              onCategoriaSeleccionada,
        ),

        const SizedBox(height: 25),

        Text(
          '$resultados resultados',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.texto,
            fontSize: 18,
          ),
        ),

        const SizedBox(height: 15),

        productosGrid,
      ],
    );
  }
}