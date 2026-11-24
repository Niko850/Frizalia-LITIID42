import 'package:flutter/material.dart';
import 'package:frizalia/Screens/pantalla_principal.dart';
import 'package:frizalia/Screens/registro_screen.dart';
import 'package:frizalia/Services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final correoController = TextEditingController();
  final contrasenaController = TextEditingController();

  bool mostrarContrasena = false;
  bool cargando = false;

  @override
  void dispose() {
    correoController.dispose();
    contrasenaController.dispose();
    super.dispose();
  }

  Future<void> iniciarSesion() async {
    if (cargando) return;
    if (correoController.text.isEmpty || contrasenaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    setState(() => cargando = true);
    try {
      await ApiService.instance.iniciarSesion(
        correo: correoController.text.trim(),
        password: contrasenaController.text,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              HomeScreen(correo: correoController.text.trim()),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF4F7), Color(0xFFFFFFFF), Color(0xFFFFF8DC)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.sizeOf(context).height -
                      MediaQuery.paddingOf(context).top -
                      MediaQuery.paddingOf(context).bottom -
                      50,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 50),

                    Container(
                      width: 115,
                      height: 115,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: const Color(0xFFF6CFDA),
                          width: 3,
                        ),
                        boxShadow: const [
                          BoxShadow(color: Color(0x20E6A9B9), blurRadius: 15),
                        ],
                      ),
                      child: const Text('🍦', style: TextStyle(fontSize: 52)),
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      'Frizalia',
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF282326),
                      ),
                    ),

                    const SizedBox(height: 7),

                    const Text(
                      'Paletería, Helados y más...',
                      style: TextStyle(fontSize: 16, color: Color(0xFF777177)),
                    ),

                    const SizedBox(height: 140),

                    TextField(
                      controller: correoController,
                      enabled: !cargando,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Correo electrónico',
                        suffixIcon: const Icon(
                          Icons.alternate_email,
                          color: Color(0xFFBDB6B9),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                            color: Color(0xFFF0E6E8),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                            color: Color(0xFFF0E6E8),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 23),

                    TextField(
                      controller: contrasenaController,
                      enabled: !cargando,
                      obscureText: !mostrarContrasena,
                      decoration: InputDecoration(
                        hintText: 'Contraseña',
                        suffixIcon: IconButton(
                          icon: Icon(
                            mostrarContrasena
                                ? Icons.visibility
                                : Icons.lock_outline,
                            color: const Color(0xFFBDB6B9),
                          ),
                          onPressed: () {
                            setState(() {
                              mostrarContrasena = !mostrarContrasena;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                            color: Color(0xFFF0E6E8),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                            color: Color(0xFFF0E6E8),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 35),

                    SizedBox(
                      width: double.infinity,
                      height: 66,
                      child: ElevatedButton(
                        onPressed: cargando ? null : iniciarSesion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF8E9AF),
                          foregroundColor: const Color(0xFF282326),
                          elevation: 2,
                          shadowColor: const Color(0x55F5D877),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: cargando
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Iniciar sesión',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    TextButton(
                      onPressed: () {
                        if (cargando) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegistroScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Crear una cuenta',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF282326),
                        ),
                      ),
                    ),

                    const SizedBox(height: 80),

                    const Text(
                      'Términos y condiciones',
                      style: TextStyle(fontSize: 14, color: Color(0xFF918B90)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
