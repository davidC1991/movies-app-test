import 'api_response.dart';

/// Traduce una excepción del repositorio/red a un mensaje presentable en la UI.
/// Centraliza el mapeo que antes se repetía en cada ViewModel (DRY): el
/// repositorio lanza en error y la presentación lo convierte con esta función.
String messageFromError(Object error) {
  if (error is ErrorApiResponse) return error.httpErrorMessage;
  return 'Ocurrió un error inesperado. Intenta de nuevo.';
}
