import 'package:equatable/equatable.dart';

import '../../domain/entities/movie.dart';

/// Estado de datos del listado paginado que expone el `HomeViewModel`
/// (dentro de `UIState.success`). Acumula los ítems de todas las páginas cargadas.
class PagedMovies extends Equatable {
  final List<Movie> items;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;
  final bool loadMoreError;

  const PagedMovies({
    required this.items,
    required this.page,
    required this.hasMore,
    this.isLoadingMore = false,
    this.loadMoreError = false,
  });

  PagedMovies copyWith({
    List<Movie>? items,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
    bool? loadMoreError,
  }) {
    return PagedMovies(
      items: items ?? this.items,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreError: loadMoreError ?? this.loadMoreError,
    );
  }

  @override
  List<Object?> get props => [items, page, hasMore, isLoadingMore, loadMoreError];
}
