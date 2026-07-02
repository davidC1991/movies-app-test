import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/remote/dio_provider.dart';
import '../../data/datasources/api/movie_service.dart';
import '../../data/datasources/movie_data_source_remote.dart';
import '../../data/repositories/movie_repository_remote.dart';
import '../../domain/usecases/movie_use_cases.dart';

/// Único provider de la feature: expone `MovieUseCases` y ensambla la cadena
/// manualmente (dio → MovieService → data source → repositorio → casos de uso).
final movieUseCasesProvider = Provider<MovieUseCases>((ref) {
  final dio = ref.read(dioProvider);
  final service = MovieService(dio);
  final dataSource = MovieDataSourceRemote(service);
  final repository = MovieRepositoryRemote(dataSource);
  return MovieUseCases(repository);
});
