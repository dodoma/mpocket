import 'package:flutter/material.dart';
import 'package:mpocket/common/global.dart';
import 'package:mpocket/models/index.dart';

class ProfileChangeNotifier extends ChangeNotifier {
  Profile get _profile => Global.profile;

  @override
  void notifyListeners() {
    Global.saveProfile();
    super.notifyListeners();
  }
}