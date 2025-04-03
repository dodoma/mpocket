import 'dart:convert';
import 'dart:ui';

import 'package:mpocket/config/language.dart';
import 'package:mpocket/models/index.dart';
import 'package:mpocket/models/teachnote.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Global {
  static late SharedPreferences _prefs;
  static Profile profile = Profile();
  static List<TeachNote> tnotes = [];

  static Future init(appdir) async {
    _prefs = await SharedPreferences.getInstance();
    //_prefs.remove('Profile');
    var _profile = _prefs.getString('Profile');
    if (_profile != null) {
      profile = Profile.fromJson(jsonDecode(_profile));
      print('profile gotted');
      print(profile.toJson());
    } else {
      // lookup system default language, or, en_US when no such language file
      Set<LanguageData> languages = await Language.instance.available;
      LanguageData lang = languages.firstWhere(
        (lang) => lang.code == PlatformDispatcher.instance.locale.toString(),
        orElse: () => LanguageData(code: 'en_US', name: 'English', country: 'United States'),
      );
  
      profile = Profile();
      profile.appDir = appdir;
      profile.msourceID = '';
      profile.defaultLibrary = '';
      profile.storeDir = '';
      profile.language = lang;
      profile.phonePlay = false;
      print(profile.toJson());
      saveProfile();
    }

    var _teachnote = _prefs.getString('TeachNotes');
    if (_teachnote != null) {
      List<dynamic> rawList = jsonDecode(_teachnote);
      tnotes = rawList.map((e) => TeachNote.fromJson(e)).toList();
      print('teach notes loaded');
      print(tnotes.map((note) => note.toJson()).toList());
    } else {
      print('teach notes EMPTY');
    }
  }

  static saveProfile() {
    _prefs.setString('Profile', jsonEncode(profile.toJson()));
    print('profile setted');
    print(profile.toJson());
  }

  static saveTeachNotes() {
    _prefs.setString('TeachNotes', jsonEncode(tnotes.map((note) => note.toJson()).toList()));
    print('teach notes setted');
    print(tnotes.map((note) => note.toJson()).toList());
  }
}