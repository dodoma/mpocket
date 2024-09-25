import 'package:json_annotation/json_annotation.dart';

part 'omusic_album.g.dart';

@JsonSerializable()
class Omusic_track {
  Omusic_track();

  late String name;
  late String duration;
  
  factory Omusic_track.fromJson(Map<String,dynamic> json) => _$Omusic_trackFromJson(json);
  Map<String, dynamic> toJson() => _$Omusic_trackToJson(this);
}

@JsonSerializable()
class OmusicAlbum {
  OmusicAlbum();

  late String name;
  late String artist;
  late String cover;
  late String PD;
  late num countTrack;
  late List<Omusic_track> tracks;

  factory OmusicAlbum.fromJson(Map<String, dynamic> json) => _$OmusicAlbumFromJson(json);
  Map<String, dynamic> toJson() => _$OmusicAlbumToJson(this);
}
