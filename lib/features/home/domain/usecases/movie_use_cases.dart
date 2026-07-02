import '../entities/movie.dart';
import '../entities/movie_detail.dart';
import '../entities/page_result.dart';
import '../repositories/movie_repository.dart';

/// Casos de uso de películas. Agrupa las operaciones del catálogo (misma
/// responsabilidad: obtenerlas del repositorio) en una sola clase, evitando
/// múltiples clases y providers. El ViewModel invoca estos métodos.
class MovieUseCases {
  final MovieRepository _repository;

  const MovieUseCases(this._repository);

  Future<PageResult<Movie>> getPopular({int page = 1}) => _repository.getPopular(page: page);

  Future<PageResult<Movie>> getTopRated({int page = 1}) => _repository.getTopRated(page: page);

  Future<MovieDetail> getDetail(int id) => _repository.getDetail(id);

  Future<PageResult<Movie>> search(String query, {int page = 1}) =>
      _repository.search(query, page: page);
}
