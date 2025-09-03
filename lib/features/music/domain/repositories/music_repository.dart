import 'package:music_app/core/exceptions/http_exception.dart';
import 'package:music_app/core/network/model/either.dart';
import 'package:music_app/features/music/data/models/music_model.dart';


abstract class MusicRepository{
  Future<Either<AppException, MusicModel>> scanForSongs();
}