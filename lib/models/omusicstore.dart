import 'package:json_annotation/json_annotation.dart';

part 'omusicstore.g.dart';

@JsonSerializable()
class OmusicStore {
  OmusicStore();

  late String name;
  late String path;
  late bool? moren;

  factory OmusicStore.fromJson(Map<String, dynamic> json) => _$OmusicStoreFromJson(json);
  Map<String, dynamic> toJson() => _$OmusicStoreToJson(this);
}

//@JsonSerializable()
//class OmusicStore {
//  OmusicStore();

//  late List<Omusic_store_item> artists;
  
//  factory OmusicStore.fromJson(Map<String,dynamic> json) => _$OmusicStoreFromJson(json);
//  Map<String, dynamic> toJson() => _$OmusicStoreToJson(this);
//}
