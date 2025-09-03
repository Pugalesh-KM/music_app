// import 'dart:async';
// import 'dart:developer';
//
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:get_it/get_it.dart';
// import 'package:music_app/core/constants/repeat_enum.dart';
// import 'package:music_app/core/services/music_service.dart';
// import 'package:music_app/features/music/data/models/music_model.dart';
// import 'package:music_app/features/music/domain/usecases/music_use_case.dart';
// import 'package:music_app/shared/models/song_model.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// part 'music_state.dart';
//
// class MusicCubit extends Cubit<MusicState> {
//   final MusicUseCase _useCase;
//   final MusicService _musicService;
//
//   Timer? _progressTimer;
//   final Set<int> _favoriteSongIds = {};
//
//   MusicCubit(this._useCase)
//       : _musicService = GetIt.instance<MusicService>(),
//         super(MusicInitial()) {
//     _startProgressTimer();
//   }
//
//   Future<void> checkPermissionAndScan() async {
//     final status = await Permission.storage.request();
//     final status1 = await Permission.audio.request();
//
//     if (status.isGranted || status1.isGranted) {
//       await scanForSongs();
//     } else {
//       log("Storage permission $status : Audio permission $status1");
//       emit(
//         MusicError("Storage permission $status : Audio permission $status1"),
//       );
//     }
//   }
//
//   void _startProgressTimer() {
//     _progressTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
//       if (state is MusicLoaded && (state as MusicLoaded).isPlaying) {
//         _updateProgress();
//       }
//     });
//   }
//
//   Future<void> _updateProgress() async {
//     if (state is! MusicLoaded) return;
//
//     final position = await _musicService.getCurrentPosition();
//     final duration = await _musicService.getCurrentDuration();
//
//     if (state is MusicLoaded) {
//       final currentState = state as MusicLoaded;
//
//       if (duration.inMilliseconds > 0 &&
//           position.inMilliseconds >= duration.inMilliseconds - 500) {
//         switch (_musicService.repeatMode) {
//           case RepeatMode.one:
//             await seekTo(Duration.zero);
//             await playSong(currentState.currentIndex);
//             break;
//
//           case RepeatMode.all:
//             await skipNext();
//             break;
//
//           case RepeatMode.off:
//             if (currentState.currentIndex ==
//                 currentState.songs.data.length - 1) {
//               await stop();
//             } else {
//               await skipNext();
//             }
//             break;
//         }
//         return;
//       }
//
//       emit(currentState.copyWith(position: position, duration: duration));
//     }
//   }
//
//   Future<void> scanForSongs() async {
//     emit(MusicLoading());
//     final result = await _useCase.scanForSongs();
//     result.fold(
//           (e) => emit(MusicError(e.message)),
//           (songs) =>
//           emit(MusicLoaded(songs: songs, currentIndex: 0, isPlaying: false)),
//     );
//   }
//
//   Future<void> playSong(int index) async {
//     if (state is! MusicLoaded) return;
//
//     final currentState = state as MusicLoaded;
//     if (index < 0 || index >= currentState.songs.data.length) return;
//
//     final song = currentState.songs.data[index];
//     _musicService.currentSongId = song.id;
//     emit(
//       currentState.copyWith(
//         currentIndex: index,
//         isPlaying: true,
//         position: Duration.zero,
//       ),
//     );
//     await _musicService.playSong(index);
//   }
//
//   Future<void> playPause() async {
//     if (state is! MusicLoaded) return;
//     final currentState = state as MusicLoaded;
//     emit(currentState.copyWith(isPlaying: !_musicService.audioPlayer.playing));
//     await _musicService.playPause();
//   }
//
//   Future<void> stop() async {
//     if (state is! MusicLoaded) return;
//
//     final currentState = state as MusicLoaded;
//     await _musicService.stop();
//     emit(currentState.copyWith(isPlaying: false, position: Duration.zero));
//   }
//
//   Future<void> skipNext() async {
//     if (state is! MusicLoaded) return;
//
//     final currentState = state as MusicLoaded;
//     if (currentState.songs.data.isEmpty) return;
//
//     final nextIndex =
//         (currentState.currentIndex + 1 + currentState.songs.data.length) %
//             currentState.songs.data.length;
//     emit(currentState.copyWith(currentIndex: nextIndex, isPlaying: true));
//
//     await _musicService.skipNext();
//   }
//
//   Future<void> skipPrevious() async {
//     if (state is! MusicLoaded) return;
//
//     final currentState = state as MusicLoaded;
//     if (currentState.songs.data.isEmpty) return;
//     final prevIndex =
//         (currentState.currentIndex - 1 + currentState.songs.data.length) %
//             currentState.songs.data.length;
//     log('prevIndex: $prevIndex');
//     emit(currentState.copyWith(currentIndex: prevIndex, isPlaying: true));
//     await _musicService.skipPrevious();
//   }
//
//   Future<void> seekTo(Duration position) async {
//     if (state is! MusicLoaded) return;
//
//     final currentState = state as MusicLoaded;
//     await _musicService.seekTo(position);
//     emit(currentState.copyWith(position: position));
//   }
//
//   Future<void> shufflePlayList() async {
//     if (state is! MusicLoaded) return;
//
//     final currentState = state as MusicLoaded;
//
//     final currentSong = _musicService.currentSong;
//     _musicService.shufflePlayList();
//
//     final shuffledData = _musicService.songs;
//
//     _musicService.currentSongId = currentSong?.id ?? 0;
//
//     emit(
//       currentState.copyWith(
//         songs: MusicModel(
//           message: currentState.songs.message,
//           status: currentState.songs.status,
//           data: shuffledData,
//         ),
//         currentIndex: shuffledData.indexWhere((s) => s.id == _musicService.currentSongId),
//       ),
//     );
//   }
//
//   Future<void> getCurrentPlaybackInfo() async {
//     if (state is! MusicLoaded) return;
//
//     bool isPlaying = await _musicService.playPause();
//     final position = await _musicService.getCurrentPosition();
//     final duration = await _musicService.getCurrentDuration();
//
//     if (state is MusicLoaded) {
//       final currentState = state as MusicLoaded;
//       emit(
//         currentState.copyWith(
//           isPlaying: isPlaying,
//           position: position,
//           duration: duration,
//         ),
//       );
//     }
//   }
//
//   void toggleRepeatMode() {
//     _musicService.toggleRepeatMode();
//     if (state is MusicLoaded) {
//       emit((state as MusicLoaded).copyWith());
//     }
//   }
//
//   void toggleFavorite(SongModel song) {
//     if (_favoriteSongIds.contains(song.id)) {
//       _favoriteSongIds.remove(song.id);
//     } else {
//       _favoriteSongIds.add(song.id);
//     }
//     if (state is MusicLoaded) {
//       emit((state as MusicLoaded).copyWith());
//     }
//   }
//
//   List<SongModel> get favoriteSongs {
//     if (state is MusicLoaded) {
//       return (state as MusicLoaded)
//           .songs
//           .data
//           .where((s) => _favoriteSongIds.contains(s.id))
//           .toList();
//     }
//     return [];
//   }
//
//   void playSongFromFavorites(SongModel song) {
//     final index = allSongs.indexWhere((s) => s.id == song.id);
//     if (index != -1) {
//       playSong(index);
//     }
//   }
//
//   bool isFavorite(SongModel song) => _favoriteSongIds.contains(song.id);
//
//   SongModel get currentSong => state is MusicLoaded
//       ? (state as MusicLoaded).songs.data.firstWhere(
//         (s) => s.id == _musicService.currentSongId,
//     orElse: () => (state as MusicLoaded).songs.data.first,
//   )
//       : SongModel(
//     id: 0,
//     title: '',
//     artist: '',
//     album: '',
//     path: '',
//     duration: Duration.zero,
//     coverImage: '',
//     lyrics: '',
//   );
//
//   bool get isPlaying =>
//       state is MusicLoaded && (state as MusicLoaded).isPlaying;
//
//   RepeatMode get repeatMode => _musicService.repeatMode;
//
//   int get currentIndex =>
//       state is MusicLoaded ? (state as MusicLoaded).currentIndex : 0;
//
//   List<SongModel> get allSongs => _musicService.songs;
//
//   Duration get currentPosition =>
//       state is MusicLoaded ? (state as MusicLoaded).position : Duration.zero;
//
//   Duration get currentDuration =>
//       state is MusicLoaded ? (state as MusicLoaded).duration : Duration.zero;
//
//   double get progress => currentDuration.inSeconds > 0
//       ? currentPosition.inSeconds / currentDuration.inSeconds
//       : 0.0;
//
//   Future<void> dispose() async {
//     _progressTimer?.cancel();
//     _musicService.dispose();
//   }
//
//   @override
//   Future<void> close() {
//     _progressTimer?.cancel();
//     return super.close();
//   }
//
//   String formatDuration(Duration duration) {
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
//     String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
//     return '$twoDigitMinutes:$twoDigitSeconds';
//   }
// }
