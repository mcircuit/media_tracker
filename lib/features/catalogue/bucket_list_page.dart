import 'package:flutter/material.dart';

import 'data/sample_movies.dart';
import 'widgets/movie_card.dart';

// Lists all media items that are on the user's bucketlist
class BucketListPage extends StatelessWidget {
  const BucketListPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bucket List'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: bucketListMovies.length,
        itemBuilder: (context, i) => MovieCard(movie: bucketListMovies[i]),
        separatorBuilder: (_, _) => const SizedBox(height: 8),
      ),

      // Button to add media items to the bucketlist
      floatingActionButton: FloatingActionButton(onPressed: () {}, child: const Icon(Icons.add)),
    );
  }
}
