part of 'omusicstore.dart';

OmusicStore _$OmusicStoreFromJson(Map<String, dynamic> json) =>
    OmusicStore()
      ..name = json['name'] as String
      ..path = json['path'] as String
      ..moren = json['default'] as bool?;

Map<String, dynamic> _$OmusicStoreToJson(OmusicStore instance) =>
    <String, dynamic>{
      'name': instance.name,
      'path': instance.path,
      'default': instance.moren,
    };