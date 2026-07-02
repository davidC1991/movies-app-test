import 'package:equatable/equatable.dart';

import 'paged_movies_state.dart';

/// Datos del catálogo: dos colecciones paginadas independientes (Popular y
/// Top Rated) que se muestran como filas estilo Netflix.
class CatalogState extends Equatable {
  final PagedMoviesState popular;
  final PagedMoviesState topRated;

  const CatalogState({required this.popular, required this.topRated});

  CatalogState copyWith({PagedMoviesState? popular, PagedMoviesState? topRated}) =>
      CatalogState(
        popular: popular ?? this.popular,
        topRated: topRated ?? this.topRated,
      );

  @override
  List<Object?> get props => [popular, topRated];
}
