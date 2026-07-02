import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api_config.dart';

/// `Dio` compartido, configurado con la base URL y el token de TMDB.
final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Accept': 'application/json',
        if (ApiConfig.tmdbToken.isNotEmpty) 'Authorization': 'Bearer ${ApiConfig.tmdbToken}',
      },
    ),
  );
});
