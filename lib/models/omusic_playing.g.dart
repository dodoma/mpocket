// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'omusic_playing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OmusicPlaying _$OmusicPlayingFromJson(Map<String, dynamic> json) =>
    OmusicPlaying()
      ..title = json['title'] as String
      ..cover = json['cover'] as String
      ..artist = json['artist'] as String
      ..album = json['album'] as String
      ..file_type = json['file_type'] as String
      ..bps = json['bps'] as String
      ..rate = json['rate'] as String
      ..duration = json['duration'] as String
      ..now_at = json['now_at'] as String
      ..volume = json['volume'] as double
      ..progress = json['progress'] as double;

Map<String, dynamic> _$OmusicPlayingToJson(OmusicPlaying instance) =>
    <String, dynamic>{
      'title': instance.title,
      'cover': instance.cover,
      'artist': instance.artist,
      'album': instance.album,
      'file_type': instance.file_type,
      'bps': instance.bps,
      'rate': instance.rate,
      'duration': instance.duration,
      'now_at': instance.now_at,
      'volume': instance.volume,
      'progress': instance.progress,
    };
