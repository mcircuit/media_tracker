import 'movie.dart';
import 'movie_status.dart';

const interstellar = Movie(
  id: '1',
  title: 'Interstellar',
  year: 2014,
  genre: 'Sci-Fi',
  rating: 9.5,
  status: MediaStatus.inCollection,
);

const eeaao = Movie(
  id: '2',
  title: 'Everything Everywhere All At Once',
  year: 2022,
  genre: 'Sci-Fi',
  rating: 9,
  status: MediaStatus.inCollection,
);

const theDarkKnight = Movie(
  id: '3',
  title: 'The Dark Knight',
  year: 2008,
  genre: 'Superhero',
  rating: 9.2,
  status: MediaStatus.inCollection,
);

const shawshank = Movie(
  id: '4',
  title: 'Shawshank Redemption',
  year: 1994,
  genre: 'Crime/Drama',
  rating: null,
  status: MediaStatus.onWatchlist,
);

const godfather = Movie(
  id: '5',
  title: 'The Godfather',
  year: 1972,
  genre: 'Crime',
  rating: null,
  status: MediaStatus.onWatchlist,
);

List<Movie> get collectedMovies => const [interstellar, eeaao, theDarkKnight];

List<Movie> get bucketListMovies => const [shawshank, godfather];
