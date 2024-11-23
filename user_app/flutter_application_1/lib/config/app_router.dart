import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/login_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/screens/home_screen.dart';

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
        }),
    GoRoute(
      path: '/login',
      pageBuilder: (BuildContext context, GoRouterState state) {
          return CustomTransitionPage(
              child: const LoginScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                    opacity: CurveTween(curve: Curves.easeInOutCirc)
                        .animate(animation),
                    child: const LoginScreen());
              }
              );
        })
  ]);
}
