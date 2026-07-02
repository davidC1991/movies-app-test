import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movies/design_system/design_system.dart';

import '../../../../core/api/api_config.dart';
import '../../../../core/state/ui_state.dart';
import '../../domain/entities/movie_detail.dart';
import '../viewmodels/movie_detail_view_model.dart';

/// Pantalla de detalle de una película: cabecera con backdrop + póster,
/// título, rating, géneros y sinopsis. Estados de carga / error con retry.
class MovieDetailScreen extends ConsumerWidget {
  final int movieId;

  const MovieDetailScreen({super.key, required this.movieId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final UIState<MovieDetail> state = ref.watch(movieDetailViewModelProvider(movieId));

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: switch (state) {
              UILoading() => const Center(child: AppSpinner()),
              UIFail(:final message) => ErrorState(
                  message: message,
                  onRetry: () =>
                      ref.read(movieDetailViewModelProvider(movieId).notifier).retry(),
                ),
              UISuccess(:final data) => _DetailContent(detail: data),
            },
          ),
          const _BackButton(),
        ],
      ),
    );
  }
}

/// Botón de volver superpuesto (estilo Netflix), respetando el área segura.
class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: AppIconButton(
            icon: Icons.arrow_back,
            semanticLabel: 'Volver',
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
      ),
    );
  }
}

/// Cuerpo del detalle cuando hay datos: cabecera + sinopsis.
class _DetailContent extends StatelessWidget {
  final MovieDetail detail;

  const _DetailContent({required this.detail});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: DetailHeader(
            backdropUrl: ApiConfig.backdropUrl(detail.backdropPath),
            posterUrl: ApiConfig.posterUrl(detail.posterPath),
            title: detail.title,
            rating: detail.voteAverage,
            metadata: _metadata(detail),
            genres: [for (final g in detail.genres) g.label],
          ),
        ),
        if (detail.overview.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText('Sinopsis', variant: AppTextVariant.titleLarge),
                  const SizedBox(height: AppSpacing.sm),
                  AppText(detail.overview, variant: AppTextVariant.bodyMedium),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Metadatos cortos ya formateados para la cabecera (año, duración).
List<String> _metadata(MovieDetail detail) {
  final List<String> data = <String>[];
  final String? date = detail.releaseDate;
  if (date != null && date.length >= 4) data.add(date.substring(0, 4));
  final int? runtime = detail.runtime;
  if (runtime != null && runtime > 0) data.add(_formatRuntime(runtime));
  return data;
}

/// Formatea una duración en minutos como "2h 15m" (o "45m").
String _formatRuntime(int minutes) {
  final int hours = minutes ~/ 60;
  final int mins = minutes % 60;
  if (hours == 0) return '${mins}m';
  return '${hours}h ${mins}m';
}
