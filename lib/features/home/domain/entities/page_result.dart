import 'package:equatable/equatable.dart';

/// Resultado paginado de dominio. Lo devuelven el repositorio y los casos de
/// uso de listado/búsqueda, sin exponer el modelo de respuesta.
class PageResult<T> extends Equatable {
  final List<T> items;
  final int page;
  final bool hasMore;

  const PageResult({
    required this.items,
    required this.page,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [items, page, hasMore];
}
