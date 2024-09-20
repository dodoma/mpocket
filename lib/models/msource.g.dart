// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'msource.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MsourceLibrary _$MsourceLibraryFromJson(Map<String, dynamic> json) =>
    MsourceLibrary()
      ..name = json['name'] as String
      ..space = json['space'] as String
      ..countSong = (json['countSong'] as num).toInt()
      ..countCached = (json['countCached'] as num).toInt()
      ..dft = json['dft'] as bool;

Map<String, dynamic> _$MsourceLibraryToJson(MsourceLibrary instance) =>
    <String, dynamic>{
      'name': instance.name,
      'space': instance.space,
      'countSong': instance.countSong,
      'countCached': instance.countCached,
      'dft': instance.dft,
    };

Msource _$MsourceFromJson(Map<String, dynamic> json) => Msource()
  ..deviceID = json['deviceID'] as String
  ..deviceName = json['deviceName'] as String
  ..capacity = json['capacity'] as String
  ..useage = json['useage'] as String
  ..percent = (json['percent'] as num).toDouble()
  ..usbON = json['usbON'] as bool
  ..autoPlay = json['autoPlay'] as bool
  ..shareLocation = json['shareLocation'] as String
  ..libraries = (json['libraries'] as List<dynamic>)
      .map((e) => MsourceLibrary.fromJson(e as Map<String, dynamic>))
      .toList();

Map<String, dynamic> _$MsourceToJson(Msource instance) => <String, dynamic>{
      'deviceID': instance.deviceID,
      'deviceName': instance.deviceName,
      'capacity': instance.capacity,
      'useage': instance.useage,
      'percent': instance.percent,
      'usbON': instance.usbON,
      'autoPlay': instance.autoPlay,
      'shareLocation': instance.shareLocation,
      'libraries': instance.libraries,
    };
