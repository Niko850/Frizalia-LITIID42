class Producto {
  final int id;
  final String nombre;
  final String descripcion;
  final String categoria;
  final double precio;
  final int stock;
  final String imagen;
  final String? imagenUrl;

  const Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.categoria,
    required this.precio,
    required this.stock,
    this.imagen = '🍦',
    this.imagenUrl,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    final imagenUrl = json['imagen_url'] ?? json['imagenUrl'];
    final imagen = json['imagen'];
    final categoriaRaw = '${json['categoria'] ?? ''}';

    return Producto(
      id: (json['id_producto'] ?? json['id'] ?? 0) as int,
      nombre: (json['nombre'] ?? '') as String,
      descripcion: (json['descripcion'] ?? json['presentacion'] ?? '') as String,
      categoria: categoriaRaw == 'Nieves' ? 'Helados' : categoriaRaw,
      precio: double.tryParse('${json['precio'] ?? 0}') ?? 0,
      stock: int.tryParse('${json['stock'] ?? 0}') ?? 0,
      imagen: imagen is String && imagen.isNotEmpty ? imagen : '🍦',
      imagenUrl: imagenUrl is String && imagenUrl.isNotEmpty ? imagenUrl : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'categoria': categoria,
      'precio': precio,
      'stock': stock,
      'imagen': imagen,
      'imagen_url': imagenUrl,
    };
  }

  Producto copyWith({
    int? id,
    String? nombre,
    String? descripcion,
    String? categoria,
    double? precio,
    int? stock,
    String? imagen,
    String? imagenUrl,
  }) {
    return Producto(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      categoria: categoria ?? this.categoria,
      precio: precio ?? this.precio,
      stock: stock ?? this.stock,
      imagen: imagen ?? this.imagen,
      imagenUrl: imagenUrl ?? this.imagenUrl,
    );
  }

  @override
  String toString() {
    return 'Producto(id: $id, nombre: $nombre, precio: $precio)';
  }
}