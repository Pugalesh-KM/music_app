import 'dart:convert';

SongModel songModelFromJson(String str) =>
    SongModel.fromJson(json.decode(str));

String songModelToJson(SongModel data) =>
    json.encode(data.toJson());

class SongModel {
  final int id;
  final String title;
  final String artist;
  final String album;
  final String path;
  final Duration duration;
  final String coverImage;
  final String lyrics;

  SongModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.path,
    required this.duration,
    required this.coverImage,
    required this.lyrics,
  });

  /// Factory constructor for creating a new SongModel from a map
  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      id: json['id'] ?? "",
      title: json['title'] ?? '',
      artist: json['artist'] ?? '',
      album: json['album'] ?? '',
      path: json['path'] ?? '',
      duration: Duration(milliseconds: json['duration'] ?? 0),
      coverImage: json['coverImage']??'',
      lyrics: json['lyrics'] ?? '',
    );
  }

  /// Convert this SongModel into a map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'path': path,
      'duration': duration.inMilliseconds,
      'coverImage': coverImage,
      'lyrics':lyrics,
    };
  }
}

