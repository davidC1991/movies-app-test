import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/api/remote/api_logger.dart';
import 'package:movies/core/api/remote/api_response.dart';
import 'package:movies/core/api/remote/api_response_handler_mixin.dart';

/// Logger silencioso para no ensuciar la salida de los tests.
class _SilentLogger implements ApiLogger {
  const _SilentLogger();
  @override
  void logError(String message, {Object? exception, StackTrace? stackTrace, String? additionalInfo}) {}
  @override
  void logInfo(String message) {}
}

class _Handler with ApiResponseHandlerMixin {
  @override
  ApiLogger get logger => const _SilentLogger();
}

DioException _dio(DioExceptionType type, {int? status}) {
  final options = RequestOptions(path: '/x');
  return DioException(
    requestOptions: options,
    type: type,
    response: status == null ? null : Response(requestOptions: options, statusCode: status),
  );
}

void main() {
  final handler = _Handler();

  test('éxito → SuccessApiResponse con el valor', () async {
    final r = await handler.executeApiCall<int>(Future.value(5));
    expect(r, isA<SuccessApiResponse<int>>());
    expect((r as SuccessApiResponse<int>).body, 5);
  });

  test('204 No Content → EmptyApiResponse', () async {
    final r = await handler.executeApiCall<int>(
      Future.error(_dio(DioExceptionType.badResponse, status: 204)),
    );
    expect(r, isA<EmptyApiResponse<int>>());
  });

  test('timeout → ErrorApiResponse 408', () async {
    final r = await handler.executeApiCall<int>(
      Future.error(_dio(DioExceptionType.receiveTimeout)),
    );
    expect(r, isA<ErrorApiResponse<int>>());
    expect((r as ErrorApiResponse<int>).httpStatusCode, 408);
  });

  test('connectionError → ErrorApiResponse 999', () async {
    final r = await handler.executeApiCall<int>(
      Future.error(_dio(DioExceptionType.connectionError)),
    );
    expect((r as ErrorApiResponse<int>).httpStatusCode, 999);
  });

  test('cancel → ErrorApiResponse 499', () async {
    final r = await handler.executeApiCall<int>(
      Future.error(_dio(DioExceptionType.cancel)),
    );
    expect((r as ErrorApiResponse<int>).httpStatusCode, 499);
  });

  test('badCertificate → ErrorApiResponse 495', () async {
    final r = await handler.executeApiCall<int>(
      Future.error(_dio(DioExceptionType.badCertificate)),
    );
    expect((r as ErrorApiResponse<int>).httpStatusCode, 495);
  });

  test('unknown → ErrorApiResponse 601', () async {
    final r = await handler.executeApiCall<int>(
      Future.error(_dio(DioExceptionType.unknown)),
    );
    expect((r as ErrorApiResponse<int>).httpStatusCode, 601);
  });

  test('excepción genérica (no Dio) → ErrorApiResponse 601', () async {
    final r = await handler.executeApiCall<int>(Future.error(StateError('boom')));
    expect(r, isA<ErrorApiResponse<int>>());
    expect((r as ErrorApiResponse<int>).httpStatusCode, 601);
  });
}
