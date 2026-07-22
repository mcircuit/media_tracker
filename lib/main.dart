import 'package:flutter/material.dart';

import 'app/router.dart';
import 'app/theme.dart';

void main() {
  runApp(const MediaTrackerApp());
}

class MediaTrackerApp extends StatelessWidget {
  const MediaTrackerApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'One-for-All Tracker',
      theme: buildAppTheme(),
      routerConfig: buildAppRouter(),
    );
  }
}
