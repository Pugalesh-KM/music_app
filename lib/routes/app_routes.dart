import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:music_app/core/constants/routes.dart';
import 'package:music_app/features/music/presentation/pages/music_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final GoRouter router = GoRouter(
  initialLocation: RoutesName.defaultPath,
  navigatorKey: navigatorKey,
  routes: <RouteBase>[
    GoRoute(
      path: RoutesName.defaultPath,
      builder: (BuildContext context, GoRouterState state) {
        return MusicPage();
      },
    ),
    // GoRoute(
    //   path: RoutesName.listMusicPath,
    //   builder: (BuildContext context, GoRouterState state) {
    //     return ListMusicPage();
    //   },
    // ),
    GoRoute(
      path: RoutesName.musicPath,
      builder: (BuildContext context, GoRouterState state) {
        return MusicPage();
      },
    ),
    GoRoute(
      path: RoutesName.settingsPath,
      builder: (BuildContext context, GoRouterState state) {
        return Scaffold();
      },
    ),
  ],
);
