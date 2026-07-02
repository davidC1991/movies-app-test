import 'dart:async';

import 'package:flutter/material.dart';

import '../atoms/app_icon_button.dart';
import '../theme/app_colors.dart';
import '../theme/app_durations.dart';
import '../theme/app_typography.dart';

/// Barra de búsqueda del catálogo con **debounce** integrado.
///
/// Responsabilidades del widget (presentación pura):
/// - Espera a que el usuario deje de escribir ([debounce]) antes de notificar
///   [onChanged], evitando disparar un request por cada tecla.
/// - Expone [onClear] al pulsar la "x" o borrar todo el texto.
///
/// La lógica de búsqueda (llamar al repositorio, restaurar la vista por
/// defecto al limpiar) vive en el ViewModel, no aquí. Así el componente es
/// reutilizable en cualquier pantalla.
class DebouncedSearchBar extends StatefulWidget {
  /// Se invoca con el texto ya "debounced" (tras [debounce] sin teclear).
  final ValueChanged<String> onChanged;

  /// Se invoca al limpiar la búsqueda (restaurar vista por defecto).
  final VoidCallback? onClear;

  final String hintText;
  final Duration debounce;
  final TextEditingController? controller;

  const DebouncedSearchBar({
    super.key,
    required this.onChanged,
    this.onClear,
    this.hintText = 'Buscar películas',
    this.debounce = AppDurations.searchDebounce,
    this.controller,
  });

  @override
  State<DebouncedSearchBar> createState() => _DebouncedSearchBarState();
}

class _DebouncedSearchBarState extends State<DebouncedSearchBar> {
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController();
  Timer? _debounceTimer;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_syncClearButton);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.removeListener(_syncClearButton);
    // Solo destruimos el controller si lo creamos nosotros.
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  /// Mantiene sincronizada la visibilidad del botón de limpiar.
  void _syncClearButton() {
    final bool hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);
  }

  void _onChanged(String value) {
    _debounceTimer?.cancel();
    // Si el campo queda vacío, restauramos de inmediato (sin esperar debounce).
    if (value.isEmpty) {
      widget.onClear?.call();
      return;
    }
    _debounceTimer = Timer(widget.debounce, () => widget.onChanged(value.trim()));
  }

  void _clear() {
    _debounceTimer?.cancel();
    _controller.clear();
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: _onChanged,
      textInputAction: TextInputAction.search,
      style: AppTypography.bodyLarge,
      cursorColor: AppColors.accent,
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.search, color: AppColors.textTertiary),
        suffixIcon: _hasText
            ? AppIconButton(
                icon: Icons.close,
                semanticLabel: 'Limpiar búsqueda',
                color: AppColors.textSecondary,
                iconSize: 20,
                onPressed: _clear,
              )
            : null,
      ),
    );
  }
}
