import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/remote/error_message.dart';
import '../../../../core/state/ui_state.dart';
import '../providers/home_providers.dart';
import 'paged_movies.dart';

/// Término de búsqueda activo. Cadena vacía = modo catálogo (vista por
/// defecto). Lo actualiza la `HomeScreen` a partir de la barra de búsqueda.
final searchQueryProvider = StateProvider<String>((ref) => '');

/// ViewModel (MVVM) de la búsqueda. La barra de búsqueda ya aplica el debounce
/// (400 ms) y sólo notifica términos no vacíos; aquí se ejecuta el request,
/// se pagina y se restaura la vista al limpiar. Estado inicial = éxito vacío
/// (idle), que la UI interpreta como "sin búsqueda".
final searchViewModelProvider =
    NotifierProvider<SearchViewModel, UIState<PagedMovies>>(SearchViewModel.new);

class SearchViewModel extends Notifier<UIState<PagedMovies>> {
  String _query = '';

  @override
  UIState<PagedMovies> build() =>
      const UISuccess(PagedMovies(items: [], page: 0, hasMore: false));

  /// Ejecuta una búsqueda por [query]. Un término en blanco se trata como
  /// "sin búsqueda" (restaura la vista por defecto).
  Future<void> search(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      clear();
      return;
    }
    _query = q;
    state = const UILoading();
    try {
      final result = await ref.read(movieUseCasesProvider).search(q, page: 1);
      // Búsquedas encadenadas: prevalece el último término escrito.
      if (_query != q) return;
      state = UISuccess(PagedMovies.fromPage(result));
    } catch (e) {
      if (_query != q) return;
      state = UIFail(messageFromError(e));
    }
  }

  /// Restaura el estado idle (vista por defecto = catálogo).
  void clear() {
    _query = '';
    state = const UISuccess(PagedMovies(items: [], page: 0, hasMore: false));
  }

  /// Reintenta la búsqueda del término actual (tras un error).
  Future<void> retry() => search(_query);

  /// Carga automática (scroll) de la siguiente página de resultados.
  Future<void> loadMore() => _loadMore();

  /// Reintento explícito del usuario tras un fallo de paginación.
  Future<void> retryLoadMore() => _loadMore(force: true);

  Future<void> _loadMore({bool force = false}) async {
    if (_query.isEmpty) return;
    final current = state;
    if (current is! UISuccess<PagedMovies>) return;
    final paged = current.data;
    if (!paged.hasMore || paged.isLoadingMore) return;
    if (paged.loadMoreError && !force) return;

    final q = _query;
    state = UISuccess(paged.startLoadingMore());
    try {
      final result = await ref.read(movieUseCasesProvider).search(q, page: paged.page + 1);
      // El término pudo cambiar durante el await: descarta la página obsoleta.
      if (_query != q) return;
      final now = state;
      if (now is! UISuccess<PagedMovies>) return;
      state = UISuccess(now.data.appendPage(result));
    } catch (_) {
      if (_query != q) return;
      final now = state;
      if (now is UISuccess<PagedMovies>) {
        state = UISuccess(now.data.failLoadingMore());
      }
    }
  }
}
