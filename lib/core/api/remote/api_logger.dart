import 'package:flutter/foundation.dart';

/// Abstract logger interface for API operations.
///
/// This abstraction allows for flexible logging implementations without
/// coupling the API layer to a specific logging framework. It enables:
/// - Easy testing with mock loggers
/// - Framework-independent logging
/// - Custom logging strategies per environment
/// - Integration with third-party logging services
///
/// Example implementations:
/// - [ConsoleApiLogger] for development (debugPrint)
/// - [SilentApiLogger] for testing (no output)
/// - Custom implementations for production logging services
abstract class ApiLogger {
  /// Logs an error message with optional context.
  ///
  /// Parameters:
  /// - [message]: The main error message
  /// - [exception]: Optional exception object
  /// - [stackTrace]: Optional stack trace for debugging
  /// - [additionalInfo]: Extra contextual information
  void logError(String message, {Object? exception, StackTrace? stackTrace, String? additionalInfo});

  /// Logs an informational message.
  ///
  /// Used for tracking normal API operations and successful requests.
  ///
  /// Parameters:
  /// - [message]: The informational message to log
  void logInfo(String message);
}

/// Console-based logger implementation using Flutter's debugPrint.
///
/// This logger only outputs in debug mode and is ideal for development.
/// Uses emoji prefixes for better visual distinction in console output.
///
/// Usage:
/// ```dart
/// final logger = ConsoleApiLogger();
/// logger.logInfo('API request started');
/// logger.logError('Request failed', exception: error);
/// ```
class ConsoleApiLogger implements ApiLogger {
  const ConsoleApiLogger();

  @override
  void logError(String message, {Object? exception, StackTrace? stackTrace, String? additionalInfo}) {
    if (kDebugMode) {
      final buffer = StringBuffer()
        ..writeln('===== API ERROR =====')
        ..writeln('message     : $message');
      if (additionalInfo != null && additionalInfo.isNotEmpty) {
        buffer.writeln('info        : $additionalInfo');
      }
      if (exception != null) {
        buffer.writeln('exception   : $exception');
      }
      if (stackTrace != null) {
        buffer.writeln('stackTrace  :\n$stackTrace');
      }
      buffer.writeln('=====================');
      print(buffer.toString());
    }
  }

  @override
  void logInfo(String message) {
    if (kDebugMode) {
      final buffer = StringBuffer()
        ..writeln('----- API INFO ------')
        ..writeln('message     : $message')
        ..writeln('---------------------');
      print(buffer.toString());
    }
  }
}
