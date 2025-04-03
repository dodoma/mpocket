import 'package:json_annotation/json_annotation.dart';
import 'package:mpocket/config/language.dart';

part 'profile.g.dart';

@JsonSerializable()
class Profile {
  Profile();

  late String appDir;
  late String msourceID;
  late String defaultLibrary;
  late String storeDir;
  late LanguageData language;
  late bool phonePlay;
  String? lastLogin;
  
  factory Profile.fromJson(Map<String,dynamic> json) => _$ProfileFromJson(json);
  Map<String, dynamic> toJson() => _$ProfileToJson(this);
}
