import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Application screens
import 'package:flutter_application_1/screens/home.dart';

class ApplicationRouter {
  GoRouter router = GoRouter(routes: <RouteBase>[
    GoRoute(
        path: '/',
        pageBuilder: (BuildContext context, GoRouterState state) {
          return CustomTransitionPage(
              child: const HomeScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                    opacity: CurveTween(curve: Curves.easeInOutCirc)
                        .animate(animation),
                    child: const HomeScreen());
              }
              );
        })
  ]);
}
