import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movies/design_system/design_system.dart';

import '../../../../../core/state/ui_state.dart';
import '../../utils/media_card_mapper.dart';
import '../../viewmodels/states/paged_movies_state.dart';
import '../../viewmodels/search_view_model.dart';

/// Contenido de los resultados de búsqueda (sliver): grilla de pósters con sus
/// estados de carga / sin resultados / error, y footer de paginación.
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
      UISuccess(:final data) => _ResultsList(
          paged: data,
          onTapMovie: onTapMovie,
          onRetryLoadMore: notifier.retryLoadMore,
        ),
    };
  }
}

/// Grilla de resultados + footer de paginación (carga/reintentar).
class _ResultsList extends StatelessWidget {
  final PagedMoviesState paged;
  final void Function(int movieId) onTapMovie;
  final VoidCallback onRetryLoadMore;

  const _ResultsList({
    required this.paged,
    required this.onTapMovie,
    required this.onRetryLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double cardWidth =
        (screenWidth - AppSpacing.lg * 2 - AppSpacing.md * 2) / 3;

    return SliverMainAxisGroup(
      slivers: [
        SliverPadding(
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
                // Reutiliza el mapeo Movie → tarjeta (posterPath → URL) del
                // mismo helper que usa el catálogo, para no duplicarlo.
                final card = movie.toCardData(onTap: () => onTapMovie(movie.id));
                return MediaCard(
                  posterUrl: card.posterUrl,
                  title: card.title,
                  rating: card.rating,
                  onTap: card.onTap,
                  width: cardWidth,
                  showTitle: false,
                );
              },
              childCount: paged.items.length,
            ),
          ),
        ),
        if (paged.isLoadingMore || paged.loadMoreError)
          SliverToBoxAdapter(
            child: _GridFooter(
              isLoading: paged.isLoadingMore,
              onRetry: paged.loadMoreError ? onRetryLoadMore : null,
            ),
          ),
      ],
    );
  }
}

/// Footer de la grilla: spinner de "cargando más" o botón de reintento.
class _GridFooter extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onRetry;

  const _GridFooter({required this.isLoading, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Center(
        child: isLoading
            ? const AppSpinner()
            : onRetry != null
                ? FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  )
                : const SizedBox.shrink(),
      ),
    );
  }
}
