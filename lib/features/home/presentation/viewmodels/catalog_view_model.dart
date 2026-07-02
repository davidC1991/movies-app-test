import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/remote/api_response.dart';
import '../../../../core/state/ui_state.dart';
import '../providers/home_providers.dart';
import 'paged_movies.dart';

/// Datos del catálogo: dos colecciones paginadas independientes (Popular y
/// Top Rated) que se muestran como filas estilo Netflix.
class CatalogState extends Equatable {
  final PagedMovies popular;
  final PagedMovies topRated;

  const CatalogState({required this.popular, required this.topRated});

  CatalogState copyWith({PagedMovies? popular, PagedMovies? topRated}) =>
      CatalogState(
        popular: popular ?? this.popular,
        topRated: topRated ?? this.topRated,
      );

  @override
  List<Object?> get props => [popular, topRated];
}

/// ViewModel (MVVM) del catálogo. Carga en paralelo las primeras páginas de
/// Popular y Top Rated y soporta scroll infinito por categoría. Expone
/// `UIState<CatalogState>` y maneja errores con try/catch (el repositorio lanza).
final catalogViewModelProvider =
    NotifierProvider<CatalogViewModel, UIState<CatalogState>>(
        CatalogViewModel.new);

class CatalogViewModel extends Notifier<UIState<CatalogState>> {
  @override
  UIState<CatalogState> build() {
    _load();
    return const UILoading();
  }

  Future<void> _load() async {
    state = const UILoading();
    try {
      final useCases = ref.read(movieUseCasesProvider);
      final results = await Future.wait([
        useCases.getPopular(page: 1),
        useCases.getTopRated(page: 1),
      ]);
      final popular = results[0];
      final topRated = results[1];
      state = UISuccess(
        CatalogState(
          popular: PagedMovies(
              items: popular.items, page: popular.page, hasMore: popular.hasMore),
          topRated: PagedMovies(
              items: topRated.items,
              page: topRated.page,
              hasMore: topRated.hasMore),
        ),
      );
    } catch (e) {
      state = UIFail(_messageFrom(e));
    }
  }

  /// Reintenta la carga inicial (tras un error).
  Future<void> retry() => _load();

  /// Carga la siguiente página de "Populares" y la anexa.
  Future<void> loadMorePopular() =>
      _loadMore(isPopular: true);

  /// Carga la siguiente página de "Mejor valoradas" y la anexa.
  Future<void> loadMoreTopRated() =>
      _loadMore(isPopular: false);

  Future<void> _loadMore({required bool isPopular}) async {
    final current = state;
    if (current is! UISuccess<CatalogState>) return;
    final paged = isPopular ? current.data.popular : current.data.topRated;
    if (!paged.hasMore || paged.isLoadingMore) return;

    state = UISuccess(_patch(current.data, isPopular,
        paged.copyWith(isLoadingMore: true, loadMoreError: false)));

    try {
      final useCases = ref.read(movieUseCasesProvider);
      final result = isPopular
          ? await useCases.getPopular(page: paged.page + 1)
          : await useCases.getTopRated(page: paged.page + 1);
      final now = state;
      if (now is! UISuccess<CatalogState>) return;
      final base = isPopular ? now.data.popular : now.data.topRated;
      state = UISuccess(_patch(
        now.data,
        isPopular,
        base.copyWith(
          items: [...base.items, ...result.items],
          page: result.page,
          hasMore: result.hasMore,
          isLoadingMore: false,
        ),
      ));
    } catch (_) {
      final now = state;
      if (now is! UISuccess<CatalogState>) return;
      final base = isPopular ? now.data.popular : now.data.topRated;
      state = UISuccess(_patch(now.data, isPopular,
          base.copyWith(isLoadingMore: false, loadMoreError: true)));
    }
  }

  /// Devuelve un `CatalogState` con la categoría indicada reemplazada.
  CatalogState _patch(CatalogState data, bool isPopular, PagedMovies updated) =>
      isPopular ? data.copyWith(popular: updated) : data.copyWith(topRated: updated);

  String _messageFrom(Object e) {
    if (e is ErrorApiResponse) return e.httpErrorMessage;
    return 'Ocurrió un error inesperado. Intenta de nuevo.';
  }
}
