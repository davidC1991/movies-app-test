// JSON crudo (forma TMDB) para probar los `fromJson` de los modelos.

/// Respuesta paginada de listado (`/movie/popular`, `/movie/top_rated`, búsqueda).
Map<String, dynamic> movieResponseJson({int page = 1, int totalPages = 3}) => {
      'page': page,
      'total_pages': totalPages,
      'results': [
        {
          'id': 1,
          'title': 'Película 1',
          'poster_path': '/p1.jpg',
          'vote_average': 7.5,
        },
        {
          'id': 2,
          'title': 'Película 2',
          'poster_path': null,
          'vote_average': 8.1,
        },
      ],
    };

/// Respuesta de detalle (`/movie/{id}`), con géneros y backdrop.
Map<String, dynamic> movieDetailJson() => {
      'id': 42,
      'title': 'Inception',
      'poster_path': '/inception.jpg',
      'backdrop_path': '/inception_bg.jpg',
      'vote_average': 8.3,
      'overview': 'Un ladrón roba secretos del subconsciente.',
      'release_date': '2010-07-16',
      'runtime': 148,
      'genres': [
        {'id': 878, 'name': 'Science Fiction'},
        {'id': 53, 'name': 'Thriller'},
      ],
    };
