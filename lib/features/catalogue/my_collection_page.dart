import 'package:flutter/material.dart';

import 'data/sample_movies.dart';
import 'widgets/movie_card.dart';

// Lists all media items that are in the user's collection
class MyCollectionPage extends StatelessWidget {
  const MyCollectionPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Collection'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: collectedMovies.length,
        itemBuilder: (context, i) => MovieCard(movie: collectedMovies[i]),
        separatorBuilder: (_, _) => const SizedBox(height: 8),
      ),

      // Button to add media items to the bucketlist
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
