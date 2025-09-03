import 'package:music_app/core/exceptions/http_exception.dart';
import 'package:music_app/core/network/model/either.dart';
import 'package:music_app/features/music/data/datasources/music_local_data_source.dart';
import 'package:music_app/features/music/data/models/music_model.dart';
import 'package:music_app/features/music/domain/repositories/music_repository.dart';


class MusicRepositoryImpl extends MusicRepository {
  final MusicLocalDataSource _localDataSource;


  MusicRepositoryImpl(this._localDataSource);

  @override
  Future<Either<AppException, MusicModel>> scanForSongs() {
    return _localDataSource.scanForSongs();
  }
}