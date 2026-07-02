import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/remote/error_message.dart';
import '../../../../core/state/ui_state.dart';
import '../providers/home_providers.dart';
import 'paged_movies.dart';

/// Término de búsqueda activo. Cadena vacía = modo catálogo (vista por
/// defecto). Lo mantiene el `SearchViewModel` (única fuente de verdad del
/// modo); la UI sólo lo **lee** para decidir qué vista mostrar.
final searchQueryProvider = StateProvider<String>((ref) => '');

/// ViewModel (MVVM) de la búsqueda. La barra de búsqueda ya aplica el debounce
/// (400 ms) y sólo notifica términos no vacíos; aquí se ejecuta el request,
/// se pagina y se restaura la vista al limpiar. Estado inicial = éxito vacío
/// (idle), que la UI interpreta como "sin búsqueda".
final searchViewModelProvider =
    NotifierProvider<SearchViewModel, UIState<PagedMovies>>(SearchViewModel.new);

class SearchViewModel extends Notifier<UIState<PagedMovies>> {
  /// Término de la búsqueda en curso. Se usa para descartar respuestas
  /// obsoletas cuando el usuario cambia de término durante un request.
  String _activeTerm = '';

  @override
  UIState<PagedMovies> build() =>
      const UISuccess(PagedMovies(items: [], page: 0, hasMore: false));

  /// Ejecuta una búsqueda por [rawTerm]. Un término en blanco se trata como
  /// "sin búsqueda" (restaura la vista por defecto). Actualiza además el modo
  /// (`searchQueryProvider`) para que la UI muestre los resultados.
  Future<void> search(String rawTerm) async {
    final term = rawTerm.trim();
    if (term.isEmpty) {
      clear();
      return;
    }
    _activeTerm = term;
    ref.read(searchQueryProvider.notifier).state = term;
    state = const UILoading();
    try {
      final result = await ref.read(movieUseCasesProvider).search(term, page: 1);
      // Búsquedas encadenadas: prevalece el último término escrito.
      if (_activeTerm != term) return;
      state = UISuccess(PagedMovies.fromPage(result));
    } catch (error) {
      if (_activeTerm != term) return;
      state = UIFail(messageFromError(error));
    }
  }

  /// Restaura el modo catálogo (vista por defecto): limpia el término activo,
  /// el modo (`searchQueryProvider`) y el estado idle.
  void clear() {
    _activeTerm = '';
    ref.read(searchQueryProvider.notifier).state = '';
    state = const UISuccess(PagedMovies(items: [], page: 0, hasMore: false));
  }

  /// Reintenta la búsqueda del término actual (tras un error).
  Future<void> retry() => search(_activeTerm);

  /// Carga automática (scroll) de la siguiente página de resultados.
  Future<void> loadMore() => _loadMore();

  /// Reintento explícito del usuario tras un fallo de paginación.
  Future<void> retryLoadMore() => _loadMore(force: true);

  Future<void> _loadMore({bool force = false}) async {
    if (_activeTerm.isEmpty) return;
    final currentState = state;
    if (currentState is! UISuccess<PagedMovies>) return;
    final currentPage = currentState.data;
    if (!currentPage.hasMore || currentPage.isLoadingMore) return;
    if (currentPage.loadMoreError && !force) return;

    final term = _activeTerm;
    state = UISuccess(currentPage.startLoadingMore());
    try {
      final result = await ref
          .read(movieUseCasesProvider)
          .search(term, page: currentPage.page + 1);
      // El término pudo cambiar durante el await: descarta la página obsoleta.
      if (_activeTerm != term) return;
      final latestState = state;
      if (latestState is! UISuccess<PagedMovies>) return;
      state = UISuccess(latestState.data.appendPage(result));
    } catch (_) {
      if (_activeTerm != term) return;
      final latestState = state;
      if (latestState is UISuccess<PagedMovies>) {
        state = UISuccess(latestState.data.failLoadingMore());
      }
    }
  }
}
