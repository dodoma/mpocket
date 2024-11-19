import 'package:json_annotation/json_annotation.dart';

part 'msource.g.dart';

@JsonSerializable()
class MsourceLibrary {
  MsourceLibrary();

  late String name;
  late String space;
  late int countTrack;
  late bool dft;

  factory MsourceLibrary.fromJson(Map<String, dynamic> json) => _$MsourceLibraryFromJson(json);
  Map<String, dynamic> toJson() => _$MsourceLibraryToJson(this);  
}

@JsonSerializable()
class Msource {
  Msource();

  late String deviceID;
  late String deviceName;
  late String capacity;
  late String useage;
  late String remain;
  late double percent;
  late bool usbON;
  late bool autoPlay;
  late String shareLocation;
  late List<MsourceLibrary> libraries;
  
  factory Msource.fromJson(Map<String,dynamic> json) => _$MsourceFromJson(json);
  Map<String, dynamic> toJson() => _$MsourceToJson(this);
}
