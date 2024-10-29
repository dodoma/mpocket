// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'omusic_playing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OmusicPlaying _$OmusicPlayingFromJson(Map<String, dynamic> json) =>
    OmusicPlaying()
      ..title = json['title'] as String
      ..id = json['id'] as String
      ..artist = json['artist'] as String
      ..album = json['album'] as String
      ..file_type = json['file_type'] as String
      ..bps = json['bps'] as String
      ..rate = json['rate'] as String
      ..length = json['length'] as num
      ..pos = json['pos'] as num
      ..volume = json['volume'] as double;

Map<String, dynamic> _$OmusicPlayingToJson(OmusicPlaying instance) =>
    <String, dynamic>{
      'title': instance.title,
      'id': instance.id,
      'artist': instance.artist,
      'album': instance.album,
      'file_type': instance.file_type,
      'bps': instance.bps,
      'rate': instance.rate,
      'length': instance.length,
      'pos': instance.pos,
      'volume': instance.volume,
    };
