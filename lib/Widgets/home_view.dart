import 'package:flutter/material.dart';
import 'package:frizalia/Models/producto.dart';
import 'package:frizalia/Utils/app_colors.dart';
import 'package:frizalia/Widgets/categorias_widget.dart';

class HomeView extends StatelessWidget {
  final List<Producto> productos;
  final List<Producto> filtrados;
  final String categoria;
  final List<String> categorias;
  final VoidCallback abrirBusqueda;
  final VoidCallback verTodos;
  final Function(String) cambiarCategoria;
  final Widget listadoProductos;

  const HomeView({
    super.key,
    required this.productos,
    required this.filtrados,
    required this.categoria,
    required this.categorias,
    required this.abrirBusqueda,
    required this.verTodos,
    required this.cambiarCategoria,
    required this.listadoProductos,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      children: [
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FRIZALIA GELATERÍA',
                    style: TextStyle(
                      color: AppColors.rosaFuerte,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 7),

                  Text(
                    'Pantalla principal',
                    style: TextStyle(
                      fontSize: 29,
                      fontWeight: FontWeight.bold,
                      color: AppColors.texto,
                    ),
                  ),
                ],
              ),
            ),
            const CircleAvatar(
              radius: 27,
              backgroundColor: AppColors.avatar,
              child: Text('🍦', style: TextStyle(fontSize: 27)),
            ),
          ],
        ),

        const SizedBox(height: 30),

        InkWell(
          onTap: abrirBusqueda,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borde),
            ),
            child: const Row(
              children: [
                Icon(Icons.search, size: 28, color: AppColors.gris),
                SizedBox(width: 13),
                Text(
                  'Buscar productos...',
                  style: TextStyle(color: AppColors.hint, fontSize: 17),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 25),

        CategoriasWidget(
          categoriaSeleccionada: categoria,
          categorias: categorias,
          onCategoriaSeleccionada: cambiarCategoria,
        ),

        const SizedBox(height: 27),

        Container(
          padding: const EdgeInsets.all(23),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(23),
            gradient: const LinearGradient(
              colors: [Color(0xFFF9BBD7), Color(0xFFFFDDD0), Color(0xFFFFF0BC)],
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'FRIZALIA',
                      style: TextStyle(
                        color: AppColors.rosaFuerte,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 18),

                    Text(
                      '${productos.length} productos disponibles',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.texto,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Descubre nuestros sabores',
                      style: TextStyle(color: AppColors.gris),
                    ),
                  ],
                ),
              ),
              const Text('🍦', style: TextStyle(fontSize: 60)),
            ],
          ),
        ),

        const SizedBox(height: 30),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Populares',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: AppColors.texto,
              ),
            ),
            TextButton(
              onPressed: verTodos,
              child: const Text(
                'Ver todos',
                style: TextStyle(color: AppColors.rosaFuerte),
              ),
            ),
          ],
        ),

        const SizedBox(height: 15),

        listadoProductos,

        const SizedBox(height: 25),
      ],
    );
  }
}
