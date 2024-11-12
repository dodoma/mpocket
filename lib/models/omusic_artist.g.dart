// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'omusic_artist.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Omusic_album _$Omusic_albumFromJson(Map<String, dynamic> json) => Omusic_album()
  ..name = json['name'] as String
  ..PD = json['PD'] as String
  ..cover = json['cover'] as String
  ..countTrack = json['countTrack'] as num
  ..cached = json['cached'] as bool;

Map<String, dynamic> _$Omusic_albumToJson(Omusic_album instance) =>
    <String, dynamic>{
      'name': instance.name,
      'PD': instance.PD,
      'cover': instance.cover,
      'countTrack': instance.countTrack,
      'cached': instance.cached,
    };

OmusicArtist _$OmusicArtistFromJson(Map<String, dynamic> json) => OmusicArtist()
  ..artist = json['artist'] as String
  ..countAlbum = json['countAlbum'] as num
  ..countTrack = json['countTrack'] as num
  ..indisk = json['indisk'] as num
  ..avt = json['avt'] as String
  ..albums = (json['albums'] as List<dynamic>)
      .map((e) => Omusic_album.fromJson(e as Map<String, dynamic>))
      .toList();

Map<String, dynamic> _$OmusicArtistToJson(OmusicArtist instance) =>
    <String, dynamic>{
      'artist': instance.artist,
      'countAlbum': instance.countAlbum,
      'countTrack': instance.countTrack,
      'indisk': instance.indisk,
      'avt': instance.avt,
      'albums': instance.albums,
    };
