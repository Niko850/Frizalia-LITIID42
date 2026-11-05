import 'package:flutter/material.dart';
import 'package:frizalia/Models/producto.dart';
import 'package:frizalia/Utils/app_colors.dart';
import 'package:frizalia/Widgets/estado_vacio.dart';

class ProductosGrid extends StatelessWidget {
  final List<Producto> productos;
  final Function(Producto) onAgregar;

  const ProductosGrid({
    super.key,
    required this.productos,
    required this.onAgregar,
  });

  @override
  Widget build(BuildContext context) {
    if (productos.isEmpty) {
      return const EstadoVacioWidget(
        icono: Icons.icecream_outlined,
        titulo: '0 productos disponibles',
        descripcion:
            'Todavía no hay productos registrados.',
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: productos.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 255,
      ),
      itemBuilder: (context, index) {
        final producto = productos[index];

        return Container(
          padding: const EdgeInsets.all(12),
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
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 115,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: index.isEven
                      ? AppColors.rosaSuave
                      : AppColors.amarilloSuave,
                  borderRadius:
                      BorderRadius.circular(15),
                ),
                child: Text(
                  producto.imagen,
                  style: const TextStyle(
                    fontSize: 55,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Text(
                producto.nombre,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.texto,
                ),
              ),

              Text(
                producto.descripcion,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.gris,
                  fontSize: 12,
                ),
              ),

              const Spacer(),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,
                children: [
                  Text(
                    '\$${producto.precio.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  InkWell(
                    onTap: () =>
                        onAgregar(producto),
                    child: Container(
                      padding:
                          const EdgeInsets.all(9),
                      decoration:
                          BoxDecoration(
                        color: AppColors
                            .amarillo,
                        borderRadius:
                            BorderRadius
                                .circular(
                                    10),
                      ),
                      child:
                          const Icon(Icons.add),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}