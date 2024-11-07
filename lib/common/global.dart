import 'dart:convert';

import 'package:mpocket/models/index.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Global {
  static late SharedPreferences _prefs;
  static Profile profile = Profile();

  static Future init(appdir) async {
    _prefs = await SharedPreferences.getInstance();
    //_prefs.remove('Profile');
    var _profile = _prefs.getString('Profile');
    if (_profile != null) {
      profile = Profile.fromJson(jsonDecode(_profile));
      print('profile gotted');
      print(profile.toJson());
    } else {
      print('default profile loaded');
      profile = Profile();
      profile.appDir = appdir;
      profile.msourceID = '';
      profile.storeDir = '';
      profile.local = 'en_US';
      profile.phonePlay = false;
      print(profile.toJson());
      saveProfile();
    }
  }

  static saveProfile() {
    _prefs.setString('Profile', jsonEncode(profile.toJson()));
    print('profile setted');
    print(profile.toJson());
  }
}