import 'package:fluro/fluro.dart';

import '../../../../navigation/route_paths.dart';
import '../ui/home_screen.dart';

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
  }
}
