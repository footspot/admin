import 'package:flutter/material.dart';
import 'package:fs_sa/presentation/features/auth/auth_view.dart';
import 'package:fs_sa/presentation/features/home/home_view.dart';
import 'package:go_router/go_router.dart';

/// The route configuration.
final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return AuthView();
      },
    ),
    GoRoute(
      path: '/home',
      builder: (BuildContext context, GoRouterState state) {
        return HomeView();
      },
    ),
  ],
);
