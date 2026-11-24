import 'package:flutter/material.dart';
import 'package:frizalia/Screens/login_screen.dart';
import 'package:frizalia/Services/api_service.dart';

import 'mis_ordenes_screen.dart';

class ProfileScreen extends StatelessWidget {
  final String nombre;
  final String correo;
  final VoidCallback? onCerrarSesion;

  const ProfileScreen({
    super.key,
    this.nombre = 'Cliente',
    this.correo = '',
    this.onCerrarSesion,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Perfil',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2522),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7D9DE),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'FRIZALIA',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B4A58),
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFCE4EC),
                          const Color(0xFFFFD180).withValues(alpha: 0.6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const CircleAvatar(
                      radius: 52,
                      backgroundColor: Color(0xFFFCE4EC),
                      child: Icon(
                        Icons.person,
                        size: 64,
                        color: Color(0xFFE91E63),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 16,
                        color: Color(0xFF5D4037),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Text(
                nombre,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2522),
                ),
              ),

              const SizedBox(height: 4),

              Text(
                correo,
                style: TextStyle(fontSize: 14, color: Color(0xFF8D827D)),
              ),

              const SizedBox(height: 28),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF8D9B5), Color(0xFFF5E5B8)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.stars,
                        color: Color(0xFF8B4A58),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Puntos Acumulados',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D2522),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '450 pts',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D2522),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Color(0xFF2D2522)),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              _buildMenuCard(
                icon: Icons.shopping_bag_outlined,
                iconBgColor: const Color(0xFFFCE4EC),
                iconColor: const Color(0xFFC2185B),
                title: 'Mis órdenes',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MisOrdenesScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              _buildMenuCard(
                icon: Icons.info_outline,
                iconBgColor: const Color(0xFFFCE4EC),
                iconColor: const Color(0xFFC2185B),
                title: 'Info',
                onTap: () {},
              ),

              const SizedBox(height: 12),

              _buildMenuCard(
                icon: Icons.settings_outlined,
                iconBgColor: const Color(0xFFFFF9C4),
                iconColor: const Color(0xFFF57F17),
                title: 'Ajustes',
                onTap: () {},
              ),

              const SizedBox(height: 12),

              _buildMenuCard(
                icon: Icons.support_agent_outlined,
                iconBgColor: const Color(0xFFFCE4EC),
                iconColor: const Color(0xFFC2185B),
                title: 'Ayuda y soporte',
                onTap: () {},
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    ApiService.instance.cerrarSesion();
                    if (onCerrarSesion != null) {
                      onCerrarSesion!();
                      return;
                    }
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFEE8A3),
                    foregroundColor: const Color(0xFF2D2522),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, color: Color(0xFF2D2522)),
                      SizedBox(width: 8),
                      Text(
                        'Cerrar sesión',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D2522),
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Color(0xFF8D827D),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
