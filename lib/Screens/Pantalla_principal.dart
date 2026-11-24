import 'package:flutter/material.dart';

import 'package:frizalia/Screens/login_screen.dart';
import 'package:frizalia/Screens/perfil_screen.dart';

import 'package:frizalia/Models/producto.dart';
import 'package:frizalia/Services/api_service.dart';
import 'package:frizalia/Services/producto_service.dart';
import 'package:frizalia/Utils/app_colors.dart';

import 'package:frizalia/Widgets/bottom_nav_widget.dart';
import 'package:frizalia/Widgets/favoritos_view.dart';
import 'package:frizalia/Widgets/home_view.dart';
import 'package:frizalia/Widgets/productos_grid.dart';
import 'package:frizalia/Widgets/search_view.dart';

class HomeScreen extends StatefulWidget {
  final String correo;

  const HomeScreen({super.key, required this.correo});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Producto> productos = [];

  final Map<int, int> seleccionados = {};

  late ProductoService productoService;

  int pagina = 0;

  String categoria = 'Todos';
  String busqueda = '';
  List<String> categorias = [];
  bool cargandoCatalogo = true;
  String? errorCatalogo;

  /// Contador de veces que el usuario ha pedido cada producto (clave: nombre o id)
  final Map<String, int> frecuenciaPedidos = {};
  final Set<String> favoritosManuales = {};
  bool cargandoFavoritos = false;

  @override
  void initState() {
    super.initState();

    productoService = ProductoService(
      productos: productos,
      seleccionados: seleccionados,
    );
    cargarCatalogo();
    cargarMasPedidos();
  }

  Future<void> cargarCatalogo() async {
    setState(() {
      cargandoCatalogo = true;
      errorCatalogo = null;
    });
    try {
      final productosNuevos = await ApiService.instance.obtenerProductos();
      final categoriasNuevas = await ApiService.instance.obtenerCategorias();
      productos
        ..clear()
        ..addAll(productosNuevos);
      categorias = categoriasNuevas;
      if (!categorias.contains(categoria) && categoria != 'Todos') {
        categoria = 'Todos';
      }
    } catch (error) {
      errorCatalogo = error.toString().replaceFirst('Exception: ', '');
    } finally {
      if (mounted) setState(() => cargandoCatalogo = false);
    }
  }

  Future<void> cargarMasPedidos() async {
    if (mounted) setState(() => cargandoFavoritos = true);
    try {
      final solicitudes = await ApiService.instance.obtenerMisSolicitudes();
      final conteo = <String, int>{};

      for (final solicitud in solicitudes) {
        final detalles = (solicitud['productos'] as List? ?? [])
            .whereType<Map<String, dynamic>>();
        for (final item in detalles) {
          final nombre = '${item['nombre_producto'] ?? ''}'.trim();
          if (nombre.isEmpty) continue;
          final cantidad = int.tryParse('${item['cantidad'] ?? 1}') ?? 1;
          conteo[nombre] = (conteo[nombre] ?? 0) + (cantidad > 0 ? cantidad : 1);
        }
      }

      if (mounted) {
        setState(() {
          frecuenciaPedidos
            ..clear()
            ..addAll(conteo);
        });
      }
    } catch (_) {
      // Si falla la carga de historial, se mantiene lo que haya en favoritosManuales
    } finally {
      if (mounted) setState(() => cargandoFavoritos = false);
    }
  }

  void toggleFavoritoManual(String nombreProducto) {
    setState(() {
      if (favoritosManuales.contains(nombreProducto)) {
        favoritosManuales.remove(nombreProducto);
      } else {
        favoritosManuales.add(nombreProducto);
      }
    });
  }

  List<Producto> get disponibles => productoService.disponibles();

  List<Producto> get filtrados =>
      productoService.filtrados(categoria: categoria, busqueda: busqueda);

  void cambiarPagina(int nuevaPagina) {
    setState(() {
      pagina = nuevaPagina;
    });
    // Refresca los más pedidos al entrar a la pestaña de Favoritos
    if (nuevaPagina == 2) {
      cargarMasPedidos();
    }
  }

  void agregarProducto(Producto producto) {
    final agregado = productoService.agregarProducto(producto);

    if (!agregado) {
      mostrarMensaje('No hay más unidades disponibles');
      return;
    }

    setState(() {});

    mostrarMensaje('${producto.nombre} agregado al carrito');
  }

  void mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  void cerrarSesion() {
    ApiService.instance.cerrarSesion();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,

      body: SafeArea(
        child: IndexedStack(
          index: pagina,
          children: [
            HomeView(
              productos: disponibles,
              filtrados: filtrados,
              categoria: categoria,
              categorias: categorias,

              abrirBusqueda: () {
                cambiarPagina(1);
              },

              verTodos: () {
                setState(() {
                  categoria = 'Todos';
                  busqueda = '';
                  pagina = 1;
                });
              },

              cambiarCategoria: (valor) {
                setState(() {
                  categoria = valor;
                });
              },

              listadoProductos: ProductosGrid(
                productos: filtrados,
                onAgregar: agregarProducto,
                isLoading: cargandoCatalogo,
                error: errorCatalogo,
                onRetry: cargarCatalogo,
              ),
            ),

            SearchView(
              categoria: categoria,
              categorias: categorias,

              resultados: filtrados.length,

              productosGrid: ProductosGrid(
                productos: filtrados,
                onAgregar: agregarProducto,
                isLoading: cargandoCatalogo,
                error: errorCatalogo,
                onRetry: cargarCatalogo,
              ),

              onBuscar: (valor) {
                setState(() {
                  busqueda = valor;
                });
              },

              onCategoriaSeleccionada: (valor) {
                setState(() {
                  categoria = valor;
                });
              },
            ),

            FavoritosView(
              catalogo: productos,
              frecuenciaPedidos: frecuenciaPedidos,
              favoritosManuales: favoritosManuales,
              isLoading: cargandoFavoritos,
              onToggleFavorito: toggleFavoritoManual,
              onAgregar: agregarProducto,
              onExplorar: () => cambiarPagina(1),
            ),

            ProfileScreen(
              nombre:
                  ApiService.instance.usuario?['nombre'] as String? ??
                  'Cliente',
              correo: widget.correo,
              onCerrarSesion: cerrarSesion,
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavWidget(
        paginaActual: pagina,
        onTap: cambiarPagina,
      ),
    );
  }
}