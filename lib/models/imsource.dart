import 'package:flutter/material.dart';
//import 'package:mpocket/ffi/libmoc.dart' as libmoc;

class IMsource extends ChangeNotifier {
  String deviceID = "";
  bool _showPlaying = false;
  OmusicTrack? _onListenTrack = null;

  OmusicTrack? get onListenTrack => _onListenTrack;
  bool get showPlaying => _showPlaying;

  void updateListenTrack(OmusicTrack track) {
    _onListenTrack = track;
    notifyListeners();
  }

  void turnOffPlaying() {
    _showPlaying = false;
    notifyListeners();
  }

  void turnOnPlaying() {
    _showPlaying = true;
    notifyListeners();
  }
}

class OmusicTrack {
  OmusicTrack(this.title, this.cover, this.artist);

  late String title;
  late String cover;
  late String artist;
}