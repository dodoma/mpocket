// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'omusic.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OmusicArtist _$OmusicArtistFromJson(Map<String, dynamic> json) => OmusicArtist()
  ..name = json['name'] as String
  ..avt = json['avt'] as String;

Map<String, dynamic> _$OmusicArtistToJson(OmusicArtist instance) =>
    <String, dynamic>{
      'name': instance.name,
      'avt': instance.avt,
    };

Omusic _$OmusicFromJson(Map<String, dynamic> json) => Omusic()
  ..deviceID = json['deviceID'] as String
  ..countArtist = json['countArtist'] as num
  ..countAlbum = json['countAlbum'] as num
  ..countSong = json['countSong'] as num
  ..localPlay = json['localPlay'] as bool
  ..artists = (json['artists'] as List<dynamic>)
      .map((e) => OmusicArtist.fromJson(e as Map<String, dynamic>))
      .toList();

Map<String, dynamic> _$OmusicToJson(Omusic instance) => <String, dynamic>{
      'deviceID': instance.deviceID,
      'countArtist': instance.countArtist,
      'countAlbum': instance.countAlbum,
      'countSong': instance.countSong,
      'localPlay': instance.localPlay,
      'artists': instance.artists,
    };
