//import 'package:mpocket/ffi/libmoc.dart' as libmoc;
import 'dart:convert';
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:mpocket/common/global.dart';
import 'package:mpocket/ffi/libmoc.dart' as libmoc;

typedef NativePlayInfoCallback = Void Function(Pointer<Utf8>, Int, Pointer<Utf8>, Pointer<Utf8>);

class IMsource extends ChangeNotifier {
  String deviceID = "";
  bool _showPlaying = false;
  OmusicTrack? _onListenTrack = null;

  OmusicTrack? get onListenTrack => _onListenTrack;
  bool get showPlaying => _showPlaying;

  void updateListenTrack(OmusicTrack track) {
    _onListenTrack = track;
    _onListenTrack!.cover = Global.profile.storeDir + "assets/cover/" + track.id;
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

  void changeDevice (String id) async {
    deviceID = id;

    await libmoc.mnetStoreList(deviceID);
    await libmoc.mnetStoreSync(Global.profile.msourceID, "默认媒体库");

    void onResponse(Pointer<Utf8> client, int ok, Pointer<Utf8> errmsgPtr, Pointer<Utf8> responsePtr) {
      if (responsePtr != nullptr) {
        String response = responsePtr.cast<Utf8>().toDartString();
        print('on play INFO response ${response}');
        if (response != "null") {
          Map<String, dynamic> jso = jsonDecode(response);
          if (jso['id'] != null) {
            updateListenTrack(OmusicTrack(jso['id'], jso['title'], jso['artist'], jso['album'], jso['length'], jso['pos']));
            turnOnPlaying();
          }
        }
        //callback.close()
      }
    }
    late final NativeCallable<NativePlayInfoCallback> callback = NativeCallable<NativePlayInfoCallback>.listener(onResponse);
    libmoc.mnetPlayInfo(deviceID, callback.nativeFunction);
  }
}

class OmusicTrack {
  OmusicTrack(this.id, this.title, this.artist, this.album, this.length, this.pos);

  late String id;
  late String title;
  late String cover;
  late String artist;
  late String album;
  late int length;
  late int pos;
}