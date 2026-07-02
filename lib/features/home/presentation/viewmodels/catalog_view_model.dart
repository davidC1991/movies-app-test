import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/remote/error_message.dart';
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
      state = UISuccess(
        CatalogState(
          popular: PagedMovies.fromPage(results[0]),
          topRated: PagedMovies.fromPage(results[1]),
        ),
      );
    } catch (e) {
      state = UIFail(messageFromError(e));
    }
  }

  /// Reintenta la carga inicial (tras un error).
  Future<void> retry() => _load();

  /// Carga automática (scroll) de la siguiente página de cada categoría.
  Future<void> loadMorePopular() => _loadMore(isPopular: true);
  Future<void> loadMoreTopRated() => _loadMore(isPopular: false);

  /// Reintento explícito del usuario tras un fallo de paginación (fuerza pese
  /// a `loadMoreError`).
  Future<void> retryLoadMorePopular() => _loadMore(isPopular: true, force: true);
  Future<void> retryLoadMoreTopRated() => _loadMore(isPopular: false, force: true);

  Future<void> _loadMore({required bool isPopular, bool force = false}) async {
    final current = state;
    if (current is! UISuccess<CatalogState>) return;
    final paged = isPopular ? current.data.popular : current.data.topRated;
    if (!paged.hasMore || paged.isLoadingMore) return;
    // Sin auto-reintento tras un fallo: se espera acción del usuario para no
    // martillar el endpoint en cada frame de scroll.
    if (paged.loadMoreError && !force) return;

    state = UISuccess(_patch(current.data, isPopular, paged.startLoadingMore()));
    try {
      final useCases = ref.read(movieUseCasesProvider);
      final result = isPopular
          ? await useCases.getPopular(page: paged.page + 1)
          : await useCases.getTopRated(page: paged.page + 1);
      final now = state;
      if (now is! UISuccess<CatalogState>) return;
      final base = isPopular ? now.data.popular : now.data.topRated;
      state = UISuccess(_patch(now.data, isPopular, base.appendPage(result)));
    } catch (_) {
      final now = state;
      if (now is! UISuccess<CatalogState>) return;
      final base = isPopular ? now.data.popular : now.data.topRated;
      state = UISuccess(_patch(now.data, isPopular, base.failLoadingMore()));
    }
  }

  /// Devuelve un `CatalogState` con la categoría indicada reemplazada.
  CatalogState _patch(CatalogState data, bool isPopular, PagedMovies updated) =>
      isPopular ? data.copyWith(popular: updated) : data.copyWith(topRated: updated);
}
