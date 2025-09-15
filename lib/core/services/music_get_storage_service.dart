import 'dart:developer';
import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:music_app/shared/models/song_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';

class MusicGetStorageService{
  final List<SongModel> _songs = [];
  List<SongModel> get songs => _songs;
  int _songIdCounter = 0;

  static Future<void> init() async {
    final statuses = await [
      Permission.audio,
      Permission.storage,
      Permission.manageExternalStorage,
    ].request();

    log("${statuses.values}");
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
      //Directory('${rootDir.path}songs')
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

}