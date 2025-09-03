/*
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
  final int currentIndex;
  final bool isPlaying;
  final Duration position;
  final Duration duration;

  const MusicLoaded({
    required this.songs,
    this.currentIndex = 0,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
  });

  MusicLoaded copyWith({
    MusicModel? songs,
    int? currentIndex,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
  }) {
    return MusicLoaded(
      songs: songs ?? this.songs,
      currentIndex: currentIndex ?? this.currentIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
    );
  }
}

class MusicEmpty extends MusicState {
  const MusicEmpty();
}*/
