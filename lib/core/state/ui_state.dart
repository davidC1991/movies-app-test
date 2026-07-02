/// Estado genérico expuesto por los ViewModels (MVVM). Lógica Dart pura,
/// sin generación de código: una clase sellada "madre" y sus subclases.
///
/// Al ser `sealed`, el `switch` sobre un `UIState` es exhaustivo (el compilador
/// obliga a cubrir loading / success / fail).
sealed class UIState<T> {
  const UIState();
}

/// Petición en curso.
class UILoading<T> extends UIState<T> {
  const UILoading();
}

/// Datos disponibles (puede ser una lista vacía).
class UISuccess<T> extends UIState<T> {
  final T data;

  const UISuccess(this.data);
}

/// Error a mostrar en la UI (mensaje).
class UIFail<T> extends UIState<T> {
  final String message;

  const UIFail(this.message);
}
