class Producto {
  final int id;
  final String nombre;
  final String descripcion;
  final String categoria;
  final double precio;
  final int stock;
  final String imagen;

  const Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.categoria,
    required this.precio,
    required this.stock,
    this.imagen = '🍦',
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      categoria: json['categoria'] ?? '',
      precio: (json['precio'] ?? 0).toDouble(),
      stock: json['stock'] ?? 0,
      imagen: json['imagen'] ?? '🍦',
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
  }) {
    return Producto(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      categoria: categoria ?? this.categoria,
      precio: precio ?? this.precio,
      stock: stock ?? this.stock,
      imagen: imagen ?? this.imagen,
    );
  }

  @override
  String toString() {
    return 'Producto(id: $id, nombre: $nombre, precio: $precio)';
  }
}