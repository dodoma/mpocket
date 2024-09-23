import 'package:json_annotation/json_annotation.dart';

part 'omusic.g.dart';

@JsonSerializable()
class Omusic_artist {
  Omusic_artist();

  late String name;
  late String avt;

  factory Omusic_artist.fromJson(Map<String, dynamic> json) => _$Omusic_artistFromJson(json);
  Map<String, dynamic> toJson() => _$Omusic_artistToJson(this);
}

@JsonSerializable()
class Omusic {
  Omusic();

  late String deviceID;
  late num countArtist;
  late num countAlbum;
  late num countTrack;
  late bool localPlay;
  late List<Omusic_artist> artists;
  
  factory Omusic.fromJson(Map<String,dynamic> json) => _$OmusicFromJson(json);
  Map<String, dynamic> toJson() => _$OmusicToJson(this);
}
