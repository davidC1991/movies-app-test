import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/state/ui_state.dart';
import '../viewmodels/home_view_model.dart';
import '../viewmodels/paged_movies.dart';
import 'widgets/movie_tile.dart';

/// Listado de películas populares (TMDB) con scroll infinito y estados
/// carga / éxito / vacío / error.
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

  void _onScroll() {
    // Dispara la carga de la siguiente página al acercarse al final.
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      ref.read(homeViewModelProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Populares')),
      body: switch (state) {
        UILoading() => const Center(child: CircularProgressIndicator()),
        UIFail(:final message) => _ErrorView(
            message: message,
            onRetry: () => ref.read(homeViewModelProvider.notifier).retry(),
          ),
        UISuccess(:final data) => _MovieList(
            data: data,
            scrollController: _scrollController,
            onRetryMore: () => ref.read(homeViewModelProvider.notifier).loadMore(),
          ),
      },
    );
  }
}

class _MovieList extends StatelessWidget {
  final PagedMovies data;
  final ScrollController scrollController;
  final VoidCallback onRetryMore;

  const _MovieList({
    required this.data,
    required this.scrollController,
    required this.onRetryMore,
  });

  @override
  Widget build(BuildContext context) {
    if (data.items.isEmpty) {
      return const Center(child: Text('No hay películas para mostrar'));
    }

    return ListView.builder(
      controller: scrollController,
      itemCount: data.items.length + 1,
      itemBuilder: (context, index) {
        if (index < data.items.length) {
          return MovieTile(movie: data.items[index]);
        }
        return _Footer(data: data, onRetryMore: onRetryMore);
      },
    );
  }
}

class _Footer extends StatelessWidget {
  final PagedMovies data;
  final VoidCallback onRetryMore;

  const _Footer({required this.data, required this.onRetryMore});

  @override
  Widget build(BuildContext context) {
    if (data.loadMoreError) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: TextButton.icon(
            onPressed: onRetryMore,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ),
      );
    }
    if (data.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return const SizedBox(height: 24);
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
