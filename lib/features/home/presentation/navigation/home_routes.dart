import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import 'package:movies/design_system/design_system.dart';

import '../../../../navigation/route_paths.dart';
import '../ui/home_screen.dart';
import '../ui/movie_detail_screen.dart';

/// Rutas hijas del feature `home`. Se exponen al router global (`AppRouter`).
class HomeRoutes {
  const HomeRoutes._();

  /// Registra las rutas del feature en el [router] de Fluro.
  static void define(FluroRouter router) {
    router.define(
      RoutePaths.home,
      handler: Handler(handlerFunc: (context, params) => const HomeScreen()),
      transitionType: TransitionType.fadeIn,
    );

    // Detalle de película: `/movie/:id`.
    router.define(
      '${RoutePaths.movieDetail}/:id',
      handler: Handler(
        handlerFunc: (context, params) {
          final id = int.tryParse(params['id']?.first ?? '');
          // Ruta malformada (`/movie/abc`): no golpear la API con un id inválido.
          if (id == null) {
            return const Scaffold(
              body: EmptyState(icon: Icons.link_off, title: 'Ruta no válida'),
            );
          }
          return MovieDetailScreen(movieId: id);
        },
      ),
      transitionType: TransitionType.cupertino,
    );
  }
}
