import 'package:flutter/widgets.dart';

/// Escala de radios de borde del design system.
///
/// Netflix usa esquinas ligeramente redondeadas en pósters/tarjetas y
/// elementos tipo "pill" para chips. Radios contenidos para una estética
/// premium y sobria.
abstract final class AppRadius {
  static const double sm = 4;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 16;
  static const double pill = 999;

  // Helpers `BorderRadius` listos para usar (evita reconstruirlos en cada widget).
  static const BorderRadius brSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius brMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius brLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius brXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius brPill = BorderRadius.all(Radius.circular(pill));
}
