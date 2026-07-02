import 'package:dio/dio.dart';
import 'package:movies/core/api/remote/api_logger.dart';
import 'package:movies/core/api/remote/api_response.dart';

/// Mixin that provides standardized API response handling for HTTP requests.
///
/// This mixin transforms raw API responses and [DioException]s into a
/// consistent [ApiResponse] format, making error handling uniform across
/// the application.
///
/// Key features:
/// - Automatic error categorization (timeout, network, server errors)
/// - Structured error response parsing
/// - Support for empty responses (201, 204 status codes)
/// - Comprehensive logging for debugging (via injectable [ApiLogger])
/// - Type-safe response wrapping
///
/// Usage:
/// ```dart
/// class MyDataSource with ApiResponseHandlerMixin {
///   @override
///   ApiLogger get logger => ConsoleApiLogger();
///
///   Future<ApiResponse<User>> getUser(String id) {
///     return executeApiCall(() => apiService.getUser(id));
///   }
/// }
/// ```
mixin ApiResponseHandlerMixin {
  // HTTP status code constants
  static const int _STATUS_CREATED = 201;
  static const int _STATUS_NO_CONTENT = 204;
  static const int _STATUS_REQUEST_TIMEOUT = 408;
  static const int _STATUS_CLIENT_CLOSED_REQUEST = 499;
  static const int _STATUS_SSL_CERTIFICATE_ERROR = 495;
  static const int _STATUS_UNKNOWN_ERROR = 601;
  static const int _STATUS_NETWORK_ERROR = 999;

  /// Logger instance for API operations.
  ///
  /// Override this getter to provide a custom logger implementation.
  /// Defaults to [ConsoleApiLogger] which outputs to debugPrint in debug mode.
  ///
  /// Example with custom logger:
  /// ```dart
  /// @override
  /// ApiLogger get logger => MyCustomLogger();
  /// ```
  ///
  /// Example with silent logger for testing:
  /// ```dart
  /// @override
  /// ApiLogger get logger => SilentApiLogger();
  /// ```
  ApiLogger get logger => const ConsoleApiLogger();

  /// Executes an API request and wraps the result in a standardized [ApiResponse].
  ///
  /// This method handles all common exceptions and HTTP status codes,
  /// transforming them into appropriate [ApiResponse] types:
  /// - [SuccessApiResponse] for successful operations with data
  /// - [EmptyApiResponse] for successful operations without data (201, 204)
  /// - [ErrorApiResponse] for failures with detailed error information
  ///
  /// Parameters:
  /// - [apiRequest]: A Future that performs the actual API call
  ///
  /// Returns a [Future<ApiResponse<T>>] wrapping the result.
  ///
  /// Example:
  /// ```dart
  /// final response = await executeApiCall(
  ///   apiService.fetchData(),
  /// );
  ///
  /// response.when(
  ///   success: (data) => print('Got data: $data'),
  ///   empty: () => print('No content'),
  ///   error: (message, code, errors) => print('Error: $message'),
  /// );
  /// ```
  Future<ApiResponse<T>> executeApiCall<T>(Future<T> apiRequest) {
    return executeApiCallLazy(() => apiRequest);
  }

  /// Executes an API request lazily using a factory function.
  ///
  /// Use this when you want to defer the API call execution until
  /// this method is invoked, rather than passing an already-started Future.
  ///
  /// Example:
  /// ```dart
  /// final response = await executeApiCallLazy(
  ///   () => apiService.fetchData(),
  /// );
  /// ```
  Future<ApiResponse<T>> executeApiCallLazy<T>(Future<T> Function() apiRequest) async {
    try {
      final result = await apiRequest();
      _logInfo('API call successful: ${T.toString()}');
      return SuccessApiResponse(result);
    } on DioException catch (dioException) {
      return _handleDioException<T>(dioException);
    } catch (exception, stackTrace) {
      return _handleGenericException<T>(exception, stackTrace);
    }
  }

  /// Handles [DioException]s by categorizing them and creating appropriate error responses.
  ///
  /// Special handling for 201/204 status codes which should be treated as
  /// successful empty responses rather than errors.
  ApiResponse<T> _handleDioException<T>(DioException dioException) {
    _logError('DioException occurred', exception: dioException, stackTrace: dioException.stackTrace);

    final statusCode = dioException.response?.statusCode;
    final requestPath = dioException.requestOptions.path;

    // Handle successful empty responses (201 Created, 204 No Content)
    if (statusCode == _STATUS_CREATED || statusCode == _STATUS_NO_CONTENT) {
      _logInfo('Empty response received (HTTP $statusCode) for $requestPath');
      return EmptyApiResponse<T>();
    }

    // Categorize and handle different exception types
    return _createErrorResponse<T>(dioException: dioException, statusCode: statusCode, requestPath: requestPath);
  }

  /// Creates an appropriate [ErrorApiResponse] based on the [DioExceptionType].
  ErrorApiResponse<T> _createErrorResponse<T>({
    required DioException dioException,
    required int? statusCode,
    required String requestPath,
  }) {
    final exceptionType = dioException.type;

    switch (exceptionType) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return _createTimeoutError<T>(
          exceptionType: exceptionType,
          message: dioException.message,
          statusCode: statusCode,
          requestPath: requestPath,
        );

      case DioExceptionType.badResponse:
      /*  return _createBadResponseError<T>(
          message: dioException.message,
          response: dioException.response,
          statusCode: statusCode,
          requestPath: requestPath,
        ); */

      case DioExceptionType.connectionError:
        return _createConnectionError<T>(
          message: dioException.message,
          statusCode: statusCode,
          requestPath: requestPath,
        );

      case DioExceptionType.cancel:
        return _createCancelError<T>(requestPath);

      case DioExceptionType.badCertificate:
        return _createBadCertificateError<T>(message: dioException.message, requestPath: requestPath);

      case DioExceptionType.unknown:
        return _createUnknownError<T>(message: dioException.message, statusCode: statusCode, requestPath: requestPath);
      case DioExceptionType.transformTimeout:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  /// Creates an [ErrorApiResponse] for timeout-related errors.
  ErrorApiResponse<T> _createTimeoutError<T>({
    required DioExceptionType exceptionType,
    required String? message,
    required int? statusCode,
    required String requestPath,
  }) {
    final timeoutType = exceptionType.toString().split('.').last;
    _logError('Timeout error ($timeoutType) for $requestPath');

    return ErrorApiResponse<T>(
      httpErrorMessage: message ?? 'Request timeout ($timeoutType)',
      httpStatusCode: statusCode ?? _STATUS_REQUEST_TIMEOUT,
    );
  }

  /// Creates an [ErrorApiResponse] for connection errors.
  ErrorApiResponse<T> _createConnectionError<T>({
    required String? message,
    required int? statusCode,
    required String requestPath,
  }) {
    _logError('Connection error for $requestPath');

    return ErrorApiResponse<T>(
      httpErrorMessage: message ?? 'Connection error - please check your network',
      httpStatusCode: statusCode ?? _STATUS_NETWORK_ERROR,
    );
  }

  /// Creates an [ErrorApiResponse] for cancelled requests.
  ErrorApiResponse<T> _createCancelError<T>(String requestPath) {
    _logInfo('Request cancelled for $requestPath');

    return ErrorApiResponse<T>(
      httpErrorMessage: 'Request was cancelled',
      httpStatusCode: _STATUS_CLIENT_CLOSED_REQUEST,
    );
  }

  /// Creates an [ErrorApiResponse] for bad certificate errors.
  ErrorApiResponse<T> _createBadCertificateError<T>({required String? message, required String requestPath}) {
    _logError('Bad certificate error for $requestPath');

    return ErrorApiResponse<T>(
      httpErrorMessage: message ?? 'SSL certificate error',
      httpStatusCode: _STATUS_SSL_CERTIFICATE_ERROR,
    );
  }

  /// Creates an [ErrorApiResponse] for unknown or unexpected errors.
  ErrorApiResponse<T> _createUnknownError<T>({
    required String? message,
    required int? statusCode,
    required String requestPath,
  }) {
    _logError('Unknown error for $requestPath');

    return ErrorApiResponse<T>(
      httpErrorMessage: message ?? 'Unknown error occurred',
      httpStatusCode: statusCode ?? _STATUS_UNKNOWN_ERROR,
    );
  }

  /// Handles generic exceptions that are not [DioException]s.
  ErrorApiResponse<T> _handleGenericException<T>(Object exception, StackTrace stackTrace) {
    _logError('Unexpected exception occurred', exception: exception, stackTrace: stackTrace);

    return ErrorApiResponse<T>(
      httpErrorMessage: 'Unexpected error: ${exception.toString()}',
      httpStatusCode: _STATUS_UNKNOWN_ERROR,
    );
  }

  /// Logs an error message with optional exception and stack trace.
  ///
  /// Uses the injectable [logger] instance.
  void _logError(String message, {Object? exception, StackTrace? stackTrace, String? additionalInfo}) {
    logger.logError(message, exception: exception, stackTrace: stackTrace, additionalInfo: additionalInfo);
  }

  /// Logs an informational message.
  ///
  /// Uses the injectable [logger] instance.
  void _logInfo(String message) {
    logger.logInfo(message);
  }
}
