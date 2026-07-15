enum Status { inCollection, onWatchlist }

class Movie {
  final String id;
  final String title;
  final int year;
  final String genre;
  final double rating;
  final Status status;

  const Movie({
    required this.id,
    required this.title,
    required this.year,
    required this.genre,
    required this.rating,
    required this.status,
  });
}
