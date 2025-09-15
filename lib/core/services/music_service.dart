import 'dart:async';
import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/core/services/music_get_storage_service.dart';
import 'package:music_app/shared/models/song_model.dart';


class MusicService extends BaseAudioHandler with QueueHandler, SeekHandler{

  final AudioPlayer _audioPlayer = AudioPlayer();
  List<SongModel> _songs = [];
  List<SongModel> get songs => _songs;
  AudioPlayer get audioPlayer => _audioPlayer;
  LoopMode get loopMode => _audioPlayer.loopMode;
  bool get shuffleEnabled => _audioPlayer.shuffleModeEnabled;
  int get currentIndex => _audioPlayer.currentIndex ?? 0;

  int _currentIndex = 0;

  Future<List<SongModel>> setPlaylist({int startIndex = 0}) async {

    List<SongModel> songs = await MusicGetStorageService().scanDeviceForAudio();
    _songs = songs;
    _currentIndex = startIndex.clamp(0, _songs.length - 1);

    // Convert SongModel list to AudioSource list
    final audioSources = _songs.map((song) {
      final mediaItem = MediaItem(
        id: song.id.toString(),
        album: song.album,
        title: song.title,
        artist: song.artist,
        artUri: song.coverImage.isNotEmpty ? Uri.file(song.coverImage) : null,
      );
      return AudioSource.uri(Uri.file(song.path), tag: mediaItem);
    }).toList();

    // Create a ConcatenatingAudioSource for the playlist
    final playlistSource = ConcatenatingAudioSource(children: audioSources);

    try {
      await stop();
      await _audioPlayer.setAudioSource(playlistSource, initialIndex: _currentIndex);
      final mediaItems = audioSources.map((s) => s.tag as MediaItem).toList();
      queue.add(mediaItems);
      mediaItem.add(mediaItems[_currentIndex]);
      _listenForCurrentSongIndexChanges();
      _audioPlayer.playbackEventStream.listen(_broadcastState);
    } catch (e) {
      log('Error setting playlist: $e');
    }

    return _songs;
  }

  Future<void> playSong(int index) async {
    if (_songs.isEmpty || index < 0 || index >= _songs.length) return;
    await _audioPlayer.seek(Duration.zero, index: index);
    play();
  }

  Future<void> playPause() async {
    _audioPlayer.playing ? pause() : play();
  }
  @override
  Future<void> play() async => await _audioPlayer.play();
  @override
  Future<void> pause() async => await _audioPlayer.pause();
  @override
  Future<void> stop() async => await _audioPlayer.stop();

  Future<void> skipNext() async {
    if (_audioPlayer.loopMode == LoopMode.one) {
      await _audioPlayer.setLoopMode(LoopMode.off);
      await _audioPlayer.seekToNext();
      await _audioPlayer.setLoopMode(LoopMode.one);
    } else if(_audioPlayer.loopMode == LoopMode.off){
      await _audioPlayer.setLoopMode(LoopMode.all);
      await _audioPlayer.seekToNext();
      await _audioPlayer.setLoopMode(LoopMode.off);
    }else {
      await _audioPlayer.seekToNext();
    }
  }

  Future<void> skipPrevious() async {
    if (_audioPlayer.loopMode == LoopMode.one) {
      await _audioPlayer.setLoopMode(LoopMode.off);
      await _audioPlayer.seekToPrevious();
      await _audioPlayer.setLoopMode(LoopMode.one);
    } else if(_audioPlayer.loopMode == LoopMode.off){
      await _audioPlayer.setLoopMode(LoopMode.all);
      await _audioPlayer.seekToPrevious();
      await _audioPlayer.setLoopMode(LoopMode.off);
    }
    else {
      await _audioPlayer.seekToPrevious();
    }
  }

  Future<void> seekTo(Duration position) async => await _audioPlayer.seek(position);
  Future<void> setLoopMode(LoopMode mode) => _audioPlayer.setLoopMode(mode);

  Future<void> shufflePlay() async{
    await _audioPlayer.setShuffleModeEnabled(true);
    await _audioPlayer.shuffle();
    skipToNext();
    await _audioPlayer.seek(Duration.zero,index: _audioPlayer.shuffleIndices.first);
    play();

    playbackState.add(
      playbackState.value.copyWith(
        shuffleMode: AudioServiceShuffleMode.all,
      ),
    );
  }
  Future<void> setShuffle(bool enable) async {
    await _audioPlayer.setShuffleModeEnabled(enable);
    if (enable) {
      await _audioPlayer.shuffle();
    }
    playbackState.add(
      playbackState.value.copyWith(
        shuffleMode: enable
            ? AudioServiceShuffleMode.all
            : AudioServiceShuffleMode.none,
      ),
    );
  }

  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration> get bufferedPositionStream => _audioPlayer.bufferedPositionStream;
  Stream<int?> get currentIndexStream => _audioPlayer.currentIndexStream;
  Stream<LoopMode> get loopModeStream => _audioPlayer.loopModeStream;
  Stream<bool> get shuffleStream => _audioPlayer.shuffleModeEnabledStream;

  void dispose() {
    _audioPlayer.dispose();
    _songs.clear();
  }

  // Listen for changes in the current song index and update the media item
  void _listenForCurrentSongIndexChanges() {
    _audioPlayer.currentIndexStream.listen((index) {
      if (index != null && index < queue.value.length) {
        mediaItem.add(queue.value[index]);
      }
    });
  }

  void _broadcastState(PlaybackEvent event) {
    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        if (_audioPlayer.playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
      ],
      processingState: {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_audioPlayer.processingState]!,
      playing: _audioPlayer.playing,
      updatePosition: _audioPlayer.position,
      bufferedPosition: _audioPlayer.bufferedPosition,
      speed: _audioPlayer.speed,
      queueIndex: event.currentIndex,
    ));
  }

}






