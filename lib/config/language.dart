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
    current = value;
    notifyListeners();
    print("language changeddd");
}

  /// Currently selected & displayed [Language].
  late LanguageData current;

  @override
  // ignore: must_call_super
  void dispose() {}
}
