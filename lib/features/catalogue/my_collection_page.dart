import 'package:flutter/material.dart';

import 'data/sample_movies.dart';
import 'widgets/movie_card.dart';

class MyCollectionPage extends StatelessWidget {
  const MyCollectionPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Collection'),
      ),
      body: ListView.builder(
        itemCount: collectedMovies.length,
        itemBuilder: (context, i) => MovieCard(movie: collectedMovies[i]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
