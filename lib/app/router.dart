import 'package:go_router/go_router.dart';
import '../features/catalogue/catalogue_page.dart';

// Routing widget for navigation
GoRouter buildAppRouter() => GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (context, state) => CataloguePage(),
    ),
  ],
);
