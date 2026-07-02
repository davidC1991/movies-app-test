import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../atoms/app_chip.dart';
import '../atoms/app_text.dart';
import '../atoms/gradient_scrim.dart';
import '../atoms/rating_badge.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';

/// Cabecera del detalle de película/serie estilo Netflix: backdrop a pantalla
/// completa con scrim, y sobre él el póster, el título, el rating, los géneros
/// y metadatos (año, duración).
///
/// Agnóstica de dominio: recibe URLs ya construidas y datos primitivos.
class DetailHeader extends StatelessWidget {
  /// URL del fondo panorámica (backdrop). `null` → usa el póster de fondo.
  final String? backdropUrl;
  final String? posterUrl;
  final String title;
  final double? rating;

  /// Metadatos cortos ya formateados (p. ej. "2024", "2h 15m").
  final List<String> metadata;

  /// Nombres de géneros a mostrar como chips.
  final List<String> genres;

  const DetailHeader({
    super.key,
    required this.backdropUrl,
    required this.posterUrl,
    required this.title,
    this.rating,
    this.metadata = const [],
    this.genres = const [],
  });

  @override
  Widget build(BuildContext context) {
    final String? bgUrl = backdropUrl ?? posterUrl;

    return SizedBox(
      height: 420,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Backdrop de fondo.
          if (bgUrl != null)
            CachedNetworkImage(
              imageUrl: bgUrl,
              fit: BoxFit.cover,
              errorWidget: (_, _, _) => const ColoredBox(color: AppColors.surface),
            )
          else
            const ColoredBox(color: AppColors.surface),

          // Velo para legibilidad y fusión con el fondo de la app.
          const GradientScrim.backdrop(),

          // Contenido inferior: póster + info.
          Positioned(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: AppSpacing.lg,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _Poster(url: posterUrl),
                const SizedBox(width: AppSpacing.lg),
                Expanded(child: _Info(
                  title: title,
                  rating: rating,
                  metadata: metadata,
                  genres: genres,
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Poster extends StatelessWidget {
  final String? url;
  const _Poster({required this.url});

  @override
  Widget build(BuildContext context) {
    const double w = 110;
    const double h = w * 3 / 2;
    return ClipRRect(
      borderRadius: AppRadius.brMd,
      child: DecoratedBox(
        decoration: const BoxDecoration(boxShadow: AppShadows.card),
        child: SizedBox(
          width: w,
          height: h,
          child: url == null
              ? const ColoredBox(
                  color: AppColors.surfaceElevated,
                  child: Icon(Icons.movie_outlined, color: AppColors.textTertiary),
                )
              : CachedNetworkImage(
                  imageUrl: url!,
                  fit: BoxFit.cover,
                  errorWidget: (_, _, _) => const ColoredBox(
                    color: AppColors.surfaceElevated,
                    child: Icon(Icons.movie_outlined, color: AppColors.textTertiary),
                  ),
                ),
        ),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  final String title;
  final double? rating;
  final List<String> metadata;
  final List<String> genres;

  const _Info({
    required this.title,
    required this.rating,
    required this.metadata,
    required this.genres,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText(title, variant: AppTextVariant.headlineLarge, maxLines: 3),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            if (rating != null && rating! > 0) ...[
              RatingBadge(value: rating!),
              const SizedBox(width: AppSpacing.md),
            ],
            if (metadata.isNotEmpty)
              Expanded(
                child: AppText(
                  metadata.join('  ·  '),
                  variant: AppTextVariant.bodySmall,
                  maxLines: 1,
                ),
              ),
          ],
        ),
        if (genres.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [for (final g in genres) AppChip(label: g)],
          ),
        ],
      ],
    );
  }
}
