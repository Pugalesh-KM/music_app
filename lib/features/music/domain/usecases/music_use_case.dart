
import 'package:music_app/core/exceptions/http_exception.dart';
import 'package:music_app/core/network/model/either.dart';
import 'package:music_app/features/music/data/models/music_model.dart';
import 'package:music_app/features/music/domain/repositories/music_repository.dart';


class MusicUseCase{
  final MusicRepository _repository;
  MusicUseCase(this._repository);

  Future<Either<AppException, MusicModel>> scanForSongs() {
    return _repository.scanForSongs();
  }

}