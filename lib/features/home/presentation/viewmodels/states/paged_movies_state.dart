import 'package:equatable/equatable.dart';

import '../../../domain/entities/movie.dart';
import '../../../domain/entities/page_result.dart';

/// Estado de datos de un listado paginado que exponen los ViewModels
/// (dentro de `UIState.success`). Acumula los ítems de todas las páginas
/// cargadas y centraliza las transiciones de scroll infinito.
class PagedMoviesState extends Equatable {
  final List<Movie> items;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;
  final bool loadMoreError;

  const PagedMoviesState({
    required this.items,
    required this.page,
    required this.hasMore,
    this.isLoadingMore = false,
    this.loadMoreError = false,
  });

  /// Primera página a partir de un `PageResult` del dominio.
  factory PagedMoviesState.fromPage(PageResult<Movie> result) => PagedMoviesState(
        items: result.items,
        page: result.page,
        hasMore: result.hasMore,
      );

  /// Marca el inicio de la carga de la siguiente página (limpia error previo).
  PagedMoviesState startLoadingMore() =>
      copyWith(isLoadingMore: true, loadMoreError: false);

  /// Anexa la página recibida y limpia los flags de carga/error.
  PagedMoviesState appendPage(PageResult<Movie> result) => copyWith(
        items: [...items, ...result.items],
        page: result.page,
        hasMore: result.hasMore,
        isLoadingMore: false,
        loadMoreError: false,
      );

  /// Marca un fallo al cargar la siguiente página (permite reintentar).
  PagedMoviesState failLoadingMore() =>
      copyWith(isLoadingMore: false, loadMoreError: true);

  PagedMoviesState copyWith({
    List<Movie>? items,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
    bool? loadMoreError,
  }) {
    return PagedMoviesState(
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
