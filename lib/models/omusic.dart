import 'package:json_annotation/json_annotation.dart';

part 'omusic.g.dart';

@JsonSerializable()
class OmusicArtist {
  OmusicArtist();

  late String name;
  late String avt;

  factory OmusicArtist.fromJson(Map<String, dynamic> json) => _$OmusicArtistFromJson(json);
  Map<String, dynamic> toJson() => _$OmusicArtistToJson(this);
}

@JsonSerializable()
class Omusic {
  Omusic();

  late String deviceID;
  late num countArtist;
  late num countAlbum;
  late num countSong;
  late bool localPlay;
  late List<OmusicArtist> artists;
  
  factory Omusic.fromJson(Map<String,dynamic> json) => _$OmusicFromJson(json);
  Map<String, dynamic> toJson() => _$OmusicToJson(this);
}
