// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'omusic_album.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Omusic_track _$Omusic_trackFromJson(Map<String, dynamic> json) => Omusic_track()
  ..id = json['id'] as String
  ..title = json['title'] as String
  ..duration = json['duration'] as String;

Map<String, dynamic> _$Omusic_trackToJson(Omusic_track instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'duration': instance.duration,
    };

OmusicAlbum _$OmusicAlbumFromJson(Map<String, dynamic> json) => OmusicAlbum()
  ..title = json['title'] as String
  ..artist = json['artist'] as String
  ..cover = json['cover'] as String
  ..PD = json['PD'] as String
  ..countTrack = json['countTrack'] as num
  ..tracks = (json['tracks'] as List<dynamic>)
      .map((e) => Omusic_track.fromJson(e as Map<String, dynamic>))
      .toList();

Map<String, dynamic> _$OmusicAlbumToJson(OmusicAlbum instance) =>
    <String, dynamic>{
      'title': instance.title,
      'artist': instance.artist,
      'cover': instance.cover,
      'PD': instance.PD,
      'countTrack': instance.countTrack,
      'tracks': instance.tracks,
    };
