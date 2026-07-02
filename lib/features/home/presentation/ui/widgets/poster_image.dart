import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../../core/api/api_config.dart';

/// Muestra el póster de una película desde su `posterPath`, con cacheo,
/// placeholder de carga y fallback si no hay imagen o falla.
class PosterImage extends StatelessWidget {
  final String? posterPath;
  final double width;
  final double height;

  const PosterImage({
    super.key,
    required this.posterPath,
    this.width = 56,
    this.height = 84,
  });

  @override
  Widget build(BuildContext context) {
    final url = ApiConfig.posterUrl(posterPath);
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: width,
        height: height,
        child: url == null
            ? _placeholder(context)
            : CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (context, url) => _placeholder(context),
                errorWidget: (context, url, error) => _placeholder(context),
              ),
      ),
    );
  }

  Widget _placeholder(BuildContext context) => Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Icon(Icons.movie_outlined, size: 28),
      );
}
