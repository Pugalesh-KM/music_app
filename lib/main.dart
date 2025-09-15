
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/services/music_service.dart';
import 'package:music_app/routes/app_routes.dart';
import 'package:music_app/shared/cubit/theme_cubit.dart';
import 'package:music_app/shared/theme/app_theme.dart';
import 'core/dependency_injection/injector.dart';
import 'core/services/music_get_storage_service.dart';
import 'core/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();
  await NotificationService.init();
  await MusicGetStorageService.init();

  final audioHandler = await AudioService.init(
    builder: () => MusicService(),
    config: AudioServiceConfig(
      androidNotificationChannelId: 'com.music_app.audio',
      androidNotificationChannelName: 'Music Playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
      androidNotificationIcon: 'drawable/ic_notification',
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key,});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => injector<ThemeCubit>()),
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
