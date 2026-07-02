import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movies/design_system/design_system.dart';

import '../../../../../core/api/api_config.dart';
import '../../../../../core/state/ui_state.dart';
import '../../viewmodels/paged_movies.dart';
import '../../viewmodels/search_view_model.dart';

/// Contenido de los resultados de búsqueda (sliver): grilla de pósters con sus
/// estados de carga / sin resultados / error.
class SearchResultsView extends ConsumerWidget {
  final void Function(int movieId) onTapMovie;

  const SearchResultsView({super.key, required this.onTapMovie});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(searchViewModelProvider);
    final notifier = ref.read(searchViewModelProvider.notifier);

    return switch (state) {
      UILoading() => const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: AppSpinner()),
        ),
      UIFail(:final message) => SliverFillRemaining(
          hasScrollBody: false,
          child: ErrorState(message: message, onRetry: notifier.retry),
        ),
      UISuccess(:final data) when data.items.isEmpty => const SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyState(
            title: 'Sin resultados',
            message: 'No encontramos películas con ese nombre.',
          ),
        ),
      UISuccess(:final data) => _ResultsGrid(paged: data, onTapMovie: onTapMovie),
    };
  }
}

/// Grilla de pósters de los resultados. El ancho de tarjeta se calcula para
/// llenar tres columnas manteniendo el ratio de póster 2:3.
class _ResultsGrid extends StatelessWidget {
  final PagedMovies paged;
  final void Function(int movieId) onTapMovie;

  const _ResultsGrid({required this.paged, required this.onTapMovie});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double cardWidth =
        (screenWidth - AppSpacing.lg * 2 - AppSpacing.md * 2) / 3;

    return SliverPadding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.lg,
          // Póster 2:3 (sin título bajo la tarjeta).
          childAspectRatio: 2 / 3,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final movie = paged.items[index];
            return MediaCard(
              posterUrl: ApiConfig.posterUrl(movie.posterPath),
              title: movie.title,
              rating: movie.voteAverage,
              width: cardWidth,
              showTitle: false,
              onTap: () => onTapMovie(movie.id),
            );
          },
          childCount: paged.items.length,
        ),
      ),
    );
  }
}
