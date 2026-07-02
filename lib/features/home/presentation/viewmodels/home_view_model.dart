import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/remote/api_response.dart';
import '../../../../core/state/ui_state.dart';
import '../providers/home_providers.dart';
import 'paged_movies.dart';

/// ViewModel (MVVM) del listado Popular. Carga la primera página al construirse
/// y soporta scroll infinito. Expone `UIState<PagedMovies>` y maneja errores
/// con try/catch (el repositorio lanza en fallo).
final homeViewModelProvider =
    NotifierProvider<HomeViewModel, UIState<PagedMovies>>(HomeViewModel.new);

class HomeViewModel extends Notifier<UIState<PagedMovies>> {
  @override
  UIState<PagedMovies> build() {
    _loadFirstPage();
    return const UILoading();
  }

  Future<void> _loadFirstPage() async {
    state = const UILoading();
    try {
      final result = await ref.read(movieUseCasesProvider).getPopular(page: 1);
      state = UISuccess(
        PagedMovies(items: result.items, page: result.page, hasMore: result.hasMore),
      );
    } catch (e) {
      state = UIFail(_messageFrom(e));
    }
  }

  /// Reintenta la carga inicial (tras un error).
  Future<void> retry() => _loadFirstPage();

  /// Carga la siguiente página y la anexa (scroll infinito).
  Future<void> loadMore() async {
    final current = state;
    if (current is! UISuccess<PagedMovies>) return;
    final paged = current.data;
    if (!paged.hasMore || paged.isLoadingMore) return;

    state = UISuccess(paged.copyWith(isLoadingMore: true, loadMoreError: false));
    try {
      final result = await ref.read(movieUseCasesProvider).getPopular(page: paged.page + 1);
      state = UISuccess(
        paged.copyWith(
          items: [...paged.items, ...result.items],
          page: result.page,
          hasMore: result.hasMore,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      // Mantiene los items ya cargados; marca error de paginación para reintento.
      state = UISuccess(paged.copyWith(isLoadingMore: false, loadMoreError: true));
    }
  }

  String _messageFrom(Object e) {
    if (e is ErrorApiResponse) return e.httpErrorMessage;
    return 'Ocurrió un error inesperado. Intenta de nuevo.';
  }
}
