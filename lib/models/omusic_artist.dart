import 'package:json_annotation/json_annotation.dart';

part 'omusic_artist.g.dart';

@JsonSerializable()
class Omusic_album {
  Omusic_album();

  late String name;
  late String PD;
  late String cover;
  late num countTrack;
  late bool cached;
  
  factory Omusic_album.fromJson(Map<String,dynamic> json) => _$Omusic_albumFromJson(json);
  Map<String, dynamic> toJson() => _$Omusic_albumToJson(this);
}

@JsonSerializable()
class OmusicArtist {
  OmusicArtist();

  late String artist;
  late num countAlbum;
  late num countTrack;
  late String avt;
  late List<Omusic_album> albums;

  factory OmusicArtist.fromJson(Map<String, dynamic> json) => _$OmusicArtistFromJson(json);
  Map<String, dynamic> toJson() => _$OmusicArtistToJson(this);
}
