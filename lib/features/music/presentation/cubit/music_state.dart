part of 'music_cubit.dart';

abstract class MusicState {
  const MusicState();
}

class MusicInitial extends MusicState {
  const MusicInitial();
}

class MusicLoading extends MusicState {
  const MusicLoading();
}

class MusicError extends MusicState {
  final String message;

  const MusicError(this.message);
}

class MusicLoaded extends MusicState {
  final MusicModel songs;
  final bool isPlaying;
  final Duration position;
  final Duration bufferedPosition;
  final Duration? duration;
  final int? currentIndex;
  final LoopMode loopMode;
  final bool shuffleEnabled;

  const MusicLoaded({
    required this.songs,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.bufferedPosition = Duration.zero,
    this.duration,
    this.currentIndex,
    this.loopMode = LoopMode.off,
    this.shuffleEnabled = false,
  });

  MusicLoaded copyWith({
    MusicModel? songs,
    bool? isPlaying,
    Duration? position,
    Duration? bufferedPosition,
    Duration? duration,
    int? currentIndex,
    LoopMode? loopMode,
    bool? shuffleEnabled,
  }) {
    return MusicLoaded(
      songs: songs ?? this.songs,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      bufferedPosition: bufferedPosition ?? this.bufferedPosition,
      duration: duration ?? this.duration,
      currentIndex: currentIndex ?? this.currentIndex,
      loopMode: loopMode ?? this.loopMode,
      shuffleEnabled: shuffleEnabled ?? this.shuffleEnabled,
    );
  }
}

class MusicEmpty extends MusicState {
  const MusicEmpty();
}