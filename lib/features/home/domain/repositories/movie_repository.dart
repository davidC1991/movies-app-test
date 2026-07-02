import '../entities/movie.dart';
import '../entities/movie_detail.dart';
import '../entities/page_result.dart';

/// Contrato del repositorio (domain). Devuelve **entidades**; en error **lanza**
/// (lo maneja la presentación con try/catch).
abstract interface class MovieRepository {
  Future<PageResult<Movie>> getPopular({int page = 1});

  Future<PageResult<Movie>> getTopRated({int page = 1});

  Future<MovieDetail> getDetail(int id);

  Future<PageResult<Movie>> search(String query, {int page = 1});
}
