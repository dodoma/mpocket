// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Profile _$ProfileFromJson(Map<String, dynamic> json) => Profile()
  ..appDir = json['appDir'] as String
  ..msourceID = json['msourceID'] as String
  ..defaultLibrary = json['defaultLibrary'] as String
  ..storeDir = json['storeDir'] as String
  ..language = LanguageData.fromJson(json['language'] as Map<String, dynamic>)
  ..phonePlay = json['phonePlay'] as bool
  ..lastLogin = json['lastLogin'] as String?;

Map<String, dynamic> _$ProfileToJson(Profile instance) => <String, dynamic>{
      'appDir': instance.appDir,
      'msourceID': instance.msourceID,
      'defaultLibrary': instance.defaultLibrary,
      'storeDir': instance.storeDir,
      'language': instance.language.toJson(),
      'phonePlay': instance.phonePlay,
      'lastLogin': instance.lastLogin,
    };
