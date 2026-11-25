import 'package:flutter/material.dart';

import 'package:frizalia/Screens/lista_screen.dart';
import 'package:frizalia/Screens/login_screen.dart';
import 'package:frizalia/Screens/perfil_screen.dart';

import 'package:frizalia/Models/producto.dart';
import 'package:frizalia/Services/api_service.dart';
import 'package:frizalia/Services/carrito_cache.dart';
import 'package:frizalia/Services/producto_service.dart';
import 'package:frizalia/Utils/app_colors.dart';

import 'package:frizalia/Widgets/bottom_nav_widget.dart';
import 'package:frizalia/Widgets/favoritos_view.dart';
import 'package:frizalia/Widgets/home_view.dart';
import 'package:frizalia/Widgets/pedidos_recientes_sheet.dart';
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
  final List<Producto> _itemsPersonalizados = [];
  final Map<int, int> seleccionados = {};

  late ProductoService productoService;

  int pagina = 0;

  String categoria = 'Todos';
  String busqueda = '';
  List<String> categorias = [];
  bool cargandoCatalogo = true;
  String? errorCatalogo;

  final Map<String, int> frecuenciaPedidos = {};
  final Set<String> favoritosManuales = {};
  bool cargandoFavoritos = false;

  @override
  void initState() {
    super.initState();

    seleccionados.addAll(CarritoCache.instance.obtenerCantidades(widget.correo));
    _itemsPersonalizados.addAll(
      CarritoCache.instance.obtenerPersonalizados(widget.correo),
    );

    productoService = ProductoService(
      productos: productos,
      seleccionados: seleccionados,
    );
    cargarCatalogo();
    cargarMasPedidos();
  }

  void _persistirPedidoEnCurso() {
    CarritoCache.instance.guardarEstado(
      correo: widget.correo,
      cantidades: seleccionados,
      itemsPersonalizados: _itemsPersonalizados,
    );
  }

  List<Producto> _productosParaPedido() {
    final idsCatalogo = productos.map((p) => p.id).toSet();
    final baseSeleccionados = productoService.seleccionadosLista();
    final extrasVigentes = _itemsPersonalizados
        .where(
          (p) => (seleccionados[p.id] ?? 0) > 0 && !idsCatalogo.contains(p.id),
        )
        .toList();
    return [...baseSeleccionados, ...extrasVigentes];
  }

  double _totalParaPedido() {
    final idsCatalogo = productos.map((p) => p.id).toSet();
    double total = productoService.totalCompra();
    for (final p in _itemsPersonalizados) {
      if (!idsCatalogo.contains(p.id)) {
        final cant = seleccionados[p.id] ?? 0;
        if (cant > 0) total += p.precio * cant;
      }
    }
    return total;
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
        final rawProductos = solicitud['productos'];
        if (rawProductos is List) {
          for (final rawItem in rawProductos) {
            if (rawItem is! Map) continue;
            final nombre = '${rawItem['nombre_producto'] ?? ''}'.trim();
            if (nombre.isEmpty) continue;
            final cantidad = int.tryParse('${rawItem['cantidad'] ?? 1}') ?? 1;
            conteo[nombre] =
                (conteo[nombre] ?? 0) + (cantidad > 0 ? cantidad : 1);
          }
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

  int get totalUnidadesCarrito =>
      seleccionados.values.fold(0, (acc, cant) => acc + cant);

  void cambiarPagina(int nuevaPagina) {
    setState(() {
      pagina = nuevaPagina;
    });
    if (nuevaPagina == 2) {
      cargarMasPedidos();
    }
  }

  void agregarProducto(Producto producto) {
    final existeEnCatalogo = productos.any((p) => p.id == producto.id);
    if (!existeEnCatalogo) {
      final idxExtra =
          _itemsPersonalizados.indexWhere((p) => p.id == producto.id);
      if (idxExtra == -1) {
        _itemsPersonalizados.add(producto);
      }
      final actual = seleccionados[producto.id] ?? 0;
      seleccionados[producto.id] = actual + 1;
      _persistirPedidoEnCurso();
      setState(() {});
      mostrarMensaje('${producto.nombre} agregado al carrito');
      return;
    }

    final agregado = productoService.agregarProducto(producto);
    if (!agregado) {
      mostrarMensaje('No hay más unidades disponibles');
      return;
    }

    _persistirPedidoEnCurso();
    setState(() {});
    mostrarMensaje('${producto.nombre} agregado al carrito');
  }

  void abrirCarrito() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StatefulBuilder(
          builder: (context, setModalState) {
            final listaPedido = _productosParaPedido();
            return ListaScreen(
              productos: listaPedido,
              cantidades: seleccionados,
              subtotal: _totalParaPedido(),
              onDisminuir: (producto) {
                setState(() {
                  if (productos.any((p) => p.id == producto.id)) {
                    productoService.cambiarCantidad(producto, -1);
                  } else {
                    final actual = seleccionados[producto.id] ?? 0;
                    if (actual <= 1) {
                      seleccionados.remove(producto.id);
                      _itemsPersonalizados.removeWhere(
                        (p) => p.id == producto.id,
                      );
                    } else {
                      seleccionados[producto.id] = actual - 1;
                    }
                  }
                  _persistirPedidoEnCurso();
                });
                setModalState(() {});
              },
              onAumentar: (producto) {
                if (productos.any((p) => p.id == producto.id)) {
                  final agregado = productoService.agregarProducto(producto);
                  if (!agregado) {
                    mostrarMensaje('No hay más unidades disponibles');
                    return;
                  }
                } else {
                  seleccionados[producto.id] =
                      (seleccionados[producto.id] ?? 0) + 1;
                }
                _persistirPedidoEnCurso();
                setState(() {});
                setModalState(() {});
              },
              onActualizarProducto: (anterior, actualizado) {
                final cantAnterior = seleccionados[anterior.id] ?? 0;
                final idxCatalogo =
                    productos.indexWhere((p) => p.id == anterior.id);
                if (idxCatalogo != -1) {
                  final idxExtra = _itemsPersonalizados.indexWhere(
                    (p) => p.id == actualizado.id,
                  );
                  if (idxExtra != -1) {
                    _itemsPersonalizados[idxExtra] = actualizado;
                  } else {
                    _itemsPersonalizados.add(actualizado);
                  }
                } else {
                  final idxExtra = _itemsPersonalizados.indexWhere(
                    (p) => p.id == anterior.id,
                  );
                  if (idxExtra != -1) {
                    _itemsPersonalizados[idxExtra] = actualizado;
                  } else {
                    _itemsPersonalizados.add(actualizado);
                  }
                }
                if (anterior.id != actualizado.id && cantAnterior > 0) {
                  seleccionados.remove(anterior.id);
                  seleccionados[actualizado.id] = cantAnterior;
                }
                _persistirPedidoEnCurso();
                setState(() {});
                setModalState(() {});
              },
              onBuscar: () {
                Navigator.pop(context);
                cambiarPagina(1);
              },
              onSolicitar: (minutosLlegada) async {
                final respuesta = await ApiService.instance.crearSolicitud(
                  productos: _productosParaPedido(),
                  cantidades: seleccionados,
                  minutosLlegada: minutosLlegada,
                );
                productoService.vaciarLista();
                _itemsPersonalizados.clear();
                CarritoCache.instance.limpiarEstado(widget.correo);
                if (mounted) {
                  setState(() {});
                  cargarMasPedidos();
                }
                setModalState(() {});
                return respuesta['folio'] as String? ?? 'registrada';
              },
            );
          },
        ),
      ),
    );
  }

  void mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  void cerrarSesion() {
    _persistirPedidoEnCurso();
    ApiService.instance.cerrarSesion();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cantidadCarrito = totalUnidadesCarrito;

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
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'btnPedidosRecientes',
            onPressed: () => mostrarPedidosRecientesSheet(
              context: context,
              onMensaje: mostrarMensaje,
            ),
            backgroundColor: Colors.white,
            foregroundColor: AppColors.texto,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.borde),
            ),
            icon: const Icon(
              Icons.receipt_long_rounded,
              color: AppColors.rosaFuerte,
            ),
            label: const Text(
              'Pedidos recientes',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: 'btnCarrito',
            onPressed: abrirCarrito,
            backgroundColor: AppColors.rosaFuerte,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.shopping_bag_rounded),
            label: Text(
              'Carrito ($cantidadCarrito) · \$${_totalParaPedido().toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavWidget(
        paginaActual: pagina,
        onTap: cambiarPagina,
      ),
    );
  }
}