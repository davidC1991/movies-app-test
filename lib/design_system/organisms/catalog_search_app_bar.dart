import 'package:flutter/material.dart';

import '../atoms/app_text.dart';
import '../molecules/debounced_search_bar.dart';
import '../theme/app_colors.dart';
import '../theme/app_durations.dart';
import '../theme/app_spacing.dart';

/// AppBar del catálogo estilo Netflix: título de marca + barra de búsqueda
/// con debounce integrada. Pensada como `SliverAppBar` dentro de un
/// `CustomScrollView` para que se pliegue al hacer scroll.
///
/// Delega toda la lógica de búsqueda al ViewModel mediante los callbacks
/// [onSearchChanged] (debounced) y [onSearchCleared].
class CatalogSearchAppBar extends StatelessWidget {
  final String title;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback? onSearchCleared;
  final Duration debounce;

  const CatalogSearchAppBar({
    super.key,
    this.title = 'Películas',
    required this.onSearchChanged,
    this.onSearchCleared,
    this.debounce = AppDurations.searchDebounce,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      floating: true,
      snap: true,
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleSpacing: AppSpacing.lg,
      title: AppText(
        title,
        variant: AppTextVariant.headlineLarge,
        // Acento Netflix en la marca.
        color: AppColors.accent,
      ),
      // La barra de búsqueda vive en el `bottom` para ocupar el ancho completo.
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: DebouncedSearchBar(
            onChanged: onSearchChanged,
            onClear: onSearchCleared,
            debounce: debounce,
          ),
        ),
      ),
    );
  }
}
