class MediaSearchResult {
  final int tmdbId;
  final String title;
  final int? year;
  final String? posterUrl;

  const MediaSearchResult({
    required this.tmdbId,
    required this.title,
    this.year,
    this.posterUrl,
  });
}
