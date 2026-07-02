import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movies/design_system/design_system.dart';

import '../../../../navigation/route_paths.dart';
import '../viewmodels/search_view_model.dart';
import 'widgets/catalog_view.dart';
import 'widgets/search_results_view.dart';

/// Pantalla principal: catálogo por categorías (Populares / Mejor valoradas)
/// con barra de búsqueda superior. Al buscar, la vista se reemplaza por los
/// resultados; al limpiar/volver, se restaura el catálogo.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Paginación vertical de los resultados de búsqueda (el catálogo pagina en
  /// horizontal, dentro de cada carrusel).
  void _onScroll() {
    if (ref.read(searchQueryProvider).isEmpty) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      ref.read(searchViewModelProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String term) {
    // El ViewModel decide (término en blanco = restaurar catálogo) y mantiene
    // el modo (`searchQueryProvider`).
    ref.read(searchViewModelProvider.notifier).search(term);
  }

  void _onSearchCleared() {
    ref.read(searchViewModelProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          CatalogSearchAppBar(
            title: 'Películas',
            onSearchChanged: _onSearchChanged,
            onSearchCleared: _onSearchCleared,
          ),
          const _HomeContent(),
        ],
      ),
    );
  }
}

/// Elige el contenido según el modo: catálogo (sin búsqueda) o resultados.
class _HomeContent extends ConsumerWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);
    if (query.isEmpty) {
      return CatalogView(onTapMovie: (id) => _openDetail(context, id));
    }
    return SearchResultsView(onTapMovie: (id) => _openDetail(context, id));
  }

  void _openDetail(BuildContext context, int movieId) {
    // Cierra el teclado (si venía de la búsqueda) antes de entrar al detalle.
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.of(context).pushNamed(RoutePaths.movieDetailOf(movieId));
  }
}
