import 'package:integration_test/integration_test_driver.dart';

/// Runner para ejecutar las pruebas de integración con `flutter drive`:
///   flutter drive --driver=test_driver/integration_test.dart \
///     --target=integration_test/app_test.dart
Future<void> main() => integrationDriver();
