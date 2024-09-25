import 'package:json_annotation/json_annotation.dart';

part 'omusic_playing.g.dart';

@JsonSerializable()
class OmusicPlaying {
  OmusicPlaying();

  late String title;
  late String cover;
  late String artist;
  late String album;
  late String file_type;
  late String bps;
  late String rate;
  late String duration;
  late String now_at;
  late double volume;
  late double progress;

  factory OmusicPlaying.fromJson(Map<String, dynamic> json) => _$OmusicPlayingFromJson(json);
  Map<String, dynamic> toJson() => _$OmusicPlayingToJson(this);
}
