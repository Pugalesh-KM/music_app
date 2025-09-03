
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/services/music_service.dart';
import 'package:music_app/features/music/presentation/cubit/music_cubit.dart';
import 'package:music_app/routes/app_routes.dart';
import 'package:music_app/shared/theme/app_theme.dart';

import 'core/dependency_injection/injector.dart';
import 'core/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();
  await NotificationService.init();
  await MusicService.init();
  final musicHandler = await AudioService.init(
    builder: () => MusicService(),
    config: AudioServiceConfig(
      androidNotificationChannelId: 'com.music_app.audio',
      androidNotificationChannelName: 'Audio Playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );
  runApp(MyApp());
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}

class MyApp extends StatelessWidget {

  const MyApp({super.key,});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        //BlocProvider(create: (_) => injector<ThemeCubit>()),
        BlocProvider(
          create: (_) => injector<MusicCubit>()..checkPermissionAndScan(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system ,
        routerConfig: router,
      ),
    );
  }
}
