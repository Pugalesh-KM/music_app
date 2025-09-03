import 'package:get_it/get_it.dart';
import 'package:music_app/core/database/hive_storage_service.dart';
import 'package:music_app/core/network/dio_network_service.dart';
import 'package:music_app/core/network/network_service.dart';
import 'package:music_app/core/services/music_service.dart';
import 'package:music_app/core/services/notification_service.dart';
import 'package:music_app/features/bluetooth/data/datasources/bluetooth_remote_data_source.dart';
import 'package:music_app/features/bluetooth/data/repositories/bluetooth_repository_impl.dart';
import 'package:music_app/features/bluetooth/domain/repositories/bluetooth_repository.dart';
import 'package:music_app/features/bluetooth/domain/usecases/bluetooth_use_case.dart';
import 'package:music_app/features/bluetooth/presentation/cubit/bluetooth_cubit.dart';
import 'package:music_app/features/music/data/datasources/music_local_data_source.dart';
import 'package:music_app/features/music/data/repositories/music_repository_impl.dart';
import 'package:music_app/features/music/domain/repositories/music_repository.dart';
import 'package:music_app/features/music/domain/usecases/music_use_case.dart';
import 'package:music_app/features/music/presentation/cubit/music_cubit.dart';
import 'package:music_app/shared/cubit/theme_cubit.dart';

final injector = GetIt.instance;

Future<void> init() async {
  injector
    ..registerLazySingleton<NetworkService>(DioNetworkService.new)
    ..registerLazySingleton<DioNetworkService>(DioNetworkService.new)
    ..registerLazySingleton<HiveService>(HiveService.new)
    ..registerLazySingleton<NotificationService>(NotificationService.new)
    ..registerLazySingleton<MusicService>(MusicService.new)
    ..registerFactory<ThemeCubit>(() => ThemeCubit())
    /// Bluetooth
    ..registerLazySingleton<BluetoothRemoteDataSource>(() => BluetoothRemoteDataSourceImpl(injector()),)
    ..registerLazySingleton<BluetoothRepository>(() => BluetoothRepositoryImpl(injector()),)
    ..registerLazySingleton<BluetoothUseCase>(() => BluetoothUseCase(injector()))
    ..registerFactory<BluetoothCubit>(() => BluetoothCubit(injector()))

    /// music
    ..registerLazySingleton<MusicLocalDataSource>(() => MusicLocalDataSourceImpl(injector()),)
    ..registerLazySingleton<MusicRepository>(() => MusicRepositoryImpl(injector()),)
    ..registerLazySingleton<MusicUseCase>(() => MusicUseCase(injector()))
    ..registerFactory<MusicCubit>(() => MusicCubit(injector()));
}
