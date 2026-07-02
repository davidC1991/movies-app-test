import 'package:flutter/material.dart';

import '../atoms/app_icon_button.dart';
import '../atoms/app_spinner.dart';
import '../atoms/shimmer.dart';
import '../molecules/media_card.dart';
import '../molecules/section_header.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// Modelo mínimo para alimentar un ítem del carrusel sin acoplarse a las
/// entidades de `features/`. El llamador mapea su `Movie`/`Serie` a esto.
class MediaCardData {
  final String? posterUrl;
  final String title;
  final double? rating;
  final VoidCallback? onTap;

  const MediaCardData({
    required this.posterUrl,
    required this.title,
    this.rating,
    this.onTap,
  });
}

/// Fila horizontal desplazable con título de sección, estilo Netflix.
/// Reutilizable para "Popular", "Top Rated" o cualquier colección.
///
/// La paginación (scroll infinito) es responsabilidad propia del carrusel: al
/// acercarse al final del desplazamiento horizontal invoca [onEndReached], y
/// muestra un footer de carga ([isLoadingMore]) o de reintento
/// ([loadMoreFailed] + [onRetryLoadMore]) al final de la fila.
class MediaCarousel extends StatelessWidget {
  final String title;
  final List<MediaCardData> items;
  final double cardWidth;
  final bool showCardTitle;

  /// Acción del encabezado (p. ej. "Ver todo").
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Se invoca al acercarse al final de la fila (para cargar más).
  final VoidCallback? onEndReached;

  /// Muestra un spinner de "cargando más" al final de la fila.
  final bool isLoadingMore;

  /// Muestra un botón de reintento al final de la fila (fallo de paginación).
  final bool loadMoreFailed;
  final VoidCallback? onRetryLoadMore;

  const MediaCarousel({
    super.key,
    required this.title,
    required this.items,
    this.cardWidth = 120,
    this.showCardTitle = false,
    this.actionLabel,
    this.onAction,
    this.onEndReached,
    this.isLoadingMore = false,
    this.loadMoreFailed = false,
    this.onRetryLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    // Altura: póster 2:3 + (título opcional bajo la tarjeta).
    final double posterHeight = cardWidth * 3 / 2;
    final double rowHeight = posterHeight + (showCardTitle ? 52 : 0);
    final bool showTrailing = isLoadingMore || loadMoreFailed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title, actionLabel: actionLabel, onAction: onAction),
        SizedBox(
          height: rowHeight,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (onEndReached != null &&
                  notification.metrics.axis == Axis.horizontal &&
                  notification.metrics.pixels >=
                      notification.metrics.maxScrollExtent - 300) {
                onEndReached!();
              }
              return false;
            },
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: items.length + (showTrailing ? 1 : 0),
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
              itemBuilder: (context, index) {
                if (index >= items.length) {
                  return _CarouselTrailing(
                    height: posterHeight,
                    isLoading: isLoadingMore,
                    onRetry: loadMoreFailed ? onRetryLoadMore : null,
                  );
                }
                final MediaCardData item = items[index];
                return MediaCard(
                  key: ValueKey('${title}_$index'),
                  posterUrl: item.posterUrl,
                  title: item.title,
                  rating: item.rating,
                  onTap: item.onTap,
                  width: cardWidth,
                  showTitle: showCardTitle,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Celda final del carrusel: spinner de carga o botón de reintento.
class _CarouselTrailing extends StatelessWidget {
  final double height;
  final bool isLoading;
  final VoidCallback? onRetry;

  const _CarouselTrailing({
    required this.height,
    required this.isLoading,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: height,
      child: Center(
        child: isLoading
            ? const AppSpinner(size: 24)
            : onRetry != null
                ? AppIconButton(
                    icon: Icons.refresh,
                    semanticLabel: 'Reintentar',
                    onPressed: onRetry,
                  )
                : const SizedBox.shrink(),
      ),
    );
  }
}

/// Placeholder de carga (shimmer) con la misma métrica que [MediaCarousel].
/// Úsalo mientras se resuelve el primer request.
class MediaCarouselSkeleton extends StatelessWidget {
  final double cardWidth;
  final int itemCount;

  const MediaCarouselSkeleton({
    super.key,
    this.cardWidth = 120,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    final double posterHeight = cardWidth * 3 / 2;

    return Shimmer(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: SkeletonBox(width: 160, height: 20),
            ),
            SizedBox(
              height: posterHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                itemCount: itemCount,
                separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
                itemBuilder: (_, _) => SkeletonBox(
                  width: cardWidth,
                  height: posterHeight,
                  borderRadius: AppRadius.brMd,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
