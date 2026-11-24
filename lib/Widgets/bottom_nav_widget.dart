import 'package:flutter/material.dart';
import 'package:frizalia/Utils/app_colors.dart';

class BottomNavWidget extends StatelessWidget {
  final int paginaActual;
  final Function(int) onTap;

  const BottomNavWidget({
    super.key,
    required this.paginaActual,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.borde)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _botonNavegacion(Icons.home, 'Home', 0),

            _botonNavegacion(Icons.search, 'Search', 1),

            _botonNavegacion(Icons.favorite_outline, 'Favoritos', 2),

            _botonNavegacion(Icons.person_outline, 'Profile', 3),
          ],
        ),
      ),
    );
  }

  Widget _botonNavegacion(IconData icono, String nombre, int indice) {
    final activo = paginaActual == indice;

    return Expanded(
      child: InkWell(
        onTap: () => onTap(indice),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: activo ? AppColors.fondoActivo : Colors.transparent,
              ),
              child: Icon(
                icono,
                color: activo ? AppColors.rosaFuerte : AppColors.iconoInactivo,
                size: 25,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              nombre,
              style: TextStyle(
                color: activo ? AppColors.rosaFuerte : AppColors.textoInactivo,
                fontSize: 12,
                fontWeight: activo ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
