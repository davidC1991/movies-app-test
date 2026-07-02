import 'package:fluro/fluro.dart';

import '../features/home/presentation/navigation/home_routes.dart';

/// Router global (Fluro). Agrega las rutas que cada feature expone desde su
/// `presentation/navigation/`. Vive fuera de `core` porque depende de Flutter.
class AppRouter {
  const AppRouter._();

  static final FluroRouter router = FluroRouter();

  /// Registra las rutas de todas las features. Llamar una vez al arrancar.
  static void setup() {
    HomeRoutes.define(router);
  }
}
