// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'omusic_albumn.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Omusic_track _$Omusic_trackFromJson(Map<String, dynamic> json) => Omusic_track()
  ..name = json['name'] as String
  ..duration = json['duration'] as String;

Map<String, dynamic> _$Omusic_trackToJson(Omusic_track instance) =>
    <String, dynamic>{
      'name': instance.name,
      'duration': instance.duration,
    };

OmusicAlbumn _$OmusicAlbumnFromJson(Map<String, dynamic> json) => OmusicAlbumn()
  ..albumn = json['albumn'] as String
  ..artist = json['artist'] as String
  ..PD = json['PD'] as String
  ..countTrack = json['countTrack'] as num
  ..tracks = (json['tracks'] as List<dynamic>)
      .map((e) => Omusic_track.fromJson(e as Map<String, dynamic>))
      .toList();

Map<String, dynamic> _$OmusicAlbumnToJson(OmusicAlbumn instance) =>
    <String, dynamic>{
      'albumn': instance.albumn,
      'artist': instance.artist,
      'PD': instance.PD,
      'countTrack': instance.countTrack,
      'tracks': instance.tracks,
    };
