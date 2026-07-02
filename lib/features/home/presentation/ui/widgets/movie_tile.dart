import 'package:flutter/material.dart';

import '../../../domain/entities/movie.dart';
import 'poster_image.dart';

/// Ítem del listado: póster + título + calificación.
class MovieTile extends StatelessWidget {
  final Movie movie;

  const MovieTile({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: PosterImage(posterPath: movie.posterPath),
      title: Text(movie.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Row(
        children: [
          const Icon(Icons.star, size: 16, color: Colors.amber),
          const SizedBox(width: 4),
          Text(movie.voteAverage.toStringAsFixed(1)),
        ],
      ),
    );
  }
}
