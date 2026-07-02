import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movies/design_system/design_system.dart';

import '../../../../../core/state/ui_state.dart';
import '../../../domain/entities/movie.dart';
import '../../viewmodels/catalog_view_model.dart';
import '../../viewmodels/media_card_mapper.dart';
import '../../viewmodels/paged_movies.dart';

/// Contenido del catálogo (sliver): filas "Populares" y "Mejor valoradas"
/// con sus estados de carga / error. Cada fila pagina en horizontal.
class CatalogView extends ConsumerWidget {
  final void Function(int movieId) onTapMovie;

  const CatalogView({super.key, required this.onTapMovie});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(catalogViewModelProvider);
    final notifier = ref.read(catalogViewModelProvider.notifier);

    return switch (state) {
      UILoading() => const SliverFillRemaining(
          hasScrollBody: false,
          child: _CatalogSkeleton(),
        ),
      UIFail(:final message) => SliverFillRemaining(
          hasScrollBody: false,
          child: ErrorState(message: message, onRetry: notifier.retry),
        ),
      UISuccess(:final data) => SliverPadding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _CategoryRow(
                title: 'Populares',
                paged: data.popular,
                onLoadMore: notifier.loadMorePopular,
                onRetryLoadMore: notifier.retryLoadMorePopular,
                onTapMovie: onTapMovie,
              ),
              const SizedBox(height: AppSpacing.xl),
              _CategoryRow(
                title: 'Mejor valoradas',
                paged: data.topRated,
                onLoadMore: notifier.loadMoreTopRated,
                onRetryLoadMore: notifier.retryLoadMoreTopRated,
                onTapMovie: onTapMovie,
              ),
            ]),
          ),
        ),
    };
  }
}

/// Una categoría del catálogo: delega en `MediaCarousel` la paginación
/// (scroll infinito) y el footer de carga/reintento.
class _CategoryRow extends StatelessWidget {
  final String title;
  final PagedMovies paged;
  final VoidCallback onLoadMore;
  final VoidCallback onRetryLoadMore;
  final void Function(int movieId) onTapMovie;

  const _CategoryRow({
    required this.title,
    required this.paged,
    required this.onLoadMore,
    required this.onRetryLoadMore,
    required this.onTapMovie,
  });

  @override
  Widget build(BuildContext context) {
    return MediaCarousel(
      title: title,
      items: [
        for (final Movie movie in paged.items)
          movie.toCardData(onTap: () => onTapMovie(movie.id)),
      ],
      onEndReached: onLoadMore,
      isLoadingMore: paged.isLoadingMore,
      loadMoreFailed: paged.loadMoreError,
      onRetryLoadMore: onRetryLoadMore,
    );
  }
}

/// Esqueleto de carga del catálogo (shimmer) con la métrica de los carruseles.
class _CatalogSkeleton extends StatelessWidget {
  const _CatalogSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MediaCarouselSkeleton(),
          SizedBox(height: AppSpacing.xl),
          MediaCarouselSkeleton(),
        ],
      ),
    );
  }
}
