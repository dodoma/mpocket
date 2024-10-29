import 'package:json_annotation/json_annotation.dart';

part 'omusic_playing.g.dart';

@JsonSerializable()
class OmusicPlaying {
  OmusicPlaying();

  late String id;
  late String title;
  late String? cover;
  late String artist;
  late String album;
  late num length;
  late num pos;
  late String file_type;
  late String bps;
  late String rate;
  late double volume;

  factory OmusicPlaying.fromJson(Map<String, dynamic> json) => _$OmusicPlayingFromJson(json);
  Map<String, dynamic> toJson() => _$OmusicPlayingToJson(this);
}
