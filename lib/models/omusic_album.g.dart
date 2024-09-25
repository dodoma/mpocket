// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'omusic_album.dart';

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

OmusicAlbum _$OmusicAlbumFromJson(Map<String, dynamic> json) => OmusicAlbum()
  ..name = json['name'] as String
  ..artist = json['artist'] as String
  ..cover = json['cover'] as String
  ..PD = json['PD'] as String
  ..countTrack = json['countTrack'] as num
  ..tracks = (json['tracks'] as List<dynamic>)
      .map((e) => Omusic_track.fromJson(e as Map<String, dynamic>))
      .toList();

Map<String, dynamic> _$OmusicAlbumToJson(OmusicAlbum instance) =>
    <String, dynamic>{
      'name': instance.name,
      'artist': instance.artist,
      'cover': instance.cover,
      'PD': instance.PD,
      'countTrack': instance.countTrack,
      'tracks': instance.tracks,
    };
