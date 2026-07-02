/// Barrel del Design System (estética Netflix / Dark Mode OLED).
///
/// Punto de entrada único: `import 'package:movies/design_system/design_system.dart';`
/// expone tokens (theme), átomos, moléculas y organismos. Construido con
/// Atomic Design y agnóstico de dominio (una tarjeta sirve para película o
/// serie). No importa nada de `features/`.
library;

// --- Theme (tokens + ThemeData) ---
export 'theme/app_colors.dart';
export 'theme/app_spacing.dart';
export 'theme/app_radius.dart';
export 'theme/app_typography.dart';
export 'theme/app_durations.dart';
export 'theme/app_shadows.dart';
export 'theme/app_theme.dart';

// --- Atoms ---
export 'atoms/app_text.dart';
export 'atoms/rating_badge.dart';
export 'atoms/app_icon_button.dart';
export 'atoms/app_chip.dart';
export 'atoms/app_spinner.dart';
export 'atoms/shimmer.dart';
export 'atoms/gradient_scrim.dart';

// --- Molecules ---
export 'molecules/debounced_search_bar.dart';
export 'molecules/media_card.dart';
export 'molecules/section_header.dart';
export 'molecules/empty_state.dart';
export 'molecules/error_state.dart';

// --- Organisms ---
export 'organisms/media_carousel.dart';
export 'organisms/catalog_search_app_bar.dart';
export 'organisms/detail_header.dart';
