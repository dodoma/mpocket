// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'omusic.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Omusic_artist _$Omusic_artistFromJson(Map<String, dynamic> json) =>
    Omusic_artist()
      ..name = json['name'] as String
      ..cachePercent = json['cachePercent'] as double
      ..avt = json['avt'] as String;

Map<String, dynamic> _$Omusic_artistToJson(Omusic_artist instance) =>
    <String, dynamic>{
      'name': instance.name,
      'cachePercent': instance.cachePercent,
      'avt': instance.avt,
    };

Omusic _$OmusicFromJson(Map<String, dynamic> json) => Omusic()
  ..deviceID = json['deviceID'] as String
  ..countArtist = json['countArtist'] as num
  ..countAlbum = json['countAlbum'] as num
  ..countTrack = json['countTrack'] as num
  ..localPlay = json['localPlay'] as bool
  ..artists = (json['artists'] as List<dynamic>)
      .map((e) => Omusic_artist.fromJson(e as Map<String, dynamic>))
      .toList();

Map<String, dynamic> _$OmusicToJson(Omusic instance) => <String, dynamic>{
      'deviceID': instance.deviceID,
      'countArtist': instance.countArtist,
      'countAlbum': instance.countAlbum,
      'countTrack': instance.countTrack,
      'localPlay': instance.localPlay,
      'artists': instance.artists,
    };
