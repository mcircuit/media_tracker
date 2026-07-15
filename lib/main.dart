import 'package:flutter/material.dart';

import 'app/theme.dart';
import 'features/catalogue/catalogue_page.dart';

void main() {
  runApp(const MediaTrackerApp());
}

class MediaTrackerApp extends StatelessWidget {
  const MediaTrackerApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'One-for-All Tracker',
      theme: buildAppTheme(),
      home: const CataloguePage(),
    );
  }
}
