import 'package:music_app/core/network/network_service.dart';

abstract class MusicRemoteDataSource{}

class MusicRemoteDataSourceImpl extends MusicRemoteDataSource {
  final NetworkService networkService;
  MusicRemoteDataSourceImpl(this.networkService);
}