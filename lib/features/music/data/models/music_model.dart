import 'dart:convert';
import 'package:music_app/shared/models/song_model.dart';

MusicModel musicModelFromJson(String str) =>
    MusicModel.fromJson(json.decode(str));

String musicModelToJson(MusicModel data) =>
    json.encode(data.toJson());

class MusicModel {
  final String? message;
  final int? status;
  final List<SongModel> data;

  const MusicModel({
    this.message,
    this.status,
    required this.data, // default empty list
  });

  factory MusicModel.fromJson(dynamic json) {
    return MusicModel(
      message: json['message'] as String?,
      status: json['status'] as int?,
      data: (json['data'] as List<dynamic>?)
          ?.map((v) => SongModel.fromJson(v))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'status': status,
      'data': data.map((v) => v.toJson()).toList(),
    };
  }
}
