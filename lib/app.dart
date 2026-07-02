import 'package:flutter/material.dart';

import 'design_system/theme/app_theme.dart';
import 'navigation/app_router.dart';
import 'navigation/route_paths.dart';

/// Widget raíz de la app. Navega a través del `FluroRouter` global
/// (no navegación hardcodeada) y aplica el tema del Design System (Netflix
/// dark). La app es dark-only por diseño (estética cinematográfica OLED).
class MoviesApp extends StatelessWidget {
  const MoviesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movies',
      // Dark-only: `theme` y `darkTheme` apuntan al mismo tema para que
      // cualquier `themeMode` del sistema muestre siempre la estética Netflix.
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      initialRoute: RoutePaths.home,
      onGenerateRoute: AppRouter.router.generator,
    );
  }
}
