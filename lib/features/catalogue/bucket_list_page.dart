import 'package:flutter/material.dart';

import 'data/sample_movies.dart';
import 'widgets/movie_card.dart';

class BucketListPage extends StatelessWidget {
  const BucketListPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bucket List'),
      ),
      body: ListView.builder(
        itemCount: bucketListMovies.length,
        itemBuilder: (context, i) => MovieCard(movie: bucketListMovies[i]),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {}, child: const Icon(Icons.add)),
    );
  }
}
