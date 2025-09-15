import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/core/services/music_service.dart';
import 'package:music_app/features/music/data/models/music_model.dart';
import 'package:music_app/features/music/domain/usecases/music_use_case.dart';
import 'package:music_app/shared/models/song_model.dart';
import 'package:permission_handler/permission_handler.dart';

part 'music_state.dart';

class MusicCubit extends Cubit<MusicState> {
  final MusicUseCases _useCase;
  final MusicService _musicService;

  Timer? _progressTimer;
  StreamSubscription? _playerStateSub;
  StreamSubscription? _positionSub;
  StreamSubscription? _bufferedSub;
  StreamSubscription? _durationSub;
  StreamSubscription? _indexSub;
  StreamSubscription? _loopModeSub;
  StreamSubscription? _shuffleSub;
  List<SongModel> _songs = [];
  bool  _isPlaying = false;

  MusicCubit(this._useCase)
    : _musicService = GetIt.instance<MusicService>(),
      super(MusicInitial());


  Future<void> requestPermissions() async{
    final storageStatus = await Permission.storage.request();
    final audioStatus = await Permission.audio.request();

    if (storageStatus.isGranted || audioStatus.isGranted) {
      await scanForSongs();
    } else if (storageStatus.isPermanentlyDenied || audioStatus.isPermanentlyDenied) {
      emit(MusicError("Permission permanently denied, please enable in settings"));
      await openAppSettings();
      Future.delayed(const Duration(seconds: 10), () async {
        final storageStatus = await Permission.storage.status;
        final audioStatus = await Permission.audio.status;

        if (storageStatus.isGranted || audioStatus.isGranted) {
          await scanForSongs();
        } else {
          emit(MusicError("Please allow permissions in settings"));
        }
      });
    } else {
      emit(MusicError("Permission denied"));
    }
  }
  Future<void> checkPermissionAndScan() async {
    final storageStatus = await Permission.storage.isGranted;
    final audioStatus = await Permission.audio.isGranted;

    if (storageStatus || audioStatus) {
      await scanForSongs();
    } else {
      log("Storage permission $storageStatus : Audio permission $audioStatus");
      emit(
        MusicError("Storage permission $storageStatus : Audio permission $audioStatus"),
      );
    }
  }

  Future<void> scanForSongs() async {
    emit(MusicLoading());
    final result = await _useCase.scanForSongs();
    result.fold(
            (e) => emit(MusicError(e.message)),
            (songs) {
              _initListeners();
              _songs = songs.data;
              emit(
                MusicLoaded(
                  songs: songs,
                  isPlaying: false,
                  position: Duration.zero,
                  bufferedPosition: Duration.zero,
                  duration: null,
                  currentIndex: 0,
                  loopMode: LoopMode.off,
                  shuffleEnabled: false,
                ),
              );
            });
  }

  void _initListeners() {
    _disposeListeners();
    _playerStateSub = _musicService.playerStateStream.listen((playerState) {
      final isActuallyPlaying =
          playerState.playing && playerState.processingState != ProcessingState.completed;
      _isPlaying = isActuallyPlaying;
      _emitUpdated(isPlaying: isActuallyPlaying);
    });

    _positionSub = _musicService.positionStream.listen((pos) {
      _emitUpdated(position: pos);
    });

    _bufferedSub = _musicService.bufferedPositionStream.listen((buf) {
      _emitUpdated(bufferedPosition: buf);
    });

    _durationSub = _musicService.durationStream.listen((dur) {
      _emitUpdated(duration: dur);
    });

    _indexSub = _musicService.currentIndexStream.listen((index) {
      _emitUpdated(currentIndex: index);
    });

    _loopModeSub = _musicService.loopModeStream.listen((mode) {
      _emitUpdated(loopMode: mode);
    });

    _shuffleSub = _musicService.shuffleStream.listen((enabled) {
      _emitUpdated(shuffleEnabled: enabled);
    });
  }

  void _emitUpdated({
    bool? isPlaying,
    Duration? position,
    Duration? bufferedPosition,
    Duration? duration,
    int? currentIndex,
    LoopMode? loopMode,
    bool? shuffleEnabled,
  }) {
    final current = state;
    if (current is MusicLoaded) {
      emit(
        current.copyWith(
          isPlaying: isPlaying,
          position: position,
          bufferedPosition: bufferedPosition,
          duration: duration,
          currentIndex: currentIndex,
          loopMode: loopMode,
          shuffleEnabled: shuffleEnabled,
        ),
      );
    } else {
      emit(
        MusicLoaded(
          isPlaying: isPlaying ?? false,
          position: position ?? Duration.zero,
          bufferedPosition: bufferedPosition ?? Duration.zero,
          duration: duration,
          currentIndex: currentIndex,
          loopMode: loopMode ?? LoopMode.off,
          shuffleEnabled: shuffleEnabled ?? false,
          songs: MusicModel(data: []),
        ),
      );
    }
  }

  Future<void> toggleShuffle() async {
    final enable =
        !(state is MusicLoaded && (state as MusicLoaded).shuffleEnabled);
    await _musicService.setShuffle(enable);
    _emitUpdated(shuffleEnabled: enable);
  }

  Future<void> setLoopMode(LoopMode mode) async {
    await _musicService.setLoopMode(mode);
    _emitUpdated(loopMode: mode);
  }

  Future<void> playSong(int index) async {
    await _musicService.playSong(index);
    _emitUpdated(
      currentIndex: index,
      isPlaying: isPlaying,
      position: Duration.zero,
    );
  }

  Future<void> playPause() async {
    await _musicService.playPause();
    _emitUpdated(isPlaying: isPlaying);
  }

  Future<void> stop() async {
    if (state is! MusicLoaded) return;
    final currentState = state as MusicLoaded;
    await _musicService.stop();
    emit(currentState.copyWith(isPlaying: isPlaying, position: Duration.zero));
  }

  Future<void> skipNext() async {
    await _musicService.skipNext();
  }

  Future<void> skipPrevious() async {
    await _musicService.skipPrevious();
  }

  Future<void> seekTo(Duration position) async {
    await _musicService.seekTo(position);
    _emitUpdated(position: position);
  }

  Future<void> shufflePlay() async {
    await _musicService.shufflePlay();
  }

  Future<void> dispose() async {
    _progressTimer?.cancel();
    _musicService.dispose();
  }


  bool get isPlaying =>  _isPlaying;

  @override
  Future<void> close() {
    _songs.clear();
    _progressTimer?.cancel();
    _musicService.dispose();
    _disposeListeners();
    return super.close();
  }
  void _disposeListeners() {
    _playerStateSub?.cancel();
    _positionSub?.cancel();
    _bufferedSub?.cancel();
    _durationSub?.cancel();
    _indexSub?.cancel();
    _loopModeSub?.cancel();
    _shuffleSub?.cancel();
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '$twoDigitMinutes:$twoDigitSeconds';
  }

}
