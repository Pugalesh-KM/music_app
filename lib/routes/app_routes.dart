import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:music_app/core/constants/routes.dart';
import 'package:music_app/features/music/presentation/cubit/music_cubit.dart';
import 'package:music_app/features/music/presentation/pages/music_page.dart';
import 'package:music_app/features/music/presentation/widgets/music_player.dart';

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
    GoRoute(
      path: RoutesName.musicPlayerPath,
      pageBuilder: (context, state) {
        final musicCubit = context.read<MusicCubit>();
        return CustomTransitionPage(
          key: state.pageKey,
          child: BlocProvider.value(
            value: musicCubit, // 👈 reuse, don’t create new
            child: const MusicPlayer(),
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0, 1);
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            final slideTween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: curve));
            final fadeTween = Tween(
              begin: 0.0,
              end: 1.0,
            ).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(slideTween),
              child: FadeTransition(
                opacity: animation.drive(fadeTween),
                child: child,
              ),
            );
          },
        );
      },
    ),
  ],
);
