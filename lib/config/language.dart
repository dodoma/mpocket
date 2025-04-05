import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:mpocket/config/strings.dart';

class LanguageData {
  /// Language & country code. e.g. `en-US`.
  /// This should match the name of the file.
  final String code;

  /// Language name. e.g. `English (United States)`.
  /// Must be in the same language.
  final String name;

  /// Name of the country. e.g. `United States`.
  /// Must be in the same language.
  final String country;

  const LanguageData({
    required this.code,
    required this.name,
    required this.country,
  });

  factory LanguageData.fromJson(dynamic json) => LanguageData(
        code: json['code'],
        name: json['name'],
        country: json['country'],
      );

  Map<String, String> toJson() => {
        'code': code,
        'name': name,
        'country': country,
      };

  @override
  int get hashCode => code.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is LanguageData) {
      return code == other.code;
    }
    return false;
  }
}

class Language extends Strings with ChangeNotifier {
  /// [Language] object singleton instance.
  static final Language instance= Language();

  /// Must be called before [runApp].
  static Future<void> initialize({
    required LanguageData language,
  }) =>
      instance.set(value: language);

  /// Returns all the available languages after reading the assets.
  Future<Set<LanguageData>> get available async {
    final data = await rootBundle.loadString('assets/translation/index.json');
    return Set.from(json.decode(data).map((e) => LanguageData.fromJson(e)));
  }

  /// Updates the [current] language & notifies the listeners.
  Future<void> set({
    required LanguageData value,
  }) async {
    final data = await rootBundle.loadString(
      'assets/translation/${value.code}.json',
      cache: true,
    );
    final map = json.decode(data);
    TAB_MUSIC = map['TAB_MUSIC']!;
    TAB_MSOURCE = map['TAB_MSOURCE']!;
    TAB_USER = map['TAB_USER']!;
    SOURCE_CONNECTING = map['SOURCE_CONNECTING']!;
    PLAY_ON_PHONE = map['PLAY_ON_PHONE']!;
    PLAY_ON_SOURCE = map['PLAY_ON_SOURCE']!;
    GET_DATA_FAILURE = map['GET_DATA_FAILURE']!;
    SEARCH_LIBRARY = map['SEARCH_LIBRARY']!;
    SEARCH_TRACK = map['SEARCH_TRACK']!;
    E_ARTISTS = map['E_ARTISTS']!;
    E_ALBUMS = map['E_ALBUMS']!;
    E_TRACKS = map['E_TRACKS']!;
    LIBRARY_EMPTY = map['LIBRARY_EMPTY']!;
    HOWTO_ADD_MEDIA = map['HOWTO_ADD_MEDIA']!;
    HINT = map['HINT']!;
    SELECT_AP = map['SELECT_AP']!;
    I_KNOW = map['I_KNOW']!;
    CONFIG_MSOURCE = map['CONFIG_MSOURCE']!;
    AP_NAME = map['AP_NAME']!;
    AP_PASSWD = map['AP_PASSWD']!;
    PASSWD_NOT_EMPTY = map['PASSWD_NOT_EMPTY']!;
    MSOURCE_NAME = map['MSOURCE_NAME']!;
    DEFAULT_SOURCE_NAME = map['DEFAULT_SOURCE_NAME']!;
    WIFI_OK = map['WIFI_OK']!;
    WIFI_NOK = map['WIFI_NOK']!;
    CONFIRM = map['CONFIRM']!;
    SEARCHING_MSOURCE = map['SEARCHING_MSOURCE']!;
    CONNECT_WIFI_TO_SET = map['CONNECT_WIFI_TO_SET']!;
    LIBRARY_EXIST = map['LIBRARY_EXIST']!;
    LIBRARY_ADD = map['LIBRARY_ADD']!;
    GIVE_LIBRARY_NAME = map['GIVE_LIBRARY_NAME']!;
    CREATE_OK = map['CREATE_OK']!;
    CANCLE = map['CANCLE']!;
    MERGE = map['MERGE']!;
    CHOSE_DEST_LIBRARY = map['CHOSE_DEST_LIBRARY']!;
    RENAME_LIBRARY = map['RENAME_LIBRARY']!;
    MODIFY_OK = map['MODIFY_OK']!;
    LIBRARY_SYNC_A = map['LIBRARY_SYNC_A']!;
    LIBRARY_SYNC_B = map['LIBRARY_SYNC_B']!;
    LIBRARY_CLEAR_A = map['LIBRARY_CLEAR_A']!;
    LIBRARY_CLEAR_B = map['LIBRARY_CLEAR_B']!;
    CLEAR_OK_A = map['CLEAR_OK_A']!;
    CLEAR_OK_B = map['CLEAR_OK_B']!;
    LIBRARY_DELTE_A = map['LIBRARY_DELTE_A']!;
    LIBRARY_DELTE_B = map['LIBRARY_DELTE_B']!;
    BUILDING = map['BUILDING']!;
    CAP_USED = map['CAP_USED']!;
    CAP_AVAILABLE = map['CAP_AVAILABLE']!;
    CAP_TOTAL = map['CAP_TOTAL']!;
    AUTO_PLAY = map['AUTO_PLAY']!;
    SET_FAILURE = map['SET_FAILURE']!;
    SHARE_URL = map['SHARE_URL']!;
    COPY_UDISK = map['COPY_UDISK']!;
    LIBRARY_DEFAULT = map['LIBRARY_DEFAULT']!;
    LIBRARY_RENAME = map['LIBRARY_RENAME']!;
    LIBRARY_CACHE = map['LIBRARY_CACHE']!;
    LIBRARY_CLEAR = map['LIBRARY_CLEAR']!;
    LIBRARY_DELETE = map['LIBRARY_DELETE']!;
    LIBRARY_MERGE = map['LIBRARY_MERGE']!;
    LIBRARY_CREATE = map['LIBRARY_CREATE']!;

    CACHED = map['CACHED']!;
    TRACK_NUM = map['TRACK_NUM']!;
    ARTIST_DELETE = map['ARTIST_DELETE']!;
    NEXT_PLAY = map['NEXT_PLAY']!;
    ARTIST = map['ARTIST']!;
    ALBUM = map['ALBUM']!;
    TRACK = map['TRACK']!;
    NO_RESULT = map['NO_RESULT']!;

    current = value;
    notifyListeners();
}

  /// Currently selected & displayed [Language].
  late LanguageData current;

  @override
  // ignore: must_call_super
  void dispose() {}
}
