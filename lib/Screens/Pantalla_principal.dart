import 'package:flutter/material.dart';

import 'package:frizalia/Screens/login_screen.dart';
import 'package:frizalia/Screens/lista_screen.dart';
import 'package:frizalia/Screens/perfil_screen.dart';

import 'package:frizalia/Models/producto.dart';
import 'package:frizalia/Services/api_service.dart';
import 'package:frizalia/Services/producto_service.dart';
import 'package:frizalia/Utils/app_colors.dart';

import 'package:frizalia/Widgets/bottom_nav_widget.dart';
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

  @override
  void initState() {
    super.initState();

    productoService = ProductoService(
      productos: productos,
      seleccionados: seleccionados,
    );
    cargarCatalogo();
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

  List<Producto> get disponibles => productoService.disponibles();

  List<Producto> get filtrados =>
      productoService.filtrados(categoria: categoria, busqueda: busqueda);

  void cambiarPagina(int nuevaPagina) {
    setState(() {
      pagina = nuevaPagina;
    });
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

            ListaScreen(
              productos: productoService.seleccionadosLista(),
              cantidades: seleccionados,
              subtotal: productoService.totalCompra(),
              onDisminuir: (producto) {
                setState(() {
                  productoService.cambiarCantidad(producto, -1);
                });
              },
              onAumentar: (producto) {
                final agregado = productoService.agregarProducto(producto);
                if (!agregado) {
                  mostrarMensaje('No hay más unidades disponibles');
                  return;
                }
                setState(() {});
              },
              onBuscar: () => cambiarPagina(1),
              onSolicitar: (minutosLlegada) async {
                final respuesta = await ApiService.instance.crearSolicitud(
                  productos: productoService.seleccionadosLista(),
                  cantidades: seleccionados,
                  minutosLlegada: minutosLlegada,
                );
                productoService.vaciarLista();
                if (mounted) setState(() {});
                return respuesta['folio'] as String? ?? 'registrada';
              },
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
