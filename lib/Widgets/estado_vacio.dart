import 'package:flutter/material.dart';
import 'package:frizalia/Utils/app_colors.dart';

class EstadoVacioWidget extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String descripcion;

  const EstadoVacioWidget({
    super.key,
    required this.icono,
    required this.titulo,
    required this.descripcion,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 65,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borde,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icono,
            size: 70,
            color: AppColors.rosa,
          ),

          const SizedBox(height: 15),

          Text(
            titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: AppColors.texto,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            descripcion,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.gris,
            ),
          ),
        ],
      ),
    );
  }
}