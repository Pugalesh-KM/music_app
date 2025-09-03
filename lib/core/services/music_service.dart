import 'dart:developer';
import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/shared/models/song_model.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class MusicService extends BaseAudioHandler with QueueHandler, SeekHandler{
  static Future<void> init() async {
    final status = await Permission.storage.request();
    final status1 = await Permission.audio.request();
    final status2 = await Permission.manageExternalStorage.request();

    log(
      "Storage permission $status \n Audio permission $status1 \n ManageExternalStorage permission $status2",
    );
  }

  final AudioPlayer _audioPlayer = AudioPlayer();

  List<SongModel> _songs = [];

  AudioPlayer get audioPlayer => _audioPlayer;

  List<SongModel> get songs => _songs;

  int _songIdCounter = 0;
  int get currentIndex => _audioPlayer.currentIndex ?? 0;

  int _currentIndex = 0;
  Future<void> setPlaylist(List<SongModel> songs, {int startIndex = 0}) async {
    _songs = List.from(songs);
    _currentIndex = startIndex.clamp(0, _songs.length - 1);

    // Convert SongModel list to AudioSource list
    final audioSources = _songs.map((song) {
      return AudioSource.uri(Uri.file(song.path),
          tag: MediaItem(
            id: song.id.toString(),
            album: song.album,
            title: song.title,
            artist: song.artist,
            artUri: song.coverImage.isNotEmpty ? Uri.file(song.coverImage) : null,
          ));
    }).toList();

    // Create a ConcatenatingAudioSource for the playlist
    final playlistSource = ConcatenatingAudioSource(children: audioSources);

    try {
      await _audioPlayer.stop();
      await _audioPlayer.setAudioSource(playlistSource, initialIndex: _currentIndex);
    } catch (e) {
      log('Error setting playlist: $e');
    }
  }

  Future<List<SongModel>> scanDeviceForAudio() async {
    _songs.clear();
    _songIdCounter = 0;

    // Get external storage directory
    Directory? externalDir = await getExternalStorageDirectory();
    if (externalDir == null) return [];

    // Compute root path (usually /storage/emulated/0)
    String rootPath = externalDir.path.split('Android').first;
    Directory rootDir = Directory(rootPath);

    log('Scanning root directory: $rootDir');
    // Public directories to scan
    List<Directory> dirsToScan = [
      rootDir,
      Directory('${rootDir.path}Music'),
      Directory('${rootDir.path}Audio'),
      Directory('${rootDir.path}Download'),
      Directory('${rootDir.path}Podcasts'),
      Directory('${rootDir.path}Ringtones'),
      Directory('${rootDir.path}Notifications'),
      Directory('${rootDir.path}Alarms'),
      Directory('${rootDir.path}songs')
    ];

    List<SongModel> allTracks = [];
    for (var dir in dirsToScan) {
      if (dir.existsSync()) {
        log('Scanning ${dir.path}...');
        allTracks.addAll(await _scanAudioFiles(dir));
      }
    }

    allTracks = _removeDuplicate(allTracks);
    allTracks.sort(
      (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
    );

    log('Found ${allTracks.length} audio files.');
    //_songs =allTracks;

    return allTracks;
  }

  Future<List<SongModel>> _scanAudioFiles(Directory dir) async {
    List<SongModel> audioFiles = [];
    final protectedPaths = [
      '/storage/emulated/0/Android/data',
      '/storage/emulated/0/Android/obb',
    ];

    if (!dir.existsSync()) {
      log('Directory does not exist: ${dir.path}');
      return audioFiles;
    }

    try {
      await for (var entity in dir.list(recursive: true, followLinks: false)) {
        if (protectedPaths.any((p) => entity.path.startsWith(p))) continue;

        if (entity is File && _isAudioFile(entity.path)) {
          try {
            final song = await _createSongFromFile(entity);
            if (song != null) {
              audioFiles.add(song);
            }
          } catch (e) {
            log("Error processing file ${entity.path}: $e");
          }
        }
      }
    } catch (e) {
      log('Error scanning ${dir.path}: $e');
    }

    return audioFiles;
  }

  bool _isAudioFile(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    final audioExtension = ['.mp3'];

    /// ,'.wav','.flac','.acc','.ogg','.mp4','.wma','.opus','.amr'
    return audioExtension.contains(extension);
  }

  Future<SongModel?> _createSongFromFile(File file) async {
    try {
      final fileName = path.basenameWithoutExtension(file.path);
      String title = fileName;
      String artist = "";
      String album = "";
      Duration duration = Duration.zero;
      String coverImage = "";
      String lyrics = 'no lyrics';
      try {
        final metadata = readMetadata(file, getImage: true);
        title = metadata.title ?? title;
        artist = metadata.artist ?? artist;
        album = metadata.album ?? album;
        duration = metadata.duration ?? duration;
        lyrics = metadata.lyrics ?? lyrics;
        if (metadata.pictures.isNotEmpty) {
          try {
            final pic = metadata.pictures.first;
            final ext = _extFromMime(pic.mimetype);
            final imgFile = File(
              '${Directory.systemTemp.path}/${DateTime.now().millisecondsSinceEpoch}.$ext',
            );
            await imgFile.writeAsBytes(pic.bytes);
            coverImage = imgFile.path;
          } catch (imgErr) {
            coverImage = '';
            log("Error saving cover image for ${file.path}: $imgErr");
          }
        }
      } catch (e) {
        if (fileName.contains('-')) {
          final parts = fileName.split('-');
          if (parts.length >= 2) {
            artist = parts[0].trim();
            title = parts.sublist(1).join('-').trim();
          }
        }
      }

      final id = _songIdCounter++;
      log("Song no - $id : ${file.path}");

      return SongModel(
        id: id,
        title: title,
        artist: artist,
        album: album,
        path: file.path,
        duration: duration,
        coverImage: coverImage,
        lyrics: lyrics,
      );
    } catch (e) {
      log("Error creating song from file ${file.path}: $e");
      return null;
    }
  }

  String _extFromMime(String mime) {
    switch (mime) {
      case 'image/png':
        return 'png';
      case 'image/jpeg':
      case 'image/jpg':
        return 'jpg';
      default:
        return 'bin';
    }
  }

  List<SongModel> _removeDuplicate(List<SongModel> songs) {
    final seen = <String>{};
    return songs.where((song) {
      final fileName = path.basenameWithoutExtension(song.path).toLowerCase();
      final key = '${song.duration.inSeconds}-$fileName';
      return seen.add(key);
    }).toList();
  }

  Future<void> playSong(int index) async {
    if (_songs.isEmpty || index < 0 || index >= _songs.length) return;
    await _audioPlayer.seek(Duration.zero, index: index);
    await _audioPlayer.play();
  }

  Future<void> playPause() async {
    if (_audioPlayer.playing) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

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
  Future<void> setShuffle(bool enable) async {
    await _audioPlayer.setShuffleModeEnabled(enable);
    if (enable) {
      await _audioPlayer.shuffle();
    }
  }

  LoopMode get loopMode => _audioPlayer.loopMode;
  bool get shuffleEnabled => _audioPlayer.shuffleModeEnabled;

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
    _songIdCounter = 0;
  }

  MusicService() {
    _listenForCurrentSongIndexChanges();
    _audioPlayer.playbackEventStream.listen(_broadcastState);

    // Automatically skip to next song when current finishes
    _audioPlayer.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _audioPlayer.seekToNext();
      }
    });
  }

 UriAudioSource _createAudioSource(MediaItem item){
    return ProgressiveAudioSource(Uri.parse(item.id));
 }

 void _listenForCurrentSongIndexChanges(){
    _audioPlayer.currentIndexStream.listen((index) {
      final playlist = queue.value;
      if (index == null || playlist.isEmpty) {
        return;
      }
      mediaItem.add(playlist[index]);
    });
 }

 void _broadcastState(PlaybackEvent event){
    playbackState.add(
        playbackState.value.copyWith(
          controls: [
            MediaControl.skipToPrevious,
            if (_audioPlayer.playing) MediaControl.pause else MediaControl.play,
            MediaControl.skipToNext
          ],
          systemActions: {
            MediaAction.seek,
            MediaAction.seekForward,
            MediaAction.seekBackward,
          },
          androidCompactActionIndices: [0, 1, 2],
          processingState:{
            ProcessingState.idle : AudioProcessingState.idle,
            ProcessingState.loading :AudioProcessingState.loading,
            ProcessingState.buffering:AudioProcessingState.buffering,
            ProcessingState.ready:AudioProcessingState.ready,
            ProcessingState.completed:AudioProcessingState.completed,
          }[_audioPlayer.processingState]!,
          playing: _audioPlayer.playing,
          updatePosition: _audioPlayer.position,
          bufferedPosition: _audioPlayer.bufferedPosition,
          speed: _audioPlayer.speed,
          queueIndex: event.currentIndex,
        ),
    );
 }

 Future<void> initSongs(List<MediaItem> songs1) async{
    _audioPlayer.playbackEventStream.listen(_broadcastState);
    final audioSource = songs1.map(_createAudioSource).toList();

    await _audioPlayer.setAudioSource(ConcatenatingAudioSource(children: audioSource));

    queue.value.clear();
    queue.value.addAll(songs1);
    queue.add(queue.value);

    _listenForCurrentSongIndexChanges();

    _audioPlayer.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _audioPlayer.seekToNext();
      }
    });
 }

}
