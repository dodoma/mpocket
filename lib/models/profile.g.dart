// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Profile _$ProfileFromJson(Map<String, dynamic> json) => Profile()
  ..msourceOK = json['msourceOK'] as bool
  ..local = json['local'] as String
  ..lastLogin = json['lastLogin'] as String?;

Map<String, dynamic> _$ProfileToJson(Profile instance) => <String, dynamic>{
      'msourceOK': instance.msourceOK,
      'local': instance.local,
      'lastLogin': instance.lastLogin,
    };
