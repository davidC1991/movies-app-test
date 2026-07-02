import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../atoms/rating_badge.dart';
import '../atoms/shimmer.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Tarjeta de póster reutilizable del catálogo (agnóstica de dominio: sirve
/// para película o serie). Muestra el póster con cacheo, un `RatingBadge`
/// opcional y, debajo, el título.
///
/// Recibe **datos primitivos** ([posterUrl] ya construida, [title], [rating])
/// para no acoplarse a entidades de `features/`. La construcción de la URL
/// (p. ej. vía `ApiConfig.posterUrl`) queda del lado del llamador.
class MediaCard extends StatelessWidget {
  /// URL completa del póster. `null` → placeholder.
  final String? posterUrl;
  final String title;

  /// Calificación 0–10 (escala TMDB). `null` → no se muestra badge.
  final double? rating;

  final VoidCallback? onTap;
  final double width;

  /// Muestra el título bajo el póster (en carruseles Netflix suele omitirse).
  final bool showTitle;

  const MediaCard({
    super.key,
    required this.posterUrl,
    required this.title,
    this.rating,
    this.onTap,
    this.width = 120,
    this.showTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    // Ratio de póster estándar TMDB 2:3.
    final double posterHeight = width * 3 / 2;

    return Semantics(
      label: title,
      button: onTap != null,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.brMd,
        child: SizedBox(
          width: width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _Poster(
                url: posterUrl,
                width: width,
                height: posterHeight,
                rating: rating,
              ),
              if (showTitle) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleMedium,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Poster extends StatelessWidget {
  final String? url;
  final double width;
  final double height;
  final double? rating;

  const _Poster({
    required this.url,
    required this.width,
    required this.height,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.brMd,
      child: DecoratedBox(
        decoration: const BoxDecoration(boxShadow: AppShadows.card),
        child: Stack(
          children: [
            SizedBox(
              width: width,
              height: height,
              child: url == null
                  ? const _PosterPlaceholder()
                  : CachedNetworkImage(
                      imageUrl: url!,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => const _PosterSkeleton(),
                      errorWidget: (_, _, _) => const _PosterPlaceholder(),
                    ),
            ),
            if (rating != null && rating! > 0)
              Positioned(
                left: AppSpacing.xs,
                bottom: AppSpacing.xs,
                child: RatingBadge(value: rating!, compact: true),
              ),
          ],
        ),
      ),
    );
  }
}

class _PosterPlaceholder extends StatelessWidget {
  const _PosterPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.surfaceElevated,
      child: Center(
        child: Icon(Icons.movie_outlined, size: 32, color: AppColors.textTertiary),
      ),
    );
  }
}

class _PosterSkeleton extends StatelessWidget {
  const _PosterSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Shimmer(
      child: SkeletonBox(borderRadius: AppRadius.brMd),
    );
  }
}
