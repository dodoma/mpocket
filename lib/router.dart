import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mpocket/common/global.dart';
import 'package:mpocket/views/msource_screen.dart';
import 'package:mpocket/views/music_screen.dart';
import 'package:mpocket/views/now_playing.dart';
import 'package:mpocket/views/user_screen.dart';
import 'package:mpocket/views/widgets.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: Global.profile.msourceID.isEmpty ? '/music' : '/music',
    routes: [
      ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) =>
              BottomNavigationBarScaffold(child: child),
          routes: [
            GoRoute(
              path: '/music',
              builder: (context, state) => const MusicScreen(),
            ),
            GoRoute(
              path: '/msource',
              builder: (context, state) => const MsourceScreen(),
            ),
            GoRoute(
              path: '/user',
              builder: (context, state) => const UserScreen(),
            ),
            GoRoute(
              path: '/now_playing',
              builder: (context, state) => const NowPlayingScreen(),
            ),
          ])
    ]);
