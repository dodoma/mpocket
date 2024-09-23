import 'package:json_annotation/json_annotation.dart';

part 'omusic_albumn.g.dart';

@JsonSerializable()
class Omusic_track {
  Omusic_track();

  late String name;
  late String duration;
  
  factory Omusic_track.fromJson(Map<String,dynamic> json) => _$Omusic_trackFromJson(json);
  Map<String, dynamic> toJson() => _$Omusic_trackToJson(this);
}

@JsonSerializable()
class OmusicAlbumn {
  OmusicAlbumn();

  late String albumn;
  late String artist;
  late String PD;
  late num countTrack;
  late List<Omusic_track> tracks;

  factory OmusicAlbumn.fromJson(Map<String, dynamic> json) => _$OmusicAlbumnFromJson(json);
  Map<String, dynamic> toJson() => _$OmusicAlbumnToJson(this);
}
