import 'package:flutter/material.dart';

import 'navigation/app_router.dart';
import 'navigation/route_paths.dart';

/// Widget raíz de la app. Navega a través del `FluroRouter` global
/// (no navegación hardcodeada).
class MoviesApp extends StatelessWidget {
  const MoviesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movies',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo), useMaterial3: true),
      initialRoute: RoutePaths.home,
      onGenerateRoute: AppRouter.router.generator,
    );
  }
}
