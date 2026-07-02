import 'package:flutter/widgets.dart';
import 'package:movies/design_system/design_system.dart';

import '../../../../core/api/api_config.dart';
import '../../domain/entities/movie.dart';

/// Mapea entidades de dominio (`Movie`) al modelo de presentación del design
/// system (`MediaCardData`). El mapeo `posterPath → posterUrl` (vía
/// `ApiConfig`) vive aquí, del lado del llamador, para que el design system se
/// mantenga agnóstico de dominio y de la API.
extension MovieMediaCardX on Movie {
  MediaCardData toCardData({VoidCallback? onTap}) => MediaCardData(
        posterUrl: ApiConfig.posterUrl(posterPath),
        title: title,
        rating: voteAverage,
        onTap: onTap,
      );
}
