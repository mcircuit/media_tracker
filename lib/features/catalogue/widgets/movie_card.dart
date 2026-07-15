import 'package:flutter/material.dart';
import '../data/movie.dart';
import '../data/movie_status.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  const MovieCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    final badgeColor = movie.status == MediaStatus.inCollection
        ? Theme.of(context).colorScheme.secondary
        : Theme.of(context).colorScheme.primary;

    final badgeFg = movie.status == MediaStatus.inCollection
        ? Theme.of(context).colorScheme.onSecondary
        : Theme.of(context).colorScheme.onPrimary;

    final badgeLabel = movie.status == MediaStatus.inCollection ? 'Collection' : 'To Consume';

    return Card(
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(movie.title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(
          '${movie.year} • ${movie.genre}',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),

        trailing: Container(
          decoration: BoxDecoration(
            color: badgeColor,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Text(badgeLabel, style: TextStyle(color: badgeFg, fontSize: 12)),
          ),
        ),
      ),
    );
  }
}
