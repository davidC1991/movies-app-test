import 'package:mockito/annotations.dart';
import 'package:movies/features/home/data/datasources/api/movie_service.dart';
import 'package:movies/features/home/data/datasources/movie_data_source.dart';
import 'package:movies/features/home/domain/repositories/movie_repository.dart';

// Declaración central de dobles de prueba (mockito). Genera `mocks.mocks.dart`
// con MockMovieRepository, MockMovieDataSource y MockMovieService.
//
// Regenerar con: dart run build_runner build --delete-conflicting-outputs
//
// Se mockea en la frontera de cada capa:
// - MovieRepository → ViewModels y MovieUseCases.
// - MovieDataSource → MovieRepositoryRemote.
// - MovieService    → MovieDataSourceRemote.
@GenerateNiceMocks([
  MockSpec<MovieRepository>(),
  MockSpec<MovieDataSource>(),
  MockSpec<MovieService>(),
])
void main() {}
