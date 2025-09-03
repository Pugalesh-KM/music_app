
import 'package:music_app/core/exceptions/http_exception.dart';
import 'package:music_app/core/network/model/either.dart';
import 'package:music_app/core/services/music_service.dart';
import 'package:music_app/features/music/data/models/music_model.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class MusicLocalDataSource {
  Future<Either<AppException, MusicModel>> scanForSongs();
}

class MusicLocalDataSourceImpl extends MusicLocalDataSource {
  final MusicService _musicService;
  MusicLocalDataSourceImpl(this._musicService);

  @override
  Future<Either<AppException, MusicModel>> scanForSongs() async {
    try {
      final status = await Permission.storage.isGranted;
      final status1 = await Permission.audio.isGranted;

      if (!status && !status1) {
        return Left(
          AppException(
            message: "Storage permission $status : Audio permission $status1",
            statusCode: 403,
            identifier: "MusicLocalDataSourceImpl.scanForSongs.permission",
          ),
        );
      }
      final songs = await _musicService.scanDeviceForAudio();

      await _musicService.setPlaylist(songs);
      return Right(MusicModel(data: songs));

    } catch (e) {
      return Left(
        AppException(
          message: "${e.toString()}\nFailed to fetch scan results",
          statusCode: -1,
          identifier: "${e.toString()}\nMusicLocalDataSourceImpl.scanForSongs",
        ),
      );
    }
  }
}
