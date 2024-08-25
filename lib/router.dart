import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mpocket/views/msource_screen.dart';
import 'package:mpocket/views/music_screen.dart';
import 'package:mpocket/views/user_screen.dart';
import 'package:mpocket/views/widgets.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

enum AppRoute {
  music,
  msource,
  user
}

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/msource',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => BottomNavigationBarScaffold(child: child),
      routes: [
        GoRoute(
          path: '/music',
          name: AppRoute.music.name,
          builder: (context, state) => const MusicScreen(),
        ),
        GoRoute(
          path: '/msource',
          name: AppRoute.msource.name,
          builder: (context, state) => const MsourceScreen(),
        ),
        GoRoute(
          path: '/user',
          name: AppRoute.user.name,
          builder: (context, state) => const UserScreen(),
        ),
      ]
    )
  ]
);
